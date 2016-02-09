/****** Object:  StoredProcedure [dbo].[uspGLGetAccountDetailReport]    Script Date: 10/30/2015 7:17:16 PM ******/
CREATE PROCEDURE [dbo].[uspGLGetAccountDetailReport]
(@xmlParam NVARCHAR(MAX)= '')
as
BEGIN
SET NOCOUNT ON;
IF (ISNULL(@xmlParam,'')  = '')
BEGIN
	SELECT DISTINCT
	'' as AccountHeader,
	'' as strAccountDescription,
	'' as strAccountType,
	'' as strAccountGroup,
	getdate() as dtmDate,
	'' as strBatchId,
	0.0  as dblDebit,
	0.0 as dblCredit,
	0.0 as dblDebitUnit,
	0.0 as dblCreditUnit,
	'' as strDetailDescription,
	'' as strTransactionId,
	0 as intTransactionId,
	'' as strTransactionType,
	'' as strTransactionForm ,
	'' as strModuleName,
	'' as strReference,
	'' as strReferenceDetail,
	'' as strDocument,
	0.0 as dblTotal,
	0 as intAccountUnitId,
	'' as strCode,
	0 as intGLDetailId,
	0 as ysnIsUnposted,
	'' as strAccountId,
	'' as [Primary Account],
	'' as Location,
	'' as strUOMCode,
	0.0 dblBeginBalance,
	0.0 as dblBeginBalanceUnit
	RETURN;
END
--SET FMTONLY off;
DECLARE @idoc INT
DECLARE @filterTable FilterTableType
DECLARE @strAccountIdFrom NVARCHAR(50)=''
DECLARE @strAccountIdTo NVARCHAR(50)=''
DECLARE @strPrimaryCodeFrom NVARCHAR(50)=''
DECLARE @strPrimaryCodeTo NVARCHAR(50)=''
DECLARE @strPrimaryCodeCondition NVARCHAR(50) = ''
DECLARE @dtmDateFrom NVARCHAR(50)=''
DECLARE @dtmDateTo NVARCHAR(50)=''
DECLARE @strAccountIdCondition NVARCHAR(20)=''

IF @xmlParam <> ''
BEGIN
	exec sp_xml_preparedocument @idoc output, @xmlParam  
	insert into @filterTable  
	SELECT  *
	FROM    OPENXML(@idoc, '/xmlparam/filters/filter', 2)  
		 with ([fieldname] nvarchar(50)  
						, [condition] nvarchar(20)  
						, [from] nvarchar(50)  
						, [to] nvarchar(50)  
						, [join] nvarchar(10)  
						, [begingroup] nvarchar(50)  
						, [endgroup] nvarchar(50)  
						, [datatype] nvarchar(50))  
		
	DELETE FROM @filterTable WHERE [from] IS NULL OR RTRIM([from]) = ''
	SELECT TOP 1 @strAccountIdFrom= ISNULL([from],'') , @strAccountIdTo = ISNULL([to],'') ,@strAccountIdCondition =ISNULL([condition],'') from  @filterTable WHERE [fieldname] = 'strAccountId' 
	SELECT TOP 1 @strPrimaryCodeFrom= ISNULL([from],'') , @strPrimaryCodeTo = ISNULL([to],'') ,@strPrimaryCodeCondition =ISNULL([condition],'') from  @filterTable WHERE [fieldname] = 'Primary Account' 
	SELECT TOP 1 @dtmDateFrom= ISNULL([from],'') , @dtmDateTo = ISNULL([to],'') from  @filterTable WHERE [fieldname] = 'dtmDate' 

	
	update @filterTable SET [fieldname] = 'strCode',[from] = '' , [condition]= 'Not Equal To' WHERE fieldname = 'ysnIncludeAuditAdjustment' AND [from] = 'Yes'
	update @filterTable SET [fieldname] = 'strCode',[from] = 'AA' , [condition]= 'Not Equal To' WHERE fieldname = 'ysnIncludeAuditAdjustment' AND [from] = 'No'
	update @filterTable SET [fieldname] = '[Primary Account]' WHERE fieldname = 'Primary Account' 
	delete FROM @filterTable WHERE [condition]= 'All Date'
	
	IF EXISTS(
	SELECT TOP 1 1 FROM @filterTable WHERE
		(condition LIKE  '%Date'  or
				 condition like '%Month' or
				 condition like '%Period' or
				 condition like '%Year' or
				 condition like '%Quarter' or
				 condition = 'As Of') AND ([from] ='' OR [to] =''))
	BEGIN
		RAISERROR (N'Between condition needs from and to parameter to be present.',10, 1); 
		RETURN
	END
	 
