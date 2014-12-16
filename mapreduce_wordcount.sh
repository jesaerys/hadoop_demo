#! /usr/bin/env bash


# Use Hadoop/MapReduce to count the number of occurrences of all words in five
# paragraphs of Lorem Ipsum.
#
# The actual MapReduce word counting task is performed by premade Java code (a
# jar file) from the example library packaged with Hadoop.
#
# Output files are placed in $HOME/hadoop_tmp/output. The first ten lines of
# the main output file (part-r-00000) should be,
#
#   Aenean	3
#   Aliquam	3
#   Cras	2
#   Curabitur	1
#   Donec	7
#   Duis	1
#   Etiam	2
#   Fusce	3
#   In	2
#   Integer	3


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
hdfs dfs -put test_data/*.txt /data/


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
