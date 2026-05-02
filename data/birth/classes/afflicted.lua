newBirthDescriptor({
	type = "subclass",
	name = "Forsaken",
	desc = {
		"In the dark recesses of the world live the Forsaken; former warriors and mercenaries",
		"left behind by their companies, abandoned either through cowardice or betrayal.",
		"Abandoned by their former friends, they have been driven mad by torture endured at",
		"the hands of dark forces, years of isolation, and resentment towards the world",
		"that abandoned them. They no longer fight the bitterness of abandonment, and",
		"instead desire to create a world that is truly empty.",
		"The Forsaken cloak themselves in the power of their isolation, shielding them",
		"from harm through the sheer denial of force. They seek to isolate their foes,",
		"instilling the same hopelessness and loneliness they will never escape.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +1 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +4 Willpower, +4 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	power_source = { psionic = true, technique = true },
	stats = { str = 1, wil = 4, cun = 4 },
	talents_types = {
		["cursed/gloom"] = { true, 0.1 },
		["cursed/cursed-form"] = { true, 0.3 },
		["cursed/isolation"] = { true, 0.3 },
		["technique/combat-training"] = { true, 0.1 },
	},
	talents = {
		[ActorTalents.T_UNNATURAL_BODY] = 1,
		[ActorTalents.T_GLOOM] = 1,
		[ActorTalents.T_ISOLATE] = 1,
		[ActorTalents.T_SECLUSION] = 5,
		[ActorTalents.T_FORCED_APATHY] = 1,
		[ActorTalents.T_GROWING_APATHY] = 1,
	},
	copy = {
		max_life = 110,
		resolvers.auto_equip_filters({
			MAINHAND = { type = "weapon", subtype = "mindstar" },
			OFFHAND = { type = "weapon", subtype = "mindstar" },
		}),
		resolvers.equipbirth({
			id = true,
			{ type = "weapon", subtype = "mindstar", name = "mossy mindstar", autoreq = true, ego_chance = -1000 },
			{ type = "weapon", subtype = "mindstar", name = "mossy mindstar", autoreq = true, ego_chance = -1000 },
			{ type = "armor", subtype = "cloth", name = "linen robe", autoreq = true, ego_chance = -1000 },
		}),
	},
	copy_add = {},
})

getBirthDescriptor("class", "Afflicted").descriptor_choices.subclass["Forsaken"] = "allow"
