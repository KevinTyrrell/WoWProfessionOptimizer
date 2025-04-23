
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

from enum import Enum, EnumMeta
from typing import TypeVar, Type, Optional, Any, Callable

_T = TypeVar("_T", bound=Enum)


class _ReverseEnumMeta(EnumMeta):
    def __new__(metacls, cls_name, bases, cls_dict):
        # Assign this as the metaclass of the original class
        enum_cls = super().__new__(metacls, cls_name, bases, cls_dict)

        # Allow implementing classes to override `_reverse_key`
        mapper: Callable = getattr(enum_cls, "_reverse_key", lambda v: v)

        # Default pairing of map[Enum value -> Enum instance]
        reverse_lookup = {
            mapper(member.value):
                member for member in enum_cls.__members__.values()
        }

        def by_id(reverse: Any) -> Optional[_T]:
            """
            :param reverse: Reverse key for the enum, instance's value by default
            :return: Mapped Enum instance, or None if no such mapping exists
            """
            return reverse_lookup.get(reverse, None)

        enum_cls.by_id = by_id
        return enum_cls


class ReverseEnum(Enum, metaclass=_ReverseEnumMeta):
    pass
