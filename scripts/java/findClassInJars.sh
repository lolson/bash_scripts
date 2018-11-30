#!/bin/bash
if [[ "$1" == help || "$1" == "-help" ]]; then 
    echo "Usage: \n"
    echo "findClassInJars.sh . javax/servlet/ServletConfig.class"
else
    find "$1" -name "*.jar" -exec sh -c 'jar -tf {}|grep -H --label {} '$2'' \;
fi

# first parameter is the directory to search recursively and 
# second parameter is a regular expression (typically just a simple class name) to search for.

# Usage 
# $ findClassInJars.sh . WSSubject
# $ findClassInJars.sh . javax/servlet/ServletConfig.class

# this script relies on the -t option to the jar command (which lists 
# the contents) and greps each table of contents, labelling any matches
# with the path of the JAR file in which it was found.

