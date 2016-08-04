#!/bin/bash

##############################################################
#
# Generating sof links files from  MythTV format.
#
# Tested with MythTV 0.26 by tav@iki.fi
#
##############################################################

if ! [ $# -eq 0 ]
  then echo "Usage: $0" ; exit 1
fi

DBNAME=mythconverg
DBUSER=mythtv
DBPASSWD=********
STORAGEDIR="/var/lib/mythtv/recordings"

for fullname in `ls $STORAGEDIR/*.mpg`
  do 
    TESTRUN=FALSE
    fname=`basename $fullname`

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
VIDEODIR="/nfs/TVShows"
MOVIEDIR=$VIDEODIR/$titlename

if  [[ $season = [0-9] ]]
  then season=0${season}
fi

if  [[ $episode = [0-9] ]]
  then episode=0${episode}
fi


if  [ $season = "00" ]
 then
   if [ "$subtitlename" = '' ]
     then LINKNAME=${titlename}-${starttime}.mkv
     else LINKNAME=${titlename}-${subtitlename}.mkv
   fi
  else LINKNAME=${titlename}.S${season}E${episode}.mkv
fi

if  [ $season = "00" ]
 then
   if [ "$subtitlename" = '' ]
     then LINKNAME=${titlename}-${starttime}.mpg
     else LINKNAME=${titlename}-${subtitlename}.mpg
   fi
  else LINKNAME=${titlename}.S${season}E${episode}.mpg
fi

# If MOVIEDIR does not exist, let's create one
if ! [ -d $MOVIEDIR ]
  then mkdir $MOVIEDIR
fi

CURDIR=`pwd`

# ------------------------------------------------------------
# Create the links
# ------------------------------------------------------------

cd $MOVIEDIR

if [ $TESTRUN = "false" ]
  then ln -s ../../Recordings/$fname $LINKNAME
  else ln -s ../../Recordings/$fname $LINKNAME
fi
cd $CURDIR
done
