
"""
    Copyright (C) 2024 Kevin Tyrrell

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

from __future__ import annotations
from enum import Enum
from dataclasses import dataclass
from typing import Optional


_reverse_expac: dict[str, ExpacType] = {}
_reverse_prof: dict[int, ProfType] = {}


def _setup_class(cls):  # Hook into class initialization
    if hasattr(cls, "setup"):
        cls.setup()
    return cls


@dataclass(frozen=True)
class ExpacData:
    name: str
    id: str
    version: int

    

    def __str__(self) -> str:
        return self.name


@_setup_class
class ExpacType(Enum):
    WORLD_OF_WARCRAFT = ExpacData("World of Warcraft", "WOW", 1)
    SEASON_OF_DISCOVERY = ExpacData("Season of Discovery", "SOD", 1)
    BURNING_CRUSADE = ExpacData("The Burning Crusade", "TBC", 2)
    WRATH_OF_LICH_KING = ExpacData("Wrath of the Lich King", "WOLTK", 3)
    CATACLYSM = ExpacData("Cataclysm", "CATA", 4)
    MISTS_OF_PANDARIA = ExpacData("Mists of Pandaria", "MOP", 5)
    WARLORDS_OF_DRAENOR = ExpacData("Warlords of Draenor", "WOD", 6)
    LEGION = ExpacData("Legion", "LEGION", 7)
    BATTLE_FOR_AZEROTH = ExpacData("Battle for Azeroth", "BFA", 8)
    SHADOWLANDS = ExpacData("Shadowlands", "SL", 9)
    DRAGONFLIGHT = ExpacData("Dragonflight", "DF", 10)
    WAR_WITHIN = ExpacData("The War Within", "TWW", 11)
    MIDNIGHT = ExpacData("Midnight", "MIDNIGHT", 12)
    LAST_TITAN = ExpacData("The Last Titan", "TLT", 13)

    @classmethod
    def setup(cls):
        for member in cls.__members__.values():
            _reverse_expac[member.value] = member

    @classmethod
    def by_id(cls, value: str) -> Optional[ExpacType]:
        return _reverse_expac.get(value, None)


# Double up in order to match the expansions structure
professions = [(x, x) for x in ["Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering", "First Aid",
                                "Inscription", "Jewelcrafting", "Leatherworking", "Mining", "Tailoring"]]


@dataclass(frozen=True)
class ProfData:
    name: str
    id: int

    def __str__(self) -> str:
        return self.name


@_setup_class
class ProfType(Enum):
    GOBLIN = ProfData("Goblin", 20222)
    GNOMISH = ProfData("Gnomish", 20219)




    @classmethod
    def setup(cls):
        for member in cls.__members__.values():
            _reverse_prof[member.value] = member

    @classmethod
    def by_id(cls, value: int) -> Optional[ProfData]:
        return _reverse_prof.get(value, None)
