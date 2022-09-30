CREATE PROCEDURE dbo.uspGLRecalcTrialBalance
AS
DECLARE @dtmDate DATETIME = GETDATE();
TRUNCATE TABLE tblGLTrialBalance
INSERT into tblGLTrialBalance (
			intAccountId
			,intGLFiscalYearPeriodId
			,YTDBalance
			,MTDBalance
			,dtmDateModified
			,strPeriod
			,strCurrency
			,intConcurrencyId

		)

SELECT 
			VTB.intAccountId
			,VTB.intGLFiscalYearPeriodId
			,ISNULL(VTB.YTDBalance,0)
			,ISNULL(VTB.MTDBalance,0)
			,@dtmDate
			,strPeriod
			,strCurrency
			,1
FROM  vyuGLTrialBalanceRE_NonRE VTB


