
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

from util import SetWrapper


class Tester(unittest.TestCase):
    def setUp(self):  # Called before each test
        self.sample_list = [5, 9, 3, 1, 0]
        self.sample_set = set(self.sample_list)
        self.empty_list = list()
        self.empty_set = set()

    def test_wrapper_1(self):
        w = SetWrapper[int](self.sample_list)
        self.assertTrue(5 in w)
        self.assertFalse(4 in w)

    def test_wrapper_size(self):
        containers = [self.sample_list, self.sample_set, self.empty_list, self.empty_set]
        sizes = [len(c) for c in containers]
        for i in range(len(containers)):
            w = SetWrapper(containers[i])
            self.assertEqual(len(w), sizes[i])

    def temp_test(self):
        a: set[int] = {5, 3, 4}
        b: set[str] = {"test", "test"}
        from typing import TypeVar, Set
        T = TypeVar("T")

        def check_int_set(ex: Set[T]) -> bool:
            return T == int
        self.assertTrue(check_int_set(a))
        self.assertFalse(check_int_set(b))


if __name__ == '__main__':
    unittest.main()
