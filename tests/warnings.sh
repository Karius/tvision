#!/bin/bash

if [ -e ../Makefile ]; then
	make -C .. distclean
fi
if [ ! -e ../configure ]; then
	(cd ..; ./bootstrap.sh)
fi

rm -rf warnings
mkdir warnings
cd warnings
LDFLAGS="-Wl,--as-needed -flto -fuse-linker-plugin" \
CXXFLAGS="-Wall -Wextra -fno-diagnostics-show-caret -Os -Wp,-D_FORTIFY_SOURCE=2 -fdiagnostics-show-option -Wcomment -Wfloat-conversion -Wfloat-equal -Wformat -Wformat-security -Wformat-signedness -Wimplicit-fallthrough -Wignored-qualifiers -Wlogical-not-parentheses -Wmaybe-uninitialized -Wmissing-braces -Wmissing-declarations -Wmissing-field-initializers -Wmissing-format-attribute -Wno-long-long -Wno-unreachable-code -Wparentheses -Wpointer-arith -Wredundant-decls -Wreturn-type -Wsequence-point -Wshadow -Wsign-compare -Wswitch -Wswitch-default -Wtype-limits -Wundef -Wuninitialized -Wunreachable-code -Wunused-but-set-variable -Wunused-function -Wunused-label -Wunused-parameter -Wunused-result -Wunused-value -Wunused-variable -Wwrite-strings" \
AR="gcc-ar" RANLIB="gcc-ranlib" NM="gcc-nm" \
../../configure --quiet --enable-maintainer-mode
echo make
make >/dev/null 2> >(tee ../warnings.err >&2)
cd ..
grep -- -W warnings.err | sed 's/.*\[//; s/\]//' | sort | uniq -c | sort -nr > warnings.log
echo >> warnings.log
echo "----------------------------------------------------------------" >> warnings.log
cat warnings.err >> warnings.log
rm -rf warnings.err
(cd warnings/doc; doxygen 2>&1) | sed "s,$(cd ..; pwd),," >doxygen.log
