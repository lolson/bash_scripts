To clean out scheduled jobs for simulated devices
Run in this order:
--DELETE  FROM  u_scheduler_run;
--DELETE  FROM  uqrtz_cron_triggers;
--DELETE  FROM  uqrtz_simple_triggers;
--DELETE  FROM  uqrtz_triggers;
--DELETE  FROM  u_scheduler_task;
--DELETE  FROM  uqrtz_job_details;

Otherwise SVC will attempt to comm w/ device for 24 hrs, 
and during that period Unity will poll SVC constantly (every second?)
whether SVC has successfully communicated with device.
