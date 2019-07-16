CREATE NONCLUSTERED INDEX [ix_ManheimDataLoad_Index01] ON [dbo].[ManheimDataLoad]
([Buyer_Deposit_Date_Key])
INCLUDE([Buyer_Account_Number],[Floor_Plan_Customer_Name],[Buyer_Account_NUL_Code],[Buyer_Customer_MEGASLR_Group_Name],[Buyer_Customer_Physical_Zip_Code],[Operating_Location_Country],[Registration_Application])
WITH (FILLFACTOR=100, ONLINE=OFF, SORT_IN_TEMPDB=ON, DATA_COMPRESSION=NONE)