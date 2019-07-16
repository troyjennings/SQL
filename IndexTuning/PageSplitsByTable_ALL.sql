
IF OBJECT_ID('tempdb..#TableName') IS NOT NULL DROP TABLE #TableName
CREATE TABLE #TableName (FullName VARCHAR(255))

INSERT INTO #TableName
SELECT value
FROM
STRING_SPLIT ('dbo.bank_accounts,dbo.branch_unpaid_interest_histories,dbo.business_addresses,dbo.business_caches_audits,dbo.business_comments,dbo.business_contacts,dbo.business_contacts_audits,dbo.businesses,dbo.businesses_audits,dbo.business_guarantors,dbo.check_issues,dbo.collections_incident_reasons,dbo.collections_incidents,dbo.collections_incident_scores,dbo.collections_incident_histories,dbo.contacts,dbo.contract_banking_information,dbo.contract_comments,dbo.contract_documents,dbo.contract_line_of_credit_details,dbo.contracts,dbo.contracts_audits,dbo.contract_signer_credits,dbo.contract_signers,dbo.disbursement_processes,dbo.disbursements,dbo.financial_export_branch_interest_and_insurances,dbo.financial_export_daily_summaries,dbo.inspection_modifications,dbo.line_of_credit_queries,dbo.mobile_analytics_turn_times,dbo.operational_settings_state_overrides,dbo.service_broker_logs,dbo.term_plan_qualified_buyers,dbo.title_action_events,dbo.title_action_history_addresses,dbo.title_followups,dbo.title_release_requests,dbo.title_release_requests_audits,dbo.unit_status_watches,dbo.web_activities,dbo.web_scheduled_account_fees,dbo.web_scheduled_payments',',')

INSERT INTO #TableName
SELECT value
FROM
STRING_SPLIT ('dbo.curtailment_amortization_histories,dbo.eligibility_integration_records,dbo.log_messages,dbo.financial_transactions,dbo.auction_access_messages,dbo.businesses_audits,dbo.curtailments,arc.dealer_queue_audit,dbo.financial_record_caches,dbo.financial_record_subledgers,dbo.financial_transaction_caches,dbo.floorplan_auto_approval_logs,dbo.floorplan_caches,dbo.floorplan_comments,dbo.floorplans_audits,dbo.partner_activity_logs,dbo.title_action_histories,dbo.unit_inspections',',')

INSERT INTO #TableName
SELECT value
FROM
STRING_SPLIT ('dbo.floorplans,dbo.financial_records',',')

SELECT
sc.name AS SchemaName,
t.NAME AS TableName,
si.NAME AS IndexName,
si.INDEX_ID,
si.type_desc,
si.fill_factor AS Fill_Factor,
ISNULL(IOS.LEAF_ALLOCATION_COUNT, 0) AS InsertSplit,
ISNULL(IOS.NONLEAF_ALLOCATION_COUNT, 0) AS UpdateSplit,
partition_sums.TotalPages,
partition_sums.TotalRows,
partition_sums.reserved_in_row_MB AS IndexSize_MB,
GETDATE() AS CollectionDateTime
FROM sys.indexes AS si
JOIN sys.tables AS t ON si.object_id=t.object_id  
JOIN sys.schemas AS sc ON t.schema_id=sc.schema_id 
--INNER JOIN #TableName tn on tn.FullName = sc.name + '.' + t.name
LEFT JOIN #TableName tn on tn.FullName = sc.name + '.' + t.name

LEFT JOIN SYS.DM_DB_INDEX_OPERATIONAL_STATS(DB_ID(),NULL,NULL,NULL) IOS ON IOS.OBJECT_ID=t.OBJECT_ID AND IOS.INDEX_ID=si.INDEX_ID
/* Partitions */ OUTER APPLY ( 
    SELECT 
        COUNT(*) AS partition_count,
        CAST(SUM(ps.in_row_reserved_page_count)*8./1024. AS NUMERIC(32,1)) AS reserved_in_row_MB,
        CAST(SUM(ps.lob_reserved_page_count)*8./1024. AS NUMERIC(32,1)) AS reserved_LOB_MB,
        SUM(ps.in_row_reserved_page_count) AS TotalPages,
        SUM(ps.row_count) AS TotalRows
    FROM sys.partitions AS p
    JOIN sys.dm_db_partition_stats AS ps ON
        p.partition_id=ps.partition_id
    WHERE p.object_id = si.object_id
        and p.index_id=si.index_id
    ) AS partition_sums
WHERE t.TYPE_DESC='USER_TABLE' AND si.type_desc <> 'HEAP'
  AND tn.FullName IS NULL
  AND ISNULL(IOS.LEAF_ALLOCATION_COUNT, 0) > 1000
ORDER BY 
partition_sums.reserved_in_row_MB / ISNULL(IOS.LEAF_ALLOCATION_COUNT, 0)
--ISNULL(IOS.LEAF_ALLOCATION_COUNT, 0) desc
--partition_sums.reserved_in_row_MB DESC, sc.name, t.name, IOS.index_id