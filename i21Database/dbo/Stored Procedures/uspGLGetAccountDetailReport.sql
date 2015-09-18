CREATE PROCEDURE [dbo].[uspGLGetAccountDetailReport]
(@xmlParam NVARCHAR(MAX)= '')
as
BEGIN
SET NOCOUNT ON;
SET FMTONLY off;
DECLARE @idoc INT
DECLARE @filterTable FilterTableType
DECLARE @strAccountIdFrom NVARCHAR(50)
DECLARE @strAccountIdTo NVARCHAR(50)
DECLARE @dtmDateFrom NVARCHAR(50)
DECLARE @dtmDateTo NVARCHAR(50)
--set @xmlParam=N'<xmlparam><filters><filter><fieldname>intGLDetailId</fieldname><condition>Equal To</condition><from/><to/><join/><begingroup/><endgroup/><datatype/></filter></filters></xmlparam>'
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
		
		
	SELECT TOP 1 @strAccountIdFrom= [from] , @strAccountIdTo = [to] from  @filterTable WHERE [fieldname] = 'strAccountId' 
	SELECT TOP 1 @dtmDateFrom= [from] , @dtmDateTo = [to] from  @filterTable WHERE [fieldname] = 'dtmDate' 

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




DECLARE @hasInactiveAccounts BIT = 0
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id('tempdb..#tempTableReport')) DROP TABLE #tempTableReport
IF @dtmDateFrom IS NOT NULL AND @strAccountIdFrom IS NULL
	SELECT @hasInactiveAccounts = 1



;WITH Units 
AS 
(
	SELECT	A.[dblLbsPerUnit], B.[intAccountId], A.[strUOMCode] 
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
)
,	
GLAccountDetails
AS
(
--*SC*--
SELECT B.strDescription  as strAccountDescription-- account description
		,C.strAccountType
		,C.strAccountGroup
		,@dtmDateFrom as dtmDate1
		,CAST(CAST(CASE WHEN  @hasInactiveAccounts = 1 THEN  ISNULL(A.dtmDate,@dtmDateFrom) ELSE A.dtmDate END AS DATE)AS datetime) as dtmDate
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
				CASE	WHEN C.strAccountType in ('Asset', 'Expense','Cost of Goods Sold') THEN isnull(A.dblDebit, 0 ) - isnull(A.dblCredit,0) 
						ELSE isnull(A.dblCredit, 0 ) - isnull(A.dblDebit,0) 
				END
				)  
		,B.intAccountUnitId 
		,A.strCode
		,A.intGLDetailId
		,D.*
		,A.ysnIsUnposted
		,isUnposted = CASE WHEN A.intAccountId IS NULL THEN 0 ELSE A.ysnIsUnposted END
		,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = A.[intAccountId]) as strUOMCode
from tblGLDetail  A
RIGHT join tblGLAccount B on B.intAccountId = A.intAccountId
INNER join tblGLAccountGroup C on C.intAccountGroupId = B.intAccountGroupId
INNER JOIN tblGLTempCOASegment D ON D.intAccountId = B.intAccountId
OUTER APPLY(
	SELECT TOP 1 strReference,strDocument FROM tblGLJournalDetail B JOIN tblGLJournal C
	ON B.intJournalId = C.intJournalId WHERE 
	 A.intJournalLineNo = B.intJournalDetailId AND
	 C.intJournalId = A.intTransactionId AND C.strJournalId = A.strTransactionId
)detail
--*SCSTART*--
--Special Case--
)

