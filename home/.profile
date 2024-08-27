# Sample .profile for SUSE Linux
# rewritten by Christian Steinruecken <cstein@suse.de>
#
# This file is read each time a login shell is started.
# All other interactive shells will only read .bashrc; this is particularly
# important for language settings, see below.

test -z "$PROFILEREAD" && . /etc/profile || true


# Variables:
export EDITOR=micro
export BROWSER=firefox

export GITMAN_REPOS_LOCATION=~/Git/

# Path:
export PATH="$PATH:"~/.nimble/bin/:~/Git/shell-utils/scripts

# Aliases:
# shellcheck source=/dev/null
source ~/.aliases
