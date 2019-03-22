CREATE PROCEDURE uspGLUpdateTrialBalance 
	@GLEntries RecapTableType READONLY
AS
DECLARE @dtmDate DATETIME = GETDATE();
MERGE 
	INTO	dbo.tblGLTrialBalance
	WITH	(HOLDLOCK) 
	AS		TrialBalanceTable
	USING	(
		SELECT intAccountId, 
		sum(dblDebit-dblCredit) dblAmount,
		F.intGLFiscalYearPeriodId  intGLFiscalYearPeriodId
		FROM  @GLEntries,  tblGLFiscalYearPeriod F 
		JOIN tblGLFiscalYear FY ON FY.intFiscalYearId = F.intFiscalYearId
		where dtmDate < F.dtmEndDate
		GROUP BY intAccountId, intGLFiscalYearPeriodId
	) AS TrialBalanceUpdateEntry
	ON TrialBalanceUpdateEntry.intGLFiscalYearPeriodId = TrialBalanceTable .intGLFiscalYearPeriodId
	AND TrialBalanceUpdateEntry.intAccountId = TrialBalanceTable.intAccountId
	WHEN MATCHED THEN 
		UPDATE 
		SET TrialBalanceTable.YTDBalance = ISNULL(TrialBalanceTable.YTDBalance,0) + ISNULL(TrialBalanceUpdateEntry.dblAmount,0),
		TrialBalanceTable.dtmDateModified = @dtmDate,
		TrialBalanceTable.intConcurrencyId = TrialBalanceTable.intConcurrencyId + 1
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			intAccountId
			,intGLFiscalYearPeriodId
			,YTDBalance
			,dtmDateModified
			,intConcurrencyId
		)
		VALUES (
			TrialBalanceUpdateEntry.intAccountId
			,TrialBalanceUpdateEntry.intGLFiscalYearPeriodId
			,ISNULL(TrialBalanceUpdateEntry.dblAmount,0)
			,@dtmDate
			,1
		);
MERGE 
	INTO	dbo.tblGLTrialBalance
	WITH	(HOLDLOCK)
	AS		TrialBalanceTable
	USING	(
		select intAccountId, 
		sum(dblDebit-dblCredit) dblAmount,
		F.intGLFiscalYearPeriodId  intGLFiscalYearPeriodId
		FROM  @GLEntries G JOIN  tblGLFiscalYearPeriod F ON
		dtmDate BETWEEN F.dtmStartDate AND F.dtmEndDate
		GROUP BY intAccountId, intGLFiscalYearPeriodId
	) AS TrialBalanceUpdateEntry
	ON TrialBalanceUpdateEntry.intGLFiscalYearPeriodId = TrialBalanceTable .intGLFiscalYearPeriodId
	AND TrialBalanceUpdateEntry.intAccountId = TrialBalanceTable.intAccountId
	WHEN MATCHED THEN 
		UPDATE 
		SET TrialBalanceTable.MTDBalance = ISNULL(TrialBalanceTable.MTDBalance,0) + ISNULL(TrialBalanceUpdateEntry.dblAmount,0),
		TrialBalanceTable.dtmDateModified = @dtmDate,
		TrialBalanceTable.intConcurrencyId = ISNULL(TrialBalanceTable.intConcurrencyId,0) + CASE WHEN dtmDateModified = @dtmDate THEN 0 ELSE  1 END
		
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			intAccountId
			,intGLFiscalYearPeriodId
			,MTDBalance
			,dtmDateModified
			,intConcurrencyId
		)
		VALUES (
			TrialBalanceUpdateEntry.intAccountId
			,TrialBalanceUpdateEntry.intGLFiscalYearPeriodId
			,ISNULL(TrialBalanceUpdateEntry.dblAmount,0)
			,@dtmDate
			,1
		);

GO