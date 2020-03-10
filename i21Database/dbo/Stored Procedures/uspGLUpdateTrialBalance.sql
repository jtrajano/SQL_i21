﻿CREATE PROCEDURE uspGLUpdateTrialBalance 
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
    strPeriod,
    intConcurrencyId,
    dtmDateModified
)
SELECT 
intAccountId, 
strTransactionId,
sum(dblDebit-dblCredit) dblAmount,
sum(dblDebit-dblCredit) dblAmount,
F.intGLFiscalYearPeriodId  intGLFiscalYearPeriodId,
F.strPeriod,
1,
@dtmDate
FROM  @GLEntries,  tblGLFiscalYearPeriod F 
JOIN tblGLFiscalYear FY ON FY.intFiscalYearId = F.intFiscalYearId
WHERE dtmDate BETWEEN F.dtmStartDate AND F.dtmEndDate
GROUP BY intAccountId, intGLFiscalYearPeriodId, strTransactionId
GO