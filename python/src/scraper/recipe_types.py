
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


_reverse_source: dict[int, SourceData] = {}
_reverse_spec: dict[int, SpecData] = {}


def _setup_class(cls):  # Hook into class initialization
    if hasattr(cls, "setup"):
        cls.setup()
    return cls


@dataclass(frozen=True)
class SourceData:
    name: str
    id: int
    major: bool = True  # Source is relevant / irrelevant

    def __str__(self) -> str:
        return self.name


@_setup_class
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

    @classmethod
    def setup(cls):
        for member in cls.__members__.values():
            _reverse_source[member.value] = member

    @classmethod
    def by_id(cls, value: int) -> Optional[SourceData]:
        return _reverse_source.get(value, None)


@dataclass(frozen=True)
class SpecData:
    name: str
    id: int

    def __str__(self) -> str:
        return self.name


@_setup_class
class SpecType(Enum):
    GOBLIN = SpecData("Goblin", 20222)
    GNOMISH = SpecData("Gnomish", 20219)

    @classmethod
    def setup(cls):
        for member in cls.__members__.values():
            _reverse_spec[member.value] = member

    @classmethod
    def by_id(cls, value: int) -> Optional[SpecData]:
        return _reverse_spec.get(value, None)
