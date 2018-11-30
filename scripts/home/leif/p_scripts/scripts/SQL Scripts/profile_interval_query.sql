select device_id, data_set, end_time, channel from profile_interval p
where device_id = '93026410'
and to_char(p.end_time, 'YYYY/MM/DD') = '2009/05/18';