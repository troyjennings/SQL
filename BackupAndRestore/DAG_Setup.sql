
SQL

/*
Title: Setup-DAGS_NGN_DWH.sql
Description: This script will help an administrator setup Distributed Availability Groups (DAGS)
Date: 1/17/19 4:21 PM
*/
/*
1. Setup the AG on data warehouse
*/
-- implement via the GUI
/*
2. Setup the AG Listener
*/
-- implement via the GUI
/*
3. Create the Endpoint on data warehouse SQL Servers
*/
USE master
GO
/****** Object:  Endpoint [Hadr_endpoint]    Script Date: 1/17/2019 4:15:19 PM ******/
CREATE ENDPOINT [Hadr_endpoint] 
    STATE=STARTED
    AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
    FOR DATA_MIRRORING (ROLE = ALL, AUTHENTICATION = WINDOWS NEGOTIATE
, ENCRYPTION = REQUIRED ALGORITHM AES)
GO
/*
4. Create SQL Service accounts on all SQL servers in the AG and grant connect permissions to the endpoint
*/
-- Run on all Production Data Warehouse SQL Servers
CREATE LOGIN [<insert service account running Discover SQL services>] FROM WINDOWS;
GRANT CONNECT ON ENDPOINT::Hadr_endpoint
TO [<insert service account running Discover SQL services>]
-- Run on all Discover Production SQL servers
CREATE LOGIN [<insert service account running Data Warehouse SQL services>] FROM WINDOWS;
GRANT CONNECT ON ENDPOINT::Hadr_endpoint
TO [<insert service account running Data Warehouse SQL services>]
/*
5. Setup the Distributed AG 
*/
--Script to Create DAG on Global Primary (Discover)
CREATE AVAILABILITY GROUP [UNGN_DWH_AO_AG]  
   WITH (DISTRIBUTED)   
   AVAILABILITY GROUP ON  
      'UNGN_AO_AG' WITH    
      (   
         LISTENER_URL = 'tcp://[someIP]:5022',    
         AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,   
         FAILOVER_MODE = MANUAL,   
         SEEDING_MODE = AUTOMATIC   
      ),   
      'UDWH_AO_AG' WITH    
      (   
         LISTENER_URL = 'tcp://[someIP]:5022',   
         AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,   
         FAILOVER_MODE = MANUAL,   
         SEEDING_MODE = AUTOMATIC   
      );    
GO
--Script to Join Replica to DAG to be run primary replica of secondary AG (Data Warehouse)
 ALTER AVAILABILITY GROUP [UNGN_DWH_AO_AG]   
   JOIN   
   AVAILABILITY GROUP ON  
     'UNGN_AO_AG' WITH    
      (   
         LISTENER_URL = 'tcp://[someIP]:5022',    
         AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,   
         FAILOVER_MODE = MANUAL,   
         SEEDING_MODE = AUTOMATIC   
      ),   
      'UDWH_AO_AG' WITH    
      (   
         LISTENER_URL = 'tcp://[someIP]:5022',   
         AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,   
         FAILOVER_MODE = MANUAL,   
         SEEDING_MODE = AUTOMATIC   
      );    
GO  
/*
6. Grant AG permissions to allow the AG objects to create databases
*/
ALTER AVAILABILITY GROUP [<data warehouse AG NAME>] JOIN
--Allow the Availability Group to create databases on behalf of the primary replica
ALTER AVAILABILITY GROUP [<data warehouse AG NAME>]  GRANT CREATE ANY DATABASE
/*
Rollback - Remove DAGs
*/
-- Execute on both Discover and Data Warehouse
--DROP AVAILABILITY GROUP [UNGN_DWH_AO_AG]

--alter database Logging set hadr availability group = [UDWH_AO_AG];