
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
    def test_set_wrapper_1(self):
        s = SetWrapper[int]()
        self.assertFalse(5 in s)


if __name__ == '__main__':
    unittest.main()
