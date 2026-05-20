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
	name = "Bitter Blades",
	short_name = "BITTER_BLADES",
	type = { "cursed/bitter-memories", 1 },
	require = forsaken_wil_req1,
	points = 5,
	cooldown = 4,
	hate = 10,
	range = 0,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 25, 125)
	end,
	radius = function(self, t)
		return math.min(2, math.floor(self:combatTalentScale(t, 2, 4)))
	end,
	tactical = { ATTACKAREA = { MIND = 2 } },
	requires_target = true,
	direct_hit = true,
	target = function(self, t)
		return {
			type = "cone",
			range = self:getTalentRange(t),
			radius = self:getTalentRadius(t),
			selffire = false,
			talent = t,
		}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then
			return nil
		end
		self:project(tg, x, y, DamageType.MIND, self:mindCrit(t.getDamage(self, t)))
		return true
	end,
	info = function(self, t)
		return ([[Shattering an old memory, you shoot out cutting mental shards in a frontal cone of radius %d. These shards lacerate the target's mind on contact, inflicting %d mind damage.]]):tformat(
			t.radius(self, t),
			t.getDamage(self, t)
		)
	end,
})
