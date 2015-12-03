#!/bin/zsh -f

NAME="$0:t:r"

if [ -e "$HOME/.path" ]
then
source "$HOME/.path"
else
PATH=/usr/local/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin
fi


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
	--indent no \
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

zmodload zsh/datetime

TIME=`strftime "%Y-%m-%d--%H.%M.%S" "$EPOCHSECONDS"`

function timestamp { strftime "%Y-%m-%d--%H.%M.%S" "$EPOCHSECONDS" }

echo "$NAME: As of $TIME:\n"

cat "$FILE" \
| sed \
	-e '/date-section-1/,$d' \
	-e '1,/date-section-0/d' \
	-e 's#,# #g' \
| fgrep 'class="date"' \
| awk '{print $3" "$4}'

cat "$FILE" \
| sed \
	-e '/date-section-1/,$d' \
	-e '1,/date-section-0/d' \
| egrep 'class="event-time"|"event-link"' \
| tr '\012' ' ' \
| sed -e 's#</div> #\
#g' \
| sed \
	-e 's#<td class="event-time">##g' \
	-e 's#</td>.*<span class="event-summary"># #g' \
	-e 's#</span></a>##g'

echo '\n\n'


exit 0



exit 0
# EOF
