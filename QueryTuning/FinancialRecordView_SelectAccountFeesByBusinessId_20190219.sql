CREATE PROCEDURE [dbo].[FinancialRecordView_SelectAccountFeesByBusinessId]
	(
	@businessId UNIQUEIDENTIFIER
)
AS
BEGIN
	declare @Fees table (
		FinancialRecordId uniqueidentifier,
		HasNsf bit);

	insert into @fees
		( FinancialRecordId, HasNsf)
	select fr.financialRecordId, 0
	from financialRecord fr with (nolock)
		inner join financialRecordCache frc with (nolock)
		on fr.financialrecordId = frc.FinancialRecordId
			AND frc.Voided = 0
			AND frc.Balance > 0
	WHERE fr.ResponsibleBusinessId = @businessId
		AND fr.FloorplanId IS NULL
		AND fr.FinancialRecordTypeId = 4;

	update f
	set HasNsf = 1
	from @fees f
		inner join businessnsf bn with (nolock)
		on bn.BusinessId = @Businessid
			and bn.financialrecordid = f.financialrecordid
		inner join financialrecord fr with (nolock)
		on bn.financialrecordid = fr.financialrecordid
			and fr.feetypeid <> 2;


	SELECT
		vw.FinancialRecordId,
		vw.Number,
		vw.Description,
		vw.FinancialContextTypeId,
		vw.FinancialActionTypeId,
		vw.FinancialRecordTypeId,
		b.LanguageId,
		vw.PaymentTypeId,
		vw.FeeTypeId,
		ftl.type AS [FeeTypeName],
		vw.FinancialTransactionId,
		vw.FloorplanId,
		vw.ApplyToFinancialRecordId,
		vw.RootFinancialRecordId,
		vw.ResponsibleBusinessId,
		vw.AmountApplied,
		vw.AmountProvided,
		vw.PostDate,
		vw.CreateDate,
		vw.EffectiveDate,
		vw.UserAccountId,
		vw.UserName,
		vw.StoreDateTime,
		vw.Balance,
		vw.Voided,
		vw.CurrencyId,
		vw.FinancialRecordCategoryId,
		f.HasNsf as [HasNsf],
		vw.Timestamp,
		CAST(
			CASE
				WHEN wsaf.WebScheduledAccountFeeId IS NULL THEN 0
				WHEN wsaf.Cancelled = 1 THEN 0
				WHEN wsaf.Processed = 1 THEN 0
				ELSE 1
			END 
			AS BIT) AS [Scheduled],
		wsaf.WebScheduledAccountFeeId,
		wsaf.ScheduledPaymentDate

	FROM FinancialRecord_View AS vw
		INNER JOIN @Fees f ON f.financialRecordId = vw.FinancialRecordId
		INNER JOIN Business AS b WITH (NOLOCK) ON vw.ResponsibleBusinessId = b.BusinessId

		LEFT JOIN
		(
		SELECT
			wub.BusinessId,
			wub.PreferredWebLanguageId,
			ROW_NUMBER() OVER (PARTITION BY wub.BusinessId ORDER BY wub.LastLoginDateTime DESC) rNum
		FROM BusinessContact wub WITH(NOLOCK) 
	) pref_lang_id ON 
		pref_lang_id.BusinessId = vw.ResponsibleBusinessId AND pref_lang_id.rNum = 1
		LEFT JOIN fee_types_lang AS ftl	WITH(NOLOCK) ON ISNULL(pref_lang_id.PreferredWebLanguageId,1) = ftl.language_id AND vw.FeeTypeId = ftl.fee_type_id
		LEFT JOIN WebScheduledAccountFees wsaf WITH(NOLOCK)
		ON wsaf.FinancialRecordId = vw.FinancialRecordId
			AND 1 = CASE WHEN Processed IS NULL THEN 1 WHEN Processed = 0 THEN 1 ELSE 0 END --(Processed IS NULL OR Processed = 0) 
			AND 1 = CASE WHEN Cancelled IS NULL THEN 1 WHEN Cancelled = 0 THEN 1 ELSE 0 END --(Cancelled IS NULL OR Cancelled = 0 )
    OPTION (RECOMPILE)
END;
