#!/bin/zsh -f
# Purpose: This script is meant to be used with [TextBar](http://www.richsomerfield.com/apps/) as an 'action' script complement to 'textbar-relay.sh'
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
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
 
##
## The `case` statement is meant to cover all of the possibilities of text we could be sent from the 'textbar-relay.sh' script
## If there are spaces in the items, they either need to be \escaped\ or "quoted"
## 

case "$TEXTBAR_TEXT" in
	"Go to Relay FM Website")
		open 'http://www.relay.fm'

		exit 0
	;;


	*Analog*)
		open 'http://www.relay.fm/analogue'

		exit 0
	;;


	*B-Sides*)
		open 'http://www.relay.fm/b-sides'

		exit 0
	;;


	*Bonanza*)
		open 'http://www.relay.fm/bonanza'

		exit 0
	;;


	*Clockwise*)
		open 'http://www.relay.fm/clockwise'

		exit 0
	;;


	*Connected*)
		open 'http://www.relay.fm/connected'

		exit 0
	;;


	*Cortex*)
		open 'http://www.relay.fm/cortex'

		exit 0
	;;


	*Inquisitive*)
		open 'http://www.relay.fm/inquisitive'

		exit 0
	;;


	*Isometric*)
		open 'http://www.relay.fm/isometric'

		exit 0
	;;


	*Less\ Than\ or\ Equal*)
		open 'http://www.relay.fm/ltoe'

		exit 0
	;;


	*Liftoff*)
		open 'http://www.relay.fm/liftoff'

		exit 0
	;;


	*Mac\ Power\ Users*|*MPU*)
		open 'http://www.relay.fm/mpu'

		exit 0
	;;


	*Material*)
		open 'http://www.relay.fm/material'

		exit 0
	;;


	*Reconcilable\ Differences*)
		open 'http://www.relay.fm/rd'

		exit 0
	;;


	*Rocket*)
		open 'http://www.relay.fm/rocket'

		exit 0
	;;


	*Pen\ Addict*)
		open 'http://www.relay.fm/penaddict'

		exit 0
	;;


	*Thoroughly\ Considered*)
		open 'http://www.relay.fm/tc'

		exit 0
	;;


	*Top\ Four*)
		open 'http://www.relay.fm/topfour'

		exit 0
	;;

	*Under\ the\ Radar*)
		open 'http://www.relay.fm/radar'

		exit 0
	;;


	*Upgrade*)
		open 'http://www.relay.fm/upgrade'

		exit 0
	;;

	*Virtual*)
		open 'http://www.relay.fm/virtual'

		exit 0
	;;


	*"Open Chat Room"*)

			# When there is a live show, 'textbar-relay.sh' will offer the user the opportunity to open the (IRC) chat rooom
			# this can be done in several ways, but so far this script only covers two:
			# 	1) If the user has the 'Textual 5.app' installed, launch that
			# 	2) Otherwise, open the IRC channel in a web browser
			# other IRC clines could easily be added as 'elif' statements 
		if [ -d '/Applications/Textual 5.app' ]
		then
			open -a 'Textual 5'
		else
			open 'http://webchat.freenode.net/?channels=relayfm&uio=d4'
		fi

	;;

	"Listen Live in VLC")

			# Where there is a live show, the 'textbar-relay.sh' script will check to see if VLC is installed in 
			# /Applications or ~/Applications/ 
			# And if it is, the user will be given the opportunity to listen to the live-stream in VLC 
			#
			# IF VLC is already running, we will open a new instance of VLC (open -n -a)
			# otherwise, we just open VLC (open -a)
		
		if [[ "`pgrep -x VLC`" == "" ]]
		then
				open    -a VLC 'http://amp.relay.fm:8000/stream'
		else
				open -n -a VLC 'http://amp.relay.fm:8000/stream'
		fi

		exit 0
	;;


	"Listen Live"|"Listen Live in Browser")

			# If VLC is not installed, the user will be given the option to “Listen Live” 
			# If VLC is installed, the user will be given the VLC option (above)
			# AND a second option will be given to Listen Live in Browser 
			# because maybe they have VLC but don't want to use it to listen to the live show  
		open 'http://www.relay.fm/live'

		exit 0
	;;


		# This last option covers if the user selects a menu 
		# "Currently Off The Air"|
		# OR
		# "View Schedule of Live Shows"
		# or
		# ANYTHING ELSE (note the lone '*' at the end 
		#
		# Basically if we get some input and we aren't sure what to do with it
		# we will show them the schedule. Because it's better than doing nothing.
	"Currently Off The Air"|"View Schedule of Live Shows"|*)

		open 'http://www.relay.fm/schedule'

		exit 0
	;;

esac


exit 0
#
#EOF
