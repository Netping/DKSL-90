#!/bin/bash
#need set version in next 3-th line
major=0
minor=0
path=1
apt-get install dpkg debconf debhelper lintian
cat <<EOF > ./DKSL-90/DEBIAN/control
Package: dksl-90
Version: $major.$minor-$path
Maintainer: vv.lisyak@gmail.com
Architecture: all
Section: misc
Description: NetPing
 First deb build.
 Try nomber one.
EOF
fakeroot dpkg-deb --build DKSL-90
mv ./DKSL-90.deb DKSL-90.$major.$minor-$path.deb
exit 0
