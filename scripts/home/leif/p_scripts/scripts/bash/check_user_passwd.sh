#!/bin/bash
# http://www.yourownlinux.com/2015/08/how-to-check-if-username-and-password-are-valid-using-bash-script.html
#root ~ > ./usrpasschk.sh
#iEnter the Username: mandar
#Enter the Password:
#Valid Username-Password Combination

read -p "Enter the Username: " USERNAME

id -u $USERNAME > /dev/null
if [ $? -ne 0 ]
then
        echo "User $USERNAME is not valid"
        exit 1
else
        echo "Enter the Password:"
        read -s PASSWD
        export PASSWD
        ORIGPASS=`grep -w "$USERNAME" /etc/shadow | cut -d: -f2`
        export ALGO=`echo $ORIGPASS | cut -d'$' -f2`
        export SALT=`echo $ORIGPASS | cut -d'$' -f3`
        GENPASS=$(perl -le 'print crypt("$ENV{PASSWD}","\$$ENV{ALGO}\$$ENV{SALT}\$")')
        if [ "$GENPASS" == "$ORIGPASS" ]
        then
                echo "Valid Username-Password Combination"
                exit 0
        else
                echo "Invalid Username-Password Combination"
                exit 1
        fi
fi

