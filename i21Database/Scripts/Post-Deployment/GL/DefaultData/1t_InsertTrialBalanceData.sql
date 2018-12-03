IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLTrialBalance)
BEGIN
	INSERT INTO tblGLTrialBalance ( [intAccountId],[MTDBalance],[YTDBalance],[intGLFiscalYearPeriodId], intConcurrencyId, dtmDateModified)
	 SELECT 
	[intAccountId], 
	[MTDBalance], 
	[YTDBalance], 
	[intGLFiscalYearPeriodId],
	1,
	GETDATE()
	FROM [dbo].[vyuGLTrialBalanceRE_NonRE] AS [Extent1]
END