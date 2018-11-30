Count of errors in scheduler_run by date:

SQL:
select trunc(started_at,'DD') XX,count(trunc(started_at,'DD')) from smmhe.scheduler_run where job_group <> 'groupedCommandRequest' and status='failed'
and message = 'Max Attempt 0/0: Communication completed with failure: internalStatus==failed, internalMessage==Error in function exectuteFunction at line 1 : null'
group by trunc(started_at,'DD') order by trunc(started_at,'DD') desc;

----------------
select started_at, ended_at, job_group, job_name, message from SMMHE.scheduler_run where message
IS NOT NULL and status <> ‘succeeded’ started_at > to_date(‘2011-01-26 23:59:59’, ‘yyyy-mm-dd HH24:MI:SS’) order by job_name;
