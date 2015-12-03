#!/bin/zsh -f
# open Relay Live
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2015-09-21

 

NAME="$0:t:r"


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


	*Chat\ Room*)
		if [ -d '/Applications/Textual 5.app' ]
		then
			open -a 'Textual 5'
		else
			open 'http://webchat.freenode.net/?channels=relayfm&uio=d4'
		fi

	;;

	"Listen Live in VLC")

		
		if [[ "`pgrep -x VLC`" == "" ]]
		then
				open    -a VLC 'http://amp.relay.fm:8000/stream'
s		else
				open -n -a VLC 'http://amp.relay.fm:8000/stream'
		fi

		exit 0
	;;


	"Listen Live"|"Listen Live in Browser")

		open 'http://www.relay.fm/live'

		exit 0
	;;

	"Currently Off The Air"|"View Schedule of Live Shows"|*)

		open 'http://www.relay.fm/schedule'

		exit 0
	;;

esac


exit 0
#
#EOF
