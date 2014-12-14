#! /usr/bin/env bash


# Use Hadoop/MapReduce to count the number of occurrences of all words in the
# first paragraph of Lorem Ipsum.
#
# The actual MapReduce word counting task is performed by premade Java code (a
# jar file) from the example library packaged with Hadoop.
#
# Output files are placed in $HOME/hadoop_tmp/output. The contents of the main
# output file (part-r-00000) should be,
#
#   Aenean	1
#   Cum	1
#   Curabitur	1
#   Donec	1
#   Duis	1
#   In	2
#   Integer	1
#   Lorem	1
#   Mauris	1
#   Nullam	1
#   Nunc	1
#   Praesent	1
#   Sed	2
#   Ut	1
#   a	1
#   adipiscing	1
#   amet	4
#   amet,	1
#   amet.	1
#   at	1
#   auctor	1
#   augue,	1
#   blandit	2
#   consectetur	1
#   consequat	1
#   dapibus	1
#   diam,	1
#   dictum	2
#   dictum,	1
#   dis	1
#   dolor	1
#   dui	1
#   elementum	1
#   elit	1
#   elit.	1
#   enim	1
#   est	1
#   et	3
#   et,	1
#   et.	1
#   eu	2
#   eu,	1
#   felis	1
#   finibus,	1
#   gravida	1
#   gravida,	1
#   gravida.	1
#   iaculis	1
#   id	2
#   imperdiet	3
#   in	1
#   ipsum	1
#   lectus.	1
#   leo.	1
#   libero	3
#   lobortis	1
#   lorem.	1
#   magnis	1
#   malesuada	2
#   mauris	2
#   maximus	2
#   metus	1
#   montes,	1
#   mus.	1
#   nascetur	1
#   natoque	1
#   nisi	3
#   nisi,	1
#   non	1
#   non,	1
#   nulla	1
#   nunc	1
#   odio,	1
#   parturient	1
#   pellentesque	1
#   penatibus	1
#   pretium	1
#   pulvinar	2
#   purus,	1
#   quam	2
#   quis	3
#   ridiculus	1
#   risus	1
#   rutrum	1
#   sapien,	1
#   sapien.	1
#   scelerisque	1
#   sem	1
#   sem.	1
#   sit	6
#   sociis	1
#   sodales	1
#   sollicitudin	1
#   suscipit	2
#   tellus	2
#   tempor	1
#   tempus	1
#   tincidunt	1
#   tortor	1
#   turpis	1
#   turpis,	1
#   turpis.	2
#   ullamcorper	1
#   ultrices,	1
#   ultricies	1
#   ultricies.	1
#   urna	1
#   urna,	2
#   ut	1
#   varius.	1
#   vehicula	1
#   vel	3
#   vestibulum	1
#   vestibulum.	2
#   vitae	2


HADOOP_DIR=/usr/local/Cellar/hadoop/2.6.0


# Create a Hadoop distributed file system (HDFS)
$HADOOP_DIR/sbin/stop-dfs.sh
HDFS_DIR="$(hdfs getconf -confKey hadoop.tmp.dir)"
if [[ -e $HDFS_DIR ]]; then
    rm -rf $HDFS_DIR
fi
mkdir -p $HDFS
hdfs namenode -format


# Start the cluster and copy the data to the HDFS
$HADOOP_DIR/sbin/start-dfs.sh
hdfs dfs -mkdir -p /data
hdfs dfs -put lorem_ipsum.txt /data/


# Perform the word count
EXAMPLE_DIR=$HADOOP_DIR/libexec/share/hadoop/mapreduce
EXAMPLE_NAME=hadoop-mapreduce-examples-2.6.0.jar
EXAMPLE_PATH=$EXAMPLE_DIR/$EXAMPLE_NAME
INPUT_DIR=/data
OUTPUT_DIR=/results
hadoop jar $EXAMPLE_PATH wordcount $INPUT_DIR $OUTPUT_DIR


# Copy the results and stop the cluster
LOCAL_OUTPUT_DIR=$HOME/hadoop_tmp/output
if [[ -e $LOCAL_OUTPUT_DIR ]]; then
    rm -rf $LOCAL_OUTPUT_DIR
fi
mkdir -p $LOCAL_OUTPUT_DIR
hdfs dfs -get $OUTPUT_DIR/* $LOCAL_OUTPUT_DIR
$HADOOP_DIR/sbin/stop-dfs.sh