,
GLAccountBalance
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
		,dblBeginBalance = dbo.fnGetBeginBalance(A.strAccountId, (SELECT ISNULL(@dtmDateFrom, MIN(dtmDate)) FROM GLAccountDetails),'')
		,dblBeginBalanceUnit =  dbo.fnGetBeginBalanceUnit(A.strAccountId,(SELECT ISNULL(@dtmDateFrom, MIN(dtmDate)) FROM GLAccountDetails),'')
		,B.[Primary Account]
		,B.[Location] 
		,C.intGLDetailId
		FROM tblGLAccount A
		INNER JOIN tblGLTempCOASegment B ON B.intAccountId = A.intAccountId
		INNER JOIN GLAccountDetails C on A.strAccountId = C.strAccountId
),
RAWREPORT AS (

----*CountStart*--
SELECT DISTINCT
'Account ID :' + A.strAccountId + ' - ' + ISNULL(RTRIM(A.strAccountDescription),RTRIM(B.strAccountDescription)) + ' ' +  A.strAccountGroup + '-' + ISNULL(A.strAccountType,B.strAccountType) as AccountHeader,
(CASE WHEN A.strAccountDescription  is  NULL  then B.strAccountDescription else A.strAccountDescription END) as strAccountDescripion
,(CASE WHEN A.strAccountType  is  NULL  then B.strAccountType else A.strAccountType END) as strAccountType
,(CASE WHEN A.strAccountGroup  is  NULL  then B.strAccountGroup else A.strAccountGroup END) as strAccountGroup
,A.dtmDate
,A.dtmDate1
,(CASE WHEN A.strBatchId  is  NULL  then '' else A.strBatchId END) as strBatchId
,(CASE WHEN A.dblDebit  is  NULL  then 0.00 else A.dblDebit END) as dblDebit
,(CASE WHEN A.dblCredit  is  NULL  then 0.00 else A.dblCredit END) as dblCredit
,(CASE WHEN A.dblDebitUnit  is  NULL  then 0.00 else A.dblDebitUnit END) as dblDebitUnit
,(CASE WHEN A.dblCreditUnit  is  NULL  then 0.00 else A.dblCreditUnit END) as dblCreditUnit
,(CASE WHEN A.strDetailDescription  is  NULL  then '' else A.strDetailDescription END) as strDetailDescription
,(CASE WHEN A.strTransactionId  is  NULL  then '' else A.strTransactionId END) as strTransactionId
,(CASE WHEN A.intTransactionId  is  NULL  then '' else A.intTransactionId END) as intTransactionId
,(CASE WHEN A.strTransactionType  is  NULL  then '' else A.strTransactionType END) as strTransactionType
,(CASE WHEN A.strTransactionForm  is  NULL  then '' else A.strTransactionForm END) as strTransactionForm 
,(CASE WHEN A.strModuleName  is  NULL  then '' else A.strModuleName END) as strModuleName
,(CASE WHEN A.strReference  is  NULL  then '' else A.strReference END) as strReference
,(CASE WHEN A.strReferenceDetail  is  NULL  then '' else A.strReferenceDetail END) as strReferenceDetail
,(CASE WHEN A.strDocument  is  NULL  then '' else A.strDocument END) as strDocument
,(CASE WHEN A.dblTotal  is  NULL  then 0.00 else A.dblTotal END) as dblTotal
,(CASE WHEN A.intAccountUnitId  is  NULL  then '' else A.intAccountUnitId END) as intAccountUnitId
,(CASE WHEN A.strCode  is  NULL  then '' else A.strCode END) as strCode
,(CASE WHEN A.intGLDetailId  is  NULL  then '' else A.intGLDetailId END) as intGLDetailId
,(CASE WHEN A.ysnIsUnposted  is  NULL  then '' else A.ysnIsUnposted END) as ysnIsUnposted
,(CASE WHEN A.strAccountId  is  NULL  then B.strAccountId else A.strAccountId END) as strAccountId
,B.[Primary Account]
,B.Location
,(CASE WHEN A.strUOMCode is  NULL  then '' else A.strUOMCode END) as strUOMCode
,ISNULL(B.dblBeginBalance,0) AS dblBeginBalance
,[dblBeginBalanceUnit] = CASE WHEN (ISNULL(B.dblBeginBalanceUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0 
					ELSE CAST(ISNULL(ISNULL(B.dblBeginBalanceUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END	
FROM GLAccountBalance B
RIGHT JOIN GLAccountDetails A ON B.intAccountId = A.intAccountId and B.intGLDetailId = A.intGLDetailId
WHERE A.isUnposted = 0 or A.isUnposted IS NULL)
SELECT * INTO #tempTableReport  from RAWREPORT

DECLARE @SqlQuery NVARCHAR(MAX)
DECLARE @Where NVARCHAR(MAX) = dbo.fnConvertFilterTableToWhereExpression (@filterTable)
select @SqlQuery = 'Select * from #tempTableReport ' 
IF @Where <> 'Where ' select @SqlQuery +=  @Where

IF @hasInactiveAccounts =1 
BEGIN
	SELECT @SqlQuery += 'OR dtmDate1 = ''' + @dtmDateFrom + ''''
END

EXEC (@SqlQuery)

END
