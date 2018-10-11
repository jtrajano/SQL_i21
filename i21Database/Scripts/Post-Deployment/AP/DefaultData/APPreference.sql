GO
IF NOT EXISTS(SELECT 1 FROM  tblAPCompanyPreference)
BEGIN
	INSERT INTO  tblAPCompanyPreference (
		[intApprovalListId]	   
		,[intDefaultAccountId]  
		,[intWithholdAccountId] 
		,[intDiscountAccountId] 
		,[intInterestAccountId] 
		,[dblWithholdPercent]
		,[strReportGroupName]
		,[strClaimReportName]
		,[intCheckPrintId]
		,[intConcurrencyId] 
	)
	SELECT
		
		[intApprovalListId]		= NULL
		,[intDefaultAccountId]	= NULL 
		,[intWithholdAccountId] = NULL
		,[intDiscountAccountId] = NULL
		,[intInterestAccountId] = NULL
		,[dblWithholdPercent]	= 0.00
		,[strReportGroupName]	= ''
		,[strClaimReportName]	= ''
		,[intCheckPrintId]		= 1
		,[intConcurrencyId]		= 1
END
ELSE
BEGIN 
	IF  EXISTS(SELECT 1 FROM  tblAPCompanyPreference WHERE intCheckPrintId IS NULL)
	BEGIN
		UPDATE tblAPCompanyPreference 
		SET intCheckPrintId = 1
	END
END
