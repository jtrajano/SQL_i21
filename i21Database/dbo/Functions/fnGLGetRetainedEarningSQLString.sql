-- CALLED BY uspGLGetGLDetailReport
CREATE FUNCTION [dbo].[fnGLGetRetainedEarningSQLString]
(
	-- Add the parameters for the function here
	 @dtmDateFrom NVARCHAR(50),
	 @strCteName NVARCHAR(20),
	 @Where NVARCHAR(MAX)
	 
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @dte DATETIME 
	DECLARE @dtmDateFrom1 NVARCHAR(10) = @dtmDateFrom
	DECLARE @dtmDateTo1 NVARCHAR(50)=''
	DECLARE @return NVARCHAR(MAX)
	SELECT TOP 1 @dte= dtmDateFrom from tblGLFiscalYear WHERE  CAST(@dtmDateFrom AS DATETIME) >= dtmDateFrom  and CAST(@dtmDateFrom AS DATETIME) <= dtmDateTo ORDER BY dtmDateFrom DESC
	IF @dte IS NOT NULL
	BEGIN
		SELECT TOP 1 @dtmDateFrom1 =  convert(varchar(10), dtmDateFrom,101) ,@dtmDateTo1 = convert(varchar(20), dtmDateTo,101)  from tblGLFiscalYear WHERE  dtmDateTo = DATEADD(DAY,-1, @dte)
	END
	DECLARE @cols2 NVARCHAR (MAX) = 'strCompanyName,AccountHeader, strAccountDescription,strAccountType = '''',strAccountGroup = '''',dtmDate,strBatchId = '''',dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,strDetailDescription='''',strTransactionId, intTransactionId = 0,strTransactionType = '''',strTransactionForm= '''',strModuleName='''',strReference ,strReferenceDetail='''',strDocument='''',dblTotal=dblCredit-dblDebit,intAccountUnitId = 0,strCode = '''',intGLDetailId= 0,ysnIsUnposted=0,strAccountId,[Primary Account],Location='''',strUOMCode='''',dblBeginBalance,dblBeginBalanceUnit'
	SET @cols2 = REPLACE(@cols2, 'AccountHeader', 'strAccountId + '' - '' + strAccountDescription + ''(Retained Earnings)'' as AccountHeader' )
	
	SELECT @return = 
	',cteRetain as(
	select sum(dblDebit) dblDebit,sum(dblCredit) dblCredit,
	sum(dblDebitUnit) dblDebitUnit, sum(dblCreditUnit) dblCreditUnit,
	intAccountId, ysnIsUnposted, dtmDate from tblGLDetail group by intAccountId, ysnIsUnposted, dtmDate
	having ysnIsUnposted = 0 ' +
	CASE WHEN @dte is NULL  THEN '),'
	ELSE ' and dtmDate between '''+ @dtmDateFrom1 + ''' AND ''' +  @dtmDateTo1 + '''),' END +
	'cteRetain1 as
	(select 
	CAST(CONVERT(VARCHAR(4),YEAR(dtmDate)) + ''-'' +  CONVERT(VARCHAR(2), MONTH (dtmDate)) + ''-'' + ''1'' AS DATE) as dtmDate,
	Account.strAccountId strAccountId,
	Segment.[Primary Account] [Primary Account],
	Account.strDescription as strAccountDescription,
	DATENAME(YEAR,dtmDate) + ''-'' + CAST(MONTH(dtmDate) AS VARCHAR(4))  as strTransactionId,
	DATENAME(MONTH,dtmDate) + '' '' +  DATENAME(YEAR,dtmDate) + '' '' + Grop.strAccountType as strReference,
	Balance.beginBalance dblBeginBalance,
	Balance.beginBalanceUnit dblBeginBalanceUnit,
	sum(dblDebit) dblDebit,
	sum(dblCredit) dblCredit, 
	sum(dblDebitUnit) dblDebitUnit,
	sum(dblCreditUnit) dblCreditUnit,  
	Company.strCompanyName as strCompanyName,
	'''' as strCode,
	Grop.strAccountType
	from cteRetain a
	join tblGLAccount b on a.intAccountId = b.intAccountId
	join tblGLAccountGroup c on b.intAccountGroupId = c.intAccountGroupId
	OUTER APPLY (SELECT TOP 1 g.strAccountType FROM tblGLFiscalYear f  join tblGLAccount a on f.intRetainAccount = a.intAccountId join tblGLAccountGroup g on g.intAccountGroupId = a.intAccountGroupId)Grop
	OUTER APPLY (SELECT beginBalance,beginBalanceUnit FROM dbo.fnGLGetBeginningBalanceAndUnitRE(b.strAccountId,''' + @dtmDateFrom + ''')) Balance
	OUTER APPLY (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup) Company
	OUTER APPLY (select top 1 s.[Primary Account] FROM tblGLFiscalYear F join tblGLTempCOASegment s on F.intRetainAccount = s.intAccountId) Segment
	OUTER APPLY (select top 1 strAccountId,strDescription FROM tblGLFiscalYear F join tblGLAccount A on F.intRetainAccount = A.intAccountId) Account
	where c.strAccountType in (''Revenue'', ''Expense'')  
	group by  DATENAME(MONTH,dtmDate) ,DATENAME(YEAR,dtmDate),MONTH(dtmDate) ,c.strAccountType, year(dtmDate),Balance.beginBalance,Balance.beginBalanceUnit,strCompanyName,Account.strAccountId,Account.strDescription,Grop.strAccountType, [Primary Account]),' +
	@strCteName +
	' as( select ' + @cols2 + ' FROM cteRetain1 ' +
	CASE WHEN @Where = 'Where' THEN  + ')' ELSE + @Where + ')' END

	RETURN @return

END