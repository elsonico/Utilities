#!/bin/bash

# *********************************** #
# Scipt to test Shard with MongoDB    #
#                                     #
# on single server environment.
#                                     #
# *********************************** #

BASDIR=/home/tav/mycluster
LOG=$BASDIR/process.txt
MONGOHOST=quelimane

# Start config servers

for i in {0..2}
        do
                if ! [ -d cfg${i} ]
                        then
                                mkdir cfg${i}
				echo mongod --configsvr --dbpath cfg${i} --port 2605$i --fork --logpath log.cfg${i} --logappend
				mongod --configsvr --dbpath cfg${i} --port 2605$i --fork --logpath log.cfg${i} --logappend >> $LOG
                        else
                                echo "Directory cfg${i} exists, skipping..."
                fi
done

# Start the mongods

for i in {a,b,c,d}
	do
		case $i in
			[a]*)
			k=0
			;;
			[b]*)
			k=1
			;;
			[c]*)
			k=2
			;;
			[d]*)
			k=3
			;;
		esac
		for j in {0..2}
			do
				if ! [ -d $i$j ]
					then 
						mkdir $i$j
						echo mongod --shardsvr --replSet $i --dbpath $i$j --logpath log.$i$j --port 27${k}0${j} --fork --logappend --smallfiles --oplogSize 50
						mongod --shardsvr --replSet $i --dbpath $i$j --logpath log.$i$j --port 27${k}0${j} --fork --logappend --smallfiles --oplogSize 50 >> $LOG
					else
						echo "Directory $i$j exist, skipping..."
				fi
			
	done
done


# Start mongoss

echo mongos --configdb $MONGOHOST:26050,$MONGOHOST:26051,$MONGOHOST:26052 --fork --logappend --logpath log.mongos0
mongos --configdb $MONGOHOST:26050,$MONGOHOST:26051,$MONGOHOST:26052 --fork --logappend --logpath log.mongos0 >> $LOG

for i in {1..3}
	do
		echo mongos --configdb $MONGOHOST:26050,$MONGOHOST:26051,$MONGOHOST:26052 --fork --logappend --logpath log.mongos${i} --port 2606${i}
		mongos --configdb $MONGOHOST:26050,$MONGOHOST:26051,$MONGOHOST:26052 --fork --logappend --logpath log.mongos0 --port 2606${i} >> $LOG
done
