CREATE PROCEDURE uspGLUpdateTrialBalance 
	@GLEntries RecapTableType READONLY
AS
DECLARE @dtmDate DATETIME = GETDATE();

INSERT INTO tblGLTrialBalance
(
    intAccountId,
    strTransactionId,
    MTDBalance,
    YTDBalance,
    intGLFiscalYearPeriodId,
    intConcurrencyId,
    dtmDateModified
)
SELECT 
intAccountId, 
strTransactionId,
sum(dblDebit-dblCredit) dblAmount,
sum(dblDebit-dblCredit) dblAmount,
F.intGLFiscalYearPeriodId  intGLFiscalYearPeriodId,
1,
@dtmDate
FROM  @GLEntries,  tblGLFiscalYearPeriod F 
JOIN tblGLFiscalYear FY ON FY.intFiscalYearId = F.intFiscalYearId
where dtmDate BETWEEN F.dtmStartDate AND F.dtmEndDate
GROUP BY intAccountId, intGLFiscalYearPeriodId, strTransactionId

INSERT INTO tblGLTrialBalance
(
    intAccountId,
    strTransactionId,
    YTDBalance,
    intGLFiscalYearPeriodId,
    intConcurrencyId,
    dtmDateModified
)
SELECT 
A.intAccountId,
strTransactionId,
sum(dblDebit-dblCredit) dblAmount,
F1.intGLFiscalYearPeriodId,
1,
@dtmDate
FROM @GLEntries A JOIN tblGLFiscalYearPeriod F ON dtmDate BETWEEN F.dtmStartDate AND F.dtmEndDate,
tblGLFiscalYearPeriod F1 
where F1.dtmEndDate > F.dtmEndDate
GROUP BY intAccountId ,  F1.intGLFiscalYearPeriodId,strTransactionId
			