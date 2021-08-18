#!/usr/bin/env python3
"Inject a grAb chunk into a PNG file"
import argparse
import png as png_util
from grab import get_bytes as get_grab_bytes

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=
                                     "Generate a grAb chunk, and inject it "
                                     "into the given PNG file")
    parser.add_argument('png', help="The PNG file to inject the grAb chunk "
                                    "into")
    parser.add_argument('x', type=int, help="X (horizontal) offset")
    parser.add_argument('y', type=int, help="Y (vertical) offset")
    args = parser.parse_args()
    grabs = get_grab_bytes(args.x, args.y)
    png = png_util.PNGFile()
    png.read(args.png)
    png_grab_index = png.chunk_index(b"grAb")
    if grabs is not None:
        grab_chunk = png_util.PNGChunk(b"grAb", grabs)
        png_ihdr_index = png.chunk_index(b"IHDR")
        if png_grab_index != -1:
            # Replace existing grAb chunk
            png.chunks[png_grab_index] = grab_chunk
        else:
            # Inject grAb chunk
            png.chunks.insert(png_ihdr_index + 1, grab_chunk)
    elif png_grab_index >= 0:
        # Remove grAb chunk
        del png.chunks[png_grab_index]
    png.write(args.png)
