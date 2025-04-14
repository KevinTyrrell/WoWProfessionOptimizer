
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
from typing import Optional, Any, Annotated, TypeAlias

from pydantic import BaseModel, Field, model_validator, AfterValidator, field_validator
from typing_extensions import Self


def verify_positive(x):
    if x <= 0: raise ValueError("must be positive")
    return x


PositiveInt: TypeAlias = Annotated[int, AfterValidator(verify_positive)]


class TestJSON(unittest.TestCase):
    def setUp(self) -> None:
        # Example JSON returned by API calls
        self.__jso_1 = {'cat': 11, 'colors': [1, 40, 55, 70], 'creates': [2302, 1, 1], 'id': 2149, 'learnedat': 1,
                        'level': 0, 'name': 'Handstitched Leather Boots', 'nskillup': 1, 'quality': 1,
                        'reagents': [[2318, 2], [2320, 1]], 'schools': 1, 'skill': [165], 'popularity': 8}
        self.__jso_2 = {'cat': 11, 'colors': [375, 385, 395, 405], 'creates': [29521, 1, 1], 'id': 35584,
                        'learnedat': 375, 'level': 0, 'name': 'Netherstrike Bracers', 'nskillup': 1, 'quality': 4,
                        'reagents': [[23793, 4], [29548, 18], [22457, 8], [22451, 8]], 'schools': 1, 'skill': [165],
                        'source': [6], 'specialization': 10656, 'trainingcost': 100000, 'popularity': 7}

    class RecipeModel(BaseModel):
        name: str
        product: PositiveInt = Field(..., alias="creates")
        min_yield: PositiveInt
        max_yield: PositiveInt
        unlock: PositiveInt = Field(..., alias="learnedat")
        yellow: PositiveInt
        grey: PositiveInt
        reagents: dict[PositiveInt, PositiveInt]
        spec: Optional[int] = Field(None, alias="specialization")
        cost: Optional[int] = Field(None, alias="trainingcost")

        @field_validator("reagents", mode="before")
        @staticmethod
        def map_reagents(value: Any) -> Any:
            if value and isinstance(value, list):
                result = {}
                for pair in value:
                    if len(pair) < 2:
                        raise ValueError("reagent sub-lists must be of [int, int]")
                    key, value, *_ = pair
                    if key in result:
                        raise ValueError(f"duplicate reagent in recipe")
                    result[key] = value
                return result

        @model_validator(mode="after")
        def check_yield_bounds(self) -> Self:
            if self.min_yield > self.max_yield:
                raise ValueError("[min_yield, max_yield] domain is non-monotonic")
            return self

        @model_validator(mode="before")
        @classmethod
        def map_creates(cls, values: dict[str, Any]) -> dict[str, Any]:
            creates = values.get("creates")
            if creates and isinstance(creates, list):
                p = creates[0]
                if len(creates) == 2: n = x = creates[1]
                elif len(creates) >= 3: n, x = creates[1], creates[2]
                else: n = x = 1
            else: p, n, x = creates, 1, 1

            values["creates"], values["min_yield"], values["max_yield"] = p, n, x
            return values

        @model_validator(mode="before")
        @classmethod
        def map_colors(cls, values: dict[str, Any]) -> dict[str, Any]:
            colors = values.get("colors")
            if not isinstance(colors, list) or len(colors) != 4:
                raise ValueError("colors must be of list[int, int, int, int]")
            values["yellow"], values["grey"] = colors[1], colors[3]
            return values

    def test1(self):
        r1 = TestJSON.RecipeModel(**self.__jso_1)
        r2 = TestJSON.RecipeModel(**self.__jso_2)
        print(r1)
        print(r2)
        self.assertTrue(True)


if __name__ == '__main__':
    unittest.main()
