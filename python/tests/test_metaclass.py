
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

import unittest
from enum import auto
from dataclasses import dataclass

from src.scraper.reverse_enum import *


class TestMetaClass(unittest.TestCase):
    def setUp(self) -> None:
        pass

    def test1(self) -> None:
        class MyEnum(ReverseEnum):
            A = auto()
            B = auto()

        self.assertEqual(MyEnum.B, MyEnum.by_id(2))
        self.assertIsNone(MyEnum.by_id(3))

    def test2(self) -> None:
        @dataclass(frozen=True)
        class _RaceData:
            name: str
            sub: Optional[str] = None

        class OblivionRace(ReverseEnum):
            BRETON = _RaceData("Breton")
            ALTMER = _RaceData("Altmer", "High Elves")
            DUNMER = _RaceData("Dunmer", "Dark Elves")

            @classmethod
            def _reverse_key(cls, data: _RaceData):
                return data.name

        self.assertEqual(OblivionRace.ALTMER, OblivionRace.by_id("Altmer"))
        self.assertIsNone(OblivionRace.by_id("Mystic Elves"))


if __name__ == '__main__':
    unittest.main()
