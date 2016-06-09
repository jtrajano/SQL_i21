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
),RAWREPORT AS (
SELECT
 strCompanyName = Company.strCompanyName
,A.intAccountId
,RTRIM(ISNULL(Account.strDescription,'''')) + '' '' +  ISNULL(Grp.strAccountGroup,'''') + ''-'' + ISNULL(Grp.strAccountType,'''') as AccountHeader
,strAccountDescription =ISNULL(Account.strDescription,'''')
,strAccountType = ISNULL(Grp.strAccountType,'''')
,strAccountGroup = ISNULL(Grp.strAccountGroup,'''')
,A.dtmDate
,strBatchId = ISNULL(strBatchId,'''')
,dblDebit = ROUND(ISNULL(A.dblDebit,0),2)
,dblCredit = ROUND(ISNULL(A.dblCredit,0),2)  
,dblDebitUnit = ISNULL(A.dblDebitUnit,0.00)
,dblCreditUnit = ISNULL(A.dblCreditUnit,0.00) 
,strDetailDescription =ISNULL(A.strDescription,'''')
,strTransactionId = ISNULL(A.strTransactionId,'''')
,A.intTransactionId
,strTransactionType = ISNULL(A.strTransactionType,'''')
,strTransactionForm=ISNULL(A.strTransactionForm ,'''')
,strModuleName =ISNULL(A.strModuleName,'''')
,strReference= ISNULL(A.strReference,'''') 

,strReferenceDetail = ISNULL(detail.strReference,'''') 
,strDocument = ISNULL(detail.strDocument,'''')

,dblTotal = ( 
				CASE	WHEN Grp.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN ISNULL(ROUND(A.dblDebit,2), 0 ) - ISNULL(ROUND(A.dblCredit,2),0) 
						ELSE (ISNULL(ROUND(A.dblCredit,2), 0 ) - ISNULL(ROUND(A.dblDebit,2),0)) * -1
				END
				)  

,ISNULL(Account.intAccountUnitId,'''') as intAccountUnitId
,ISNULL(A.strCode,'''') as strCode
,intGLDetailId = ISNULL(A.intGLDetailId,'''')
,ISNULL(A.ysnIsUnposted,0) as ysnIsUnposted
,Account.strAccountId as strAccountId
,Segment.[Primary Account]
,Segment.Location
FROM
tblGLAccount Account
LEFT JOIN tblGLDetail A ON A.intAccountId = Account.intAccountId
INNER JOIN tblGLAccountGroup Grp ON Account.intAccountGroupId = Grp.intAccountGroupId
LEFT JOIN tblGLTempCOASegment Segment ON Account.intAccountId = Segment.intAccountId
OUTER APPLY(
	SELECT TOP 1 strReference,strDocument FROM tblGLJournalDetail B JOIN tblGLJournal C
	ON B.intJournalId = C.intJournalId WHERE 
	 A.intJournalLineNo = B.intJournalDetailId AND
	 C.intJournalId = A.intTransactionId AND C.strJournalId = A.strTransactionId
)detail
OUTER APPLY(SELECT TOP 1  strCompanyName from tblSMCompanySetup) Company
WHERE ISNULL(A.ysnIsUnposted ,0) = 0 
) '

DELETE FROM @filterTable WHERE fieldname = 'dtmDate'
DECLARE @Where1 NVARCHAR(MAX) = dbo.fnConvertFilterTableToWhereExpression (@filterTable)

DECLARE @sqlRetain NVARCHAR(MAX) = dbo.fnGLGetRetainedEarningSQLString(@dtmDateFrom,@dtmDateTo,'cteRetain2',@Where1)

IF @sqlRetain <> 'Retained Earnings Activity Not Displayed'
	SELECT @sqlCte += @sqlRetain

SELECT @sqlCte += ',cteBase1 as(SELECT * from RAWREPORT ' +  CASE WHEN @Where <> 'Where' THEN  @Where ELSE '' END +' )'-- UNION ALL SELECT ' + @cols + ' from cteRetain2 )'

DECLARE @colsWithoutBalance NVARCHAR(MAX)

SELECT @colsWithoutBalance = REPLACE(@cols,',strUOMCode,dblBeginBalance,dblBeginBalanceUnit','')

SELECT @sqlCte+= '
,cteBase as (SELECT '+ @colsWithoutBalance +'
,ISNULL(U.strUOMCode,'''') AS strUOMCode
,ISNULL(ROUND(B.beginBalance,2),0) AS dblBeginBalance
,[dblBeginBalanceUnit] = CASE WHEN (ISNULL(B.beginBalanceUnit, 0) = 0) OR (ISNULL(U.dblLbsPerUnit, 0) = 0) THEN 0
					ELSE CAST(ISNULL(ISNULL(B.beginBalanceUnit, 0) / ISNULL(U.dblLbsPerUnit, 0),0) AS NUMERIC(18, 6)) END

from cteBase1 A
OUTER APPLY (SELECT dblLbsPerUnit,[strUOMCode] FROM Units WHERE [intAccountId] = A.[intAccountId]) U
OUTER APPLY (SELECT beginBalance,beginBalanceUnit from dbo.fnGLGetBeginningBalanceAndUnit( A.strAccountId,ISNULL((SELECT min(dtmDate) from cteBase1),  ''' + @dtmDateFrom + '''))) B


' +  CASE WHEN  @sqlRetain <> 'Retained Earnings Activity Not Displayed' THEN ' UNION ALL SELECT ' + @cols + ' FROM  cteRetain2)' ELSE ')' END

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

	SELECT @cols1 =  REPLACE(@cols1,',dblBeginBalance,dblBeginBalanceUnit','')

	IF @strAccountIdFrom <> '' or @strPrimaryCodeFrom <> '' SELECT @Where1 += CASE WHEN @Where1 <> 'Where' then  'AND ' ELSE ''  END + ' strAccountId NOT IN(SELECT strAccountId FROM cteBase1)'
	SET @sqlCte +=',cteInactive (accountId,id) AS ( SELECT  strAccountId, MIN(intGLDetailId) FROM RAWREPORT ' + CASE WHEN @Where1 <> 'Where' THEN  @Where1 ELSE '' END + ' GROUP BY strAccountId),
		cte1  AS( SELECT * FROM RAWREPORT	A join cteInactive B ON B.accountId = A.strAccountId AND B.id = A.intGLDetailId)'
	SELECT @sqlCte +=	' select ' + @cols1  + '
	,ISNULL(ROUND(B.beginBalance,2),0) AS dblBeginBalance
	,[dblBeginBalanceUnit] = CASE WHEN (ISNULL(B.beginBalanceUnit, 0) = 0) OR (ISNULL(U.dblLbsPerUnit, 0) = 0) THEN 0
					ELSE CAST(ISNULL(ISNULL(B.beginBalanceUnit, 0) / ISNULL(U.dblLbsPerUnit, 0),0) AS NUMERIC(18, 6)) END
	 FROM cte1 A
	 OUTER APPLY (SELECT beginBalance,beginBalanceUnit from dbo.fnGLGetBeginningBalanceAndUnit( A.strAccountId,ISNULL((SELECT min(dtmDate) from cteBase1),  ''' + @dtmDateFrom + '''))) B
	 OUTER APPLY (SELECT dblLbsPerUnit,[strUOMCode] FROM Units WHERE [intAccountId] = A.[intAccountId]) U
	 UNION ALL SELECT ' + @cols + ' from cteBase '
	END

	EXEC (@sqlCte)
END