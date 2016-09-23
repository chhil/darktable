#!/bin/sh

git shortlog -sne ^release-1.6.9 HEAD

echo "are you sure these guys received proper credit in the about dialog?"
read answer

# prefix rc with ~, so debian thinks its less than
echo "* archiving git tree"
dt_decoration=$(git describe --tags $branch | sed 's,^release-,,;s,-,+,;s,-,~,;' | sed 's/rc/~rc/')
git archive HEAD --prefix=darktable-$dt_decoration/ -o darktable-$dt_decoration.tar

SRCDIR=`pwd`
TMPDIR=`mktemp -d -t darktable-XXXXXX`
cd "$TMPDIR"
tar xf "$SRCDIR/darktable-$dt_decoration.tar"

# create version header for non-git tarball:
echo "* creating version header"
echo "#define PACKAGE_VERSION \"$dt_decoration\"" > darktable-$dt_decoration/src/version_gen.h

# remove usermanual, that's > 80 MB and released separately
echo "* removing usermanual"
rm -rf darktable-$dt_decoration/doc/usermanual

# ... and also remove RELEASE_NOTES. that file is just for internal use
echo "* removing RELEASE_NOTES"
rm -rf darktable-$dt_decoration/RELEASE_NOTES

# wrap it up again
echo "* creating final tarball"
tar cf darktable-$dt_decoration.tar darktable-$dt_decoration/
rm "$DT_SRC_DIR/darktable-$dt_decoration.tar"
xz -z -v -9 -e darktable-$dt_decoration.tar
cp darktable-$dt_decoration.tar.xz "$SRCDIR"

# now test the build:
echo "* test compiling"
rm -rf darktable-$dt_decoration/
tar xf darktable-$dt_decoration.tar.xz
cd darktable-$dt_decoration/
./build.sh --prefix "$TMPDIR/darktable/"

echo
echo "to actually test this build you should do:"
echo "cd $TMPDIR/darktable-$dt_decoration/build && make install"
echo "then run darktable from:"
echo "$TMPDIR/darktable/bin/darktable"



