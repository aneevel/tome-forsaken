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

newTalent({
    name = "Recluse",
    short_name = "RECLUSE",
    mode = "sustained",
    type = { "cursed/recluse", 1 },
    points = 5,
    require = forsaken_wil_req1,
    cooldown = 0,
    no_energy = true,
    tactical = { BUFF = 5},
    radius = function(self, t)
        return math.ceil(self:combatTalentScale(t, 8, 3))
    end,
    getAllResist = function(self, t)
        return self:combatScale(self:getTalentLevel(t) * 16 + self:combatMindpower(), 2, 26, 20, 146)
    end,
    getLifeRegen = function(self, t)
        return self:combatScale(self:getTalentLevel(t) * 6.5 + self:combatMindpower(), 2, 16.5, 25, 89)
    end,
    getMovementSpeed = function(self, t)
        return self:combatScale(self:getTalentLevel(t) * 6.5 + self:combatMindpower(), 5, 16.5, 35, 89)
    end,
    info = function(self, t)
        local all_damage_resist = t.getAllResist(self, t)
        local life_regen = t.getLifeRegen(self, t)
        local movement_speed = t.getMovementSpeed(self, t)
        local radius = t.radius(self, t)
        return ([[Years of loneliness have taught you that there is safety in being alone. None can touch you in the safety of isolation, and you begin to grow more resilient the further you are from others. At full power, your Recluse status gives you %d%% all damage resist, %d health regeneration, and %d%% movement speed. You project a %d radius around you; enemies within the radius decay these bonuses, growing stronger the closer they are, potentially hindering you instead.]]):tformat(
                all_damage_resist,
                life_regen,
                movement_speed,
                radius
        )
    end,
    activate = function(self, t)
        local p = {
            all_resist = self:addTemporaryValue("resists", {all=t.getAllResist(self, t)}),
            life_regen = self:addTemporaryValue("life_regen", t.getLifeRegen(self, t)),
            movement_speed = self:addTemporaryValue("movement_speed", t.getMovementSpeed(self, t) / 100.0),
            scalar = 1
        }

        if self:knowTalent(self.T_SEQUESTERED) then
            local t_sequestered = self:getTalentFromId(self.T_SEQUESTERED)
            p.physical_saves = self:addTemporaryValue("combat_physresist", t_sequestered.getSaves(self, t_sequestered))
            p.mental_saves = self:addTemporaryValue("combat_mentalresist", t_sequestered.getSaves(self, t_sequestered))
            p.confusion_conversion = self:addTemporaryValue("confusion_immune", (t_sequestered.getMentalSaveConversion(self, t_sequestered) / 100.0) * self.combat_mentalresist / 100.0)
            p.mind_conversion = self:addTemporaryValue("resists", { [DamageType.MIND] = (t_sequestered.getMentalSaveConversion(self, t_sequestered) / 100.0) * self.combat_mentalresist / 100.0})
            p.fear_conversion = self:addTemporaryValue("fear_immune", (t_sequestered.getMentalSaveConversion(self, t_sequestered) / 100.0) * self.combat_mentalresist / 100.0)
            p.stun_conversion = self:addTemporaryValue("stun_immune", (t_sequestered.getPhysicalSaveConversion(self, t_sequestered) / 100.0) * self.combat_physresist / 100.0)
            p.disease_conversion = self:addTemporaryValue("disease_immune", (t_sequestered.getPhysicalSaveConversion(self, t_sequestered) / 100.0) * self.combat_physresist / 100.0)
            p.physical_conversion = self:addTemporaryValue("resists", { [DamageType.PHYSICAL] = (t_sequestered.getPhysicalSaveConversion(self, t_sequestered) / 100.0) * self.combat_physresist / 100.0})
        end

        if self:knowTalent(self.T_UNKNOWN_NATURE) then
            local t_unknown_nature = self:getTalentFromId(self.T_UNKNOWN_NATURE)
            p.spell_saves = self:addTemporaryValue("combat_spellresist", t_unknown_nature.getSaves(self, t_unknown_nature))
            p.arcane_conversion = self:addTemporaryValue("resists", { [DamageType.ARCANE] = (t_unknown_nature.getSpellSaveConversion(self, t_unknown_nature) / 100.0) * self.combat_spellresist / 100.0})
            p.fire_conversion = self:addTemporaryValue("resists", { [DamageType.FIRE] = (t_unknown_nature.getSpellSaveConversion(self, t_unknown_nature) / 100.0) * self.combat_spellresist / 100.0})
            p.cold_conversion = self:addTemporaryValue("resists", { [DamageType.COLD] = (t_unknown_nature.getSpellSaveConversion(self, t_unknown_nature) / 100.0) * self.combat_spellresist / 100.0})
            p.lightning_conversion = self:addTemporaryValue("resists", { [DamageType.LIGHTNING] = (t_unknown_nature.getSpellSaveConversion(self, t_unknown_nature) / 100.0) * self.combat_spellresist / 100.0})
            p.acid_conversion = self:addTemporaryValue("resists", { [DamageType.ACID] = (t_unknown_nature.getSpellSaveConversion(self, t_unknown_nature) / 100.0) * self.combat_spellresist / 100.0})
            p.blight_conversion = self:addTemporaryValue("resists", { [DamageType.BLIGHT] = (t_unknown_nature.getSpellSaveConversion(self, t_unknown_nature) / 100.0) * self.combat_spellresist / 100.0})
        end

        return p
    end,
    deactivate = function(self, t, p)
        if p.all_resist then self:removeTemporaryValue("resists", p.all_resist) end
        if p.life_regen then self:removeTemporaryValue("life_regen", p.life_regen) end
        if p.movement_speed then self:removeTemporaryValue("movement_speed", p.movement_speed) end
        if p.physical_saves then self:removeTemporaryValue("combat_physresist", p.physical_saves) end
        if p.mental_saves then self:removeTemporaryValue("combat_mentalresist", p.mental_saves) end
        if p.confusion_conversion then self:removeTemporaryValue("confusion_immune", p.confusion_conversion) end
        if p.mind_conversion then self:removeTemporaryValue("resists", p.mind_conversion) end
        if p.fear_conversion then self:removeTemporaryValue("fear_immune", p.fear_conversion) end
        if p.stun_conversion then self:removeTemporaryValue("stun_immune", p.stun_immune) end
        if p.disease_conversion then self:removeTemporaryValue("disease_immune", p.disease_conversion) end
        if p.physical_conversion then self:removeTemporaryValue("resists", p.physical_conversion) end
        if p.spell_saves then self:removeTemporaryValue("combat_spellresist", p.spell_saves) end
        if p.arcane_conversion then self:removeTemporaryValue("resists", p.arcane_conversion) end
        if p.fire_conversion then self:removeTemporaryValue("resists", p.fire_conversion) end
        if p.cold_conversion then self:removeTemporaryValue("resists", p.cold_conversion) end
        if p.lightning_conversion then self:removeTemporaryValue("resists", p.lightning_conversion) end
        if p.acid_conversion then self:removeTemporaryValue("resists", p.acid_conversion) end
        if p.blight_conversion then self:removeTemporaryValue("resists", p.blight_conversion) end

        self:removeEffect(self.EFF_RECLUSE_SOLITUDE)
        return {}
    end,
    callbackOnActBase = function(self, t)

        -- remove old values before anything else
        local p = self:isTalentActive(t.id)
        if p.all_resist then self:removeTemporaryValue("resists", p.all_resist) end
        if p.life_regen then self:removeTemporaryValue("life_regen", p.life_regen) end
        if p.movement_speed then self:removeTemporaryValue("movement_speed", p.movement_speed) end
        if p.physical_saves then self:removeTemporaryValue("combat_physresist", p.physical_saves) end
        if p.mental_saves then self:removeTemporaryValue("combat_mentalresist", p.mental_saves) end
        if p.confusion_conversion then self:removeTemporaryValue("confusion_immune", p.confusion_conversion) end
        if p.mind_conversion then self:removeTemporaryValue("resists", p.mind_conversion) end
        if p.fear_conversion then self:removeTemporaryValue("fear_immune", p.fear_conversion) end
        if p.stun_conversion then self:removeTemporaryValue("stun_immune", p.stun_conversion) end
        if p.disease_conversion then self:removeTemporaryValue("disease_immune", p.disease_conversion) end
        if p.physical_conversion then self:removeTemporaryValue("resists", p.physical_conversion) end
        if p.spell_saves then self:removeTemporaryValue("combat_spellresist", p.spell_saves) end
        if p.arcane_conversion then self:removeTemporaryValue("resists", p.arcane_conversion) end
        if p.fire_conversion then self:removeTemporaryValue("resists", p.fire_conversion) end
        if p.cold_conversion then self:removeTemporaryValue("resists", p.cold_conversion) end
        if p.lightning_conversion then self:removeTemporaryValue("resists", p.lightning_conversion) end
        if p.acid_conversion then self:removeTemporaryValue("resists", p.acid_conversion) end
        if p.blight_conversion then self:removeTemporaryValue("resists", p.blight_conversion) end

        -- set radius and weight from talent level
        local radius = t.radius(self, t)
        local weight = 80 / self:getTalentLevel(t)

        -- initialize score
        local power = 100

        for i, a in ipairs(self.fov.actors_dist) do
            if a == self then goto continue end
            local distance = core.fov.distance(self.x, self.y, a.x, a.y)
            if distance > radius then goto continue end

            power = power - (weight / distance)
            ::continue::
        end

        -- provide scalar based off power
        local scalar = power / 100

        -- actually set the effects here
        p.all_resist = self:addTemporaryValue("resists", {all=t.getAllResist(self, t) * scalar})
        p.life_regen = self:addTemporaryValue("life_regen", t.getLifeRegen(self, t) * scalar)
        p.movement_speed = self:addTemporaryValue("movement_speed", t.getMovementSpeed(self, t) * scalar / 100)
        p.scalar = scalar

        if (self:knowTalent(self.T_SEQUESTERED)) then
           local t_sequestered = self:getTalentFromId(self.T_SEQUESTERED)
            p.physical_saves = self:addTemporaryValue("combat_physresist", t_sequestered.getSaves(self, t_sequestered) * scalar)
            p.mental_saves = self:addTemporaryValue("combat_mentalresist", t_sequestered.getSaves(self, t_sequestered) * scalar)
            p.confusion_conversion = self:addTemporaryValue("confusion_immune", (t_sequestered.getMentalSaveConversion(self, t_sequestered) / 100.0) * self.combat_mentalresist / 100.0 * scalar)
            p.mind_conversion = self:addTemporaryValue("resists", { [DamageType.MIND] = (t_sequestered.getMentalSaveConversion(self, t_sequestered) / 100.0) * self.combat_mentalresist / 100.0 * scalar})
            p.fear_conversion = self:addTemporaryValue("fear_immune", (t_sequestered.getMentalSaveConversion(self, t_sequestered) / 100.0) * self.combat_mentalresist / 100.0 * scalar)
            p.stun_conversion = self:addTemporaryValue("stun_immune", (t_sequestered.getPhysicalSaveConversion(self, t_sequestered) / 100.0) * self.combat_physresist / 100.0 * scalar)
            p.disease_conversion = self:addTemporaryValue("disease_immune", (t_sequestered.getPhysicalSaveConversion(self, t_sequestered) / 100.0) * self.combat_physresist / 100.0 * scalar)
            p.physical_conversion = self:addTemporaryValue("resists", { [DamageType.PHYSICAL] = (t_sequestered.getPhysicalSaveConversion(self, t_sequestered) / 100.0) * self.combat_physresist / 100.0 * scalar})
        end

        if self:knowTalent(self.T_UNKNOWN_NATURE) then
            local t_unknown_nature = self:getTalentFromId(self.T_UNKNOWN_NATURE)
            p.spell_saves = self:addTemporaryValue("combat_spellresist", t_unknown_nature.getSaves(self, t_unknown_nature) * scalar)
            p.arcane_conversion = self:addTemporaryValue("resists", { [DamageType.ARCANE] = (t_unknown_nature.getSpellSaveConversion(self, t_unknown_nature) / 100.0) * self.combat_spellresist / 100.0 * scalar})
            p.fire_conversion = self:addTemporaryValue("resists", { [DamageType.FIRE] = (t_unknown_nature.getSpellSaveConversion(self, t_unknown_nature) / 100.0) * self.combat_spellresist / 100.0 * scalar})
            p.cold_conversion = self:addTemporaryValue("resists", { [DamageType.COLD] = (t_unknown_nature.getSpellSaveConversion(self, t_unknown_nature) / 100.0) * self.combat_spellresist / 100.0 * scalar})
            p.lightning_conversion = self:addTemporaryValue("resists", { [DamageType.LIGHTNING] = (t_unknown_nature.getSpellSaveConversion(self, t_unknown_nature) / 100.0) * self.combat_spellresist / 100.0 * scalar})
            p.acid_conversion = self:addTemporaryValue("resists", { [DamageType.ACID] = (t_unknown_nature.getSpellSaveConversion(self, t_unknown_nature) / 100.0) * self.combat_spellresist / 100.0 * scalar})
            p.blight_conversion = self:addTemporaryValue("resists", { [DamageType.BLIGHT] = (t_unknown_nature.getSpellSaveConversion(self, t_unknown_nature) / 100.0) * self.combat_spellresist / 100.0 * scalar})
        end

        if self:knowTalent(self.T_FORGET) then
            local t_forget = self:getTalentFromId(self.T_FORGET)

            -- check if we hit threshold
            local threshold = t_forget.getThreshold(self, t_forget)
            if power >= threshold then
                local chance = t_forget.getChance(self, t_forget)
                if rng.percent(chance) then

                    -- get random effect
                    local effects = t_forget.getEffects(self, t_forget)
                    for i = 1, effects do
                       self:removeEffectsFilter(self, {status="detrimental"})
                    end

                    game.log("%s has forgotten one of their ailments!", self:getName():capitalize())
                end
            end
        end

        -- get effect for visual display
        self:setEffect(self.EFF_RECLUSE_SOLITUDE, 1, { power = power })
    end
})

