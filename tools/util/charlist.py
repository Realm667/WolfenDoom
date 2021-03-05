#!/usr/bin/env python3
# Get all of the font characters used in a CSV file
import csv
import argparse

parser = argparse.ArgumentParser(
    description="Print a list of characters used in every cell of a CSV file"
)
parser.add_argument("csv_file", type=str)
parser.add_argument("--header", type=str)
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
    chrepr = char
    if chrepr == '"':
        chrepr = '""'
    return "{} - {:04X}".format(chrepr, codepoint)

if args.header:
    print(args.header)
print("\n".join(map(char_list_item, charlist)))