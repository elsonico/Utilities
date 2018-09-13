#!/bin/bash

CURRENTDIR=`pwd`
TICKETNRO=1234
MEMBERID=12345
MEMBERNAME='Member Name'

echo -e "connect to ethoca~\n" > $CURRENTDIR/PROD-${TICKETNRO}-2.sql
echo -e "connect to ethoca~\n" > $CURRENTDIR/PROD-${TICKETNRO}-3.sql
echo -e "connect to ethoca~\n" > $CURRENTDIR/PROD-${TICKETNRO}-4.sql
echo -e "connect to ethoca~\n" > $CURRENTDIR/PROD-${TICKETNRO}-1_rollback.sql
echo -e "connect to ethoca~\n" > $CURRENTDIR/PROD-${TICKETNRO}-2_rollback.sql
echo -e "connect to ethoca~\n" > $CURRENTDIR/PROD-${TICKETNRO}-4_rollback.sql

db2 +o connect to ethoca > /dev/null 2>&1

db2 +o -z $CURRENTDIR/PROD-${TICKETNRO}-2.sql -x > /dev/null 2>&1 << EOF
select distinct 'CALL datasteward.sp_manage_user_role(''REMOVE'', ''' || trim(u.username) || ''', ''' ||  trim(rr.name) || ''', ''YES'', ''PROD-${TICKETNRO}'')~'\
  from db2user.user u,\
       db2user.member m,\
       db2user.user_role r,\
       db2user.role rr\
  where u.member_id = m.id and\
        u.member_id = ${MEMBERID} and\
        r.user_id = u.id and\
        rr.name in('FraudReporter-Alerts','FraudReporter-Operator')\
  for read only with UR
EOF

db2 +o -z $CURRENTDIR/PROD-${TICKETNRO}-3.sql -x > /dev/null 2>&1 << EOF
select distinct 'CALL datasteward.datasteward.sp_manage_user_ldap(''ADD'', ''' || trim(u.username) || ''', ''YES'', ''PROD-${TICKETNRO}'')~'\
  from db2user.user u,\
       db2user.member m,\
       db2user.user_role r,\
       db2user.role rr\
  where u.member_id = m.id and\
        u.member_id = ${MEMBERID} and\
        r.user_id = u.id and\
        rr.name in('FraudReporter-Alerts','FraudReporter-Operator')\
  for read only with UR
EOF

db2 terminate > /dev/null 2>&1

cat PROD-${TICKETNRO}-2.sql | sed "s/FraudReporter-Alerts/Merchant-Alerts/g" | sed "s/FraudReporter-Operator/Merchant-Issuer\ Alert Reports/g" | sed "s/REMOVE/ADD/g " >> PROD-${TICKETNRO}-1.sql

echo -e "CALL datasteward.sp_manage_member_ldap('ADD', ${MEMBERID}, '${MEMBERNAME}', 'YES', 'PROD-${TICKETNRO}')~" >> PROD-${TICKETNRO}-4.sql

sed "s/REMOVE/ADD/g" < $CURRENTDIR/PROD-${TICKETNRO}-2.sql > $CURRENTDIR/PROD-${TICKETNRO}-1_rollback.sql
sed "s/ADD/REMOVE/g" < $CURRENTDIR/PROD-${TICKETNRO}-1.sql > $CURRENTDIR/PROD-${TICKETNRO}-2_rollback.sql
sed "s/ADD/REMOVE/g" < $CURRENTDIR/PROD-${TICKETNRO}-3.sql > $CURRENTDIR/PROD-${TICKETNRO}-3_rollback.sql
sed "s/ADD/REMOVE/g" < $CURRENTDIR/PROD-${TICKETNRO}-4.sql > $CURRENTDIR/PROD-${TICKETNRO}-4_rollback.sql


echo -e "\ncommit~\nterminate~" >> $CURRENTDIR/PROD-${TICKETNRO}-1.sql
echo -e "\ncommit~\nterminate~" >> $CURRENTDIR/PROD-${TICKETNRO}-2.sql
echo -e "\ncommit~\nterminate~" >> $CURRENTDIR/PROD-${TICKETNRO}-3.sql
echo -e "\ncommit~\nterminate~" >> $CURRENTDIR/PROD-${TICKETNRO}-4.sql
echo -e "\ncommit~\nterminate~" >> $CURRENTDIR/PROD-${TICKETNRO}-1_rollback.sql
echo -e "\ncommit~\nterminate~" >> $CURRENTDIR/PROD-${TICKETNRO}-2_rollback.sql
echo -e "\ncommit~\nterminate~" >> $CURRENTDIR/PROD-${TICKETNRO}-3_rollback.sql
echo -e "\ncommit~\nterminate~" >> $CURRENTDIR/PROD-${TICKETNRO}-4_rollback.sql
