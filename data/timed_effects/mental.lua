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
			game.log(
				"%s does know Seclusion, at level %d",
				eff.src:getName(),
				eff.src:getTalentLevel(eff.src.T_SECLUSION)
			)
		end
		DamageType:get(DamageType.MIND).projector(eff.src, self.x, self.y, DamageType.MIND, eff)
		self:addTemporaryValue("combat_mentalresist", -eff.saveRed)
		game.log("%s continues to feel the loneliness of isolation!", self:getName())
	end,
	activate = function(self, eff) end,
})