newTalent({
    name = "Sequestered",
    short_name = "SEQUESTERED",
    mode = "passive",
    type = { "cursed/recluse", 2},
    points = 5,
    require = forsaken_wil_req2,
    cooldown = 0,
    no_energy = true,
    tactical = { BUFF = 5},
    getSaves = function(self, t)
        return self:combatScale(self:getTalentLevel(t) * 8 + self:combatMindpower(), 4, 30, 25, 150)
    end,
    getMentalSaveConversion = function(self, t)
        return self:combatScale(self:getTalentLevel(t) * 5 + self:combatMindpower(), 40, 15, 55, 120)
    end,
    getPhysicalSaveConversion = function(self, t)
        return self:combatScale(self:getTalentLevel(t) * 3 + self:combatMindpower(), 35, 12, 40, 100)
    end,
    info = function(self, t)
        local saves = t.getSaves(self, t)
        local mental_save_conversion = t.getMentalSaveConversion(self, t)
        local physical_save_conversion = t.getPhysicalSaveConversion(self, t)
        return([[Hidden away from the world, you forget the pains and troubles of others. As the world forgot you, you forgot the world, reducing the impact natural forces of the world have on you. Your Recluse status now grants you %d mental and physical saves, %d%% of your mental saves as Mind, Confusion, and Fear resistance, and %d%% of your physical saves as Physical, Stun, and Disease Resistance.]]):tformat(
                saves,
                mental_save_conversion,
                physical_save_conversion
        )
    end,
})

