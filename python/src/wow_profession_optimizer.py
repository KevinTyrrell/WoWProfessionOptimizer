
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

import requests
from bs4 import BeautifulSoup

import re
import json
import argparse
from math import floor
from os import path


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


def parse_json(raw: str) -> dict | list:
    """
    :param raw: JSON string to parse into a JSON object
    :return: parsed JSON object
    """
    raw = raw.replace("popularity:", "\"popularity\":")
    raw = raw.replace("quality:", "\"quality\":")
    return json.loads(raw)


def clean_json(jso: dict | list) -> dict | list | None:
    """
    Cleans a JSON object, trimming un-needed data

    :param jso: JSON object
    :return: cleaned JSON object
    """
    if "colors" not in jso or "creates" not in jso or "reagents" not in jso:
        return  # Entries without 'colors', 'creates', or 'reagents' are not actual crafting skills

    product = jso["creates"]
    clean = {
        "name": jso["name"],
        "levels": [jso["learnedat"]] + jso["colors"],  # Merge 'learnedat' with 'colors'
        "reagents": {sub[0]: sub[1] for sub in jso["reagents"]},
        "product": str(product[0]),  # Turn into string since most IDs are already strings
        "source": [6] if "source" not in jso else jso["source"]  # [6] is 'Trainer'
    }

    if "specialization" in jso:  # Certain crafts require specializations in their given profession
        clean["spec"] = jso["specialization"]

    low = product[1]
    high = low if len(product) <= 2 else product[2]
    if high != low:  # Crafting recipe varies in how much it produces
        low = (low + high) / 2
    high = floor(low)
    if low == high:  # Whole number
        if high != 1:  # 'produces' of 1 is implied and is thus omitted
            clean["produces"] = high
    else:
        clean["produces"] = low
    return clean


def save_json_file(jso: dict | list, path: str, filename: str):
    """
    :param jso: JSON object
    :param path: Absolute path to the directory of where the file will be saved
    :param filename: Name of the output file, without extension
    """
    with open(f"{path}/{filename}.json", "w") as file:
        json.dump(jso, file, indent=4)


def save_lua_file(jso: dict | list, path: str, filename: str):
    """
    Saves the JSON object, making it compatible with the Lua programming language

    Certain changes are made to accommodate Lua's environment:
    * JSON object is single-lined, spaces removed, and surrounded by asteriks
    * JSON string is assigned to a Lua table variable, based on 'filename'
    * JSON string has asteriks escaped out
    * JSON string has quotes escaped out

    This function modifies the JSON object
    """
    for e in jso:
        name: str = e["name"]
        # TODO: Escaping characters here seems to cause double escapes e.g.: \\\"
        # TODO: I have tried using rStrings or varying backslashes but dumps() adds extras
        # TODO: NOTE -- Names with quotes MUST be double escaped: \\"
        # name = name.replace('"', '\\"')  # Escape quotation
        e["name"] = name
    with open(f"{path}/{filename}.lua", "w") as file:
        s = json.dumps(jso, separators=(",", ":"), ensure_ascii=False)
        s = s.replace("'", "\\'")  # Escape apostrophe
        file.write(f"select(2, ...)[\"Profession\"][\"{filename}\"] = '{s}'")


def get_and_save(url: str, filename: str) -> None:
    """
    :param url: URL to retrieve table data
    :param filename: Filename (without extension) to be saved
    """
    raw = get_raw_table_data(url)
    if not raw:
        raise RuntimeError("No matching <script> tag detected on the web page.")
    jso = parse_json(raw)
    cleaned = [clean_json(e) for e in jso if clean_json(e) is not None]

    DATA_RELATIVE_PATH = "../../lua/WoWProfessionOptimizer/data/"
    abs_path = path.join(path.dirname(path.abspath(__file__)), DATA_RELATIVE_PATH)

    save_json_file(cleaned, f"{abs_path}/json/", filename)
    save_lua_file(cleaned, f"{abs_path}/strings/", filename)


def main():
    # Create an argument parser
    parser = argparse.ArgumentParser(description="Retrieves table information from specified profession page")
    parser.add_argument("url", type=str, help="Profession webpage URL")
    parser.add_argument("profession", type=str, help="Name of the profession, used for JSON file output")
    args = parser.parse_args()

    get_and_save(args.url, args.profession)


if __name__ == '__main__':
    main()
