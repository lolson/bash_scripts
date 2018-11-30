#!/bin/sh --

prefix=/sw
exec_prefix=${prefix}
bindir=${exec_prefix}/bin
libdir=${exec_prefix}/lib
mandir=/sw/share/man
srcdir=.
datarootdir=${prefix}/share
docdir=${datarootdir}/doc/${PACKAGE_TARNAME}
includedir=${prefix}/include
top_srcdir=..
top_builddir=..

SOURCE="$1"
TARGET="$2"


rm -f "$TARGET"

sed -e "s;/usr/local/bin/;$bindir/;g" 	 	\
    -e "s;/usr/local/doc/mutt/;$docdir/;g" 	\
    "$SOURCE" > $TARGET

chmod 644 "$TARGET"
