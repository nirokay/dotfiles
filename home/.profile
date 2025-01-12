# shellcheck disable=SC2148
# Sample .profile for SUSE Linux
# rewritten by Christian Steinruecken <cstein@suse.de>
#
# This file is read each time a login shell is started.
# All other interactive shells will only read .bashrc; this is particularly
# important for language settings, see below.

[ -f "/etc/profile" ] && test -z "$PROFILEREAD" && . /etc/profile || true


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
export LC_MEASUREMENT="en_DE.UTF-8"
export LC_MONETARY="en_DE.UTF-8"
export LC_PAPER="en_DE.UTF-8"
export LC_TELEPHONE="en_DE.UTF-8"
export LC_TIME="en_DE.UTF-8"

# Stfu perl:
export PERL_BADLANG=0

# Path:
# shellcheck source=/dev/null
source ~/.paths

# Aliases:
# shellcheck source=/dev/null
source ~/.aliases
