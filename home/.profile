# shellcheck disable=SC2148
# Sample .profile for SUSE Linux
# rewritten by Christian Steinruecken <cstein@suse.de>
#
# This file is read each time a login shell is started.
# All other interactive shells will only read .bashrc; this is particularly
# important for language settings, see below.

[ -f "/etc/profile" ] && test -z "$PROFILEREAD" && . /etc/profile || true

[ -f ~/.local/bin/tldr ] && compctl -k "($( tldr 2>/dev/null --list))" tldr

# Variables:
export EDITOR=micro
export VISUAL=$EDITOR
export BROWSER=firefox
export PAGER=less

# Paths:
export GITMAN_REPOS_LOCATION=~/Git/
export NIM_DOCS_DIRECTORY=~/Git/nirokay.github.io/nim-docs/
export GOPATH=~/.go/

# Language:
export LANG="en_GB.UTF-8"
export LANGUAGE="en:de"

export LC_MEASUREMENT="en_DE.UTF-8"
export LC_MONETARY="en_DE.UTF-8"
export LC_PAPER="en_DE.UTF-8"
export LC_TELEPHONE="en_DE.UTF-8"
export LC_TIME="en_DE.UTF-8"
export LC_NUMERIC="en_GB.UTF-8"
export LC_COLLATE="de_DE@dict"
export LC_MESSAGES="$LANG"
# export LC_ADDRESS=""              # commented out because it is not documented enough
export LC_IDENTIFICATION=""
# export LC_NAME=""                 # commented out because it is not documented enough

# Stfu perl:
export PERL_BADLANG=0

# Path:
# shellcheck source=/dev/null
source ~/.paths

# Aliases:
# shellcheck source=/dev/null
source ~/.aliases
