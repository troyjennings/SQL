
--IF OBJECT_ID('tempdb..#TableProviders') IS NOT NULL DROP TABLE #TableProviders
--CREATE TABLE #TableProviders (ProviderName NVARCHAR(255), ProviderType NVARCHAR(50))

--INSERT INTO #TableProviders
--SELECT REPLACE(REPLACE(LTRIM(value), CHAR(13), ''), CHAR(10), ''), 'Bank'
--FROM
--STRING_SPLIT 
--('Chase Auto Finance, Bank Of America, Wells Fargo Bank,
--Suntrust Bank, M&T Bank, Bmo Harris Bank,
--Huntington National Bank, Comerica Bank,
--Compass Bank Automated Flrpln, Branch Banking & Trust Co,
--US Bank, Key Bank, Bank Of America - Manual Pmt,
--PNC Bank, Bank Of The West,
--JP MORGAN CHASE FINANCIAL - FLOORPLAN,
--Td Bank Automated Floorplan, World Omni Financial - Auto,
--Fifth Third Bank, Sovereign Bank, Capital One,
--Banco Popular, Fulton Bank, S&T Bank,
--BBVA Compass (PRAA), Reliable Finance Holding Co.,
--First Hawaiian Bank, US Bank Manual,
--First Choice Financial Service, Banco Popular (PRAA),
--Republic Bank, Wells Fargo Revolving Credit, First Bank,
--Townebank, First Bank (PRAA), BMO HARRIS BANK -FLOORPLAN,
--Trustmark National Bank, Bank Of Hawaii,
--First National Bank, Banking Services Corp, Compass Bank,
--Macatawa Bank, Legacy Services Group, Cosmopolitan Finance,
--TD Banknorth NA, Oriental Bank, First Source, Ws Lending,
--Farmers & Merchants, Katahdin Trust Company,
--Jpmorgan Chase, Mainland Bank, Service Credit Union,
--BRSR Investment, Commercial State Bank, Scotia Bank (PRAA),
--World Omni Financial - Manual, Wesbanco Bank, Inc,
--Androscoggin Bank',',')
WITH CanZIP (business_unit_name,division_name,region_name,market_name,zip) AS 
(SELECT 
  ISNULL(u.name,'International') AS business_unit_name
	,ISNULL(d.division_name, 'Unassigned') AS division_name
	,ISNULL(r.name, 'Unassigned') AS region_name
	,ISNULL(b.name, 'Unassigned') AS market_name
	,CAST(UPPER(LEFT(LTRIM(z.zip),3)) AS VARCHAR(10)) AS zip
FROM DSCWarehouse.emap.ca_centers c WITH(nolock)
-- In case there are new zip codes in the TerrAlign tables
LEFT OUTER JOIN DSC2Prod.dbo.contract_zip_branch_mappings z WITH(nolock) ON CAST(c.gid AS VARCHAR) = z.zip
LEFT OUTER JOIN DSC2Prod.dbo.branches b WITH(nolock) ON (z.branch_id = b.id)
LEFT OUTER JOIN DSC2Prod.dbo.regions r WITH(nolock) ON (b.region_id = r.id)
LEFT OUTER JOIN DSC2Prod.dbo.divisions d WITH(nolock) ON (r.division_id = d.id)
LEFT OUTER JOIN DSC2Prod.dbo.business_units u WITH(nolock) ON (d.business_unit_id = u.id)
	  -- We need to get all zipcodes not just those where we have dealers
WHERE (u.name = 'International' 
	AND LEN(z.zip) = 3
	-- Get only the most current "key" market assignment for each zip code.
	AND z.timestamp = (SELECT MAX(zz.timestamp) FROM DSC2Prod.dbo.contract_zip_branch_mappings zz WITH(nolock)
												JOIN DSC2Prod.dbo.branches zb WITH(nolock) ON (zz.branch_id = zb.id)
												JOIN DSC2Prod.dbo.regions zr WITH(nolock) ON (zb.region_id = zr.id)
												JOIN DSC2Prod.dbo.divisions zd WITH(nolock) ON (zr.division_id = zd.id)
												JOIN DSC2Prod.dbo.business_units zu WITH(nolock) ON (zd.business_unit_id = zu.id)
											WHERE zu.name = 'International' 
											AND LEN(zz.zip) = 3						
											AND (z.zip = zz.zip)
                      ))
	OR z.id IS NULL
GROUP BY 
	u.name,
	d.division_name,
	r.name,
	b.name,
	z.zip),
  USZIP (business_unit_name,division_name,region_name,market_name,zip) AS 
(SELECT 
		   ISNULL(u.name,'Key') AS business_unit_name
		  ,ISNULL(d.division_name, 'Unassigned') AS division_name
		  ,ISNULL(r.name, 'Unassigned') AS region_name
		  ,ISNULL(b.name, 'Unassigned') AS market_name
		  ,z.zip AS zip
	  FROM DSCWarehouse.emap.us_id_to_shape i WITH(nolock)
	  JOIN DSCWarehouse.emap.us_centers c WITH(nolock) ON (i.shape = c.gid)
	  -- In case there are new zip codes in the TerrAlign tables
	  LEFT OUTER JOIN DSC2Prod.dbo.contract_zip_branch_mappings z WITH(nolock) ON CAST(i.id AS VARCHAR) = z.zip
	  LEFT OUTER JOIN DSC2Prod.dbo.branches b WITH(nolock) ON (z.branch_id = b.id)
	  LEFT OUTER JOIN DSC2Prod.dbo.regions r WITH(nolock) ON (b.region_id = r.id)
	  LEFT OUTER JOIN DSC2Prod.dbo.divisions d WITH(nolock) ON (r.division_id = d.id)
	  LEFT OUTER JOIN DSC2Prod.dbo.business_units u WITH(nolock) ON (d.business_unit_id = u.id)
	  -- We need to get all zipcodes not just those where we have dealers
	 WHERE (u.name = 'Key' 
	   AND LEN(z.zip) = 5
	   -- Get only the most current "key" market assignment for each zip code.
	   AND z.timestamp = (SELECT MAX(zz.timestamp) FROM DSC2Prod.dbo.contract_zip_branch_mappings zz WITH(nolock)
												   JOIN DSC2Prod.dbo.branches zb WITH(nolock) ON (zz.branch_id = zb.id)
												   JOIN DSC2Prod.dbo.regions zr WITH(nolock) ON (zb.region_id = zr.id)
												   JOIN DSC2Prod.dbo.divisions zd WITH(nolock) ON (zr.division_id = zd.id)
												   JOIN DSC2Prod.dbo.business_units zu WITH(nolock) ON (zd.business_unit_id = zu.id)
												  WHERE zu.name = 'Key' 
													AND LEN(zz.zip) = 5									
													AND (z.zip = zz.zip)))
		 OR z.id IS NULL
	 GROUP BY 
			  u.name,
			  d.division_name,
			  r.name,
			  b.name,
			  z.zip),
FactDealer ([Business Id], [Business Number], [Is Written Off], [Total Principal Balance], [LOC Amount], [Snapshot Date]) AS
(SELECT 
       btyp2.[Business Id]
     , btyp2.[Business Number]
     , btyp2.[Is Written Off]
     , dlr.[Total Principal Balance]
     , dlr.[LOC Amount]
     , dt.[Date] AS [Snapshot Date]
  FROM DSCWarehouse.Dealer.FactDealer AS dlr WITH (NOLOCK)
 INNER JOIN DSCWarehouse.Securitization.DimBusinessType2 AS btyp2 WITH (NOLOCK)
    ON dlr.[Securitization Business Key] = btyp2.PK_Dim_Business
 INNER JOIN DSCWarehouse.Dealer.DimTimeDealerFactSnapshotDate AS dt WITH (NOLOCK)
    ON dlr.[Snapshot Date Key] = dt.PK_Dim_Date
  INNER JOIN
    (
      SELECT (CAST((YEAR(DT.Year)) AS CHAR(4)) + '-' + CAST((MONTH(DT.Month)) AS VARCHAR(2)) + '-'
              + CAST((MAX(DT.Day_of_Month)) AS VARCHAR(2)) + ' 00:00:00.000'
            ) AS 'Snapshot Dates'
      FROM DSCWarehouse.dbo.DimTime DT
      WHERE YEAR(DT.Year) > 2015
      GROUP BY DT.Year,
              DT.Month
    ) AS DTime ON DTime.[Snapshot Dates] = dt.Date   )


SELECT CASE
           WHEN D.division_name IS NULL
                AND FPA.[Operating_Location_Country] <> 'Canada' THEN
               ZIP.division_name
           WHEN D.division_name IS NULL
                AND FPA.[Operating_Location_Country] = 'Canada' THEN
               CZIP.division_name
           ELSE
               D.division_name
       END AS 'Division',
       CASE
           WHEN R.name IS NULL
                AND FPA.[Operating_Location_Country] <> 'Canada' THEN
               ZIP.region_name
           WHEN R.name IS NULL
                AND FPA.[Operating_Location_Country] = 'Canada' THEN
               CZIP.region_name
           ELSE
               R.name
       END AS 'Region',
       CASE
           WHEN BR.name IS NULL
                AND FPA.[Operating_Location_Country] <> 'Canada' THEN
               ZIP.market_name
           WHEN BR.name IS NULL
                AND FPA.[Operating_Location_Country] = 'Canada' THEN
               CZIP.market_name
           ELSE
               BR.name
       END AS 'Market',
       CASE
           WHEN FPA.[Floor_Plan_Customer_Name] LIKE '%next%'
                OR BR.number IS NOT NULL
                OR R.name IS NOT NULL THEN
               'Yes'
           ELSE
               'No'
       END AS 'NGC Dealer',
       CASE
           WHEN FPA.[Buyer_Account_NUL_Code] IN ( 'N', 'L' )
                OR FPA.[Buyer_Customer_MEGASLR_Group_Name] IN ( 'CARMAX CORPORATE HQ', 'Drivetime', 'CARVANA' ) THEN
               'Franchise/Mega Indy'
           ELSE
               'Independent'
       END AS 'Dealer Class',
       PM.description AS 'Performance Market',
       AAA.[Business Number],
       BS.[Buyer Business Relationship Status Name] AS 'Buyer Status',
       RS.IsLocked,
       RS.LocSegment,
       RS.AcctRiskScore,
       RS.AcctRiskGrp,
       RS.LocAmount,
       ISNULL(DLR.[LOC Amount], 0) AS 'Credit Limit',
       ISNULL(DLR.[Total Principal Balance], 0) AS 'Total Principal Balance',
       DLR.[Snapshot Date],
       CASE
           WHEN (FPA.[Floor_Plan_Customer_Name]) LIKE '%next%' THEN
               'NGC'
           WHEN (FPA.[Floor_Plan_Customer_Name]) IN ( 'Auto Bank Floorplan  Llc', 'auto bank floorplan llc',
                                                      'Westlake Flooring', 'City Auto Finance Llc', 'AFC',
                                                      'Afc Automated Outside Flooring', 'AFC Rental', 'AFC RV',
                                                      'AUTOMOTIVE FINANCE CORP - FLOAT',
                                                      'AUTOMOTIVE FINANCE CORP - TRA', 'ALLY/GMAC',
                                                      'Westlake Financial Services', 'Floorplan Xpress',
                                                      'Floorplan Xpress LLC', 'Carbucks Inc', 'Hinckley''s Inc.',
                                                      'Safs (Southern Auto Auction)', 'Automotive Capital Services',
                                                      'Auctioncredit Enterprises LLC', 'Auto Use',
                                                      'Vehicle Acceptance Corporation', 'Automotive Capital Services',
                                                      'Auto Bank Floorplan, LLC', 'City Auto Finance, Llc',
                                                      'Primalend Capital Group Inc', 'Auto Dealers Investments Inc',
                                                      'Car Financial', 'Diamond Floor Plan Inc',
                                                      'Reliable Financial (PRAA)', 'Used Cars Inc.',
                                                      'Pinnacle Financial Partners', 'Flex Plus Llc',
                                                      'Auto Finance Solutions', 'Southern Auto Auction',
                                                      'Dealer Preferred Capital', 'Automotive Dealers Finance',
                                                      'KCS Floor Plan', 'ABS Finance', 'ACR Dealer Funding',
                                                      'Coastal Dealer Services', 'Direct Financial Services LLC',
                                                      'Dealers Credit Express', 'Dealer Financial',
                                                      'Greater Kalamazoo Auto Auction', 'Shamrock Finance',
                                                      'Valley National', 'Strategic Finance LLC',
                                                      'Commander Financial Svcs Llc', 'Ace Motor Acceptance Corp',
                                                      'Pinnacle Financial Group LLC', 'First Acceptance', 'Partners 1',
                                                      'Automotive Capital Corp Of Atl', 'Auto Funding Group',
                                                      'Fresno Commercial Lenders', 'GE Commerical Distribution Fin',
                                                      'Quick Capital', 'Auction Solution', 'The Auto Fund',
                                                      'Palisades Dealer Funding LLC', 'Triangle Auto',
                                                      'Marlton Auto Credit', 'Dealers First Financial LLC',
                                                      'Hinckley%', 'Freedom Financial Capital Llc',
                                                      'Manheim Express Title Absent', 'Automotive Finance Solutions',
                                                      'Brasher%', 'Manheim Chicago', 'Cars On Credit'
                                                    ) THEN
               'Floor Plan'
           WHEN (FPA.[Floor_Plan_Customer_Name]) IN ( ' ', 'Joe Carrollo', 'MAFS', 'Manheim Globaltrader' ) THEN
               'Cash'
           WHEN (FPA.[Floor_Plan_Customer_Name]) IN ( 'BENTLEY FINANCIAL SERVICES', 'FORD MOTOR CREDIT',
                                                      'Ford Signature Closed Sale', 'Toyota Financial Auto Fp',
                                                      'Nissan Motor - Manual', 'Ford Signature Open Sale',
                                                      'Ford Used Auction Floor Plan', 'BMW',
                                                      'Nissan Motor Acceptance Corp', 'Mercedes Benz Financial Servic',
                                                      'GM Financial', 'Ford Manual Floor Plan',
                                                      'Hyundai Automated Floor Plan', 'Ford Motor Credit Manual',
                                                      'American Honda Finance Corp', 'Chrysler Capital',
                                                      'Volkswagen Credit', 'Toyota Financial Manual FP',
                                                      'Volkswagen Manual', 'Ford Motor Comp Service/FMCC',
                                                      'MERCEDES BENZ FINANCIAL SERVICES - FLOORPLAN',
                                                      'Harley Davidson Credit', 'Toyota Credit (PRAA)',
                                                      'Hyundai Motor Finance - Kia', 'Ford Signature Canada',
                                                      'Porsche', 'Subaru', 'Landrover', 'Jaguar',
                                                      'Hitachi Capital America Corp', 'Volkswagen Group Canada Tdi',
                                                      'GM Financial Canada', 'ARCTIC CAT',
                                                      'Mercedes Benz Financial-Manual', 'Hyundai Capital Canada'
                                                    ) THEN
               'OEM'
           WHEN (FPA.[Floor_Plan_Customer_Name]) IN ( 'Chase Auto Finance', 'Bank Of America', 'Wells Fargo Bank',
                                                      'Suntrust Bank', 'M&T Bank', 'Bmo Harris Bank',
                                                      'Huntington National Bank', 'Comerica Bank',
                                                      'Compass Bank Automated Flrpln', 'Branch Banking & Trust Co',
                                                      'US Bank', 'Key Bank', 'Bank Of America - Manual Pmt',
                                                      'PNC Bank', 'Bank Of The West',
                                                      'JP MORGAN CHASE FINANCIAL - FLOORPLAN',
                                                      'Td Bank Automated Floorplan', 'World Omni Financial - Auto',
                                                      'Fifth Third Bank', 'Sovereign Bank', 'Capital One',
                                                      'Banco Popular', 'Fulton Bank', 'S&T Bank',
                                                      'BBVA Compass (PRAA)', 'Reliable Finance Holding Co.',
                                                      'First Hawaiian Bank', 'US Bank Manual',
                                                      'First Choice Financial Service', 'Banco Popular (PRAA)',
                                                      'Republic Bank', 'Wells Fargo Revolving Credit', 'First Bank',
                                                      'Townebank', 'First Bank (PRAA)', 'BMO HARRIS BANK -FLOORPLAN',
                                                      'Trustmark National Bank', 'Bank Of Hawaii',
                                                      'First National Bank', 'Banking Services Corp', 'Compass Bank',
                                                      'Macatawa Bank', 'Legacy Services Group', 'Cosmopolitan Finance',
                                                      'TD Banknorth NA', 'Oriental Bank', 'First Source', 'Ws Lending',
                                                      'Farmers & Merchants', 'Katahdin Trust Company',
                                                      'Jpmorgan Chase', 'Mainland Bank', 'Service Credit Union',
                                                      'BRSR Investment', 'Commercial State Bank', 'Scotia Bank (PRAA)',
                                                      'World Omni Financial - Manual', 'Wesbanco Bank, Inc',
                                                      'Androscoggin Bank'
                                                    ) THEN
               'Bank'
           ELSE
               FPA.[Floor_Plan_Customer_Name]
       END AS 'Provider',
     
       CASE
           WHEN (FPA.[Buyer_Account_Number]) LIKE '[A-Z]%' THEN
               0
           ELSE
               FPA.[Buyer_Account_Number]
       END AS 'Buyer Account Number',
       FPA.[Buyer_Account_Name],
       FPA.[Transaction_Date_Calendar_Year_Month],
       FPA.[Seller_Customer_MEGASLR_Group_Name],
       FPA.[Seller_Account_Number],
       FPA.[Seller_Account_Name],
       FPA.[Transaction_Date_Reporting_Week],
       FPA.[VIN],
       SUBSTRING([VIN], 10, 1) AS VIN10,
       FPA.[Operating_Location],
       FPA.[Operating_Division],
       FPA.[Operating_Location_State],
       FPA.[Operating_Location_Zip_Code],
       FPA.[Operating_Location_Country],
       FPA.[Transaction_Application_Channel],
       FPA.[Dealer_or_Commercial],
       FPA.[FLNDR_Description],
       FPA.[Buyer_Account_NUL_Code],
       FPA.[Floor_Plan_Customer_Name],
       FPA.[Buyer_Customer_MEGASLR_Group_Name],
       FPA.[Payment_Type],
       FPA.[Registration_Application],
       FPA.[Net_Transactions_Total],
       FPA.[Final_Purchase_Price],
       FPA.[Final_Purchase_Price_Tier_Summarized],
       CAST(FPA.[Buyer_Customer_Physical_Zip_Code] AS VARCHAR(10)) AS 'Buyer Customer Physical Zip Code',
       FPA.[Buyer_Customer_OVC_ID],
       FPA.[Payment_Receipt_Method],
       FPA.[Floor_Plan_Agency_Code],
       FPA.[Buyer_Account_Physical_Address_Line_1],
       FPA.[Buyer_Account_Physical_Address_Line_2],
       FPA.[Buyer_Account_Physical_City],
       FPA.[Buyer_Account_Physical_State],
       FPA.[Buyer_Customer_Phone],
       FPA.[Buyer_Customer_Primary_Contact_Name],
       FPA.[Registration_Application_Channel],
       FPA.[Buyer_Deposit_Date_Key],
       FPA.[Mobile_Auction_Flag]
FROM [CSVImport].[dbo].[ManheimDataLoad] FPA WITH (NOLOCK)
    OUTER APPLY
     (
         SELECT AA.auction_access_dealership_number,
                MAX(AA.business_number) AS 'Business Number'
         FROM
         (
             SELECT B.auction_access_dealership_number,
                    B.business_number
             FROM DSC2Prod.dbo.businesses B WITH (NOLOCK)
             UNION
             SELECT AAC.company_id AS auction_access_dealership_number,
                    B.business_number
             FROM DSC2Prod.dbo.auction_access_companies AAC WITH (NOLOCK)
                 LEFT JOIN DSC2Prod.dbo.businesses B WITH (NOLOCK)
                     ON B.id = AAC.business_id
         ) AS AA
         WHERE AA.auction_access_dealership_number = 
         CASE
           WHEN (FPA.[Buyer_Account_Number]) LIKE '[0-9]%' THEN
               FPA.[Buyer_Account_Number]
           ELSE
               0
          END
                                                     
         GROUP BY AA.auction_access_dealership_number
     ) AS AAA
    ---------------------------------------------------------------------
    LEFT OUTER JOIN USZIP
     --(
         --SELECT ZIP.t4_zip,
         --       ZIP.market_name,
         --       ZIP.region_name,
         --       ZIP.division_name,
         --       ZIP.zip
         --FROM DSCWarehouse.eMap.us_key_zipcode_assignment ZIP WITH (NOLOCK)
         --WHERE ZIP.zip IS NOT NULL

     --) 
     AS ZIP
		ON [ZIP].[zip] =  CAST(FPA.[Buyer_Customer_Physical_Zip_Code] AS VARCHAR(10))
    LEFT OUTER JOIN CanZIP
     --(
     --    SELECT CZIP.t4_zip,
     --           CZIP.market_name,
     --           CZIP.region_name,
     --           CZIP.division_name,
     --           CZIP.zip
     --    FROM DSCWarehouse.eMap.ca_international_zipcode_assignment CZIP WITH (NOLOCK)
     --    WHERE CZIP.zip IS NOT NULL

     --) 
     AS CZIP
	  ON FPA.[Operating_Location_Country] = CZIP.division_name
	  AND CZIP.zip = LEFT(FPA.[Buyer_Customer_Physical_Zip_Code], 3)
    LEFT OUTER JOIN FactDealer
     --(
     --    SELECT FDV.[Snapshot Date],
     --           FDV.[Business Id],
     --           FDV.[Is Written Off],
     --           FDV.[Business Number],
     --           FDV.[LOC Amount],
     --           FDV.[Total Principal Balance]
     --    FROM DSCWarehouse.Dealer.FactDealerView FDV WITH (NOLOCK)
     --    WHERE FDV.[Snapshot Date] IN
     --          (
     --              SELECT (CAST((YEAR(DT.Year)) AS CHAR(4)) + '-' + CAST((MONTH(DT.Month)) AS VARCHAR(2)) + '-'
     --                      + CAST((MAX(DT.Day_of_Month)) AS VARCHAR(2)) + ' 00:00:00.000'
     --                     ) AS 'Snapshot Dates'
     --              FROM DSCWarehouse.dbo.DimTime DT
     --              WHERE YEAR(DT.Year) > 2015
     --              GROUP BY DT.Year,
     --                       DT.Month
     --          )

     --) 
     DLR
		ON DLR.[Business Number] = AAA.[Business Number]
        AND YEAR(DLR.[Snapshot Date]) = LEFT(FPA.[Buyer_Deposit_Date_Key], 4)
        AND MONTH(DLR.[Snapshot Date]) = RIGHT(LEFT(FPA.[Buyer_Deposit_Date_Key], 6), 2)
    OUTER APPLY
     (
         SELECT ARS.[BusinessNumber],
                ARS.[LocAmount],
                ARS.[IsLocked],
                ARS.[LocSegment],
                ARS.[AcctRiskScore],
                ARS.[AcctRiskGrp]
         FROM
         (
             SELECT [ModelVersion],
                    [ScoreEffectiveDate],
                    [LocAmount],
                    [BusinessNumber],
                    [LocSegment],
                    [AcctRiskScore],
                    [IsLocked],
                    [AcctRiskGrp],
                    ROW_NUMBER() OVER (PARTITION BY [BusinessNumber] ORDER BY [ScoreEffectiveDate] DESC) AS rn
             FROM [DSCWarehouse].[dbo].[BI_AccountRiskScores] WITH (NOLOCK)
         ) AS ARS
         WHERE ARS.rn = 1
               AND ARS.ModelVersion =
               (
                   SELECT MAX(ARS2.ModelVersion)
                   FROM DSCWarehouse.dbo.BI_AccountRiskScores ARS2 WITH (NOLOCK)
               )
               AND ARS.BusinessNumber = AAA.[Business Number]
     ) RS
    OUTER APPLY
     (
         SELECT BRS.[Buyer Business Number],
                BRS.[Buyer Business Relationship Status Name],
                BRS.[Buyer Business Relationship Reason Description]
         FROM [DSCWarehouse].[Securitization].[DimBuyerBusinessRelationshipStatusType2] BRS
         WHERE BRS.PK_Dim_BusinessStatus > 0
               AND BRS.[Effective Date] <= (CAST(LEFT(FPA.[Buyer_Deposit_Date_Key], 4) AS CHAR(4)) + '-'
                                            + CAST(RIGHT(LEFT(FPA.[Buyer_Deposit_Date_Key], 6), 2) AS VARCHAR(2)) + '-'
                                            + CAST(RIGHT(FPA.[Buyer_Deposit_Date_Key], 2) AS VARCHAR(2))
                                            + ' 00:00:00.000'
                                           )
               AND BRS.[End Date] IS NULL
               AND BRS.[Buyer Business Number] = AAA.[Business Number]
         --AND BRS.[Buyer Business Relationship Status Name] <> 'Not Applicable'

         UNION
         SELECT BRS.[Buyer Business Number],
                BRS.[Buyer Business Relationship Status Name],
                BRS.[Buyer Business Relationship Reason Description]
         FROM [DSCWarehouse].[Securitization].[DimBuyerBusinessRelationshipStatusType2] BRS
         WHERE BRS.PK_Dim_BusinessStatus > 0
               AND BRS.[Effective Date] <= (CAST(LEFT(FPA.[Buyer_Deposit_Date_Key], 4) AS CHAR(4)) + '-'
                                            + CAST(RIGHT(LEFT(FPA.[Buyer_Deposit_Date_Key], 6), 2) AS VARCHAR(2)) + '-'
                                            + CAST(RIGHT(FPA.[Buyer_Deposit_Date_Key], 2) AS VARCHAR(2))
                                            + ' 00:00:00.000'
                                           )
               AND BRS.[End Date] > (CAST(LEFT(FPA.[Buyer_Deposit_Date_Key], 4) AS CHAR(4)) + '-'
                                     + CAST(RIGHT(LEFT(FPA.[Buyer_Deposit_Date_Key], 6), 2) AS VARCHAR(2)) + '-'
                                     + CAST(RIGHT(FPA.[Buyer_Deposit_Date_Key], 2) AS VARCHAR(2)) + ' 00:00:00.000'
                                    )
               AND BRS.[Buyer Business Number] = AAA.[Business Number]
     --AND BRS.[Buyer Business Relationship Status Name] <> 'Not Applicable'

     ) BS
    LEFT JOIN DSC2Prod.dbo.businesses B2 WITH (NOLOCK)
        ON B2.business_number = AAA.[Business Number]
    LEFT JOIN DSC2Prod.dbo.branches BR WITH (NOLOCK)
        ON BR.id = B2.branch_id
    LEFT JOIN DSC2Prod.dbo.regions R WITH (NOLOCK)
        ON R.id = BR.region_id
    LEFT JOIN DSC2Prod.dbo.divisions D WITH (NOLOCK)
        ON D.id = R.division_id
    LEFT JOIN DSC2Prod.dbo.business_units BU WITH (NOLOCK)
        ON BU.id = D.business_unit_id
    LEFT JOIN DSC2Prod.dbo.performance_markets PM WITH (NOLOCK)
        ON PM.id = B2.performance_market_id
WHERE FPA.[Buyer_Deposit_Date_Key] >= 20170101
      AND FPA.[Operating_Location_Country] <> 'Canada'
      AND FPA.[Registration_Application] <> 'TRAcast'
      AND FPA.[Buyer_Account_NUL_Code] NOT IN ( 'N', 'L' )
      AND FPA.[Buyer_Customer_MEGASLR_Group_Name] NOT IN ( 'CARMAX CORPORATE HQ', 'Drivetime', 'carvana' )
      --AND PM.id IS NOT NULL

      AND (CASE
               WHEN D.division_name IS NULL
                    AND FPA.[Operating_Location_Country] <> 'Canada' THEN
                   ZIP.division_name
               WHEN D.division_name IS NULL
                    AND FPA.[Operating_Location_Country] = 'Canada' THEN
                   CZIP.division_name
               ELSE
                   D.division_name
           END
          ) IN ( 'East', 'Central', 'West', 'Major Dealer' )