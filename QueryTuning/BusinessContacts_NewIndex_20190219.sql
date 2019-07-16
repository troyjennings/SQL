CREATE NONCLUSTERED INDEX [IX_BusinessContact_Index10] 
ON [dbo].[business_contacts] ([Business_Id],[last_login_date_time] DESC) 
INCLUDE ([preferred_web_language_id]) 
WITH (FILLFACTOR=80, ONLINE=OFF, SORT_IN_TEMPDB=ON, DATA_COMPRESSION=NONE)ON [DSC_Other_FG];

--DROP INDEX [IX_BusinessContact_Index10] ON [dbo].[business_contacts]
