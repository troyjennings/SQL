SELECT dp.type_desc, dp.SID, dp.name AS user_name,  'EXEC sp_change_users_login ' + '''Auto_Fix''' + ', ''' + dp.name + ''' ' AS FixScript
FROM sys.database_principals AS dp  
LEFT JOIN sys.server_principals AS sp  
    ON dp.SID = sp.SID  
WHERE sp.SID IS NULL  
    AND authentication_type_desc = 'INSTANCE'
    order by dp.name;
 
