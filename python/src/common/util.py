
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
from typing import TypeVar, Any, Callable, Iterable, Generic
from abc import ABC, abstractmethod
from collections.abc import MutableSet, Container
import os
from os import path


_T = TypeVar("_T")


def require_non_none(obj: _T) -> _T:
    """
    :param obj: Object which should not be None
    :return: Identity
    """
    if obj is None:
        raise ValueError("Expected non-None argument was None.")
    return obj


class FileValidator(ABC):

    class _PathValidatorDecorator(ABC):
        def __init__(self, decorator=None):
            self._decorator = decorator

        @abstractmethod
        def validate(self, path_str: str) -> str:
            """
            :param path_str: Path to be validated
            :return: Identity
            :raises: RuntimeError if the path was invalid
            """
            pass

    class FileExists(_PathValidatorDecorator):
        def validate(self, path_str: str) -> str:
            if not path.isfile(require_non_none(path_str)):
                raise RuntimeError(f"Expected valid file does not exist: {path_str}")
            if self._decorator is not None:
                return self._decorator.validate(path_str)
            return path_str

    class DirExists(_PathValidatorDecorator):
        def validate(self, path_str: str) -> str:
            if not path.isdir(require_non_none(path_str)):
                raise RuntimeError(f"Expected valid directory does not exist: {path_str}")
            if self._decorator is not None:
                return self._decorator.validate(path_str)
            return path_str

    class PathWritable(_PathValidatorDecorator):
        def validate(self, path_str: str) -> str:
            if not os.access(path_str, os.W_OK):
                raise RuntimeError(f"Expected mutable path does not have write permissions: {path_str}")
            if self._decorator is not None:
                return self._decorator.validate(path_str)
            return path_str
