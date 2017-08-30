#!/bin/bash

# Purpose of this script is to extract data from source
# Netezza appliance to different destination Netezza appliance.
#
# For example from Netezza PROD to Netezza DEV.
#
#  AUTHOR: Tapio Vaattanen
#  RELEASE HISTORY:
#         2017/08/17: tvaattanen: Release 0.2

# If you want to truncate destination tables before load set to "yes"
TRUNCATE="no"

# Source Netezza settings: MUST BE CHANGED!!!
SRC_NZ_USER=admin
SRC_NZ_PASSWORD=password
SRC_NZ_HOST=production.example.com
SRC_NZ_DATABASE=DB1

# Destination Netezza settings: MUST BE CHANGED!!!
DST_NZ_USER=admin
DST_NZ_PASSWORD=password
DST_NZ_HOST=dev.example.com
DST_NZ_DATABASE=DB2

# Specify tablenames separated by space.
TABLES="TMP_COLLECTOR_KEY_LKP"

# There should be no need to edit below settings
NZ_SRC_OPTS="-u $SRC_NZ_USER -pw $SRC_NZ_PASSWORD -host $SRC_NZ_HOST -db \
                     $SRC_NZ_DATABASE"
NZ_DST_OPTS="-u $DST_NZ_USER -pw $DST_NZ_PASSWORD -host $DST_NZ_HOST -db \
                     $DST_NZ_DATABASE"

for TABLENAME in $TABLES
do
   mkfifo /tmp/${TABLENAME}.fifo
   nzsql $NZ_SRC_OPTS -Aqt -o /tmp/${TABLENAME}.fifo -c \
	  "select * from ${TABLENAME};" &
  if [ $TRUNCATE == "yes" ] ; then
     nzsql $NZ_DST_OPTS -e -c "TRUNCATE TABLE ${TABLENAME};"
  fi
   nzload $NZ_DST_OPTS -df /tmp/${TABLENAME}.fifo -delim '|' \
	  -t ${TABLENAME}
   rm -f /tmp/${TABLENAME}.fifo
done
