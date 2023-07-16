import argparse
import requests
import re
import json
from bs4 import BeautifulSoup


def html_table_to_json(url):
    # Send a GET request to the URL
    response = requests.get(url)
    # Create a BeautifulSoup object from the response content
    soup = BeautifulSoup(response.content, "html.parser")
    # Find the <script> tag that contains the desired variable
    script_tag = soup.find('script', string=re.compile(r'var listviewspells ='))

    # Check if the script tag exists
    if script_tag is not None:
        # Extract the script content
        script_content = script_tag.string

        # Use string manipulation or regular expressions to extract the variable value
        # Here's an example assuming the variable assignment follows a specific pattern
        variable_pattern = r'var listviewspells = (.+?);'
        variable_match = re.search(variable_pattern, script_content)

        if variable_match:
            variable_value = variable_match.group(1)
            print("Variable Value:", variable_value)
        else:
            print("Variable not found in the script.")
    else:
        print('Script tag not found on the web page.')


def main():
    # Create an argument parser
    parser = argparse.ArgumentParser(description="Retrieves table information from specified profession page")
    parser.add_argument("url", type=str, help="Profession webpage URL")
    args = parser.parse_args()
    html_table_to_json(args.url)


if __name__ == '__main__':
    main()
