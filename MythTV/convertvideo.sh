#!/bin/bash

##############################################################
#
# Generating Matroska files from  MythTV format.
#
# Tested with MythTV 0.26 by tav@iki.fi
#
##############################################################

if ! [ $# -eq 1 ]
  then echo "Usage: $0 <filename.mpg>" ; exit 1
fi

TESTRUN=false
DBNAME=mythconverg
DBUSER=mythtv
DBPASSWD=*******
fname=$1

sql_starttime="select starttime from recorded where basename = '$fname';"
sql_title="select title from recorded where basename = '$fname';"
sql_subtitle="select subtitle from recorded where basename = '$fname';"
sql_chanid="select chanid from recorded where basename = '$fname';"
sql_season="select season from recorded where basename = '$fname';"
sql_episode="select episode from recorded where basename = '$fname';"

starttime=$(mysql -u$DBUSER -p$DBPASSWD $DBNAME -s -N <<QUERY_INPUT
    $sql_starttime
QUERY_INPUT
)
titlename=$(mysql -u$DBUSER -p$DBPASSWD $DBNAME -s -N <<QUERY_INPUT
    $sql_title
QUERY_INPUT
)
subtitlename=$(mysql -u$DBUSER -p$DBPASSWD $DBNAME -s -N <<QUERY_INPUT
    $sql_subtitle
QUERY_INPUT
)

chanid=$(mysql -u$DBUSER -p$DBPASSWD $DBNAME -s -N <<QUERY_INPUT
    $sql_chanid
QUERY_INPUT
)

season=$(mysql -u$DBUSER -p$DBPASSWD $DBNAME -s -N <<QUERY_INPUT
    $sql_season
QUERY_INPUT
)

episode=$(mysql -u$DBUSER -p$DBPASSWD $DBNAME -s -N <<QUERY_INPUT
    $sql_episode
QUERY_INPUT
)

timespec=$starttime
starttime=`echo $starttime | sed "s/\:/\./g" | sed "s/\ /\-/g"`
subtitlename=`echo $subtitlename | sed "s/\:/\./g" | sed "s/\ /\_/g" | sed "s/'//g" | sed "s/\!//g"`
titlename=`echo $titlename | sed "s/\:/\./g" | sed "s/\ /\_/g" | sed "s/'//g" | sed "s/\!//g"`


BASEVIDEONAME=`echo $1 | sed "s/\..*$//g"`
STORAGEDIR="/var/lib/mythtv/recordings"
VIDEODIR="/var/lib/mythtv/videos"
PROJECTX='/usr/bin/projectx'
INI='/home/tav/ProjectX/ProjectX.ini'
MKVMERGE=/usr/bin/mkvmerge
MOVIEDIR=$VIDEODIR/$titlename
TMPDIR=$MOVIEDIR/tmp
LOGDIR=$MOVIEDIR/log

if  [[ $season = [0-9] ]]
  then season=0${season}
fi

if  [[ $episode = [0-9] ]]
  then episode=0${episode}
fi


if  [ $season = "00" ]
 then
   if [ "$subtitlename" = '' ]
     then MKVNAME=${titlename}-${starttime}.mkv
     else MKVNAME=${titlename}-${subtitlename}.mkv
   fi
  else MKVNAME=${titlename}.S${season}E${episode}.mkv
fi


# If MOVIEDIR does not exist, let's create one
if ! [ -d $MOVIEDIR ]
  then mkdir $MOVIEDIR
fi

#Don't forget to create and use tmpdir!
if ! [ -d $TMPDIR ]
  then mkdir $TMPDIR
fi

if ! [ -d $LOGDIR ]
  then mkdir $LOGDIR
fi


cd $MOVIEDIR

# ------------------------------------------------------------
# Part 1 - Extract Closed Captions
# ------------------------------------------------------------
if [ $TESTRUN = "false" ]
  then ccextractor.pl $chanid "$timespec" $TMPDIR/$BASEVIDEONAME.srt > $LOGDIR/ccextractor.log 2>&1
  else echo ccextractor.pl $chanid \"$timespec\" $TMPDIR/$BASEVIDEONAME.srt
fi

# ------------------------------------------------------------
# Part 2 - De-multiplexing
# ------------------------------------------------------------

if [ $TESTRUN = "false" ]
  then $PROJECTX $STORAGEDIR/$fname -ini $INI -demux -out $TMPDIR > $LOGDIR/projectx.log 2>&1
  else echo $PROJECTX $STORAGEDIR/$fname -ini $INI -demux -out $TMPDIR
fi

# ------------------------------------------------------------
# Part 3 - Encoding
# ------------------------------------------------------------

if [ $TESTRUN = "false" ]
  then $MKVMERGE $TMPDIR/$BASEVIDEONAME.m2v $TMPDIR/$BASEVIDEONAME.ac3 $TMPDIR/$BASEVIDEONAME.srt -o $MOVIEDIR/$MKVNAME  > $LOGDIR/mkvmerge.log 2>&1
  else echo $MKVMERGE $TMPDIR/$BASEVIDEONAME.m2v $TMPDIR/$BASEVIDEONAME.ac3 $TMPDIR/$BASEVIDEONAME.srt -o $MOVIEDIR/$MKVNAME
fi

# ------------------------------------------------------------
# Part 4 - Clean up the mess, but leave log files  
# ------------------------------------------------------------

rm -rf  $TMPDIR
