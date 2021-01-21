#!/usr/bin/env bash

# Copyright (C) 2019 Pierre PENNINCKX <ibizapeanut@gmail.com>.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Modifications carried out by ArcherN9
# - Removed Rofi
# - The program no longer attempts to generate a password if it does not already exist
# - The original program in its current shape and form was not OSX compliant.
#   This version is.

################## -- Modifications by burnsac5040 -- ##################
# - Removed rofi and is only compatible with fzf
# - Added a show option (pass' default command)
# - Removed everyhting else including generating new passwords
# - Works best with pass autocompletion (zsh plugins for example)
# - MacOS compatible

PASSWORD_STORE_DIR="${PASSWORD_STORE_DIR:-$HOME/.password-store}"

die() {
    echo "$@"
    exit 1
}

cmd_clip_usage() {
    cat <<-_EOF
    Usage:
    $PROGRAM clip [options]
        Provide an interactive solution to copy passwords to the
        clipboard. It will show all pass-names in fzf, waits for the user
	to select one then copies it to the clipboard.

    Options:
        -s, --show     Equivalent to pass show
        -t, --term     Search for a term before fzf starts
_EOF
    exit 0
}

cmd_clip_short_usage() {
    echo "Usage: $PROGRAM $COMMAND [--help,-h] [--show,-s] [--term,-t]"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1 || exit 1
}

cmd_clip() {
    local opts fzf=0
    local show=0
    local term=""
    opts="$($GETOPT -o t:s -l term:,show -n "$PROGRAM $COMMAND" -- "$@")"
    local err=$?
    eval set -- "$opts"

    while true; do case "$1" in
            -s|--show) show=1; shift ;;
            -t|--term) term="$2"; shift 2 ;;
            --) shift; break ;;
    esac done

    if command_exists fzf; then
        fzf=1
    fi

    [[ $err -ne 0 ]] && die "$(cmd_clip_short_usage)"

    local prompt='Searching for a password : '
    local fzf_cmd="fzf --print-query --prompt=\"$prompt\""

    if [ -n "$term" ]; then
        fzf_cmd="$fzf_cmd -q\"$term\""
    fi
    fzf_cmd="$fzf_cmd | tail -n1"

    if [[ $fzf = 1 ]]; then
        command_exists fzf || die "Could not find fzf in \$PATH"
        menu="$fzf_cmd"
    fi

    cd "$PASSWORD_STORE_DIR" || die "Could not locate password store directory. Please ensure \$PASSWORD_STORE_DIR is setup."

    # Select a passfile
    passfile=$(find -L "$PASSWORD_STORE_DIR" -path '*/.git' -prune -o -iname '*.gpg' -print \
        | sed -e 's/.gpg$//' \
	      | sed -e 's@'"$PASSWORD_STORE_DIR"\/'@@' \
        | sort \
        | eval "$menu" )

    if [ -z "$passfile" ]; then
        die 'No passfile selected.'
    fi

    if ls "$passfile.gpg" > /dev/null 2>&1 && [[ $show = 1 ]]; then
        cmd_show "$passfile" || exit 1
    elif ls "$passfile.gpg" > /dev/null 2>&1; then
        cmd_show "$passfile" --clip || exit 1
    fi
}

[[ "$1" == "help" || "$1" == "--help" || "$1" == "-h" ]] && cmd_clip_usage

cmd_clip "$@"
