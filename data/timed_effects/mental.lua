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
			local t_growing_apathy = eff.src:getTalentFromId(eff.src.T_GROWING_APATHY)
			local apathy_radius = eff.src:getTalentRadius(t_growing_apathy)
			local spread_chance = t_growing_apathy.spreadChance(eff.src, t_growing_apathy)
			local mind_speed = t_growing_apathy.mentalSpeed(eff.src, t_growing_apathy)
			local mindpower = t_growing_apathy.mindpower(eff.src, t_growing_apathy)

			self:project(
				{ type = "ball", range = 0, friendlyfire = true, radius = apathy_radius },
				self.x,
				self.y,
				function(px, py)
					local target = game.level.map(px, py, Map.ACTOR)
					if not target then
						return
					end
					if
						target
						and target ~= self
						and target.faction == self.faction
						and not target:hasEffect(target.EFF_FORCED_APATHY)
						and rng.percent(spread_chance)
					then
						local t_forced_apathy = eff.src:getTalentFromId(eff.src.T_FORCED_APATHY)
						local duration = t_forced_apathy.duration(eff.src, t_forced_apathy)
						local damage = eff.src:mindCrit(t_forced_apathy.damage(self, t))
						local saveReduction = t_forced_apathy.saveReduction(self, t)
						local movementSpeedReduction = t_forced_apathy.movementSpeedReduction(self, t)

						target:removeEffect(target.EFF_ISOLATED)
						target:setEffect(target.EFF_FORCED_APATHY, duration, {
							src = eff.src,
							duration = 5,
							saveReduction = saveReduction,
							movementSpeedReduction = movementSpeedReduction,
						})

						eff.src:setEffect(target.EFF_BITTER, duration, {
							mentalSpeed = mind_speed,
							mindpower = mindpower
						})

						DamageType:get(DamageType.MIND).projector(target, px, py, DamageType.MIND, damage)
						game.level.map:particleEmitter(
							target.x,
							target.y,
							1,
							"reproach",
							{ dx = self.x - target.x, dy = self.y - target.y }
						)
						game.log("%s becomes apathetic due to proximity to %s", target.name, self.name)
						game:playSoundNear(self, "talents/fire")
					end
				end
			)
		end
	end,
})

newEffect({
	name = "BITTER",
	image = "talents/flame.png",
	desc = _t("Bitter"),
	long_desc = function(self, eff)
		return _t(
			"The target has become empowered by their bitterness, increasing their mental speed by %d%% and mindpower by %d"
		):tformat(eff.mentalSpeed, eff.mindpower)
	end,
	type = "mental",
	subtype = {},
	status = "beneficial",
	cancel_on_level_change = true,
	parameters = {},
	on_gain = function(self, err)
		return _t("#Target# is being fueled by their bitterness."), _t("+Bitter")
	end,
	on_lose = function(self, err)
		return _t("#Target# has forgotten their bitterness...for now."), _t("-Bitter")
	end,
	activate = function(self, eff)
		self:addTemporaryValue("combat_mindspeed", eff.mentalSpeed)
		self:addTemporaryValue("combat_mindpower", eff.mindpower)
	end
})