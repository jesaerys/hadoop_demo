README
======
A collection of basic Hadoop/MapReduce examples.

Installation and configuration instructions for setting up a single-node Hadoop
"cluster" are provided below, making it possible to run the examples on a
personal machine. The installation instructions assume Mac OS 10.6.8, but they
should work for any version of Mac OS as long as Homebrew and a recent Java
installation are available. The Configuration instructions assume Hadoop 2.6.

(The bash prompt is indicated by ``>>>`` in the snippets below.)

1. `Hadoop installation`_
2. `Single node configuration`_

   - `Setup remote access to localhost`_
   - `Configure Hadoop`_

3. `MapReduce examples`_


Hadoop installation
-------------------

1. Check Java version::

     >>> java -version
     java version "1.6.0_65"
     Java(TM) SE Runtime Environment (build 1.6.0_65-b14-462-10M4609)
     Java HotSpot(TM) 64-Bit Server VM (build 20.65-b04-462, mixed mode)

   According to http://wiki.apache.org/hadoop/HadoopJavaVersions, only versions
   1.6.0_16, 1.6.0_18, and 1.6.0_19 in the 1.6 series are reported to have
   problems, so 1.6.0_65 should be fine.

2. Install Hadoop via Homebrew (make sure to update and upgrade first)::

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

3. Test the installation. This should bring up the usage message::

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
Homebrew places the Hadoop configuration files in
``/usr/local/Cellar/hadoop/2.6.0/libexec/etc/hadoop``.

1. Assign the name of the default filesystem to ``localhost`` (the port number
   is arbitrary) and set a base directory for temporary data. Enter the
   following between the ``<configuration>`` tags in ``core-site.xml``::

     <property>
       <name>fs.defaultFS</name>
       <value>hdfs://localhost:54310</value>
     </property>
     
     <property>
       <name>hadoop.tmp.dir</name>
       <value>/Users/Jake/hadoop/tmp</value>
     </property>

   Create the ``hadoop.tmp.dir`` directory::

     >>> mkdir -p ~/hadoop/tmp

2. Set the number of file replications to 1. Enter the following between the
   ``<configuration>`` tags in ``hdfs-site.xml``::

     <property>
       <name>dfs.replication</name>
       <value>1</value>
     </property>

3. Copy the template MapReduce config file::

     >>> cd /usr/local/Cellar/hadoop/2.6.0/libexec/etc/hadoop
     >>> cp mapred-site.xml.template mapred-site.xml

   .. Assign the host and port that the MapReduce job tracker runs at. Enter
   .. the following between the ``<configuration>`` tags in
   .. ``mapred-site.xml``::
   ..
   ..     <property>
   ..       <name>mapreduce.jobtracker.address</name>
   ..       <value>hdfs://localhost:54311</value>
   ..     </property>

   Set the MapReduce job tracker address to ``local`` so that jobs are run
   in-process as a single map and reduce task. Enter the following between the
   ``<configuration>`` tags in ``mapred-site.xml``::

       <property>
         <name>mapreduce.jobtracker.address</name>
         <value>local</value>
       </property>


MapReduce examples
------------------

1. ``mapreduce_grep.sh``: search for strings ("grep") using a jar file from the
   builtin example collection.
.. 2. ``mapreduce_wordcount.sh``: count the number of occurrences of all words
..    using a jar file from the builtin example collection.
.. 3. ``mapreduce_pywordcount.sh``: the same word count task, but implemented
..    using a custom python code with the Hadoop streaming utility.
