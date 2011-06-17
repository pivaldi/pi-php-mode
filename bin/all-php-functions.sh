#!/bin/bash

# Copyright (c) 2010, Philippe Ivaldi <www.piprime.fr>
# $Last Modified on 2011/06/17

# This program is free software ; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation ; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY ; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public License
# along with this program ; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

# COMMENTARY:

# This program generates the list of all php functions from the documentation of php.
# The functions are presented with its arguments.
# With the -v option, a brief description is added in the line after.
# With the -l option, output only the function name

# Output without option :
# 8<------8<------8<------8<------8<------8<------8<------8<------
# abs(mixed number)
# acos(float arg)
# acosh(float arg)
# addcslashes(string str, string charlist)
# etc
# 8<------8<------8<------8<------8<------8<------8<------8<------

# Output with -v option :
# 8<------8<------8<------8<------8<------8<------8<------8<------
# abs(mixed number)
#    Absolute value --returns number--
# acos(float arg)
#    Arc cosine --returns float--
# acosh(float arg)
#    Inverse hyperbolic cosine --returns float--
# addcslashes(string str, string charlist)
#    Quote string with slashes in a C style --returns string--
# etc
# 8<------8<------8<------8<------8<------8<------8<------8<------

# Output with -l option :
# 8<------8<------8<------8<------8<------8<------8<------8<------
# abs
# acos
# acosh
# addcslashes
# addslashes
# etc
# 8<------8<------8<------8<------8<------8<------8<------8<------

# CODE:

DIR="/usr/share/doc/php-doc/html/"


VERBOSE=false
LIST=false
case $1 in
    -v)
	VERBOSE=true
        ;;
    -l)
	LIST=true
        VERBOSE=false
        ;;
esac

function extract_function () {
    FUNC=$(cat "$1" | \
        awk -v FS="^Z" '/<div class="methodsynopsis \
dc-description">/,/<\/div>/{print}')

    if [ "X$FUNC" == "X" ]; then # cas des alias et autres
        FUNC=$(cat "$1" | \
            awk -v FS='<span class="refname">' -v RS='^Z' '{print $2}' | \
            awk -v FS='</span>' -v RS='^Z' '{print $1}')
        # Add a phantom type because it's needed later
        FUNC="? ${FUNC}"
    fi

    FUNC=$(echo $FUNC | \
        tr '\n' ' ' | \
        awk 'BEGIN {ORS = "@-@"; RS = "<[^<>]*>"}{print}'  | \
        sed 's/@-@//g;s/\$//g')

    SIGN=$(echo $FUNC | awk '{for(k=2; k <= NF; k++) print $k}' | \
        tr '\n' ' ' | sed 's/ ( /(/g;s/ )/)/g;s/ ,/,/g')

    $LIST && {
        SIGN=$(echo $SIGN | sed 's/(.*)//g')
    }

    $VERBOSE && {
        TYP=$(echo $FUNC | awk '{print $1}')

        DESC=$(cat $1 | \
            awk -v FS='<span class="dc-title">' -v RS='^Z' '{print $2}' | \
            awk -v FS='</span>' -v RS='^Z' '{print $1}' | \
            tr '\n' ' ' | \
            awk 'BEGIN {ORS = "@-@"; RS = "<[^<>]*>"}{print}'  | \
            sed -re "s/@-@//g;s/^ *//g;s/ *$//g;s/  +/ /g;s/&#039;/'/g;s/\\$//g")
    }

    echo "$SIGN"
    $VERBOSE && echo "   ${DESC} --returns $TYP--"
}


for fic in `find "$DIR" -name "function.*.html" | sort`; do
    extract_function "$fic"

    # For testing the script on 10 fonctions only
    # i=$[$i+1]
    # [ $i -gt 10 ] && exit
done