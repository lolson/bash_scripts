Time range
select job_name, count(*) as NumberOfTasks from smmhe.scheduler_run where job_name 
between TO_TIMESTAMP('21/07/2011 13:00:00.000000','DD/MM/YYYY HH24:MI:SS.FF') AND TO_TIMESTAMP('21/07/2011 23:59:00.000000','DD/MM/YYYY HH24:MI:SS.FF')
and 
job_group like 'set%' and status = 'succeeded' group by job_name order by job_name;

DeviceId range
select job_name, count(*) as NumberOfTasks from smmhe.scheduler_run where job_name 
between 'PER103821' and 'PER103870' 
and 
job_group like 'set%' and status = 'succeeded' group by job_name order by job_name;

