The SQL for the successful meters is:

select * from smmhe.scheduler_run where job_name between 'PER801200' and 'PER801799' and 
started_at between TO_TIMESTAMP('21/07/2011 13:00:00.000000','DD/MM/YYYY HH24:MI:SS.FF') 
AND TO_TIMESTAMP('21/07/2011 23:59:00.000000','DD/MM/YYYY HH24:MI:SS.FF') and job_group like 'set%' and status = 'succeeded' order by job_name;

The SQL for the failed meters is:

select * from smmhe.scheduler_run where job_name between 'PER801200' and 'PER801799' and 
started_at between TO_TIMESTAMP('21/07/2011 13:00:00.000000','DD/MM/YYYY HH24:MI:SS.FF') 
AND TO_TIMESTAMP('21/07/2011 23:59:00.000000','DD/MM/YYYY HH24:MI:SS.FF') and job_group like 'set%' and status != 'succeeded' order by job_name;

