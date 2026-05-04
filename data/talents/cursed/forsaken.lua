newTalentType({
	allow_random = true,
	type = "cursed/isolation",
	generic = false,
	name = _t("isolation", "talent type"),
	description = _t("They will feel your loneliness."),
})

newTalentType({
	allow_random = true,
	type = "cursed/recluse",
	generic = true,
	name = _t("recluse", "talent type"),
	description = _t("I exist in complete seclusion."),
})

forsaken_wil_req1 = {
	stat = {
		wil = function(level)
			return 12 + (level - 1) * 2
		end,
	},
	level = function(level)
		return 0 + (level - 1)
	end,
}

forsaken_wil_req2 = {
	stat = {
		wil = function(level)
			return 20 + (level - 1) * 2
		end,
	},
	level = function(level)
		return 4 + (level - 1)
	end,
}

forsaken_wil_req3 = {
	stat = {
		wil = function(level)
			return 28 + (level - 1) * 2
		end,
	},
	level = function(level)
		return 8 + (level - 1)
	end,
}

forsaken_wil_req4 = {
	stat = {
		wil = function(level)
			return 36 + (level - 1) * 2
		end,
	},
	level = function(level)
		return 12 + (level - 1)
	end,
}

load("/data-forsaken/talents/cursed/isolation.lua")
load("/data-forsaken/talents/cursed/recluse.lua")