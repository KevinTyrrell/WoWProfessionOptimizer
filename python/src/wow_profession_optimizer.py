
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
from typing import Callable, IO
import requests
from bs4 import BeautifulSoup

import re
import json
import argparse
from os import path
from os.path import join

from util import require_non_none
from util import FileValidator as Fv


def get_raw_table_data(url: str) -> str:
    """
    Retrieves profession table data from a specified URL

    :param url: URL of the web page
    :return: json string, possibly malformed
    """

    # Send a GET request to the URL
    response = requests.get(url)
    # Create a BeautifulSoup object from the response content
    soup = BeautifulSoup(response.content, "html.parser")
    # Find the <script> tag that contains the desired variable
    script_tag = soup.find('script', string=re.compile(r'var listviewspells ='))

    if script_tag is not None:
        # Extract the script content
        script_content = script_tag.string
        # Use string manipulation or regular expressions to extract the variable value
        pattern = r'var listviewspells = (.+?);'
        match = re.search(pattern, script_content)
        if match:
            return match.group(1)


def parse_json_to_obj(raw_json: str) -> dict | list:
    """
    :param raw_json: JSON string to parse into a JSON object
    :return: parsed JSON object
    """
    raw_json = raw_json.replace("popularity:", "\"popularity\":")
    raw_json = raw_json.replace("quality:", "\"quality\":")
    return json.loads(raw_json)





def clean_json_obj(jso: dict | list) -> dict | list | None:
    """
    Cleans a JSON object, trimming un-needed members & formatting data

    :param jso: JSON object
    :return: cleaned JSON object
    """

    # Attempt to filter out 'recipes' which are not actually crafting skills
    # Note: Most enchanting recipes don't 'create' items, thus null "creates" should not be ignored
    if "colors" not in jso or "reagents" not in jso:
        return

    product = jso["creates"]
    clean = {
        "name": jso["name"],
        "levels": [jso["learnedat"]] + jso["colors"],  # Merge 'learnedat' with 'colors'
        "reagents": {sub[0]: sub[1] for sub in jso["reagents"]},
        "product": str(product[0]),  # Turn into string since most IDs are already strings
        #"source": [6] if "source" not in jso else jso["source"]  # [6] is 'Trainer'
    }

    if

    if "specialization" in jso:  # Certain crafts require specializations in their given profession
        clean["spec"] = jso["specialization"]

    min_product = product[1]
    if len(product) <= 2:  # Product amount per-craft does not vary
        if min_product != 1:
            clean["produces"] = min_product
    else:  # Note: Should be impossible for avg(min,max) to be 1
        clean["produces"] = (min_product + product[2]) / 2

    return clean


class ProfIOController:
    def __init__(self, home_path: str, ext: str):
        """
        :param home_path: Relative or absolute path for the controller to manage
        :param ext: Extension in which the controller reads/writes to
        """
        if path.isabs(require_non_none(home_path)):
            self.__home_path = home_path
        else:
            home_path = path.join(path.dirname(path.abspath(__file__)), home_path)
            self.__home_path = path.abspath(home_path)
        self.__ext = require_non_none(ext)

    def read(self, expansion: str, profession: str) -> str:
        """
        Reads a file and stores the contents in a string

        :param expansion: Expansion name
        :param profession: Profession name
        :return: Contents of the file, as a string
        """
        Fv.DirExists().validate(self.__home_path)
        file_path = self._get_file_path(require_non_none(expansion), require_non_none(profession))
        with open(Fv.FileExists(Fv.PathWritable()).validate(file_path), "r") as file:
            return file.read()

    def write(self, expansion: str, profession: str, cb: Callable[[IO[str]], None]) -> None:
        """
        Prepares a profession file to-be written to

        :param expansion: Expansion name
        :param profession: Profession name
        :param cb: Callback(file) callback for writing to the file
        """
        Fv.DirExists().validate(self.__home_path)
        file_path = self._get_file_path(require_non_none(expansion), require_non_none(profession))
        if path.isfile(file_path):
            Fv.PathWritable().validate(file_path)
        with open(file_path, "w") as file:
            cb(file)

    def _get_file_path(self, expansion: str, profession: str) -> str:
        return join(self.__home_path, f"{expansion}-{profession}{self.__ext}")


# Path to JSON and Lua JSON profession folder
PROF_DATA_RELATIVE_PATH = "../../lua/WoWProfessionOptimizer/data/"
json_controller = ProfIOController(f"{PROF_DATA_RELATIVE_PATH}/json/", ".json")
lua_controller = ProfIOController(f"{PROF_DATA_RELATIVE_PATH}/lua/", ".lua")


def create_json_data(expansion: str, profession: str, url: str) -> None:
    table_data = get_raw_table_data(require_non_none(url))
    if not table_data:
        raise RuntimeError("No matching <script> tag detected on the web page.")
    jso = parse_json_to_obj(table_data)
    cleaned = [clean_json_obj(e) for e in jso if clean_json_obj(e) is not None]
    json_controller.write(expansion, profession, lambda f: json.dump(cleaned, f, indent=4))


