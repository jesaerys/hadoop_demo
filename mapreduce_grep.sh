#! /usr/bin/env bash


# Use Hadoop/MapReduce to grep for all words containing the substring "am" in
# five paragraphs of Lorem Ipsum.
#
# The actual MapReduce grepping task is performed by premade Java code (a jar
# file) from the example library packaged with Hadoop. Adapted from
# http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html.
#
# Output files are placed in $HOME/hadoop_tmp/output. The contents of the main
# output file (part-r-00000) should be,
#
#   11	amet
#   4	diam
#   4	Vivamus
#   3	Aliquam
#   2	ullamcorper
#   2	Nullam
#   2	Etiam
#   1	quam
#   1	aliquam
#   1	Nam


HADOOP_DIR=/usr/local/Cellar/hadoop/2.6.0


# Create a Hadoop distributed file system (HDFS) at the location indicated by
# the hadoop.tmp.dir parameter in core-site.xml. First make sure that no
# cluster processes are currently running, then clear all contents of the HDFS
# directory if it already exists and create it if it doesn't.
$HADOOP_DIR/sbin/stop-dfs.sh
HDFS_DIR="$(hdfs getconf -confKey hadoop.tmp.dir)"
if [[ -e $HDFS_DIR ]]; then
    rm -rf $HDFS_DIR
fi
mkdir -p $HDFS
hdfs namenode -format


# Start the single-node cluster. This script will start the SecondaryNameNode,
# NameNode, and DataNode processes (use the jps command to check). HDFS
# operations only work when the cluster is running.
$HADOOP_DIR/sbin/start-dfs.sh


# Create the input data directory on the HDFS and copy fresh data into it.
# Designate /data as the HDFS input data location.
hdfs dfs -mkdir -p /data
hdfs dfs -put test_data/*.txt /data/

# Note: The HDFS is its own file system, so directories created within it have
# no corresponding entity in the local file system. The contents of the HDFS
# are shown using the special ``hdfs dfs -ls`` command rather than with the
# standard ``cd`` and ``ls`` commands. For example, ``hdfs dfs -ls -R /`` will
# return a recursive listing for the whole HDFS.
#
# Note: MapReduce will automatically create /user and /user/<username> on the
# HDFS. Both directories can be ignored for this example.


# Grep the input data for the given pattern. Designate /results as the
# (automatically created) location for the output.
EXAMPLE_DIR=$HADOOP_DIR/libexec/share/hadoop/mapreduce
EXAMPLE_NAME=hadoop-mapreduce-examples-2.6.0.jar
EXAMPLE_PATH=$EXAMPLE_DIR/$EXAMPLE_NAME
INPUT_DIR=/data
OUTPUT_DIR=/results
PATTERN='[a-zA-Z]*am[a-zA-Z]*'
hadoop jar $EXAMPLE_PATH grep $INPUT_DIR $OUTPUT_DIR $PATTERN


# Copy the results to the local file system for safe keeping
LOCAL_OUTPUT_DIR=$HOME/hadoop_tmp/output
if [[ -e $LOCAL_OUTPUT_DIR ]]; then
    rm -rf $LOCAL_OUTPUT_DIR
fi
mkdir -p $LOCAL_OUTPUT_DIR
hdfs dfs -get $OUTPUT_DIR/* $LOCAL_OUTPUT_DIR


# Stop the single-node cluster
$HADOOP_DIR/sbin/stop-dfs.sh
