echo "dropping old keyspace..."
docker exec -it cassandra-node cqlsh -e "DROP KEYSPACE a2_keyspace;"
echo "creating new keyspace and table..."
docker exec -it cassandra-node cqlsh -e "CREATE KEYSPACE a2_keyspace WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 2}; CREATE TABLE a2_keyspace.urls(short text PRIMARY KEY, long text);"
