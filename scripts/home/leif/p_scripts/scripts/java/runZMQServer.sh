#!/bin/bash
# Need java bindingsa @See ~/git_repo/jzmq
# /usr/local/lib/
# libjzmq.a   libjzmq.so    libjzmq.so.0.0.0  libzmq.la  libzmq.so.4      
# libjzmq.la  libjzmq.so.0  libzmq.a          libzmq.so  libzmq.so.4.0.0  

LIB_ROOT=/home/leif/opt/zeromq-4.0.5/src/.libs
CPATH=$LIB_ROOT/*:.

#$ java -Djava.library.path=/usr/local/lib -classpath /home/user/zeromq/libjzmq local_lat tcp://127.0.0.1:5555 1 100

echo $CPATH
javac -cp "$CPATH" ActivemqConsumerTopic.java
java -cp $CPATH ActivemqConsumerTopic
