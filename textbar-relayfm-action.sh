#!/bin/zsh -f
# Actions to take after a TextBar Relay.fm menu bar item has been clicked
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2015-10-27

if [ -e "$HOME/.path" ]
then
	source "$HOME/.path"
else
	PATH=/usr/local/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin
fi

NAME="$0:t:r"

VERSION='0.0.1'

SELF_URL='https://raw.githubusercontent.com/tjluoma/textbar-relayfm/master/textbar-relayfm-action.sh'

CURRENT_VERSION=`curl -sfL "$SELF_URL" | egrep '^VERSION='  | tr -dc '[0-9].'`

if [ "$CURRENT_VERSION" != "$VERSION" ]
then
	echo "$NAME: Not up to date"
else
	echo "$NAME: Up To Date"

fi


exit 0
#
#EOF

