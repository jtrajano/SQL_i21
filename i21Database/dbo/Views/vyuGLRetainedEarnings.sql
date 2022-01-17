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
ISNULL(a.strType,'') COLLATE Latin1_General_CI_AS strType,
ISNULL(c.strAccountId,'')  COLLATE Latin1_General_CI_AS strAccountId,
ISNULL(c.intAccountId,0)intAccountId,
a.dtmDate,
ISNULL(c.strCode,'')  COLLATE Latin1_General_CI_AS strCode,
ISNULL(c.strBatchId,'')  COLLATE Latin1_General_CI_AS strBatchId,
c.intTransactionId,
c.strTransactionForm,
c.strModuleName,
c.strTransactionType,
a.strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,
ISNULL(c.intEntityId,0) intEntityId,
ISNULL(c.intSourceEntityId,0) intSourceEntityId,
ISNULL(c.strDescription,'')  COLLATE Latin1_General_CI_AS strDescription,
a.dblDebit,
a.dblCredit,
ISNULL(a.dblDebitUnit,0)dblDebitUnit,
ISNULL(a.dblCreditUnit,0)dblCreditUnit,
ISNULL(c.strUOMCode,'')  COLLATE Latin1_General_CI_AS strUOMCode,
a.dblDebitForeign,
a.dblCreditForeign,
ISNULL(c.strReference,'') COLLATE Latin1_General_CI_AS strReference,
ISNULL(c.strDocument,'') COLLATE Latin1_General_CI_AS strDocument,
ISNULL(c.strComments,'') COLLATE Latin1_General_CI_AS strComments,
ISNULL(c.strUserName,'') COLLATE Latin1_General_CI_AS strUserName,
ISNULL(c.strSourceEntity,'') COLLATE Latin1_General_CI_AS strSourceEntity
FROM u a LEFT JOIN
vyuGLDetail c ON a.intGLDetailId = c.intGLDetailId
GO