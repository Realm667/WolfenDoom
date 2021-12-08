#!/usr/bin/env python3
# Check for cells in a CSV file which end in a newline
import csv
import argparse
import io

parser = argparse.ArgumentParser(
    description="Check for cells in a CSV file which end in a newline"
)
parser.add_argument("csv_file", type=str)
args = parser.parse_args()


with open(args.csv_file, "r") as csvdata:
    reader = csv.DictReader(csvdata)
    for lineno, row in enumerate(reader):
        rowid = str(lineno + 1) + " " + row["Identifier"]
        for lang in row:
            content = row[lang]
            if content.endswith("\n") or content.endswith("\r"):
                preview = content[:15] + "..." \
                    if len(content) > 15 \
                    else content
                preview = preview.replace("\n", "\x1B[31m\\n\x1B[39m")
                print("{}[{}] ({}) ends with a newline!".format(
                    rowid, lang, preview
                ))
