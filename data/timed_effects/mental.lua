local Map = require("engine.Map")

newEffect({
	name = "ISOLATED",
	image = "talents/flame.png",
	desc = _t("Isolated"),
	long_desc = function(self, eff)
		return _t("The target is isolated, taking %d damage and reducing saves by %d every turn for %d turns."):tformat(
			eff.dam,
			eff.saveRed,
			eff.dur
		)
	end,
	type = "mental",
	subtype = {},
	status = "detrimental",
	cancel_on_level_change = true,
	parameters = { saves = 5, dam = 10, scalar = 0 },
	on_gain = function(self, err)
		return _t("#Target# has been isolated."), _t("+Isolated")
	end,
	on_lose = function(self, err)
		return _t("#Target# is no longer being isolated."), _t("-Isolated")
	end,
	on_timeout = function(self, eff)
		eff.scalar = eff.scalar + 1
		eff.dam = math.ceil(eff.dam * (eff.scalar + 0.2))
		eff.saves = math.ceil(eff.saves * (eff.scalar + 0.1))

		if eff.dam > eff.maxDam then
			eff.dam = eff.maxDam
		end
		if eff.saves > eff.maxSaveRed then
			eff.saves = eff.maxSaveRed
		end

		if eff.src:knowTalent(eff.src.T_SECLUSION) then
			local t_seclusion = eff.src:getTalentFromId(eff.src.T_SECLUSION)
			local seclusion_radius = eff.src:getTalentRadius(t_seclusion)
			local seclusion_duration = t_seclusion.duration(eff.src, t_seclusion)
			local mindpower = eff.src:combatMindpower()

			self:project(
				{ type = "ball", range = 0, friendlyfire = true, radius = seclusion_radius },
				self.x,
				self.y,
				function(px, py)
					local target = game.level.map(px, py, Map.ACTOR)
					if not target then
						return
					end
					if target and target ~= self and target.faction == self.faction then
						if target:checkHit(mindpower, target:combatMentalResist()) then
							game.log(
								"%s is forced to feel the effects of %s's Seclusion for %d turns!",
								target.name,
								self.name,
								seclusion_duration
							)
							if target:canBe("stun") then
								target:setEffect(target.EFF_STUNNED, seclusion_duration, {})
							end
						end
					end
				end
			)
		end
		DamageType:get(DamageType.MIND).projector(eff.src, self.x, self.y, DamageType.MIND, eff)
		self:addTemporaryValue("combat_mentalresist", -eff.saveRed)
		game.log("%s continues to feel the loneliness of isolation!", self:getName())
	end,
	activate = function(self, eff) end,
})

newEffect({
	name = "FORCED_APATHY",
	image = "talents/flame.png",
	desc = _t("Apathetic"),
	long_desc = function(self, eff)
		return _t(
			"The target is apathetic, reducing their will to act or resist. Their mental save is reduced by %d and movement speed by %d%%."
		):tformat(eff.saveReduction, eff.movementSpeedReduction, eff.critSusceptibility)
	end,
	type = "mental",
	subtype = {},
	status = "deterimental",
	cancel_on_level_change = true,
	parameters = {},
	on_gain = function(self, err)
		return _t("#Target# has become apathetic to the world."), _t("+Apathetic")
	end,
	on_lose = function(self, err)
		return _t("#Target has regained their connection to the world."), _t("-Apathetic")
	end,
	on_timeout = function(self, eff)
		self:addTemporaryValue("combat_mentalresist", -eff.saveReduction)
		self:addTemporaryValue("movement_speed", (1.0 - (1.0 + eff.movementSpeedReduction)))

		if eff.src:knowTalent(eff.src.T_GROWING_APATHY) then
			game.log("By the force of %s's growing apathy, the misery spreads.", self.name)
		end
	end,
})
