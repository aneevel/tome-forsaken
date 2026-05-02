-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org
--
local DamageType = require("engine.DamageType")
local Actor = require("engine.Actor")

function getHateMultiplier(self, min, max, cursedWeaponBonus, hate)
	local fraction = (hate or self.hate) / 100
	if cursedWeaponBonus then
		if self:hasDualWeapon() then
			if self:hasCursedWeapon() then
				fraction = fraction + 0.13
			end
			if self:hasCursedOffhandWeapon() then
				fraction = fraction + 0.07
			end
		else
			if self:hasCursedWeapon() then
				fraction = fraction + 0.2
			end
		end
	end
	fraction = math.min(fraction, 1)
	return (min + ((max - min) * fraction))
end

newTalent({
	name = "Isolate",
	short_name = "ISOLATE",
	mode = "activated",
	type = { "cursed/isolation", 1 },
	points = 5,
	require = forsaken_wil_req1,
	cooldown = 6,
	hate = 5,
	requires_target = true,
	range = 5,
	target = function(self, t)
		return { type = "hit", range = self:getTalentRange(t), talent = t }
	end,
	getDuration = function(self, t)
		return math.floor(self:combatTalentScale(t, 3, 10))
	end,
	getDamagePower = function(self, t)
		return self:combatTalentMindDamage(t, 5, 50)
	end,
	getSaveReductionPower = function(self, t)
		return math.ceil(self:combatTalentMindDamage(t, 1, 12))
	end,
	getDamageMax = function(self, t)
		return self:combatTalentMindDamage(t, 7, 100)
	end,
	getSaveReductionMax = function(self, t)
		return math.ceil(self:combatTalentMindDamage(t, 2, 25))
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damagePower = t.getDamagePower(self, t)
		local saveReduction = t.getSaveReductionPower(self, t)
		local damageMax = t.getDamageMax(self, t)
		local saveReductionMax = t.getSaveReductionMax(self, t)
		return ([[Mark an enemy to isolate from their comrades. For %d turns, that enemy
  is isolated, taking %d mental damage and reducing their saves by %d. Each turn they
  are isolated, the damage and save reduction increases, to a max of %d and %d]]):tformat(
			duration,
			damagePower,
			saveReduction,
			damageMax,
			saveReductionMax
		)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)

		if not x or not y then
			return nil
		end

		local _
		_, x, y = self:canProject(tg, x, y)
		if not x or not y then
			return nil
		end

		local target = game.level.map(x, y, Map.ACTOR)
		if not target then
			return nil
		end

		-- Get power, which can crit based off mind
		local damagePower = self:mindCrit(t.getDamagePower(self, t))
		local duration = t.getDuration(self, t)
		local saveReduction = t.getSaveReductionPower(self, t)
		local damageMax = t.getDamageMax(self, t)
		local saveReductionMax = t.getSaveReductionMax(self, t)
		target:setEffect(target.EFF_ISOLATED, t.getDuration(self, t), {
			src = self,
			dam = damagePower,
			saveRed = saveReduction,
			dur = duration,
			maxDam = damageMax,
			maxSaveRed = saveReductionMax,
		})
		return true
	end,
})

newTalent({
	name = "Seclusion",
	short_name = "SECLUSION",
	mode = "passive",
	type = { "cursed/isolation", 2 },
	points = 5,
	require = forsaken_wil_req2,
	requires_target = false,
	radius = function(self, t)
		return math.ceil(self:combatTalentScale(t, 1, 6, 0.75))
	end,
	-- probably rethink this
	duration = function(self, t)
		return math.floor(self:combatTalentScale(t, 1, 4))
	end,
	info = function(self, t)
		local radius = t.radius(self, t)
		local duration = t.duration(self, t)
		return ([[Allies of isolated enemies are kept at bay by your mental powers. In a radius of %d 
    around any isolated or apathetic foe, enemies must make a mental save each turn or become Stunned for %d turns.]]):tformat(
			radius,
			duration
		)
	end,
})

