#!/bin/zsh -f
# a Relay.fm menu bar item for TextBar
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2015-10-27


# @NOTDONE @TODO

# Put a "Check for Updates" into menu
# Put a "Check for Updates" script into "Actions"

if [ -e "$HOME/.path" ]
then
	source "$HOME/.path"
else
	PATH=/usr/local/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin
fi

NAME="$0:t:r"

VERSION='0.0.1'

SELF_URL='https://raw.githubusercontent.com/tjluoma/textbar-relayfm/master/textbar-relayfm.sh'

CURRENT_VERSION=`curl -sfL "$SELF_URL" | egrep '^VERSION=' | tr -dc '[0-9].'`

echo "CURRENT_VERSION: $CURRENT_VERSION"

if [ "$CURRENT_VERSION" != "$VERSION" -a "$CURRENT_VERSION" != "" ]
then
	echo "$NAME: Not up to date"

		# Make a temporary directory
	TEMPDIR=`mktemp -q "${TMPDIR-/tmp}/${NAME}.XXXXXX`

		# cd into temporary directory
	cd "$TEMPDIR" || cd "$TMPDIR" || cd "/tmp"

	FILENAME="$SELF_URL:t"

	rm -f "$FILENAME"

	curl --silent --fail --location --remote-name "$SELF_URL"

	chmod 755 "$FILENAME"

	cp "$0" "$HOME/.Trash/$NAME.$VERSION.sh"
fi








exit 0
#
#EOF


