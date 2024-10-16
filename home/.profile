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
export BROWSER=firefox

export GITMAN_REPOS_LOCATION=~/Git/
export NIM_DOCS_DIRECTORY=~/Git/nirokay.github.io/nim-docs/

# Path:
# shellcheck source=/dev/null
source ~/.paths

# Aliases:
# shellcheck source=/dev/null
source ~/.aliases
