CREATE PROCEDURE [dbo].[uspGLGetAccountDetailReport]
(@xmlParam NVARCHAR(MAX)= '')
as
BEGIN
SET NOCOUNT ON;
IF (ISNULL(@xmlParam,'')  = '')
BEGIN
	SELECT DISTINCT
	'' as strCompanyName,
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
	update @filterTable SET [fieldname] = 'strCode',[from] = '' , [condition]= 'Not Equal To' WHERE fieldname = 'ysnIncludeAuditAdjustment' AND [from] = 'Yes'
	update @filterTable SET [fieldname] = 'strCode',[from] = 'AA' , [condition]= 'Not Equal To' WHERE fieldname = 'ysnIncludeAuditAdjustment' AND [from] = 'No'
	update @filterTable SET [fieldname] = '[Primary Account]' WHERE fieldname = 'PrimaryAccount'
	update @filterTable SET [fieldname] = '[Primary Account]' WHERE fieldname = 'Primary Account'
	delete FROM @filterTable WHERE [condition]= 'All Date'


	SELECT TOP 1 @strAccountIdFrom= ISNULL([from],'') , @strAccountIdTo = ISNULL([to],'') ,@strAccountIdCondition =ISNULL([condition],'') from  @filterTable WHERE [fieldname] = 'strAccountId' 
	SELECT TOP 1 @strPrimaryCodeFrom= ISNULL([from],'') , @strPrimaryCodeTo = ISNULL([to],'') ,@strPrimaryCodeCondition =ISNULL([condition],'') from  @filterTable WHERE [fieldname] = '[Primary Account]' 
	SELECT TOP 1 @dtmDateFrom= ISNULL([from],'') , @dtmDateTo = ISNULL([to],'') from  @filterTable WHERE [fieldname] = 'dtmDate' 

	
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
DECLARE @cols NVARCHAR (MAX) = 'strCompanyName,AccountHeader, strAccountDescription,strAccountType,strAccountGroup,dtmDate,strBatchId,dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,strDetailDescription,strTransactionId, intTransactionId,strTransactionType,strTransactionForm,strModuleName,strReference,strReferenceDetail,strDocument,dblTotal,intAccountUnitId,strCode,intGLDetailId,ysnIsUnposted,strAccountId,[Primary Account],Location,strUOMCode,dblBeginBalance,dblBeginBalanceUnit'
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
				CASE	WHEN C.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN isnull(ROUND(A.dblDebit,2), 0 ) - isnull(ROUND(A.dblCredit,2),0) 
						ELSE isnull(ROUND(A.dblCredit,2), 0 ) - isnull(ROUND(A.dblDebit,2),0) 
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
C.strCompanyName as strCompanyName
,ISNULL(RTRIM(A.strAccountDescription),RTRIM(B.strAccountDescription)) + '' '' +  A.strAccountGroup + ''-'' + ISNULL(A.strAccountType,B.strAccountType) as AccountHeader
,(CASE WHEN A.strAccountDescription  is  NULL  then B.strAccountDescription else A.strAccountDescription END) as strAccountDescription
,(CASE WHEN A.strAccountType  is  NULL  then B.strAccountType else A.strAccountType END) as strAccountType
,(CASE WHEN A.strAccountGroup  is  NULL  then B.strAccountGroup else A.strAccountGroup END) as strAccountGroup
,A.dtmDate
,(CASE WHEN A.strBatchId  is  NULL  then '''' else A.strBatchId END) as strBatchId
,(CASE WHEN A.dblDebit  is  NULL  then 0.00 else ROUND(A.dblDebit,2) END) as dblDebit
,(CASE WHEN A.dblCredit  is  NULL  then 0.00 else ROUND(A.dblCredit,2) END) as dblCredit
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
,ISNULL(ROUND(B.dblBeginBalance,2),0) AS dblBeginBalance
,[dblBeginBalanceUnit] = CASE WHEN (ISNULL(B.dblBeginBalanceUnit, 0) = 0) OR (ISNULL(U.dblLbsPerUnit, 0) = 0) THEN 0 
					ELSE CAST(ISNULL(ISNULL(B.dblBeginBalanceUnit, 0) / ISNULL(U.dblLbsPerUnit, 0),0) AS NUMERIC(18, 6)) END

FROM
GLAccountDetails A 
OUTER APPLY(SELECT * from GLAccountBalance  bal WHERE bal.intAccountId = A.intAccountId and bal.intGLDetailId = A.intGLDetailId) B
OUTER APPLY(SELECT dblLbsPerUnit from Units u WHERE u.intAccountId = A.intAccountId) U
OUTER APPLY(SELECT TOP 1 strCompanyName from tblSMCompanySetup) C
WHERE ISNULL(A.ysnIsUnposted ,0) = 0 
) '

DELETE FROM @filterTable WHERE fieldname = 'dtmDate'
DECLARE @Where1 NVARCHAR(MAX) = dbo.fnConvertFilterTableToWhereExpression (@filterTable)

DECLARE @sqlRetain NVARCHAR(MAX) = dbo.fnGLGetRetainedEarningSQLString(@dtmDateFrom,@dtmDateTo,'cteRetain2',@Where1)

IF @sqlRetain <> 'Retained Earnings Activity Not Displayed'
	SELECT @sqlCte += @sqlRetain

SELECT @sqlCte += ',cteBase1 as(SELECT * from RAWREPORT ' +  CASE WHEN @Where <> 'Where' THEN  @Where ELSE '' END +' )'-- UNION ALL SELECT ' + @cols + ' from cteRetain2 )'


SELECT @sqlCte+= ',cteBase as (SELECT '+ @cols +' from cteBase1 ' +  CASE WHEN  @sqlRetain <> 'Retained Earnings Activity Not Displayed' THEN ' UNION ALL SELECT ' + @cols + ' FROM  cteRetain2)' ELSE ')' END

IF @dtmDateFrom = ''
	SELECT @sqlCte +=	' select * from cteBase '
ELSE
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
	SELECT @cols1 = REPLACE (@cols1,'strCode,',''''' as strCode,')
	SELECT @cols1 = REPLACE (@cols1,'strReferenceDetail,',''''' as strReferenceDetail,')
	SELECT @cols1 = REPLACE (@cols1,'strDocument,',''''' as strDocument,')
	SELECT @cols1 = REPLACE (@cols1,'strBatchId,',''''' as strBatchId,')
	SELECT @cols1 = REPLACE (@cols1,'strReference,',''''' as strReference,')
	SELECT @cols1 = REPLACE (@cols1,'strUOMCode,',''''' as strUOMCode,')
	SELECT @cols1 = REPLACE (@cols1,'Location,',''''' as Location,')

	IF @strAccountIdFrom <> '' or @strPrimaryCodeFrom <> '' SELECT @Where1 += CASE WHEN @Where1 <> 'Where' then  'AND ' ELSE ''  END + ' strAccountId NOT IN(SELECT strAccountId FROM cteBase1)'
	SET @sqlCte +=',cteInactive (accountId,id) AS ( SELECT  strAccountId, MIN(intGLDetailId) FROM RAWREPORT ' + CASE WHEN @Where1 <> 'Where' THEN  @Where1 ELSE '' END + ' GROUP BY strAccountId),
		cte1  AS( SELECT * FROM RAWREPORT	A join cteInactive B ON B.accountId = A.strAccountId AND B.id = A.intGLDetailId)'
	SELECT @sqlCte +=	' select ' + @cols1  + ' FROM cte1 union all select ' + @cols + ' from cteBase '
	END

	EXEC (@sqlCte)
END