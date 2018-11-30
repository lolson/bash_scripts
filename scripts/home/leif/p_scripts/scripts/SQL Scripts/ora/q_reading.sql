select device_id, status, job_group, ended_at from scheduler_run where job_name='SAM11043' and trunc(started_at)=trunc(sysdate);

select count(*) from smmhe.Reading Where
TIME BETWEEN TO_TIMESTAMP('22/05/2011 23:00:00.000000','DD/MM/YYYY HH24:MI:SS.FF') 
AND TO_TIMESTAMP('23/05/2011 22:59:59.000000','DD/MM/YYYY HH24:MI:SS.FF') order by TIME;

select smmhe.device.device_id, smmhe.tblaccount_rate_program.sdp_id, smmhe.tbldevice_info.sdp_id, smmhe.tblaccount_rate_program.type, 
smmhe.reading.data_register, smmhe.reading.time from smmhe.tblaccount_rate_program 
INNER JOIN smmhe.tbldevice_info on smmhe.tbldevice_info.sdp_id = smmhe.tblaccount_rate_program.sdp_id 
INNER JOIN smmhe.device on smmhe.tbldevice_info.device_id = smmhe.device.id 
INNER JOIN smmhe.reading on reading.device_id = smmhe.device.device_id where smmhe.tbldevice_info.sdp_id is not null and smmhe.reading.reg_sequence_number = 0 
and smmhe.tblaccount_rate_program.type = 'Electric' and smmhe.reading.TIME BETWEEN TO_TIMESTAMP('22/05/2011 23:00:00.000000','DD/MM/YYYY HH24:MI:SS.FF') 
AND TO_TIMESTAMP('23/05/2011 22:59:59.000000','DD/MM/YYYY HH24:MI:SS.FF') order by smmhe.reading.time;

In the second query, change ‘Electric’ to ‘Gas’ to get the gas reads.

-- query to get all electric "commissioned" devices
select count(*) from tbldevice_info t2
join
(select pkey
from device_pkey
join device
on device_pkey.device_id = device.device_id
where device.device_class = 'NEMA.76.71.48.52')
t1
on t1.pkey = t2.device_id
where t2.sdp_id <> ' ';
--26,003
--27,582 (5/24)

--Query of the scheduler_run to get distinct device ids, returns 30,051
select count(*) from (
select distinct job_name from scheduler_run
where job_name <> 'groupedCommandRequest'
and job_name <> 'commandBeansContainer');

--Query of the scheduler_run table which should have record of all device communication, returns 15,752
select count(*) from (
select parent_run_id, job_name,
count(parent_run_id) as Message_Count
from scheduler_run
GROUP BY parent_run_id, job_name HAVING count(parent_run_id) > 1);

--TODO Query that identifies 6000 elec meters without reads - also no entry in scheduler_run?

select count(*) from device
join
(select pk.device_id
from device_pkey pk
join tbldevice_info di
on pk.pkey = di.device_id
where di.sdp_id <> ' ') t1
on t1.device_id = device.device_id
where device.device_class = 'NEMA.76.71.48.52';


-- JOIN commissioned with distinct devices in scheduler_run
select d.device_id from 
(
select dev.device_id from device dev
join
(select pk.device_id
from device_pkey pk
join tbldevice_info di
on pk.pkey = di.device_id
where di.sdp_id <> ' ') t1
on t1.device_id = dev.device_id
where dev.device_class = 'NEMA.76.71.48.52'
) d
join
(
select distinct device_id from scheduler_run
where device_id is not null
) sr
on d.device_id = sr.device_id;


select count(*) from smmhe.Reading Where
TIME BETWEEN TO_TIMESTAMP('22/05/2011 23:00:00.000000','DD/MM/YYYY HH24:MI:SS.FF') 
AND TO_TIMESTAMP('23/05/2011 22:59:59.000000','DD/MM/YYYY HH24:MI:SS.FF') order by TIME;