END

DECLARE @Where NVARCHAR(MAX) = dbo.fnConvertFilterTableToWhereExpression (@filterTable)
DECLARE @cols NVARCHAR (MAX) = 'AccountHeader, strAccountDescription,strAccountType,strAccountGroup,dtmDate,strBatchId,dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,strDetailDescription,strTransactionId, intTransactionId,strTransactionType,strTransactionForm,strModuleName,strReference,strReferenceDetail,strDocument,dblTotal,intAccountUnitId,strCode,intGLDetailId,ysnIsUnposted,strAccountId,[Primary Account],Location,strUOMCode,dblBeginBalance,dblBeginBalanceUnit'
DECLARE @sqlCte NVARCHAR(MAX) 
SET @sqlCte = ';WITH Units 
AS 
(
	SELECT	A.[dblLbsPerUnit], B.[intAccountId], A.[strUOMCode] 
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
)
,	
GLAccountDetails
AS
(

SELECT B.strDescription  as strAccountDescription-- account description
		,C.strAccountType
		,C.strAccountGroup
		,CAST(CAST( A.dtmDate AS DATE)AS datetime) as dtmDate
		,A.strBatchId
		,ISNULL(A.dblDebit,0) as dblDebit
		,ISNULL(A.dblCredit,0) as dblCredit
		,[dblDebitUnit]	= CASE WHEN (ISNULL(A.dblDebitUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0 
					ELSE CAST(ISNULL(ISNULL(A.dblDebitUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
		,[dblCreditUnit] = CASE WHEN (ISNULL(A.dblCreditUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0 
					ELSE CAST(ISNULL(ISNULL(A.dblCreditUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END			
		,A.strDescription as strDetailDescription-- detail description
		,A.strTransactionId
		,A.intTransactionId
		,A.strTransactionType
		,A.strTransactionForm
		,A.strModuleName
		,A.strReference
		,strReferenceDetail = detail.strReference
	    ,strDocument = detail.strDocument
		,dblTotal = ( 
				CASE	WHEN C.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN isnull(A.dblDebit, 0 ) - isnull(A.dblCredit,0) 
						ELSE isnull(A.dblCredit, 0 ) - isnull(A.dblDebit,0) 
				END
				)  
		,B.intAccountUnitId 
		,A.strCode
		,A.intGLDetailId
		,D.*
		,A.ysnIsUnposted
		,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = A.[intAccountId]) as strUOMCode
from tblGLDetail  A
LEFT join tblGLAccount B on B.intAccountId = A.intAccountId
INNER join tblGLAccountGroup C on C.intAccountGroupId = B.intAccountGroupId
INNER JOIN tblGLTempCOASegment D ON D.intAccountId = B.intAccountId
OUTER APPLY(
	SELECT TOP 1 strReference,strDocument FROM tblGLJournalDetail B JOIN tblGLJournal C
	ON B.intJournalId = C.intJournalId WHERE 
	 A.intJournalLineNo = B.intJournalDetailId AND
	 C.intJournalId = A.intTransactionId AND C.strJournalId = A.strTransactionId
)detail

)




,GLAccountBalance
(
intAccountId
,strAccountId
,strAccountDescription
,strAccountType
,strAccountGroup
,dblBeginBalance
,dblBeginBalanceUnit
,[Primary Account]
,[Location] 
,intGLDetailId
)
AS
(
	SELECT 
		A.intAccountId
		,A.strAccountId
		,A.strDescription as strAccountDescription
		,(select strAccountType from tblGLAccountGroup where intAccountGroupId = A.intAccountGroupId) as strAccountType
		,(select strAccountGroup from tblGLAccountGroup where intAccountGroupId = A.intAccountGroupId) as strAccountGroup
		,dblBeginBalance = D.beginBalance
		,dblBeginBalanceUnit =  D.beginBalanceUnit
		,B.[Primary Account]
		,B.[Location] 
		,C.intGLDetailId
		FROM tblGLAccount A
		INNER JOIN tblGLTempCOASegment B ON B.intAccountId = A.intAccountId
		INNER JOIN GLAccountDetails C on A.strAccountId = C.strAccountId
		OUTER APPLY dbo.fnGLGetBeginningBalanceAndUnit(A.strAccountId,(SELECT CASE WHEN ''' + @dtmDateFrom + ''' = '''' THEN MIN(dtmDate) ELSE ''' +  @dtmDateFrom + ''' END FROM GLAccountDetails)) D
),'

SET @sqlCte +='RAWREPORT AS (
SELECT 
ISNULL(RTRIM(A.strAccountDescription),RTRIM(B.strAccountDescription)) + '' '' +  A.strAccountGroup + ''-'' + ISNULL(A.strAccountType,B.strAccountType) as AccountHeader,
(CASE WHEN A.strAccountDescription  is  NULL  then B.strAccountDescription else A.strAccountDescription END) as strAccountDescription
,(CASE WHEN A.strAccountType  is  NULL  then B.strAccountType else A.strAccountType END) as strAccountType
,(CASE WHEN A.strAccountGroup  is  NULL  then B.strAccountGroup else A.strAccountGroup END) as strAccountGroup
,A.dtmDate
,(CASE WHEN A.strBatchId  is  NULL  then '''' else A.strBatchId END) as strBatchId
,(CASE WHEN A.dblDebit  is  NULL  then 0.00 else A.dblDebit END) as dblDebit
,(CASE WHEN A.dblCredit  is  NULL  then 0.00 else A.dblCredit END) as dblCredit
,(CASE WHEN A.dblDebitUnit  is  NULL  then 0.00 else A.dblDebitUnit END) as dblDebitUnit
,(CASE WHEN A.dblCreditUnit  is  NULL  then 0.00 else A.dblCreditUnit END) as dblCreditUnit
,(CASE WHEN A.strDetailDescription  is  NULL  then '''' else A.strDetailDescription END) as strDetailDescription
,(CASE WHEN A.strTransactionId  is  NULL  then '''' else A.strTransactionId END) as strTransactionId
,(CASE WHEN A.intTransactionId  is  NULL  then '''' else A.intTransactionId END) as intTransactionId
,(CASE WHEN A.strTransactionType  is  NULL  then '''' else A.strTransactionType END) as strTransactionType
,(CASE WHEN A.strTransactionForm  is  NULL  then '''' else A.strTransactionForm END) as strTransactionForm 
,(CASE WHEN A.strModuleName  is  NULL  then '''' else A.strModuleName END) as strModuleName
,(CASE WHEN A.strReference  is  NULL  then '''' else A.strReference END) as strReference
,(CASE WHEN A.strReferenceDetail  is  NULL  then '''' else A.strReferenceDetail END) as strReferenceDetail
,(CASE WHEN A.strDocument  is  NULL  then '''' else A.strDocument END) as strDocument
,(CASE WHEN A.dblTotal  is  NULL  then 0.00 else A.dblTotal END) as dblTotal
,(CASE WHEN A.intAccountUnitId  is  NULL  then '''' else A.intAccountUnitId END) as intAccountUnitId
,(CASE WHEN A.strCode  is  NULL  then '''' else A.strCode END) as strCode
,(CASE WHEN A.intGLDetailId  is  NULL  then '''' else A.intGLDetailId END) as intGLDetailId
,(CASE WHEN A.ysnIsUnposted  is  NULL  then 0 else A.ysnIsUnposted END) as ysnIsUnposted
,(CASE WHEN A.strAccountId  is  NULL  then B.strAccountId else A.strAccountId END) as strAccountId
,B.[Primary Account]
,B.Location
,(CASE WHEN A.strUOMCode is  NULL  then '''' else A.strUOMCode END) as strUOMCode
,ISNULL(B.dblBeginBalance,0) AS dblBeginBalance
,[dblBeginBalanceUnit] = CASE WHEN (ISNULL(B.dblBeginBalanceUnit, 0) = 0) OR (ISNULL(U.dblLbsPerUnit, 0) = 0) THEN 0 
					ELSE CAST(ISNULL(ISNULL(B.dblBeginBalanceUnit, 0) / ISNULL(U.dblLbsPerUnit, 0),0) AS NUMERIC(18, 6)) END	
FROM
GLAccountDetails A 
OUTER APPLY(SELECT * from GLAccountBalance  bal WHERE bal.intAccountId = A.intAccountId and bal.intGLDetailId = A.intGLDetailId) B
OUTER APPLY(SELECT dblLbsPerUnit from Units u WHERE u.intAccountId = A.intAccountId) U
WHERE ISNULL(A.ysnIsUnposted ,0) = 0 and A.intAccountId NOT IN (SELECT intRetainAccount FROM tblGLFiscalYear))'



SELECT @sqlCte += ',cteBase as(
	select * from RAWREPORT ' + CASE WHEN @Where <> 'Where' THEN  @Where END + ')'


IF @dtmDateFrom <> ''
BEGIN
	DECLARE @cols1 NVARCHAR(MAX) = ''
	SELECT @cols1 = REPLACE (@cols,'dtmDate','''' + @dtmDateFrom  + '''' + ' as dtmDate')
	SELECT @cols1 = REPLACE (@cols1,'dblDebit,','0 as dblDebit,')
	SELECT @cols1 = REPLACE (@cols1,'dblDebitUnit,','0 as dblDebitUnit,')
	SELECT @cols1 = REPLACE (@cols1,'dblCredit,','0 as dblCredit,')
	SELECT @cols1 = REPLACE (@cols1,'dblCreditUnit,','0 as dblCreditUnit,')
	SELECT @cols1 = REPLACE (@cols1,'dblTotal,','0 as dblTotal,')
	SELECT @cols1 = REPLACE (@cols1,'strTransactionId,',''''' as strTransactionId,')
	SELECT @cols1 = REPLACE (@cols1,'intTransactionId,','0 as intTransactionId,')

	IF @strAccountIdFrom = '' AND @strPrimaryCodeFrom = ''
	BEGIN
	SET @sqlCte +=
		',cteInactive (accountId,id)AS
		(
			SELECT  strAccountId, MIN(intGLDetailId) FROM RAWREPORT
			WHERE strAccountId NOT IN(SELECT strAccountId FROM cteBase)
			GROUP BY strAccountId
		),
		cte1 
		AS(
			SELECT * FROM RAWREPORT	A join cteInactive B
			ON B.accountId = A.strAccountId 
			AND B.id = A.intGLDetailId
		)'
		
	END

	IF @strAccountIdFrom <> ''  AND @strPrimaryCodeFrom = ''
	BEGIN


	SET @sqlCte +=
		',cteInactive (accountId,id)AS
		(
			SELECT  strAccountId, MIN(intGLDetailId) FROM RAWREPORT
			WHERE strAccountId BETWEEN ''' + @strAccountIdFrom + '''  AND CASE WHEN ''' + @strAccountIdTo + ''' = '''' THEN ''' + @strAccountIdFrom + ''' ELSE ''' + @strAccountIdTo + ''' END 
			AND strAccountId NOT IN(SELECT strAccountId FROM cteBase)
			GROUP BY strAccountId
		),
		cte1 
		AS(
			SELECT * FROM RAWREPORT	A join cteInactive B
			ON B.accountId = A.strAccountId 
			AND B.id = A.intGLDetailId
		
		)'
		
	END
	IF @strAccountIdFrom IS NULL  AND @strPrimaryCodeFrom IS NOT NULL
	BEGIN
	SET @sqlCte +=
		',cteInactive (accountId,id)AS
		(
			SELECT  strAccountId, MIN(intGLDetailId) FROM RAWREPORT
			WHERE [Primary Account] BETWEEN ''' + @strPrimaryCodeFrom + '''  AND CASE WHEN ''' + @strPrimaryCodeTo + ''' = '''' THEN ''' + @strPrimaryCodeFrom + ''' ELSE ''' + @strPrimaryCodeTo + ''' END 
			AND [Primary Account] NOT IN(SELECT [Primary Account] FROM cteBase)
			GROUP BY strAccountId
		),
		cte1 
		AS(
			SELECT * FROM RAWREPORT	A join cteInactive B
			ON B.accountId = A.strAccountId 
			AND B.id = A.intGLDetailId
		
		)'
		
	END
	DECLARE @dte DATETIME 
	DECLARE @dtmDateFrom1 NVARCHAR(10) = @dtmDateFrom
	
	SELECT TOP 1 @dte= dtmDateFrom from tblGLFiscalYear WHERE  CAST(@dtmDateFrom AS DATETIME) >= dtmDateFrom  and CAST(@dtmDateFrom AS DATETIME) <= dtmDateTo ORDER BY dtmDateFrom DESC
	IF @dte IS NOT NULL
	BEGIN
		SELECT TOP 1 @dtmDateFrom =  convert(varchar(10), dtmDateFrom,101) ,@dtmDateTo = convert(varchar(20), dtmDateTo,101)  from tblGLFiscalYear WHERE  dtmDateTo = DATEADD(DAY,-1, @dte)
	END
	DECLARE @cols2 NVARCHAR (MAX) = 'AccountHeader, strAccountDescription,strAccountType = '''',strAccountGroup = '''',dtmDate,strBatchId = '''',dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,strDetailDescription='''',strTransactionId, intTransactionId = 0,strTransactionType = '''',strTransactionForm= '''',strModuleName='''',strReference ,strReferenceDetail='''',strDocument='''',dblTotal=dblCredit-dblDebit,intAccountUnitId = 0,strCode = '''',intGLDetailId= 0,ysnIsUnposted=0,strAccountId,[Primary Account]='''',Location='''',strUOMCode='''',dblBeginBalance,dblBeginBalanceUnit'
	SET @cols2 = REPLACE(@cols2, 'AccountHeader', 'strAccountId + '' - '' + strAccountDescription + ''(Retained Earnings)'' as AccountHeader' )
	SET @sqlCte +=
	',cteRetain as(
	select sum(dblDebit) dblDebit,sum(dblCredit) dblCredit,
	sum(dblDebitUnit) dblDebitUnit, sum(dblCreditUnit) dblCreditUnit,
	intAccountId, ysnIsUnposted, dtmDate from tblGLDetail group by intAccountId , ysnIsUnposted, dtmDate
	having ysnIsUnposted = 0
	and dtmDate between '''+ @dtmDateFrom + ''' and '''+ @dtmDateTo + '''),
	cteRetain1 as
	(select 
	CAST(CONVERT(VARCHAR(4),YEAR(dtmDate)) + ''-'' +  CONVERT(VARCHAR(2), MONTH (dtmDate)) + ''-'' + ''1'' AS DATE) as dtmDate,
	(select top 1 strAccountId from tblGLFiscalYear F join tblGLAccount A on F.intRetainAccount = A.intAccountId) as strAccountId,
	(select top 1 strDescription from tblGLFiscalYear F join tblGLAccount A on F.intRetainAccount = A.intAccountId) as strAccountDescription,
	DATENAME(YEAR,dtmDate) + ''-'' + CAST(MONTH(dtmDate) AS VARCHAR(4))  as strTransactionId,
	DATENAME(MONTH,dtmDate) + '' '' +  DATENAME(YEAR,dtmDate) + '' '' +c.strAccountType as strReference,
	D.beginBalance dblBeginBalance,
	D.beginBalanceUnit dblBeginBalanceUnit, 
	sum(dblDebit) dblDebit,
	sum(dblCredit) dblCredit, 
	sum(dblDebitUnit) dblDebitUnit,
	sum(dblCreditUnit) dblCreditUnit,  
	c.strAccountType from cteRetain a
	join tblGLAccount b on a.intAccountId = b.intAccountId
	join tblGLAccountGroup c on b.intAccountGroupId = c.intAccountGroupId
	OUTER APPLY dbo.fnGLGetBeginningBalanceAndUnitRE(b.strAccountId,''' + @dtmDateFrom1 + ''') D
	where c.strAccountType in (''Revenue'', ''Expense'') 
	group by  DATENAME(MONTH,dtmDate) ,DATENAME(YEAR,dtmDate),MONTH(dtmDate) ,strAccountType, year(dtmDate),D.beginBalance,D.beginBalanceUnit)
	select ' + @cols2 + ' FROM cteRetain1 union all select ' + @cols1  + ' FROM cte1 union all select ' + @cols + ' from cteBase '

END
ELSE
BEGIN
	SET @sqlCte += 'SELECT * FROM cteBase'
END
	EXEC (@sqlCte)
END