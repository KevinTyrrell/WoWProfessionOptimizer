
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
from dataclasses import dataclass

from reverse_enum import *


@dataclass(frozen=True)
class ExpansionData:
    name: str
    id: str
    version: int

    def __str__(self) -> str:
        return self.name


class ExpansionType(ReverseEnum):
    WORLD_OF_WARCRAFT = ExpansionData("World of Warcraft", "WOW", 1)
    SEASON_OF_DISCOVERY = ExpansionData("Season of Discovery", "SOD", 1)
    BURNING_CRUSADE = ExpansionData("The Burning Crusade", "TBC", 2)
    WRATH_OF_LICH_KING = ExpansionData("Wrath of the Lich King", "WOLTK", 3)
    CATACLYSM = ExpansionData("Cataclysm", "CATA", 4)
    MISTS_OF_PANDARIA = ExpansionData("Mists of Pandaria", "MOP", 5)
    WARLORDS_OF_DRAENOR = ExpansionData("Warlords of Draenor", "WOD", 6)
    LEGION = ExpansionData("Legion", "LEGION", 7)
    BATTLE_FOR_AZEROTH = ExpansionData("Battle for Azeroth", "BFA", 8)
    SHADOWLANDS = ExpansionData("Shadowlands", "SL", 9)
    DRAGONFLIGHT = ExpansionData("Dragonflight", "DF", 10)
    WAR_WITHIN = ExpansionData("The War Within", "TWW", 11)
    MIDNIGHT = ExpansionData("Midnight", "MIDNIGHT", 12)
    LAST_TITAN = ExpansionData("The Last Titan", "TLT", 13)

    @staticmethod
    def _reverse_key(value: ExpansionData) -> str:
        return value.id


@dataclass(frozen=True)
class ProfessionData:
    name: str
    since: ExpansionType = ExpansionType.WORLD_OF_WARCRAFT

    def __str__(self) -> str:
        return self.name


class ProfessionType(ReverseEnum):
    ALCHEMY = ProfessionData("Alchemy")
    BLACKSMITHING = ProfessionData("Blacksmithing")
    COOKING = ProfessionData("Cooking")
    ENCHANTING = ProfessionData("Enchanting")
    ENGINEERING = ProfessionData("Engineering")
    FIRST_AID = ProfessionData("First-Aid")
    INSCRIPTION = ProfessionData("Inscription", ExpansionType.WRATH_OF_LICH_KING)
    JEWELCRAFTING = ProfessionData("Jewelcrafting", ExpansionType.BURNING_CRUSADE)
    LEATHERWORKING = ProfessionData("Leatherworking")
    MINING = ProfessionData("Mining")
    TAILORING = ProfessionData("Tailoring")

    @staticmethod
    def _reverse_key(value: ProfessionData) -> str:
        return value.name


@dataclass(frozen=True)
class SpecializationData:
    name: str
    id: int

    def __str__(self) -> str:
        return self.name


class SpecializationType(ReverseEnum):
    GOBLIN = SpecializationData("Goblin", 20222)
    GNOMISH = SpecializationData("Gnomish", 20219)
    # Mooncloth Tailor
    # Spellfire Tailor
    # Shadoweave Tailor
    # Armorsmith
    # Weaponsmith
    # Swordsmith
    # Axesmith
    # Hammersmith
    # Tribal Leatherworking
    # Dragonscale Leatherworking
    # Elemental Leatherworking

    @staticmethod
    def _reverse_key(value: SpecializationData) -> int:
        return value.id
    def __str__(self) -> str:
        return self.name


@dataclass(frozen=True)
class SourceData:
    name: str
    id: int
    major: bool = True  # Source is relevant / irrelevant

    def __str__(self) -> str:
        return self.name


class SourceType(Enum):
    """
    Method in which a recipe can be learned/obtained.

    Some recipe sources are redundant or unrealistic (e.g. fishing/pickpocketing).
    """
    CRAFT = SourceData("Craft", 1)  # Not verified, found by induction
    DROP = SourceData("Drop", 2)
    PVP = SourceData("PvP", 3, False)  # Not verified, found by induction
    QUEST = SourceData("Quest", 4)
    VENDOR = SourceData("Vendor", 5)
    TRAINER = SourceData("Trainer", 6)
    STARTER = SourceData("Starter", 7, False)  # Not verified, found by induction
    FISHING = SourceData("Fishing", 16, False)
    PICKPOCKET = SourceData("Pickpocket", 21, False)

    @staticmethod
    def _reverse_key(value: SourceData) -> int:
        return value.id
