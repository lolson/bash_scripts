
export M2_HOME=/usr/share/maven
export WEBSPHERE_HOME=/home/leif/MiddlewareClients/websphere75/lib
export ACTIVEMQ_HOME=/home/leif/opt/apache-activemq-5.14.5

export JAVA_HOME=/home/leif/opt/jdk1.8.0_161
export GMSEC_HOME=/home/leif/GMSEC/GMSEC_API
export GSS_HOME=/home/leif/GSS
export GSS_SOURCE=/home/leif/GSS/gss
export ELYSIUM_DB_PASSWORD=postgres
export ELYSIUM_DB_USERNAME=postgres
export JEMALLOC_HOME=/home/leif/opt/jemalloc

export PATH=$JAVA_HOME:$JAVA_HOME/bin:$GMSEC_HOME/bin:$WEBSPHERE_HOME:$PATH 
export LD_LIBRARY_PATH=/home/leif/GMSEC/GMSEC_API/bin:$LD_LIBRARY_PATH

alias atom='atom-beta'
alias bolt_sub='gmsub connectionType=gmsec_bolt server=127.0.0.1 port=9100 subject='\''GMSEC.>'\'''
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias git_status='git status | grep -v ".iml"'
alias gmsecmb='MBServer'
alias go_gss='cd /home/leif/GSS/gss'
alias grep='grep --color=auto'
alias gss_prod='mvn -P prod clean package install'
alias gulp_prepAppJS='gulp prepareAppJS:dev'
alias gulp_watch='gulp watch'
alias gulp_e2e='gulp protractor'
alias gulp_test_chart='gulp itest --suite chart'
alias intellij='/home/leif/opt/idea-IU-173.4548.28/bin/idea.sh'
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias run_amq_pub='gmpub connectionType=gmsec_activemq384 server=tcp://127.0.0.1:61616'
alias run_amq_sub='gmsub connectionType=gmsec_activemq384 server=tcp://127.0.0.1:61616'
alias run_bolt='java -jar $GMSEC_HOME/bin/bolt.jar'
alias run_bolt_arch='java -jar $GMSEC_HOME/bin/bolt.jar port=9101'
alias run_bolt_pub='gmpub connectionType=gmsec_bolt server=127.0.0.1 port=9100'
alias run_bolt_sub='gmsub connectionType=gmsec_bolt server=127.0.0.1 port=9100'
alias springboot='mvn spring-boot:run'
alias vi='vim'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
alias ws_pub='gmpub connectionType=gmsec_websphere75 server=gs580s-gpts2 port=1414'
alias ws_sub='gmsub connectionType=gmsec_websphere75 server=gs580s-gpts2 port=1414 mw-channel=GMSEC.TEST.CHANNEL'
alias postman='~/opt/Postman'
alias list_services='systemctl list-unit-files --type=service'
alias open_psql='sudo -u postgres psql postgres'
