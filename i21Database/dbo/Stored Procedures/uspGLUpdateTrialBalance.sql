CREATE PROCEDURE uspGLUpdateTrialBalance 
	@GLEntries RecapTableType READONLY
AS
DECLARE @dateTime DATETIME = GETDATE()
MERGE 
	INTO	dbo.tblGLTrialBalance
	WITH	(HOLDLOCK) 
	AS		TrialBalanceTable
	USING(
		SELECT intAccountId, sum(dblDebit-dblCredit) dblAmount , F.intGLFiscalYearPeriodId  FROM  @GLEntries
		JOIN tblGLFiscalYearPeriod F on dtmDate between F.dtmStartDate and F.dtmEndDate
		GROUP BY intAccountId, intGLFiscalYearPeriodId
	)AS GLEntries
	ON GLEntries.intAccountId = TrialBalanceTable.intAccountId  AND GLEntries.intGLFiscalYearPeriodId = TrialBalanceTable.intGLFiscalYearPeriodId 
	WHEN MATCHED
		THEN
		UPDATE SET TrialBalanceTable.MTDBalance = TrialBalanceTable.MTDBalance + GLEntries.dblAmount,
		TrialBalanceTable.YTDBalance = TrialBalanceTable.YTDBalance + GLEntries.dblAmount,
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
			,GLEntries.dblAmount
			,GLEntries.dblAmount
			,@dateTime
			,1
		);
GO