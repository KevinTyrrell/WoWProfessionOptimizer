import argparse
import requests
import re
import json
from bs4 import BeautifulSoup


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

    clean = {
        "name": jso["name"],
        "levels": [jso["learnedat"]] + jso["colors"],  # Merge 'learnedat' with 'colors'
        "reagents": {sub[0]: sub[1] for sub in jso["reagents"]}
    }

    if "specialization" in jso:  # Certain crafts require specializations in their given profession
        clean["spec"] = jso["specialization"]
    p = jso["creates"]
    # Associate item ID with number of items crafted, taking the average if it varies
    clean["product"] = {p[0]: (p[1] + p[2]) / 2} if len(p) > 2 else {p[0]: p[1]}
    return clean


def main():
    # Create an argument parser
    parser = argparse.ArgumentParser(description="Retrieves table information from specified profession page")
    parser.add_argument("url", type=str, help="Profession webpage URL")
    parser.add_argument("profession", type=str, help="Name of the profession, used for JSON file output")
    args = parser.parse_args()

    raw = get_raw_table_data(args.url)
    if raw:
        jso = parse_json(raw)
        if jso:
            cleaned = [clean_json(e) for e in jso if clean_json(e) is not None]
            with open(args.profession + ".json", 'w') as file:
                json.dump(cleaned, file, indent=4)
        else:
            print("JSON object could not be parsed.")
    else:
        print("No such script tag detected in web page.")


if __name__ == '__main__':
    main()
