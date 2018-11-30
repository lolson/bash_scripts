Select device_id, rateprogram_id, rate_tier_schedule_id, rateplan_id,
tier_start_time, tier_end_time, tou_type, data, tier_name, tier_rate from
tbltoumeterdata 
where device_id in ('99447484', 'MLT51576', '99447487','99447485', '99447486')
and (tier_start_time) > '03-Feb-09 04:59:59'
and (tier_start_time) < '11-Feb-09 12:00:00' order by deivce_id, tier_start_time;

