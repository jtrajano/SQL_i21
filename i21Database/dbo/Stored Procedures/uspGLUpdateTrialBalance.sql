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
FROM  @GLEntries 
    INNER JOIN tblGLFiscalYearPeriod F on 1=1
    JOIN tblGLFiscalYear FY ON FY.intFiscalYearId = F.intFiscalYearId
where 
    dtmDate BETWEEN F.dtmStartDate AND F.dtmEndDate
GROUP BY intAccountId, intGLFiscalYearPeriodId, strTransactionId

-- NON -RETAINED EARNING 
-- ADD YTD BALANCE WHERE PERIOD IS GREATER THAN POSTING DATE
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
FROM @GLEntries A JOIN tblGLFiscalYearPeriod F ON dtmDate BETWEEN F.dtmStartDate AND F.dtmEndDate
inner join tblGLFiscalYearPeriod F1  on 1=1
WHERE F1.dtmEndDate > F.dtmEndDate
AND A.intAccountId NOT IN ( SELECT intRetainAccount FROM tblGLFiscalYear)
GROUP BY intAccountId ,  F1.intGLFiscalYearPeriodId,strTransactionId

-- RETAINED EARNINGS --DEV ONLY
-- ADD YTD BALANCE WHERE PERIOD IS GREATER THAN POSTING DATE UP TO FISCAL PERIOD END
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
FROM @GLEntries A JOIN tblGLFiscalYearPeriod F ON dtmDate BETWEEN F.dtmStartDate AND F.dtmEndDate
JOIN tblGLFiscalYear FY on FY.intFiscalYearId = F.intFiscalYearId
inner join tblGLFiscalYearPeriod F1 on 1=1
WHERE F1.dtmEndDate > F.dtmEndDate and F1.dtmStartDate < FY.dtmDateTo
AND A.intAccountId IN (SELECT  intRetainAccount FROM tblGLFiscalYear)
GROUP BY intAccountId ,  F1.intGLFiscalYearPeriodId, strTransactionId