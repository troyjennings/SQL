SELECT db_name() AS the__database
	, OBJECT_SCHEMA_NAME(P.object_id) AS the__schema
	, P.name AS procedure__name 
	, C.text AS procedure__text
	, C.colid
FROM sys.procedures P WITH(NOLOCK)
	LEFT JOIN sys.syscomments C ON P.object_id = C.id
WHERE C.text LIKE '%recompile%';