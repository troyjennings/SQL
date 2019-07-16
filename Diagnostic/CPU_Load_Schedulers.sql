SELECT
 parent_node_id,
 [status],
 scheduler_id,
 [cpu_id],
 is_idle,
 current_tasks_count,
 runnable_tasks_count,
 active_workers_count,
 load_factor
FROM sys.dm_os_schedulers
WHERE
 [status] = N'VISIBLE ONLINE'
OR
 [status] = N'VISIBLE OFFLINE';