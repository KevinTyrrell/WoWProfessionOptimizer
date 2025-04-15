
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

from typing import Optional, Any, Annotated, TypeAlias
from typing_extensions import Self

from pydantic import BaseModel, Field, model_validator, AfterValidator, field_validator, BeforeValidator

from recipe_types import *


def _verify_positive(value):
    if value <= 0: raise ValueError("must be positive")
    return value


def _map_spec(value: Any) -> Optional[str]:
    if value:
        spec: Optional[SpecData] = SpecType.by_id(value)
        if not spec: raise ValueError("specialization is unrecognized")
        return spec.name


_PositiveInt: TypeAlias = Annotated[int, AfterValidator(_verify_positive)]


class RecipeModel(BaseModel):
    name: str
    product: _PositiveInt = Field(..., alias="creates")
    min_yield: _PositiveInt
    max_yield: _PositiveInt
    unlock: _PositiveInt = Field(..., alias="learnedat")
    yellow: _PositiveInt
    grey: _PositiveInt
    reagents: dict[_PositiveInt, _PositiveInt]
    source: list[str]
    spec: Optional[Annotated[str, BeforeValidator(_map_spec)]] = Field(None, alias="specialization")
    cost: Optional[int] = Field(0, alias="trainingcost")

    @field_validator("reagents", mode="before")
    @staticmethod
    def __map_reagents(value: Any) -> Any:
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

    @field_validator("source", mode="before")
    @staticmethod
    def __before_source(value: Any) -> Any:
        if value and isinstance(value, list):
            sources: set[str] = set()
            for source_id in value:
                source_type: Optional[SourceData] = SourceType.by_id(source_id)
                if source_type is None:
                    raise ValueError("source type is unrecognized")
                if source_type.major:
                    sources.add(source_type.name)
            if not sources: raise ValueError("no major sources found")
            return list(sources)

    @model_validator(mode="after")
    def __check_yield_bounds(self) -> Self:
        if self.min_yield > self.max_yield:
            raise ValueError("[min_yield, max_yield] domain is non-monotonic")
        return self

    @model_validator(mode="before")
    @classmethod
    def __before_creates(cls, values: dict[str, Any]) -> dict[str, Any]:
        creates = values.get("creates")
        if creates and isinstance(creates, list):
            p = creates[0]
            if len(creates) == 2:
                n = x = creates[1]
            elif len(creates) >= 3:
                n, x = creates[1], creates[2]
            else: n = x = 1
        else: p, n, x = creates, 1, 1
        values["creates"], values["min_yield"], values["max_yield"] = p, n, x
        return values

    @model_validator(mode="before")
    @classmethod
    def __before_colors(cls, values: dict[str, Any]) -> dict[str, Any]:
        colors = values.get("colors")
        if not isinstance(colors, list) or len(colors) != 4:
            raise ValueError("colors must be of list[int, int, int, int]")
        values["yellow"], values["grey"] = colors[1], colors[3]
        return values
