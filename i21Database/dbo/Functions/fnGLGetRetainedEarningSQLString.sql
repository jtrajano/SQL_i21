CREATE FUNCTION [dbo].[fnGLGetRetainedEarningSQLString]
(
	-- Add the parameters for the function here
	 @dtmDateFrom NVARCHAR(50),
	 @dtmDateTo NVARCHAR(50),
	 @strCteName NVARCHAR(20),
	 @Where NVARCHAR(MAX)
	 
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
DECLARE @dte NVARCHAR(10) DECLARE @return NVARCHAR(MAX) DECLARE @bottomDtmDateFrom NVARCHAR(10)
SELECT @dtmDateFrom = convert(varchar(10),CONVERT(DATE ,@dtmDateFrom),111)
SELECT @dtmDateTo = convert(varchar(10),CONVERT(DATE ,@dtmDateTo),111)
	
	SELECT TOP 1 @bottomDtmDateFrom= convert(varchar(10), dtmDateFrom,111)
	FROM tblGLFiscalYear
	ORDER BY dtmDateFrom

IF (@dtmDateFrom <= @bottomDtmDateFrom)
	BEGIN
	SELECT TOP 1 @dte = convert(varchar(10), dtmDateFrom,111)
		FROM tblGLFiscalYear
		WHERE (@dtmDateTo > =dtmDateFrom AND @dtmDateTo<=dtmDateTo)
		OR @dtmDateTo > dtmDateTo
		ORDER BY dtmDateFrom DESC
	IF isnull(@dte,'') = ''
	BEGIN
		SELECT @return = 'Retained Earnings Activity Not Displayed'
			RETURN @return
	END
END
	ELSE
	BEGIN
	SELECT @return = 'Retained Earnings Activity Not Displayed'
		RETURN @return
	END


DECLARE @cols2 NVARCHAR (MAX) = 'strCompanyName,AccountHeader, strAccountDescription,strAccountType = '''',strAccountGroup = '''',dtmDate,strBatchId = '''',dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,strDetailDescription='''',strTransactionId, intTransactionId = 0,strTransactionType = '''',strTransactionForm= '''',strModuleName='''',strReference ,strReferenceDetail='''',strDocument='''',dblTotal=dblCredit-dblDebit,intAccountUnitId = 0,strCode = '''',intGLDetailId= 0,ysnIsUnposted=0,strAccountId,[Primary Account],Location='''',strUOMCode='''',dblBeginBalance,dblBeginBalanceUnit'
SET @cols2 = REPLACE(@cols2, 'AccountHeader', 'strAccountId + '' - '' + strAccountDescription + ''(Retained Earnings)'' as AccountHeader')
SELECT @return = ',cteRetain as(
	SELECT SUM(dblDebit) dblDebit,SUM(dblCredit) dblCredit,
	SUM(dblDebitUnit) dblDebitUnit, SUM(dblCreditUnit) dblCreditUnit,
	intAccountId, ysnIsUnposted, dtmDate FROM tblGLDetail GROUP BY intAccountId, ysnIsUnposted, dtmDate
HAVING ysnIsUnposted = 0 ' + CASE
								 WHEN @dte IS NULL THEN '),'
								 ELSE ' and dtmDate < '''+ @dte + '''),'
							 END + 'cteRetain1 as
	(select 
	CAST(CONVERT(VARCHAR(4),YEAR(dtmDate)) + ''-'' +  CONVERT(VARCHAR(2), MONTH (dtmDate)) + ''-'' + ''1'' AS DATE) AS dtmDate,
	Account.strAccountId strAccountId,
	Segment.[Primary Account] [Primary Account],
	Account.strDescription as strAccountDescription,
	DATENAME(YEAR,dtmDate) + ''-'' + CAST(MONTH(dtmDate) AS VARCHAR(4))  AS strTransactionId,
	DATENAME(MONTH,dtmDate) + '' '' +  DATENAME(YEAR,dtmDate) + '' '' + c.strAccountType AS strReference,
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
	OUTER APPLY (SELECT TOP 1 g.strAccountType FROM tblGLFiscalYear f  JOIN tblGLAccount a ON f.intRetainAccount = a.intAccountId JOIN tblGLAccountGroup g ON g.intAccountGroupId = a.intAccountGroupId)Grop
	OUTER APPLY (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup) Company
	OUTER APPLY (select top 1 s.[Primary Account] FROM tblGLFiscalYear F JOIN tblGLTempCOASegment s ON F.intRetainAccount = s.intAccountId) Segment
	OUTER APPLY (select top 1 strAccountId,strDescription FROM tblGLFiscalYear F JOIN tblGLAccount A ON F.intRetainAccount = A.intAccountId) Account
	WHERE c.strAccountType IN (''Revenue'', ''Expense'')
	GROUP BY
	c.strAccountType,
	DATENAME(YEAR,dtmDate) + ''-'' + CAST(MONTH(dtmDate) AS VARCHAR(4)),
	CAST(CONVERT(VARCHAR(4),YEAR(dtmDate)) + ''-'' +  CONVERT(VARCHAR(2), MONTH (dtmDate)) + ''-'' + ''1'' AS DATE),
	DATENAME(MONTH,dtmDate) + '' '' +  DATENAME(YEAR,dtmDate),
strCompanyName,Account.strAccountId,Account.strDescription,Grop.strAccountType, [Primary Account]),' + @strCteName + ' AS( SELECT ' + @cols2 + ' FROM cteRetain1 ' + CASE
																																										 WHEN @Where = 'Where' THEN + ')'
																																										 ELSE + @Where + ')'
																																									 END RETURN @return

END