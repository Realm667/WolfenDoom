#!/usr/bin/env python3
# Check for cells in a CSV file which end in a newline
import argparse
import csv
import io
from sys import platform

parser = argparse.ArgumentParser(
    description="Check for cells in a CSV file which end in a newline"
)
parser.add_argument("csv_file")
parser.add_argument("--escaped", action='store_true')
args = parser.parse_args()

with open(args.csv_file) as csvdata:
    reader = csv.DictReader(csvdata)
    for lineno, row in enumerate(reader):
        # Add 2 because the first row is not counted, and because "enumerate"
        # starts at 0.
        rowid = "{} {}".format(lineno + 2, row["Identifier"])
        for lang in row:
            content = row[lang]
            if args.escaped:
                content = content.replace("\\n", "\n")
            if content.endswith("\n") or content.endswith("\r"):
                preview = content[:15] + "..." \
                    if len(content) > 15 \
                    else content
                if platform == "linux":
                    # Linux-only text colour codes (see console_codes(4))
                    preview = preview.replace("\n", "\x1B[31m\\n\x1B[39m")
                else:
                    preview = preview.replace("\n", "\\n")
                print("{}[{}] ({}) ends with a newline!".format(
                    rowid, lang, preview
                ))
