CREATE PROCEDURE uspGLUpdateTrialBalance 
	@GLEntries RecapTableType READONLY
AS
DECLARE @intGLFiscalYearPeriodId INT, @intAccountId INT,@MTDBalance NUMERIC(38,6), @YTDBalance NUMERIC(38,6)

DECLARE @temp TABLE
(
  intAccountId INT, 
  dblAmount NUMERIC(18,6),
  intGLFiscalYearPeriodId int
)
DECLARE @dtmDate DATETIME = GETDATE();

;WITH CTE AS(
	SELECT intAccountId, 
	sum(dblDebit-dblCredit) dblAmount,
	F.intGLFiscalYearPeriodId  intGLFiscalYearPeriodId
	FROM  @GLEntries,  tblGLFiscalYearPeriod F 
	JOIN tblGLFiscalYear FY ON FY.intFiscalYearId = F.intFiscalYearId
	where dtmDate < F.dtmEndDate
	GROUP BY intAccountId, intGLFiscalYearPeriodId
)
UPDATE TB SET 
	YTDBalance= TB.YTDBalance + dblAmount,
	dtmDateModified = @dtmDate,
	intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
FROM tblGLTrialBalance TB 
JOIN CTE C ON C.intAccountId = TB.intAccountId 
AND C.intGLFiscalYearPeriodId = TB.intGLFiscalYearPeriodId

;WITH CTE AS(
	select intAccountId, 
	sum(dblDebit-dblCredit) dblAmount,
	F.intGLFiscalYearPeriodId  intGLFiscalYearPeriodId
	FROM  @GLEntries G JOIN  tblGLFiscalYearPeriod F ON
	dtmDate BETWEEN F.dtmStartDate AND F.dtmEndDate
	GROUP BY intAccountId, intGLFiscalYearPeriodId
)
UPDATE TB SET 
	MTDBalance= TB.MTDBalance + dblAmount,
	dtmDateModified = @dtmDate,
	intConcurrencyId = ISNULL(intConcurrencyId,0) + CASE WHEN dtmDateModified = @dtmDate THEN 0 ELSE  1 END
FROM tblGLTrialBalance TB 
JOIN CTE C ON C.intAccountId = TB.intAccountId 
AND C.intGLFiscalYearPeriodId = TB.intGLFiscalYearPeriodId
GO