DECLARE @DBName VARCHAR(128) ;

DECLARE curDBs CURSOR READ_ONLY STATIC LOCAL
FOR
SELECT d.name
FROm sys.databases d
WHERE d.state_desc = 'ONLINE'
  AND d.name NOT IN ('master','msdb','model','tempdb')
ORDER BY d.name ;

OPEN curDBs ;
FETCH NEXT FROM curDBs INTO @DBName ;

WHILE (@@FETCH_STATUS = 0)
BEGIN

  SELECT @DBName ;

  FETCH NEXT FROM curDBs INTO @DBName ;

END ;

CLOSE curDBs ;
DEALLOCATE curDBs ;
