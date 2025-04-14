
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

from enum import Enum
from dataclasses import dataclass
from functools import lru_cache
from typing import Optional


@dataclass(frozen=True)
class _SourceData:
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
    CRAFT = _SourceData("Craft", 1)  # Not verified, found by induction
    DROP = _SourceData("Drop", 2)
    PVP = _SourceData("PvP", 3, False)  # Not verified, found by induction
    QUEST = _SourceData("Quest", 4)
    VENDOR = _SourceData("Vendor", 5)
    TRAINER = _SourceData("Trainer", 6)
    STARTER = _SourceData("Starter", 7, False)  # Not verified, found by induction
    FISHING = _SourceData("Fishing", 16, False)
    PICKPOCKET = _SourceData("Pickpocket", 21, False)

    @classmethod
    @lru_cache  # Transforms this function into O(1)
    def by_id(cls, source_id: int) -> Optional[_SourceData]:
        for source in SourceType:
            if source.value.id == source_id:
                return source.value
