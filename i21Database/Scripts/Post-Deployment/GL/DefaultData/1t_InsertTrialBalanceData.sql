GO
PRINT ('Begin updating Trial Balance table')
GO
DECLARE @dateTime DATETIME = GETDATE()
MERGE 
	INTO	dbo.tblGLTrialBalance
	WITH	(HOLDLOCK) 
	AS		TrialBalanceTable
	USING(
		select intAccountId, sum(MTDBalance)MTDBalance, sum(YTDBalance)YTDBalance , intGLFiscalYearPeriodId  FROM  [vyuGLTrialBalanceRE_NonRE]
		GROUP BY intAccountId, intGLFiscalYearPeriodId
	)AS GLEntries
	ON GLEntries.intAccountId = TrialBalanceTable.intAccountId  AND GLEntries.intGLFiscalYearPeriodId = TrialBalanceTable.intGLFiscalYearPeriodId 
	WHEN MATCHED AND ( GLEntries.MTDBalance <> TrialBalanceTable.MTDBalance OR GLEntries.YTDBalance <> TrialBalanceTable.YTDBalance)
		THEN
		Update SET TrialBalanceTable.MTDBalance =  GLEntries.MTDBalance,
		TrialBalanceTable.YTDBalance = GLEntries.YTDBalance,
		TrialBalanceTable.intConcurrencyId = TrialBalanceTable.intConcurrencyId + 1,
		dtmDateModified = @dateTime

	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			intAccountId
			,intGLFiscalYearPeriodId
			,MTDBalance
			,YTDBalance
			,dtmDateModified
			,intConcurrencyId
		)
		VALUES (
			GLEntries.intAccountId
			,GLEntries.intGLFiscalYearPeriodId
			,GLEntries.MTDBalance
			,GLEntries.YTDBalance
			,@dateTime
			,1
		)
	WHEN NOT MATCHED BY SOURCE THEN
	DELETE;
GO
PRINT ('Finished updating Trial Balance table')
GO