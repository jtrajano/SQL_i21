CREATE PROCEDURE dbo.uspGLRecalcTrialBalance
AS
DECLARE @dtmDate DATETIME = GETDATE();
MERGE 
	INTO	dbo.tblGLTrialBalance
	WITH	(HOLDLOCK) 
	AS		TB
	USING	(
		SELECT 
		intAccountId, 
		YTDBalance,
		MTDBalance,
		intGLFiscalYearPeriodId
		FROM  vyuGLTrialBalanceRE_NonRE
	) AS VTB
	ON VTB.intGLFiscalYearPeriodId = TB .intGLFiscalYearPeriodId
	AND VTB.intAccountId = TB.intAccountId
	WHEN MATCHED THEN 
		UPDATE 
		SET TB.YTDBalance = TB.YTDBalance,
		TB.MTDBalance = VTB.MTDBalance,
		TB.dtmDateModified = @dtmDate,
		TB.intConcurrencyId = TB.intConcurrencyId + 1
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			intAccountId
			,intGLFiscalYearPeriodId
			,YTDBalance
			,MTDBalance
			,dtmDateModified
			,intConcurrencyId
		)
		VALUES (
			VTB.intAccountId
			,VTB.intGLFiscalYearPeriodId
			,ISNULL(VTB.YTDBalance,0)
			,ISNULL(VTB.MTDBalance,0)
			,@dtmDate
			,1
		);