CREATE VIEW [dbo].[vyuGLRetainedEarnings]
AS
WITH c AS (
SELECT
'ExRev' strType,
0 as intGLDetailId,
DATENAME (MM, dtmDate) + ' ' + DATENAME(YY,dtmDate) + ' ' +  strAccountType strTransactionId,
dateadd(day,-1, dateadd(month, datediff(month,0,dtmDate) +1,0)) dtmDate,
sum(dblDebit)dblDebit,
sum(dblCredit)dblCredit,
sum(dblDebitUnit) dblDebitUnit,
sum(dblCreditUnit) dblCreditUnit,
sum(dblDebitForeign) dblDebitForeign,
sum(dblCreditForeign) dblCreditForeign
FROM vyuGLDetail a
WHERE ysnIsUnposted = 0
and strAccountType in ('Expense', 'Revenue')
GROUP BY strAccountType, DATENAME (MM, dtmDate), DATENAME(YY,dtmDate),  dateadd(day,-1, dateadd(month, datediff(month,0,dtmDate) +1,0))
),
d AS (
SELECT 
'RE' strType,
a.intGLDetailId,
a.strTransactionId,
a.dtmDate, 
a.dblDebit,
a.dblCredit, 
a.dblDebitUnit,
a.dblCreditUnit,
a.dblDebitForeign,
a.dblCreditForeign
FROM tblGLDetail a
 WHERE a.ysnIsUnposted = 0
and a.intAccountId in (SELECT intRetainAccount FROM tblGLFiscalYear)
),
u AS (
SELECT * FROM c UNION
SELECT * FROM d
)
SELECT
ISNULL(a.strType,'') strType,
ISNULL(c.strAccountId,'')strAccountId,
ISNULL(c.intAccountId,0)intAccountId,
a.dtmDate,
ISNULL(c.strCode,'')strCode,
ISNULL(c.strBatchId,'')strBatchId,
a.strTransactionId,
ISNULL(c.intEntityId,0)intEntityId,
ISNULL(c.strDescription,'')strDescription,
a.dblDebit,
a.dblCredit,
ISNULL(a.dblDebitUnit,0)dblDebitUnit,
ISNULL(a.dblCreditUnit,0)dblCreditUnit,
ISNULL(c.strUOMCode,'')strUOMCode,
a.dblDebitForeign,
a.dblCreditForeign,
ISNULL(c.strReference,'')strReference,
ISNULL(c.strDocument,'')strDocument,
ISNULL(c.strComments,'')strComments,
ISNULL(c.strUserName,'') strUserName
FROM u a LEFT JOIN
vyuGLDetail c ON a.intGLDetailId = c.intGLDetailId
GO