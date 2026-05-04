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
    hate = 0,
    requires_target = false,
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
        return ([[Years of loneliness have taught you that there is safety in being alone. None
        can touch you in the safety of isolation, and you begin to grow more resilient the further you are
        from others. At full power, your Recluse status gives you %d%% all damage resist, %d health regeneration,
        and %d%% movement speed. You project a %d radius around you; enemies with the radius decay these bonuses,
        growing stronger the closer they are, potentially hindering you instead.]]):tformat(
                all_damage_resist,
                life_regen,
                movement_speed,
                radius
        )
    end,
    action = function(self, t)
        return {
            all_resist = self:addTemporaryValue("resists", {all=t.getAllResist(self, t)}),
            health_regen = self:addTemporaryValue("life_regen", t.getLifeRegen(self, t)),
            movement_speed = self:addTemporaryValue("move", t.getMovementSpeed(self, t))
        }
    end,
    callbackOnActBase = function(self, t)
        game.log("Callback for Recluse")
        local p = self:isTalentActive(t.id)
        game.log(p)
    end
})