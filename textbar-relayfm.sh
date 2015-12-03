#!/bin/zsh -f
# Purpose:
#
# From:	Tj Luo.ma
# Mail:	luomat at gmail dot com
# Web: 	http://RhymesWithDiploma.com
# Date:	2015-09-21

if [ -e "$HOME/.path" ]
then
	source "$HOME/.path"
else
	PATH=/usr/local/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin
fi

NAME="$0:t:r"

PREVIOUS_LIVE_STATUS_FILE="$HOME/.$NAME.live.status.txt"

[[ ! -e "$PREVIOUS_LIVE_STATUS_FILE" ]] && touch "$PREVIOUS_LIVE_STATUS_FILE"

TEMPFILE="${TMPDIR-/tmp}/${NAME}.${TIME}.$$.$RANDOM"

curl -sfL 'http://www.relay.fm/live' > "${TEMPFILE}"

if [[ ! -s "$TEMPFILE" ]]
then
	# echo 'Relay Status Unknown'
	sleep 5
	exec "$0"
	exit 0
fi

fgrep -iq '<h2>Not Currently Live</h2>' "$TEMPFILE"

EXIT="$?"

if [ "$EXIT" = "0" ]
then


echo "
Currently Off The Air

"

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		BEGIN - Get Next Show
#

	FILE="${TMPDIR-/tmp/}relayfm.$RANDOM.html"

	PREVIOUS="${TMPDIR-/tmp/}relayfm.previous.html"

	CURRENT_TIMEZONE=`date +%Z`

	CALENDAR_URL_HTML="https://www.google.com/calendar/htmlembed?showTitle=0&showPrint=0&showTabs=0&showCalendars=0&mode=AGENDA&height=600&wkst=1&bgcolor=%23FFFFFF&src=relay.fm_t9pnsv6j91a3ra7o8l13cb9q3o@group.calendar.google.com&color=%23182C57&ctz=$CURRENT_TIMEZONE"

	# get the whole HTML, and reformat it with `tidy` and save it to a local file we can parse
	curl -sfL "$CALENDAR_URL_HTML" \
	| tidy \
		--char-encoding utf8 \
		--wrap 0 \
		--show-errors 0 \
		--indent yes \
		--input-xml no \
		--output-xml no \
		--quote-nbsp no \
		--show-warnings no \
		--uppercase-attributes no \
		--uppercase-tags no \
		--clean yes \
		--force-output yes \
		--join-classes yes \
		--join-styles yes \
		--markup yes \
		--output-xhtml yes \
		--quiet yes \
		--quote-ampersand yes \
		--quote-marks yes > "$FILE"

	# if the file is not longer than 0 bytes, we didn't get the info we need
	# so re-use the previous info
	if [[ ! -s "$FILE" ]]
	then

		if [ -s "$PREVIOUS" ]
		then
			# if a previous file exists, use it
			# take the first line
			# but truncate it after 50 characters
			# just in case it's full of junk
			head -1 "$PREVIOUS" | colrm 50-

			exit 0

		else
			# if a previous file doesn't exist
			# or is 0 bytes, just give an error
			echo "Relay FM Error"

			exit 0
		fi
	fi

	# look for the 'event-summary' as a span (important!) and then take the first one, and remove the HTML
	SHOW_TITLE=`fgrep -A1 '<span class="event-summary">' "$FILE" | head -1 | sed 's#</span></a>##; s#.*>##g'`

	# Make an ARRAY out of the date info
	# we get something like
	#           Fri May 1, 2015
	# but we only _need_ the Month and DayOfMonth
	# and strip any leading spaces or tabs
	SHOW_DATE=($(fgrep -A1 '<div class="date">' "$FILE" | head -2 | tail -1 | sed 's#^[     ]*##g'))

	# Get the time and strip any leading spaces or tabs
	SHOW_TIME=`fgrep -A1 '<td class="event-time">' "$FILE" | head -2 | tail -1 | sed 's#^[     ]*##g'`

	# This will give us the month as letters.
	MONTH="${SHOW_DATE[2]}"

	# Get the number, remove the comma
	DAY_OF_MONTH=`echo "${SHOW_DATE[3]}" | tr -d ','`

	# now get today's month/date (strip leading zeros from the day)
	TODAYS_DATE=`date '+%b %d' | sed 's# 0*# #g'`

	if [[ "$TODAYS_DATE" == "$MONTH $DAY_OF_MONTH" ]]
	then
		# The next show is today, just show time
		echo "Next: $SHOW_TITLE ($SHOW_TIME)" | tee "$PREVIOUS"

	else
		# Output the show title, month/day @ time)
		echo "Next: $SHOW_TITLE ($MONTH $DAY_OF_MONTH @ $SHOW_TIME)" | tee "$PREVIOUS"
	fi



######################## END - Get Next Show ######################## 
#####################################################################  



echo off > "$PREVIOUS_LIVE_STATUS_FILE"


else

	## There _IS_ a live show

	SHOW_TITLE_RAW=`curl -sfL 'http://www.relay.fm/live' | fgrep -i '<title' `

	SHOW_TITLE_CLEAN=`echo "${SHOW_TITLE_RAW}" | sed 's#<title>On-Air: ##g ; s# - Relay FM</title>##g'`

	PREVIOUS_LIVE_STATUS=`head -1 "$PREVIOUS_LIVE_STATUS_FILE"`

	if [[ "$PREVIOUS_LIVE_STATUS" != "live" ]]
	then

		if (( $+commands[growlnotify])) && (pgrep -qx Growl)
		then
			afplay /System/Library/Sounds/Glass.aiff >/dev/null

			growlnotify \
			--sticky \
			--image "$HOME/Pictures/Icons/RelayFM/RelayFM-logo-growl.png" \
			--identifier "$NAME" \
			--message "Click to listen" \
			--url "http://www.relay.fm/live" \
			--title "$SHOW_TITLE_CLEAN is live"
		fi

		echo "live" > "$PREVIOUS_LIVE_STATUS_FILE"
	fi

	if [ -d '/Applications/VLC.app' ]
	then
		echo "$SHOW_TITLE_CLEAN\nListen Live in Browser\nListen Live in VLC\n---\nOpen Chat Room"
	else
		echo "$SHOW_TITLE_CLEAN\nListen Live\n---\nOpen Chat Room"
	fi

fi


echo '
View Schedule of Live Shows
Go to Relay FM Website
---
Analog
B-Sides
Bonanza
Clockwise
Connected
Cortex
Inquisitive
Isometric
Less Than or Equal
Liftoff
Mac Power Users
Material
Reconcilable Differences
Rocket
Pen Addict
Thoroughly Considered
Top Four
Under the Radar
Upgrade
Virtual
'

exit 0



## This seems to 'work' even when it shouldn't. So that's no good.
# http://amp.relay.fm:8000/stream
# /usr/bin/nc -d -z amp.relay.fm 8000 2>&1 ) >/dev/null

# curl -sfL --max-time 5 -o /dev/null http://amp.relay.fm:8000/stream
# = exit code 28

#
#EOF
