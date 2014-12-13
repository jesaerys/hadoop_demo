README
======


Hadoop installation
-------------------
Steps for Mac OS 10.6.8.

(To improve visual separation between commands and output in the snippets
below, the bash promt and continuation lines are indicated by ``>>>`` and
``...``, respectively .)

1. Check Java version::

     >>> java -version
     java version "1.6.0_65"
     Java(TM) SE Runtime Environment (build 1.6.0_65-b14-462-10M4609)
     Java HotSpot(TM) 64-Bit Server VM (build 20.65-b04-462, mixed mode)

   According to http://wiki.apache.org/hadoop/HadoopJavaVersions, only versions
   1.6.0_16, 1.6.0_18, and 1.6.0_19 in the 1.6 series are reported to have
   problems, so I'll assume 1.6.0_65 will work.

2. Install hadoop via homebrew (make sure to update and upgrade first)::

     >>> brew update
     >>> brew upgrade
     >>> brew install hadoop
     ...
     In Hadoop's config file:
       /usr/local/Cellar/hadoop/2.6.0/libexec/etc/hadoop/hadoop-env.sh,
       /usr/local/Cellar/hadoop/2.6.0/libexec/etc/hadoop/mapred-env.sh and
       /usr/local/Cellar/hadoop/2.6.0/libexec/etc/hadoop/yarn-env.sh
     $JAVA_HOME has been set to be the output of:
       /usr/libexec/java_home
     ...

3. Test (should bring up the usage message)::

     >>> hadoop
     Usage: hadoop [--config confdir] COMMAND
     ...



Single node configuration
-------------------------
Adapted from
http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html.

Setup remote access to localhost
````````````````````````````````

1. Enable remote login in System Preferences/Sharing.

2. Create an ssh key for passwordless login::

     >>> ssh-keygen -t rsa -f ~/.ssh/id_rsa-localhost -P ""  # No password
     >>> cat ~/.ssh/id_rsa-localhost.pub >> ~/.ssh/authorized_keys
     >>> eval "$(ssh-agent -s)"
     >>> ssh-add ~/.ssh/id_rsa-localhost

3. Test the connection::

     >>> ssh localhost -i ~/.ssh/id_rsa-localhost
     >>> who  # Should see an entry with "localhost"
     >>> exit

Configure Hadoop
````````````````
The hadoop configuration files are located in
/usr/local/Cellar/hadoop/2.6.0/libexec/etc/hadoop.

1. Assign the name of the default filesystem to localhost (the port number is
   arbitrary number) and set a base directory for temporary data. Enter the
   following between the ``<configuration>`` tags in core-site.xml::

     <property>
       <name>fs.defaultFS</name>
       <value>hdfs://localhost:54310</value>
     </property>
     
     <property>
       <name>hadoop.tmp.dir</name>
       <value>/Users/Jake/hadoop/tmp</value>
     </property>

   Create the hadoop.tmp.dir directory::

     >>> mkdir -p ~/hadoop/tmp

2. Set the number of file replications to 1. Enter the following between the
   ``<configuration>`` tags in hdfs-site.xml::

     <property>
       <name>dfs.replication</name>
       <value>1</value>
     </property>

3. Copy the template MapReduce config file::

     >>> cd /usr/local/Cellar/hadoop/2.6.0/libexec/etc/hadoop
     >>> cp mapred-site.xml.template mapred-site.xml

   .. Assign the host:port that the MapReduce job tracker runs at. Enter the
   .. following between the ``<configuration>`` tags in mapred-site.xml::
   ..
   ..     <property>
   ..       <name>mapreduce.jobtracker.address</name>
   ..       <value>hdfs://localhost:54311</value>
   ..     </property>

   Set the MapReduce job tracker address to local so that jobs are run
   in-process as a single map and reduce task. Enter the following between the
   ``<configuration>`` tags in mapred-site.xml::

       <property>
         <name>mapreduce.jobtracker.address</name>
         <value>local</value>
       </property>