newTalent({
    name = "Unknown Nature",
    short_name = "UNKNOWN_NATURE",
    mode = "passive",
    type = { "cursed/recluse", 3},
    points = 5,
    require = forsaken_wil_req3,
    cooldown = 0,
    no_energy = true,
    tactical = { BUFF = 5},
    getSaves = function(self, t)
        return self:combatScale(self:getTalentLevel(t) * 8 + self:combatMindpower(), 6, 35, 30, 175)
    end,
    getSpellSaveConversion = function(self, t)
        return self:combatScale(self:getTalentLevel(t) * 4 + self:combatMindpower(), 45, 16, 70, 125)
    end,
    info = function(self, t)
        local saves = t.getSaves(self, t)
        local spell_save_conversion = t.getSpellSaveConversion(self, t)
        return([[Your existence is barely acknowledged within the world, let alone studied in the works of scholars and mages. Arcane forces cannot comprehend your nature, and thus have difficulty affecting you. Your Recluse gains the ability to protect you from magical powers, granting you %d spell save, as well as %d%% of your spell save as Arcane, Fire, Cold, Lightning, Acid, and Blight resistance.]]):tformat(
                saves,
                spell_save_conversion
        )
    end,
})

newTalent({
    name = "Forget",
    short_name = "FORGET",
    mode = "passive",
    type = { "cursed/recluse", 4},
    points = 5,
    require = forsaken_wil_req4,
    cooldown = 0,
    no_energy = true,
    tactical = { BUFF = 5},
    getChance = function(self, t)
        return self:combatScale(self:getTalentLevel(t) * 3 + self:combatMindpower(), 5, 20, 20, 75)
    end,
    getEffects = function(self, t)
        return math.floor(self:combatTalentScale(self:getTalentLevel(t), 1, 3, 1))
    end,
    getThreshold = function(self, t)
        return math.floor(self:combatTalentScale(self:getTalentLevel(t), 90, 50))
    end,
    info = function(self, t)
        local threshold = t.getThreshold(self, t)
        local chance = t.getChance(self, t)
        local effects = t.getEffects(self, t)
        return([[It is easy for you to forget, as the world forgot you. Your powers warp reality, allowing you to exist in a realm where elements of your form come and go as you choose. Each turn, if your Recluse power is over %d, there is a %d%% chance you will completely forget %d negative status effects on you.]]):tformat(
                threshold,
                chance,
                effects
        )
    end
})
