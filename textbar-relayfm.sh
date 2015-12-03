#!/bin/zsh -f
# Purpose: This script is meant to be used with [TextBar](http://www.richsomerfield.com/apps/) and create a drop-down menu of text which can be sent to 'textbar-relayfm-action.sh'
#
# From:	Tj Luo.ma
# Mail:	luomat at gmail dot com
# Web: 	http://RhymesWithDiploma.com
# Date:	2015-09-21


PATH=/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin

if [ -e "$HOME/.path" ]
then
		# if the user has a file in their ~/ which defines the path, use it 
	source "$HOME/.path"
elif [ -d /usr/local/scripts ]
then
		# if /usr/local/scripts exists, add it to $PATH
	PATH=/usr/local/scripts:$PATH
fi

NAME="$0:t:r"

	# When this script runs, it will be helpful to know whether or not Relay.FM previously was "live" on the air 
	# or if that has just happened in the interim. Therefore, we keep track of the status so we can refer to it
	# on subsequent invocations 
PREVIOUS_LIVE_STATUS_FILE="$HOME/.$NAME.live.status.txt"

	# if the file doesn't exist, `touch` it 
[[ ! -e "$PREVIOUS_LIVE_STATUS_FILE" ]] && touch "$PREVIOUS_LIVE_STATUS_FILE"

	# We're going to dump the HTML of 'http://www.relay.fm/live' to a local file so we can process that 
	# rather than have to make multiple `curl` calls to the website
TEMPFILE="${TMPDIR-/tmp}/${NAME}.$$.$RANDOM"

	# save HTML of the website to temp file 
curl -sfL 'http://www.relay.fm/live' > "${TEMPFILE}"

	# if the temp file is zero bytes, something went wrong
	# so wait 5 seconds and try again 
	# (This most often happens when a Mac wakes from sleep and the script runs before
	# there is an active network connection.)
if [[ ! -s "$TEMPFILE" ]]
then
	# echo 'Relay Status Unknown'
	sleep 5
	exec "$0"
	exit 0
fi

	# This is NOT a fool-proof test, but it works 99% of the time 
	# If the text '<h2>Not Currently Live</h2>' if found in the HTML of the page
	# then there is no live show currently on the air 
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

## Basically this whole section is an ugly hack. We want to be able to 
## display WHEN the next live show will be (if there is not currently one)
## BUT the only way to do that is to parse (read: scrape) the HTML version
## of Relay.FM’s Google Calendar.
##
## There are several problems with this:
## 		1. If the calendar isn't up-to-date due to "human error" then obviously the info will be bad.
##
## 		2. Sometimes changes are made to the Fancy JavaScript version of the Google Calendar page 
## 			but those changes do NOT show up in the basic/Non-JS HTML version that we are parsing.
##			This seems to be a bug with Google Calendar which goes largely unnoticed because 
## 			who doesn't use a JavaScript enabled browser when reading Google Calendar?!
##
##	Those two problems cannot be overcome with scripting.
## 
## HOWEVER, there is currently an additional problem, which I do not know how to fix yet.
##
## Consider this scenario: It's Wednesday and there are two live shows planned: one at 12noon and one at 7pm (US/Eastern)
##
## This code will correctly show the 12noon show before 12noon, but after the show ends, the already-aired show still
## appears as 'next' until some unspecified time later when Google decides to update the HTML version 
## of the Google Calendar page to drop the older entry.
##
## Fixing this would have to involve checking the scheduled time of the "next" show and making sure it isn't in the past 
## and, if it is, continuing to parse/scrape the file until the next show is found 
## BUT then there's the case where the calendar says that a show will start at 12noon and it doesn't actually start 
## until, say, 12:10pm or 12:15pm. So that would have to be taken into consideration as well.
## because if this script runs at 12:05pm and says "There's no live show and the next live show is at 7pm" 
## that's not good either.
## 
## PERHAPS the “best” option is to show ALL live shows which are scheduled for TODAY 
## regardless of whether or not the time for one of them has passed
## OR if none is found, then show ALL live shows for the next day any are found 
##
## Suffice it to say: this part of the script will need more work.

		# This is where we can store the `tidy`-ed HTML page 
	FILE="${TMPDIR-/tmp/}relayfm.calendar.$RANDOM.html"

		# This serves as a cache in case we don't get any new info from trying to connect to the calendar 
	PREVIOUS="${TMPDIR-/tmp/}relayfm.previous.html"

		# Get the user's current time zone. HOPEFULLY this will mean that show times will display in the user's 
		# local time zone, even if they are not in the One True Time Zone (US/Eastern, of course)
	CURRENT_TIMEZONE=`date +%Z`

	## This is the URL of the plain HTML version of the Google Calendar 
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

	## TODO - Make sure that the SHOW_DATE and SHOW_TIME are correct even if the user is not in the One True Time Zone 

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

	## if we get here, There _IS_ a live show


		# fetch the title of the currently-live show from the live show web page 
	SHOW_TITLE_RAW=`curl -sfL 'http://www.relay.fm/live' | fgrep -i '<title' `

		# Remove some extra text from the show title 
		# namely the word "On-Air" and 
	SHOW_TITLE_CLEAN=`echo "${SHOW_TITLE_RAW}" | sed 's#<title>On-Air: ##g ; s# - Relay FM</title>##g'`

		## CHECK to see what the previous status was.
		## If there is a live show, did it just come on 
		## 		or was it already on last time we checked? 
		## Because if it is the former, 
		## 		we should make sure to alert the user with a sound
		##		and Growl notification (if Growl is running and growlnotify is installed)
	PREVIOUS_LIVE_STATUS=`head -1 "$PREVIOUS_LIVE_STATUS_FILE"`

	if [[ "$PREVIOUS_LIVE_STATUS" != "live" ]]
	then
			## IF we get here, then there is a live show
			## AND there was NOT a live show last time we checked 
			
			# Play a sound -- obviously this only works if the 
			# sound isn't muted 
		afplay /System/Library/Sounds/Glass.aiff >/dev/null

			# If the user has the growlnotify command in their $PATH and 
			# Growl is running, use growlnotify to tell them 
			#
		if (( $+commands[growlnotify])) && (pgrep -qx Growl)
		then
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

	if [ -d '/Applications/VLC.app' -o -d "$HOME/Applications/VLC.app" ]
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

#
#EOF
