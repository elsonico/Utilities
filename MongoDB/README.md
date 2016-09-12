<p>Once replicasets are created and shards added you should see something like:</p?

mongos> db.shards.find()<br>
{ "_id" : "a", "host" : "a/quelimane:27000,quelimane:27001,quelimane:27002" }<br>
{ "_id" : "b", "host" : "b/quelimane:27100,quelimane:27101,quelimane:27102" }<br>
{ "_id" : "c", "host" : "c/quelimane:27200,quelimane:27201,quelimane:27202" }<br>
{ "_id" : "d", "host" : "d/quelimane:27300,quelimane:27301,quelimane:27302" }<