select smmhe.device.device_id, smmhe.tblaccount_rate_program.sdp_id, smmhe.tbldevice_info.sdp_id, 
smmhe.tblaccount_rate_program.type, 
smmhe.reading.data_register, smmhe.reading.time 
FROM smmhe.tblaccount_rate_program 
INNER JOIN smmhe.tbldevice_info on smmhe.tbldevice_info.sdp_id = smmhe.tblaccount_rate_program.sdp_id 
INNER JOIN smmhe.device on smmhe.tbldevice_info.device_id = smmhe.device.id 
INNER JOIN smmhe.reading on reading.device_id = smmhe.device.device_id where smmhe.tbldevice_info.sdp_id is not null 
and smmhe.reading.reg_sequence_number = 0 
and smmhe.tblaccount_rate_program.type = 'Electric' 
and smmhe.reading.TIME BETWEEN TO_TIMESTAMP('22/05/2011 23:00:00.000000','DD/MM/YYYY HH24:MI:SS.FF') 
AND TO_TIMESTAMP('23/05/2011 22:59:59.000000','DD/MM/YYYY HH24:MI:SS.FF') order by smmhe.reading.time;


-- Query with Device_ID, latest Read, Timestamp for device read
select distinct smmhe.reading.device_id, smmhe.reading.REG_SEQUENCE_NUMBER, smmhe.reading.data_register, max(smmhe.reading.time), count(*) 
from smmhe.reading inner join smmhe.device on smmhe.device.device_id = smmhe.reading.device_id join
smmhe.tbldevice_info on smmhe.device.id = smmhe.tbldevice_info.device_id where smmhe.tbldevice_info.sdp_id is not null and 
smmhe.reading.device_id not in ( select distinct smmhe.reading.device_id from smmhe.reading where time between
TO_TIMESTAMP('18/06/2011 00:00:00.000000','DD/MM/YYYY HH24:MI:SS.FF') 
AND TO_TIMESTAMP('21/07/2011 23:00:00.000000','DD/MM/YYYY HH24:MI:SS.FF')) 
group by smmhe.reading.device_id, smmhe.reading.REG_SEQUENCE_NUMBER, smmhe.reading.data_register order by smmhe.reading.REG_SEQUENCE_NUMBER;


-- Query to find missing reads

SELECT (SELECT TRUNC(SYSDATE-1) FROM DUAL) AS "Report Run Date",
(SELECT COUNT(*) FROM SMMHE.TBLDEVICE_INFO WHERE SDP_ID IS NOT NULL AND SDP_ID <> ' ') AS "Total Commissioned Devices",
(SELECT COUNT(*) FROM SMMHE.TBLDEVICE_INFO A, SMMHE.DEVICE B
WHERE SDP_ID IS NOT NULL AND A.DEVICE_ID = B.ID
AND B.DEVICE_CLASS = 'NEMA.76.71.48.53')
AS "Gas-Commissioned", 
(SELECT COUNT(*) FROM SMMHE.TBLDEVICE_INFO A, SMMHE.DEVICE B
WHERE SDP_ID IS NOT NULL AND A.DEVICE_ID = B.ID
AND B.DEVICE_CLASS = 'NEMA.76.71.48.52')
AS "Electric-Commissioned",
(SELECT COUNT(DISTINCT DEVICE_ID) FROM SMMHE.READING WHERE TRUNC(TIME) = TRUNC(SYSDATE-1)) AS "Total Reading Devices",
(SELECT COUNT(DISTINCT DEVICE_ID) FROM SMMHE.READING WHERE TRUNC(TIME) = TRUNC(SYSDATE-1) AND SENSOR_SOURCE_ID IN(4)
) AS "Total Reading Gas",
(SELECT COUNT(DISTINCT DEVICE_ID) AS "1=Gas, 2=Electric" FROM SMMHE.READING 
WHERE TRUNC(TIME) = TRUNC(SYSDATE-1) AND SENSOR_SOURCE_ID IN(3)
) AS "Total Reading Electric" FROM DUAL

-- Above Missing Reads Reports contains:
1.	Date
2.	Total number of Commissioned Devices
3.	Total number of Commissioned Electricity Devices
4.	Total number of Commissioned Gas Devices
5.	Number of Devices with Meter Reads
6.	Number of Electricity Devices with Meter Reads

