CREATE  FUNCTION [dbo].[fnGLGetRetainedEarningSQLString]
(
-- Add the parameters for the function here
@dtmDateFrom NVARCHAR(50),
@dtmDateTo NVARCHAR(50),
@strCteName NVARCHAR(20),
@Where NVARCHAR(MAX)

)
RETURNS @tbl TABLE(
QueryString NVARCHAR(MAX),
DateTo VARCHAR(10),
MultiFiscal BIT
)
AS
BEGIN

DECLARE @multiFiscal BIT = 1
DECLARE @return NVARCHAR(MAX)

IF @dtmDateTo = ''  SET @dtmDateTo = '2100/01/01'
IF @dtmDateFrom = '' SET @dtmDateFrom = '1900/01/01'



SELECT @dtmDateFrom =CONVERT(VARCHAR(10), CONVERT(DATE,@dtmDateFrom) ,111)
SELECT @dtmDateTo = CONVERT(VARCHAR(10), CONVERT(DATE,@dtmDateTo) ,111)


DECLARE @topDtmDateFrom VARCHAR(10),@bottomDtmDateFrom  VARCHAR(10)
SELECT top 1 @dtmDateTo =  CONVERT(VARCHAR(10),dtmDateFrom,111) FROM dbo.tblGLFiscalYear tgy WHERE @dtmDateTo BETWEEN dtmDateFrom AND dtmDateTo
SELECT top 1 @topDtmDateFrom = CONVERT(VARCHAR(10),dtmDateFrom,111) FROM dbo.tblGLFiscalYear tgy  ORDER BY dtmDateFrom DESC
SELECT top 1 @bottomDtmDateFrom = CONVERT(VARCHAR(10),dtmDateFrom,111) FROM dbo.tblGLFiscalYear tgy ORDER BY dtmDateFrom


IF(@dtmDateTo = '') SET @dtmDateTo =@topDtmDateFrom
ELSE
BEGIN
	IF(@dtmDateTo >= @topDtmDateFrom) SET @dtmDateTo =@topDtmDateFrom ELSE
	IF(@dtmDateTo <= @bottomDtmDateFrom) SET @dtmDateTo =@bottomDtmDateFrom

END
IF(@dtmDateFrom = '') SET @dtmDateFrom =@bottomDtmDateFrom
ELSE
BEGIN
	IF(@dtmDateFrom >=@topDtmDateFrom) SET @dtmDateFrom = @topDtmDateFrom ELSE
	IF(@dtmDateFrom <=@bottomDtmDateFrom) SET @dtmDateFrom = @bottomDtmDateFrom
END



SELECT TOP 1 @multiFiscal = 0 FROM tblGLFiscalYear WHERE @dtmDateFrom BETWEEN dtmDateFrom AND dtmDateTo AND @dtmDateTo BETWEEN dtmDateFrom and dtmDateTo
IF @multiFiscal = 0
BEGIN
INSERT INTO @tbl  SELECT 'Retained Earnings Activity Not Displayed', @dtmDateTo , @multiFiscal
RETURN
END




DECLARE @cols2 NVARCHAR (MAX) = 'strCompanyName,AccountHeader, strAccountDescription,strAccountType = '''',strAccountGroup = '''',dtmDate,strBatchId = '''',dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,strDetailDescription='''',strTransactionId, intTransactionId = 0,strTransactionType = '''',strTransactionForm= '''',strModuleName='''',strReference ,strReferenceDetail='''',strDocument='''',dblTotal=dblCredit-dblDebit,intAccountUnitId = 0,strCode = '''',intGLDetailId= 0,ysnIsUnposted=0,strAccountId,[Primary Account],Location='''',strUOMCode='''',dblBeginBalance,dblBeginBalanceUnit'
SET @cols2 = REPLACE(@cols2, 'AccountHeader', 'strAccountId + '' - '' + strAccountDescription + ''(Retained Earnings)'' as AccountHeader')
INSERT INTO @tbl
SELECT ',cteRetain as(
select sum(dblDebit) dblDebit,sum(dblCredit) dblCredit,
SUM(dblDebitUnit) dblDebitUnit, sum(dblCreditUnit) dblCreditUnit,
intAccountId, ysnIsUnposted, dtmDate from tblGLDetail

GROUP by intAccountId, ysnIsUnposted, dtmDate
HAVING ysnIsUnposted = 0 AND dtmDate >= ''' + @dtmDateFrom  + ''' AND dtmDate < ''' + @dtmDateTo + '''),
						 cteRetain1 AS
(select
CAST(CONVERT(VARCHAR(4),YEAR(dtmDate)) + ''-'' +  CONVERT(VARCHAR(2), MONTH (dtmDate)) + ''-'' + ''1'' AS DATE) AS dtmDate,
Account.strAccountId strAccountId,
Segment.[Primary Account] [Primary Account],
Account.strDescription AS strAccountDescription,
DATENAME(YEAR,dtmDate) + ''-'' + CAST(MONTH(dtmDate) AS VARCHAR(4))  as strTransactionId,
DATENAME(MONTH,dtmDate) + '' '' +  DATENAME(YEAR,dtmDate) + '' '' + c.strAccountType as strReference,
0 AS dblBeginBalance,
0 AS dblBeginBalanceUnit,
SUM(dblDebit) dblDebit,
SUM(dblCredit) dblCredit,
SUM(dblDebitUnit) dblDebitUnit,
SUM(dblCreditUnit) dblCreditUnit,
Company.strCompanyName AS strCompanyName,
'''' AS strCode,
Grop.strAccountType
FROM cteRetain a
JOIN tblGLAccount b ON a.intAccountId = b.intAccountId
JOIN tblGLAccountGroup c on b.intAccountGroupId = c.intAccountGroupId
OUTER APPLY (SELECT TOP 1 g.strAccountType FROM tblGLFiscalYear f  join tblGLAccount a on f.intRetainAccount = a.intAccountId join tblGLAccountGroup g on g.intAccountGroupId = a.intAccountGroupId)Grop
OUTER APPLY (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup) Company

OUTER APPLY (select top 1 s.[Primary Account] FROM tblGLFiscalYear F join tblGLTempCOASegment s on F.intRetainAccount = s.intAccountId) Segment
OUTER APPLY (select top 1 strAccountId,strDescription FROM tblGLFiscalYear F join tblGLAccount A on F.intRetainAccount = A.intAccountId) Account

where c.strAccountType in (''Revenue'', ''Expense'')
group by
c.strAccountType,
DATENAME(YEAR,dtmDate) + ''-'' + CAST(MONTH(dtmDate) AS VARCHAR(4)),
CAST(CONVERT(VARCHAR(4),YEAR(dtmDate)) + ''-'' +  CONVERT(VARCHAR(2), MONTH (dtmDate)) + ''-'' + ''1'' AS DATE),
DATENAME(MONTH,dtmDate) + '' '' +  DATENAME(YEAR,dtmDate),
strCompanyName,Account.strAccountId,Account.strDescription,Grop.strAccountType, [Primary Account]),' + @strCteName + ' AS( SELECT ' + @cols2 + ' FROM cteRetain1 ' + CASE
																																									 WHEN @Where = 'Where' THEN + ')'
																																									 ELSE + @Where + ')'
																																								 END , @dtmDateTo , @multiFiscal

RETURN

END