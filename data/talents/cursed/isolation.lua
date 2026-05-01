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
	critSusceptibility = function(self, t)
		return self:combatScale(self:getTalentLevel(t) + self:combatMindpower(), 2, 2, 10, 10, 0.4, 0, 0)
	end,
	damage = function(self, t)
		return self:combatTalentIntervalDamage(t, "wil", 0.25, 0.8, 0.4) * getHateMultiplier(self, 0.5, 1, false, hate)
	end,
	info = function(self, t)
		local duration = t.duration(self, t)
		local saveReduction = t.duration(self, t)
		local movementSpeedReduction = t.duration(self, t)
		local critSusceptibility = t.critSusceptibility(self, t)
		local damage = t.damage(self, t)
		return ([[Remove the effects of Isolation, instead making them Apathetic to their condition 
    for %d turns. Apathy reduces their mental save even further (%d), reduces movement speed by %d and makes them %d 
    more susceptible to critical attacks. The sudden emotional change of state is painful for the recipient, causing %d 
    damage on gain.]]):tformat(duration, saveReduction, movementSpeedReduction, critSusceptibility, damage)
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

		target:removeEffect(target.EFF_ISOLATED)
		target:setEffect(target.EFF_FORCED_APATHY, t.duration(self, t), { src = self })
		return true
	end,
})
