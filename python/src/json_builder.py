
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
from abc import ABC, abstractmethod
from typing import Callable, Any, Generator

from util import require_non_none

JSON = dict[str, Any] | list  # Shorthand annotation for JSON objects


class JSONTransformer(ABC):
    def __new__(cls, members: dict[str, Any] | list, inclusive: bool = True):
        if isinstance(members, list):
            return JSOListTF(members, inclusive)
        else:
            return JSOMapTF(members, inclusive)

    def __init__(self, members: dict[str, Any] | list, inclusive: bool = True):
        """
        :param members: JSON object reference
        :param inclusive: Includes all members of the JSO by default, if True
        """
        self._source: dict[str, Any] | list = require_non_none(members).copy()
        require_non_none(inclusive)

    @abstractmethod
    def map(self, member: str | int, mapper: Callable[[Any], Any]) -> JSONTransformer:
        """
        Re-maps a member of the JSO by key

        :param member: JSO key of the member to be re-mapped
        :param mapper: Callback, passed member value, returned re-mapped value
        :return: self
        """
        pass

    @abstractmethod
    def filter(self, members: set[int] | set[str]) -> JSONTransformer:
        """
        Removes members from the JSO, by keys or indexes

        :param members: Set of member keys or member indexes to be filtered out of the JSO
        :return: self
        """
        pass

    @abstractmethod
    def include(self, members: set[int] | set[str]) -> JSONTransformer:
        """
        Includes members from the source JSO, by keys or indexes

        :param members: Set of member keys
        :return: self
        """
        pass

    @abstractmethod
    def build(self) -> dict[str, Any] | list:
        """
        Builds the resulting transformed JSO

        :return: Transformed JSO
        """
        pass


class JSOMapTF(JSONTransformer):
    def __init__(self, members: dict[str, Any], inclusive: bool = True):
        super().__init__(members, inclusive)
        self.__translate = set(members.keys()) if inclusive else set()

    def map(self, member: str, mapper: Callable[[Any], Any]) -> JSONTransformer:
        if member in self._source:
            value = self._source[member]
            self._source[member] = require_non_none(mapper)(value)
        return self

    def filter(self, members: set[str]) -> JSONTransformer:
        for e in members:
            if e in self.__translate:
                self.__translate.remove(e)
        return self

    def include(self, members: set[str]) -> JSONTransformer:
        for e in members:
            self.__translate.add(e)
        return self

    def build(self) -> dict[str, Any]:
        return {k: v for k, v in self._source.items() if k in self.__translate}


class JSOListTF(JSONTransformer):
    def __init__(self, members: list, inclusive: bool = True):
        super().__init__(members, inclusive)
        self.__translate = set(range(len(members))) if inclusive else set()

    def map(self, member: int, mapper: Callable[[Any], Any]) -> JSONTransformer:
        if 0 <= member < len(self._source):
            value = self._source[member]
            self._source[member] = require_non_none(mapper)(value)
        return self

    def filter(self, members: set[int]) -> JSONTransformer:
        for e in members:
            if e in self.__translate:
                self.__translate.remove(e)
        return self

    def include(self, members: set[int]) -> JSONTransformer:
        for e in members:
            self.__translate.add(e)
        return self

    def build(self) -> dict[str, Any] | list:
        return [e for e in self._source if e in self.__translate]
