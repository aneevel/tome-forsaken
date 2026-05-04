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
        return {
            all_resist = self:addTemporaryValue("resists", {all=t.getAllResist(self, t)}),
            life_regen = self:addTemporaryValue("life_regen", t.getLifeRegen(self, t)),
            movement_speed = self:addTemporaryValue("movement_speed", t.getMovementSpeed(self, t)),
            scalar = 1
        }
    end,
    deactivate = function(self, t, p)
        if p.all_resist then self:removeTemporaryValue("resists", p.all_resist) end
        if p.life_regen then self:removeTemporaryValue("life_regen", p.life_regen) end
        if p.movement_speed then self:removeTemporaryValue("movement_speed", p.movement_speed) end

        self:removeEffect(self.EFF_RECLUSE_SOLITUDE)
        return {}
    end,
    callbackOnActBase = function(self, t)
        game.log("Callback for Recluse")

        -- remove old values before anything else
        local p = self:isTalentActive(t.id)
        if p.all_resist then self:removeTemporaryValue("resists", p.all_resist) end
        if p.life_regen then self:removeTemporaryValue("life_regen", p.life_regen) end
        if p.movement_speed then self:removeTemporaryValue("movement_speed", p.movement_speed) end

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

        -- get effect for visual display
        self:setEffect(self.EFF_RECLUSE_SOLITUDE, 1, { power = power })
    end
})