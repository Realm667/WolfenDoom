# DEBUG=${DEBUG:+-g}
CC = gcc
CFLAGS = -g -Wall
#FREETYPE_INCLUDE=${FREETYPE_INCLUDE:=${HOME}/Downloads/misc/freetype-2.10.2/include}
#FREETYPE_LIB=${FREETYPE_LIB:=${HOME}/Downloads/misc/freetype-2.10.2/objs/.libs}

MKFONTSINGLE_INCLUDE = -I/usr/include/freetype2

all: palhack mkfontsingle

palhack: palhack.c
	$(CC) $(CFLAGS) palhack.c -lpng -o palhack

mkfontsingle: mkfontsingle.c
	$(CC) $(CFLAGS) $(MKFONTSINGLE_INCLUDE) mkfontsingle.c -lfreetype -lpng -lm -o mkfontsingle
