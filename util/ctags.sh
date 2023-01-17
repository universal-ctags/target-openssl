#!/bin/sh
#
# Usage: ./ctags.sh [...arguments for ctags...]
#
# This script runs ctags twice. In the first pass, ctags extract macro
# definitions. readtags that is part of Universal Ctags converts them
# to ctags options. In the second pass, ctags reads the options and
# extracts language objects with expanding macros.
#
: ${CTAGS=~/bin/ctags}
: ${READTAGS=~/bin/readtags}

if ! type "${CTAGS}" > /dev/null; then
    echo "${CTAGS}: not found" 1>&2
    exit 1
fi

if ! "${CTAGS}" --version | grep -q "Universal Ctags"; then
    echo "${CTAGS}: not Univrsal Ctags" 1>&2
    exit 1
fi

if "${CTAGS}" --version | grep -q "Universal Ctags 5.*"; then
    echo "${CTAGS}: Univrsal Ctags but too old (5)" 1>&2
    exit 1
fi

if ! type "${READTAGS}" > /dev/null; then
    echo "${READTAGS}: not found" 1>&2
    exit 1
fi

if ! [ -d ./.ctags.d ]; then
    echo "No ./.ctags.d directory" 1>&2
    exit 1
fi

if [ $# -eq 0 ]; then
    set - -R
fi

#
# Universal Ctags 6.0.0 is assumed.
#
# We can simplify the following command lines if we can use newer version.
#
$CTAGS --quiet --options=NONE \
       --options=./.ctags.d/stage1/default.ctags \
    | $READTAGS -t - \
		-Q '(eq? $kind "d")'  \
		-F '(list "-D" $name $signature "=" ($ "macrodef") #t)' -l > .ctags.d/stage2/macros.ctags &&
    $CTAGS --exclude=.ctags.d \
	   --options=./.ctags.d/stage2/default.ctags \
	   --options=./.ctags.d/stage2/macros.ctags  \
	   "$@"
