SELECT 
	SCHEMA_NAME(q.schema_id) AS SchemaName
	,q.name AS QueueName
	,p.rows AS QueueRows
FROM sys.service_queues AS q
JOIN sys.objects AS o ON 
	o.object_id = q.object_id
JOIN sys.objects AS i ON 
	i.parent_object_id = q.object_id
JOIN sys.partitions p ON 
	p.object_id = i.object_id 
	AND p.index_id IN(0,1);