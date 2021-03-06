#!/usr/bin/env python3
# Get all of the font characters used in a CSV file
import csv
import argparse
import io

parser = argparse.ArgumentParser(
    description="Print a list of characters used in every cell of a CSV file"
)
parser.add_argument("csv_file", type=str)
parser.add_argument("--header", type=str, nargs=1)
parser.add_argument("--csv", action="store_true")
parser.add_argument("--code-only", action="store_true")
args = parser.parse_args()

usedchars = set()
skipcols = []

with open(args.csv_file, "r") as csvdata:
    reader = csv.reader(csvdata, doublequote=True)
    firstrow = True
    for row in reader:
        for col, cell in enumerate(row):
            if firstrow:
                title = cell.lower()
                if title == "remarks" or title == "identifier":
                    skipcols.append(col)
            if col in skipcols:
                continue
            for char in cell:
                if not char.isprintable() or char.isspace():
                    continue
                usedchars.add(char.lower()[0])
                usedchars.add(char.upper()[0])
        firstrow = False

charlist = sorted(list(usedchars), key=ord)

def char_list_item(char):
    codepoint = ord(char)
    chrepr = "{} - {:04X}".format(char, codepoint)
    if args.code_only:
        chrepr = "{:04X}".format(codepoint)
    if args.csv:
        csvrow = io.StringIO()
        csvwriter = csv.writer(csvrow, lineterminator="")
        csvwriter.writerow([chrepr])
        return csvrow.getvalue()
    return chrepr

if args.header:
    print(args.header[0])
print("\n".join(map(char_list_item, charlist)))