select count(device_id) as cnt, device_id from profile 
group by device_id
order by cnt;

in ascending order, display the counts of device ids found
in the profile table. one column for counts, and second for device_ids

select device_group.device_id, device.device_class  
from device_group
join device
on device.device_id = device_group.device_id;

update table1 set datepaid = to_date('12/12/1999','MM/DD/YYYY');
select * from LP_DATA where to_char(end_time, 'dd-mm-yy hh')='30-06-09 04';

select device_id, data_register, time from reading
where to_char(time, 'dd-mm-yy')='19-06-09' and
device_id='000833732';

update tbldevice_times set tou_last_sum_time = '2009-07-15 00:00:00' where device_id = 'MLT51569';