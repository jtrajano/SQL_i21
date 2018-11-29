CREATE PROCEDURE uspGLUpdateTrialBalance 
	@GLEntries RecapTableType READONLY
AS
DECLARE @intGLFiscalYearPeriodId INT, @intAccountId INT,@MTDBalance numeric(38,6), @YTDBalance numeric(38,6)

DECLARE @temp TABLE
(
  intAccountId int, 
  dblAmount numeric(18,6),
  intGLFiscalYearPeriodId int
)
INSERT INTO @temp
select intAccountId, sum(dblDebit-dblCredit) dblAmount , F.intGLFiscalYearPeriodId  FROM  @GLEntries
JOIN tblGLFiscalYearPeriod F on dtmDate between F.dtmStartDate and F.dtmEndDate
GROUP BY intAccountId, intGLFiscalYearPeriodId


UPDATE tblGLTrialBalance set 
	MTDBalance = MTDBalance + T.dblAmount, 
	YTDBalance= YTDBalance + T.dblAmount,
	dtmDateModified = GETDATE(), 
	intConcurrencyId = ISNULL(intConcurrencyId,0) +1
FROM tblGLTrialBalance TB JOIN
@temp T ON T.intAccountId = TB.intAccountId AND T.intGLFiscalYearPeriodId = TB.intGLFiscalYearPeriodId

GO