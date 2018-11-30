oracle[VSMMHE01]> cat /oracle01/admin/bin/lock_log.sh
#!/bin/ksh
#
# C E N T R I C A     P L C
#     ORACLE DATABASE ADMINISTRATION
#
# NAME     : lock_log.sh
# FUNCTION : Logs session details for lock holders and waiters
# USAGE    : lock_log.sh
# AUTHOR   : PJQ
# VERSION  : 1.0
# DATE     : 29-OCT-2010
################################################################################
# History
# Modified By   Date            Purpose
# -----------   ----------      ------------------------------------------------
# P Raven       22-Feb-2011     Deployed onto cnsv0042
################################################################################

#############################################################
# Main
#############################################################

# Set up environment
. ~oracle/.DefineEnv
$1

export BIN_DIR=/oracle01/admin/bin
export SQL_DIR=/oracle01/admin/sql
export LOG_DIR=/oracle01/admin/log
echo $ORACLE_HOME
#
# Insert into ops$oracle.lock_details details of lock holder, lock waiter and locked object.
#
/oracle01/product/10.2.0/64/a/bin/sqlplus -s / <<HERE1 > ${LOG_DIR}/lock_log.log
insert into lock_details
select w.holding_session, w.waiting_session, bs.username, bs.program,
       decode(bl.type,'TX','Trans','TM','DML') type,
       decode(bl.lmode,1,'Null',2,'Row-S (SS)',3,'Row-X (SX)',4,'Share (S)',
                       5,'S/Row-X (SSX)',6,'Exclusive (X)',0,null) mode_,
       bl.ctime,
       decode(bl.type,'TM',o.owner||'.'||o.object_name) obj,
       bs.status , sysdate, bs.osuser
from v\$lock bl, v\$session bs, dba_objects o, dba_waiters w
where bl.sid in (select sid from v\$lock where block=1)
and bl.sid=bs.sid
and w.holding_session=bl.sid
and decode(bl.type,'TM',bl.id1,0)=o.object_id
and o.object_name = 'UQRTZ_LOCKS';
commit;
exit;
HERE1

# and o.object_name = 'UQRTZ_LOCKS';
#
# Determine if there are any new locks older than 5 minutes
#

max_lock_time=`/oracle01/product/10.2.0/64/a/bin/sqlplus -s / <<HERE0
set pages 0
set verify off
set heading off
set feedback off
set echo on
-- select largest ctime  from lock_details
-- where lock details were entered in the last two minutes, the latest batch
-- and the locking session was not killed previously in the last half hour
-- was not waiting in the last 2 minutes , ie still blocked in th latest details collected.
select nvl(max(ctime),0)
   from lock_details
 where lock_time >  sysdate - 1/720
   and holding_session not in
  (select holding_session
     from lock_killed
    where kill_time > sysdate - 1/48)
   and holding_session not in
  (select waiting_session
     from lock_details
    where lock_time > sysdate - 1/720)
;
exit;
HERE0
`

echo max_lock_time $max_lock_time

if (( $max_lock_time > 299 )) then
  echo kill process here

  /oracle01/product/10.2.0/64/a/bin/sqlplus -s / <<HERE2 > ${LOG_DIR}/kill_lock.log
  set pages 0
  set feed off
  select 'prompt ======================'||chr(10)||
         'prompt Session Waits for '|| s.sid||chr(10)||
         'prompt ======================'||chr(10)||
         '@/oracle01/admin/sql/sesswait '|| s.sid||chr(10)||
         'prompt ======================'||chr(10)||
         'prompt Last SQL for '|| s.sid||chr(10)||
         'prompt ======================'||chr(10)||
         '@/oracle01/admin/sql/sidsql '|| s.sid||chr(10)||
         'alter system kill session '''|| s.sid||','||s.serial#||''';' ||chr(10)||
         'insert into lock_killed values ('||s.sid||',sysdate);'||chr(10)||
         'commit;'
  from v\$session s
  where s.sid in (
  select holding_session
     from lock_details
   where lock_time >  sysdate - 1/720
     and ctime > 299
     and holding_session not in
  (select holding_session
     from lock_killed
    where kill_time > sysdate - 1/48)
     and holding_session not in
  (select waiting_session
     from lock_details
    where lock_time > sysdate - 1/720))


  spool ${DBA_SQL}/kill_locks.sql
/
  spool off

  exit;
HERE2

  cat <<HERE3 > ${BIN_DIR}/kill_email
  Trilliant HeadEnd Pre-prod - Locking Sessions Killed
  ======================================================

  This report is produced from cnsv0042 using cron under the oracle user.
  If there are any issues with HeadEnd in general please call database services support.
  The report is sent to
    tony.johnson@centrica.com
    paul.spencer@centrica.com
    Leif.Olson@trilliantinc.com
    Ian.riddick@trilliantinc.com

  The following database sessions have been killed

HERE3

  /oracle01/product/10.2.0/64/a/bin/sqlplus -s / <<HERE4 >> ${BIN_DIR}/kill_email
  set pages 0
  set feed off
  set lines 120
  col username form a20
  col program form a20
  col mode_ form a20
  col obj form a20
  select distinct 'session id    : '||holding_session||chr(10)||
                  'userid        : '||username||chr(10)||
                  'osuser        : '||osuser||chr(10)||
                  'program       : '||program||chr(10)||
                  'status        : '||status||chr(10)||
                  'mode          : '||mode_||chr(10)||
                  'Locked Object : '||obj ||chr(10)||
                  '------------------------------------------------------------------------'
     from lock_details
   where lock_time >  sysdate - 1/720
     and ctime > 299
     and holding_session not in
  (select holding_session
     from lock_killed
    where kill_time > sysdate - 1/48)
     and holding_session not in
  (select waiting_session
     from lock_details
    where lock_time > sysdate - 1/720);

  set feed on
  spool ${DBA_LOG}/kill_locks.log
  @${DBA_SQL}/kill_locks
  spool off

exit;
HERE4

#  mailx -s "Trilliant HeadEnd Pre-prod Locks Killed" paul.raven@centrica.com < ${BIN_DIR}/kill_email
  mailx -s "Trilliant HeadEnd Pre-prod Locks Killed" rob.beattie@centrica.com < ${BIN_DIR}/kill_email
  mailx -s "Trilliant HeadEnd Pre-prod Locks Killed" tony.johnson@centrica.com < ${BIN_DIR}/kill_email
  mailx -s "Trilliant HeadEnd Pre-prod Locks Killed" paul.spencer@centrica.com < ${BIN_DIR}/kill_email
  mailx -s "Trilliant HeadEnd Pre-prod Locks Killed" Leif.Olson@trilliantinc.com < ${BIN_DIR}/kill_email
  mailx -s "Trilliant HeadEnd Pre-prod Locks Killed" Ian.riddick@trilliantinc.com < ${BIN_DIR}/kill_email
  mailx -s "Trilliant HeadEnd Pre-prod Locks Killed" John.Lyons@centrica.com < ${BIN_DIR}/kill_email

fi