def create_lua_data(expansion: str, profession: str) -> None:
    """
    Maps an existing JSON profession file into its Lua equivalent.
    The resulting Lua file will be saved to the storage medium.

    Certain changes are made to accommodate Lua's environment:
    * JSON string will be single-lined, spaces removed, and treated as a Lua string
    * JSON string is assigned to Lua table value corresponding with expac/prof
    * JSON string has asteriks and quotation marks escaped out

    :param expansion: Expansion name
    :param profession: Profession name
    """
    json_raw = json_controller.read(expansion, profession)
    jso = json.loads(json_raw)
    json_raw = json.dumps(jso, separators=(",", ":"), ensure_ascii=False)
    json_raw = json_raw.replace("'", "\\'")  # Escape apostrophe
    json_raw = f"select(, ...)[\"Profession\"][\"{expansion}-{profession}\"] = '{json_raw}'"
    lua_controller.write(expansion, profession, lambda f: f.write(json_raw))


expansions = [
    ("World of Warcraft", "WOW"),
    ("The Burning Crusade", "TBC"),
    ("Wrath of the Lich King", "WOLTK"),
    ("Season of Discovery", "SOD"),
    ("Cataclysm", "CATA"),
    ("Mists of Pandaria", "MOP"),
    ("Warlords of Draenor", "WOD"),
    ("Legion", "LEGION"),
    ("Battle for Azeroth", "BFA"),
    ("Shadowlands", "SL"),
    ("Dragonflight", "DF")
]


# Double up in order to match the expansions structure
professions = [(x, x) for x in ["Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering", "First Aid",
                                "Inscription", "Jewelcrafting", "Leatherworking", "Mining", "Tailoring"]]


class ArpStrings:
    PROG_NAME = "WoWProfessionOptimizer"
    PROG_DESC = """Retrieves profession information from WoWHead as a JSON object,
      and/or formats a profession JSON object into a Lua profession object."""
    EXPANSION_ARG = "expansion"
    EXPANSION_HELP = "Expansion associated with the recipe data (by ID, see: help)"
    PROFESSION_ARG = "profession"
    PROFESSION_HELP = "Profession associated with the recipe data (by ID, see: help)"
    JSON_ARG = "json"
    JSON_ARG1 = f"--{JSON_ARG}"
    JSON_ARG2 = f"-{JSON_ARG[0]}"
    JSON_HELP = "Profession data URL in which to iterate and save as a JSON object"
    LUA_ARG = "lua"
    LUA_ARG1 = f"--{LUA_ARG}"
    LUA_ARG2 = f"-{LUA_ARG[0]}"
    LUA_HELP = "Parses and saves the existing JSON file for this query into a Lua object"


class ChoiceTranslator:
    def __init__(self, choices: list[tuple[str, str]]):
        self.__choices = choices

    def verify(self, choice: int) -> int:
        """
        :param choice: Index to be range-checked
        :return: Identity
        """
        try:
            choice = int(choice)
            if choice < 1 or choice > len(self.__choices):
                raise argparse.ArgumentTypeError(f"Index '{choice}' is not of the domain: [1, {len(self.__choices)}]")
            return choice
        except ValueError:
            raise argparse.ArgumentTypeError(f"Parameter type mismatch, expected integer: {choice}")

    def translate(self, choice: int) -> str:
        return self.__choices[choice - 1][1]

    def choices_text(self) -> str:
        return "\n  ".join([f"{i+1:>2}:   {self.__choices[i][0]}" for i in range(len(self.__choices))])


exp_translator = ChoiceTranslator(expansions)
prof_translator = ChoiceTranslator(professions)

choice_mapper = {  # Maps arg keys --> arg translators
    ArpStrings.EXPANSION_ARG: exp_translator,
    ArpStrings.PROFESSION_ARG: prof_translator
}


class ChoiceHelpFormatter(argparse.HelpFormatter):
    help_shown = False  # Flag which indicates whether argparse has shown the help screen

    def format_help(self):
        ChoiceHelpFormatter.help_shown = True
        return super().format_help()

    def _format_action_invocation(self, action):
        if action.choices and action.dest in choice_mapper:
            return choice_mapper[action.dest].choices_text()
        # noinspection PyProtectedMember
        return super()._format_action_invocation(action)


def main():
    parser = argparse.ArgumentParser(prog=ArpStrings.PROG_NAME, description=ArpStrings.PROG_DESC,
                                     formatter_class=ChoiceHelpFormatter)
    parser.add_argument(ArpStrings.EXPANSION_ARG,
                        type=lambda x: exp_translator.verify(x),
                        choices=[i+1 for i in range(len(expansions))],
                        help=ArpStrings.EXPANSION_HELP)
    parser.add_argument(ArpStrings.PROFESSION_ARG,
                        type=lambda x: prof_translator.verify(x),
                        choices=[i+1 for i in range(len(professions))],
                        help=ArpStrings.PROFESSION_HELP)
    parser.add_argument(ArpStrings.JSON_ARG1, ArpStrings.JSON_ARG2,
                        type=str, help=ArpStrings.JSON_HELP)
    parser.add_argument(ArpStrings.LUA_ARG1, ArpStrings.LUA_ARG2,
                        action="store_true", help=ArpStrings.LUA_HELP)

    args = vars(parser.parse_args())
    if not ChoiceHelpFormatter.help_shown:  # Avoid printing help menu twice
        parser.print_help()
    exp = exp_translator.translate(args[ArpStrings.EXPANSION_ARG])
    prof = prof_translator.translate(args[ArpStrings.PROFESSION_ARG])
    if args[ArpStrings.JSON_ARG]:
        create_json_data(exp, prof, args[ArpStrings.JSON_ARG])
    if args[ArpStrings.LUA_ARG]:
        create_lua_data(exp, prof)


if __name__ == '__main__':
    main()
