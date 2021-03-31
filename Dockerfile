FROM debian:stretch

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y ssh 
RUN apt-get install -y rsync 
RUN apt-get install -y vim 
RUN apt-get install -y sudo 
RUN apt-get install -y net-tools
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y libxml2-dev 
RUN apt-get install -y libkrb5-dev 
RUN apt-get install -y libffi-dev 
RUN apt-get install -y libssl-dev 
RUN apt-get install -y libldap2-dev 
RUN apt-get install -y libxslt1-dev 
RUN apt-get install -y libgmp3-dev 
RUN apt-get install -y libsasl2-dev 
RUN apt-get install -y curl
 
ENV HADOOP_HOME=/opt/hadoop
ENV USER=root
ENV PATH $HADOOP_HOME/bin/:$PATH


# If you have already downloaded the tgz, add this line OR comment it AND ...
ADD /hadoop/hadoop-3.1.3.tar.gz /

# ... uncomment the 2 first lines
RUN \
#    wget http://apache.crihan.fr/dist/hadoop/common/hadoop-3.1.3/hadoop-3.1.3.tar.gz && \
#    tar -xzf hadoop-3.1.3.tar.gz && \
    mv hadoop-3.1.3 $HADOOP_HOME && \
    for user in hadoop hdfs yarn mapred hue; do \
         useradd -U -M -d /opt/hadoop/ --shell /bin/bash ${user}; \
    done && \
    for user in root hdfs yarn mapred ; do \
         usermod -G hadoop ${user}; \
    done && \
    echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_DATANODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
#    echo "export HDFS_DATANODE_SECURE_USER=hdfs" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_NAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_SECONDARYNAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export YARN_RESOURCEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    echo "export YARN_NODEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc

RUN mkdir /tmp/hadoop
RUN mkdir /HDFS/
RUN mkdir /HDFS/namenode
RUN mkdir /HDFS/datanode

RUN \
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

ADD /hadoop/*xml $HADOOP_HOME/etc/hadoop/

ADD ssh_config /root/.ssh/config

ADD start-all.sh start-all.sh
RUN chmod 777 start-all.sh

CMD bash start-all.sh       

##### PIG #####
#Se agrega Pig
WORKDIR /

ADD /pig/pig-0.17.0.tar.gz /

#moverlo a su carpeta
RUN mv pig-0.17.0 /opt/hadoop/pig/

#Poner variables de entorno de hive 
ENV PIG_HOME /opt/hadoop/pig
ENV PIG_CLASSPATH /opt/hadoop/etc/hadoop/
ENV PATH $PIG_HOME/bin:$PIG_CLASSPATH:$PATH
  
RUN echo "PATH=$PATH::$HIVE_HOME/bin:$PIG_CLASSPATH:$PATH" >> ~/.bashrc

##### PIG #####


##### hive #####################################

#Se agrega Hive
ADD /hive/apache-hive-3.1.2-bin.tar.gz /

#moverlo a su carpeta correspondiente a su home
RUN mv apache-hive-3.1.2-bin /opt/hadoop/hive 

#Poner variables de entorno de hive 
ENV HIVE_HOME /opt/hadoop/hive
ENV HIVE_CONF_DIR /opt/hadoop/hive/conf
ENV PATH  $HIVE_HOME/bin:$PATH
  
RUN  echo "PATH=$PATH::$HIVE_HOME/bin:$PATH" >> ~/.bashrc
RUN  echo "CLASSPATH=$CLASSPATH:/opt/hadoop/lib/*:." >> ~/.bashrc
RUN  echo "CLASSPATH=$CLASSPATH:/opt/hadoop/hive/lib/*:." >> ~/.bashrc 

##EMPATAR CONNECTOR
WORKDIR /opt/hadoop/hive/lib
ADD mysql-connector-java-8.0.19.jar /opt/hadoop/hive/lib/mysql-connector-java.jar
RUN ls

##Corregir librerias guava
RUN rm /opt/hadoop/hive/lib/guava-19.0.jar 
RUN cp /opt/hadoop/share/hadoop/hdfs/lib/guava-27.0-jre.jar /opt/hadoop/hive/lib

WORKDIR /opt/hadoop/hive/conf
RUN ls 
RUN cp hive-env.sh.template hive-env.sh 
RUN echo "export HADOOP_HOME=/opt/hadoop" >> hive-env.sh
ADD /hive/hive-site.xml  /opt/hadoop/hive/conf

RUN mkdir -p /tmp/hive/java
WORKDIR /
#####  hive    ###################################################


##### hbase #####################################

ENV HBASE_HOME /opt/hadoop/hbase

ENV PATH $HBASE_HOME/bin:$PATH

ADD /hbase/hbase-2.2.5-bin.tar.gz /

RUN mv hbase-2.2.5 /opt/hadoop/hbase

COPY /hbase/hbase-site.xml /opt/hadoop/hbase/conf/

COPY /hbase/hbase-env.sh /opt/hadoop/hbase/conf/

##### hbase #####################################

RUN apt-get install -y wget 

##### ZEPPELIN #####
# Se agrega Zeppelin

ADD /zeppelin/zeppelin-0.9.0-bin-all.tgz /

RUN mv /zeppelin-0.9.0-preview2-bin-all /zeppelin

COPY /zeppelin/conf/zeppelin-site.xml /zeppelin/conf

COPY /zeppelin/conf/shiro.ini /zeppelin/conf

COPY /zeppelin/conf/zeppelin-env.sh /zeppelin/conf

##### /ZEPPELIN #####


##### FLUME #####
ENV FLUME_HOME /opt/hadoop/flume
ENV PATH $FLUME_HOME/bin:$PATH
RUN echo "PATH=$PATH:$FLUME_HOME/bin" >> ~/.bashrc

WORKDIR /
ADD flume/apache-flume-1.9.0-bin.tar.gz /
RUN mv apache-flume-1.9.0-bin $FLUME_HOME
RUN cp /opt/hadoop/share/hadoop/hdfs/lib/guava-27.0-jre.jar $FLUME_HOME/lib
# RUN rm /opt/hadoop/share/hadoop/hdfs/lib/guava-11.0-jre.jar

COPY flume/example-memory.conf /opt/hadoop/flume/conf/

##### /FLUME #####

# HDFS
EXPOSE 9000 9820 9864 9866 9867 9868 9870

# MAPREDUCE
EXPOSE 10020 10033 19888

# YARN
EXPOSE 8030 8031 8032 8050 8025 8042 8088

# HIVE
EXPOSE 10000 9999 9083

# HBASE
EXPOSE 16000 16010 16020 16030 9090 9095

#SPARK
EXPOSE 4040 8080 8081 7077 6066 18080

# ZEPPELIN
EXPOSE 9900

CMD tail -f /dev/null