newTalent({
	name = "Forced Apathy",
	short_name = "FORCED_APATHY",
	mode = "activated",
	type = { "cursed/isolation", 3 },
	points = 5,
	require = forsaken_wil_req3,
	range = 5,
	requires_target = true,
	cooldown = 6,
	hate = 10,
	target = function(self, t)
		return { type = "hit", range = self:getTalentRange(t), talent = t }
	end,
	duration = function(self, t)
		return math.floor(self:combatTalentScale(t, 1, 5)) + self:combatMindpower()
	end,
	saveReduction = function(self, t)
		return self:combatScale(self:getTalentLevel(t) + self:combatMindpower(), 8, 5, 30, 30, 0.8, 0, 0)
	end,
	movementSpeedReduction = function(self, t)
		return self:combatScale(self:getTalentLevel(t) + self:combatMindpower(), 3, 3, 22, 22, 0.6, 0, 0)
	end,
	damage = function(self, t)
		return self:combatTalentMindDamage(t, 35, 250) * getHateMultiplier(self, 0.5, 1, false, hate)
	end,
	info = function(self, t)
		local duration = t.duration(self, t)
		local saveReduction = t.saveReduction(self, t)
		local movementSpeedReduction = t.movementSpeedReduction(self, t)
		local damage = t.damage(self, t)
		return ([[Remove the effects of Isolation, instead making them Apathetic to their condition 
    for %d turns. Apathy reduces their mental save even further (%d) and reduces movement speed by %d%%.
    The sudden emotional change of state is painful for the recipient, causing %d 
    damage on gain.]]):tformat(duration, saveReduction, movementSpeedReduction, damage)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)

		if not x or not y then
			return nil
		end

		local target = game.level.map(x, y, Map.ACTOR)
		if not target then
			return nil
		end

		if not target:hasEffect(target.EFF_ISOLATED) then
			game.logPlayer(self, "You must target an isolated target to use this talent.")
			return nil
		end

		local damage = self:mindCrit(t.damage(self, t))
		local duration = t.duration(self, t)
		local saveReduction = t.saveReduction(self, t)
		local movementSpeedReduction = t.movementSpeedReduction(self, t)

		target:removeEffect(target.EFF_ISOLATED)
		target:setEffect(target.EFF_FORCED_APATHY, duration, {
			src = self,
			duration = duration,
			saveReduction = saveReduction,
			movementSpeedReduction = movementSpeedReduction,
		})

		DamageType:get(DamageType.MIND).projector(target, x, y, DamageType.MIND, damage)
		return true
	end,
})

newTalent({
	name = "Growing Apathy",
	short_name = "GROWING_APATHY",
	mode = "passive",
	type = { "cursed/isolation", 1 },
	points = 5,
	require = forsaken_wil_req4,
	requires_target = false,
	spreadChance = function(self, t)
		return math.ceil(self:combatTalentScale(t, 15, 50))
	end,
	radius = function(self, t)
		return math.ceil(self:combatTalentScale(t, 1, 6, 0.75))
	end,
	duration = function(self, t)
		return math.floor(self:combatTalentScale(t, 3, 7))
	end,
	enemies = function(self, t)
		return math.ceil(self:combatTalentScale(t, 5, 2))
	end,
	mentalSpeed = function(self, t)
		return math.floor(self:combatTalentScale(t, 15, 35))
	end,
	mindpower = function(self, t)
		return math.floor(self:combatTalentScale(t, 5, 20))
	end,
	info = function(self, t)
		local radius = t.radius(self, t)
		local duration = t.duration(self, t)
		local spreadChance = t.spreadChance(self, t)
		local enemies = t.enemies(self, t)
		local mentalSpeed = t.mentalSpeed(self, t)
		local mindpower = t.mindpower(self, t)
		return ([[Each turn an enemy is afflicted with Apathy, there is a %d%% chance they spread their apathy 
    to all enemies within a %d radius. If %d enemies are affected by Apathy in one turn, you will receive the
    "Bitter" effect for %d turns, increasing your mental speed by %d%% and mindpower by %d.]]):tformat(
			spreadChance,
			radius,
			enemies,
			duration,
			mentalSpeed,
			mindpower
		)
	end,
})
