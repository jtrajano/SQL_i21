CREATE PROCEDURE [dbo].[uspGLGetTrialBalanceDetailReport]
(@xmlParam NVARCHAR(MAX)= '')
as
BEGIN
SET NOCOUNT ON;
IF (ISNULL(@xmlParam,'')  = '')
BEGIN
	SELECT DISTINCT
	'' as strCompanyName,
	0 as intAccountId,
	'' as strTransactionId,
	'' as strAccountId,
	'' as strAccountDescription,
	'' as strDetailDescription,
	'' as strAccountGroup,
	''  as strAccountType,
	0.0 as dblDebit,
	0.0 as dblCredit,
	0.0 as dblDebitUnit,
	0.0 as dblCreditUnit,
	GETDATE() AS dtmDate,
	0.0 as dblBeginBalance,
	0.0 as dblBeginBalanceUnit,
	0 as intAccountUnitId,
	0.0 as dblTotal,
	0.0 as dblTotalUnit,
	'' as strUOMCode
	RETURN;
END
--SET FMTONLY off;
DECLARE @idoc INT
DECLARE @filterTable FilterTableType
DECLARE @strAccountIdFrom NVARCHAR(50)
DECLARE @strAccountIdTo NVARCHAR(50)
DECLARE @strPrimaryCodeFrom NVARCHAR(50)
DECLARE @strPrimaryCodeTo NVARCHAR(50)
DECLARE @strPrimaryCodeCondition NVARCHAR(50) = ''
DECLARE @dtmDateFrom NVARCHAR(50)
DECLARE @dtmDateTo NVARCHAR(50)
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
	update @filterTable SET [fieldname] = '[Primary Account]' WHERE fieldname = 'Primary Account' 
	update @filterTable SET [fieldname] = '[Primary Account]' WHERE fieldname = 'PrimaryAccount' 
	delete FROM @filterTable WHERE [condition]= 'All Date'
	
	SELECT TOP 1 @strAccountIdFrom= [from] , @strAccountIdTo = [to] ,@strAccountIdCondition =[condition] from  @filterTable WHERE [fieldname] = 'strAccountId' 
	SELECT TOP 1 @strPrimaryCodeFrom= [from] , @strPrimaryCodeTo = [to] ,@strPrimaryCodeCondition =[condition] from  @filterTable WHERE [fieldname] = '[Primary Account]' 
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
DECLARE @Where NVARCHAR(MAX) = dbo.fnConvertFilterTableToWhereExpression (@filterTable)

DECLARE @cols NVARCHAR (MAX) = 'strCompanyName, intAccountId, strTransactionId,strAccountId,strAccountDescription,strDetailDescription,strAccountGroup,strAccountType,dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,dtmDate,dblBeginBalance,dblBeginBalanceUnit
,intAccountUnitId,dblTotal,dblTotalUnit,strUOMCode'
DECLARE @sqlCte NVARCHAR(MAX) 
SET @sqlCte =
';WITH Units
AS
(
	SELECT	A.[dblLbsPerUnit], B.[intAccountId], A.[strUOMCode]
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
),
TrialBalanceDetails
AS
(

		--*SC*--
			SELECT
			  tblGLAccount.strDescription as strAccountDescription
			 ,tblGLDetail.strTransactionId as strTransactionId
			 ,tblGLDetail.strDescription as strDetailDescription
			 ,ISNULL(ROUND(dblDebit,2),0) as dblDebit
			 ,ISNULL(ROUND(dblCredit,2),0) as dblCredit
			 ,ISNULL((Case When intAccountUnitId IS NULL Then dblDebitUnit
				   Else
					Case  When dblDebitUnit IS NULL Then ISNULL(dblDebitUnit,0)
						 Else dblDebitUnit
					End
				End),0) as dblDebitUnit
			,ISNULL((Case When intAccountUnitId IS NULL Then dblCreditUnit
				   Else
					Case  When dblCreditUnit IS NULL Then ISNULL(dblCreditUnit,0)
						 Else dblCreditUnit
					End
				End),0) as dblCreditUnit
			 ,Cast(Cast(tblGLDetail.dtmDate as Date) as DateTime) as dtmDate
			 ,tblGLAccountGroup.strAccountType
			 ,tblGLAccountGroup.strAccountGroup
			 ,intAccountUnitId
			 ,strCode
			 ,Segments.*
			 , tblGLDetail.intGLDetailId
,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = tblGLAccount.[intAccountId]) as strUOMCode
			FROM tblGLAccount
			INNER JOIN tblGLDetail on tblGLAccount.intAccountId = tblGLDetail.intAccountId
			INNER JOIN tblGLAccountGroup ON tblGLAccount.intAccountGroupId  = tblGLAccountGroup.intAccountGroupId
			LEFT JOIN tblGLTempCOASegment Segments ON tblGLAccount.intAccountId = Segments.intAccountId
			WHERE ysnIsUnposted = ''False''
		--*SCSTART*--
),

BeginBalance
(
intAccountId
,strAccountId
,dblBeginBalance
,dblBeginBalanceUnit
)
AS
(
	SELECT
		A.intAccountId
		,A.strAccountId
        ,dblBeginBalance = MIN(D.beginBalance)
		,dblBeginBalanceUnit = MIN(D.beginBalanceUnit)
	FROM tblGLAccount A
		LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
		LEFT JOIN tblGLDetail C ON A.intAccountId = C.intAccountId
	OUTER APPLY dbo.fnGLGetBeginningBalanceAndUnit(A.strAccountId,(SELECT CASE WHEN ''' + ISNULL(@dtmDateFrom,'') + ''' = '''' THEN MIN(dtmDate) ELSE ''' +  ISNULL(@dtmDateFrom,'') + ''' END FROM TrialBalanceDetails)) D
	GROUP BY A.intAccountId, A.strAccountId
),
RAWREPORT AS
(

	SELECT
	C.strCompanyName
	,A.intAccountId
	,A.strTransactionId
	,A.strAccountId
	,A.strAccountDescription
	,A.strDetailDescription
	,A.strAccountGroup
	,A.strAccountType
	,dblDebit
	,dblCredit
	,dblDebitUnit
	,dblCreditUnit
	,0 as dblTotalUnit
	,A.dtmDate
	,ISNULL(ROUND(B.dblBeginBalance,2),0) AS dblBeginBalance
	,[dblBeginBalanceUnit] = CASE WHEN (ISNULL(B.dblBeginBalanceUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0
			ELSE CAST(ISNULL(ISNULL(B.dblBeginBalanceUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
	,intAccountUnitId
	,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = A.[intAccountId]) as strUOMCode
	,(CASE WHEN A.intGLDetailId  is  NULL  then '''' else A.intGLDetailId END) as intGLDetailId
	,[Primary Account]
		FROM TrialBalanceDetails A
			LEFT JOIN BeginBalance B ON A.intAccountId = B.intAccountId
			OUTER APPLY(SELECT TOP 1 strCompanyName from tblSMCompanySetup) C
	
)'
SELECT @sqlCte += ',cteBase1 as(
	select 
	strCompanyName
	,intAccountId, strTransactionId,strAccountId,strAccountDescription,strDetailDescription,strAccountGroup,strAccountType
	,sum(dblDebit) AS dblDebit
	,sum(dblCredit) as dblCredit
	,dtmDate
	,dblBeginBalance
	,dblBeginBalanceUnit
	,intAccountUnitId
	,CASE WHEN (ISNULL(SUM(dblDebitUnit), 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0
	          ELSE CAST(ISNULL(ISNULL(SUM(dblDebitUnit), 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END as dblDebitUnit
	,CASE WHEN (ISNULL(SUM(dblCreditUnit), 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0
	          ELSE CAST(ISNULL(ISNULL(SUM(dblCreditUnit), 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END as [dblCreditUnit] 
	,SUM(
					CASE	WHEN A.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN isnull(dblDebit, 0 ) - isnull(dblCredit,0)
							ELSE (isnull(dblCredit, 0 ) - isnull(dblDebit,0)) * -1
					END
				) as dblTotal


	,CASE WHEN (ISNULL(SUM(
							CASE	WHEN A.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN isnull(dblDebitUnit, 0 ) - isnull(dblCreditUnit,0)
									ELSE isnull(dblCreditUnit, 0 ) - isnull(dblDebitUnit,0)
							END), 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0
					 ELSE CAST(ISNULL(ISNULL(SUM(
							CASE	WHEN A.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN isnull(dblDebitUnit, 0 ) - isnull(dblCreditUnit,0)
									ELSE isnull(dblCreditUnit, 0 ) - isnull(dblDebitUnit,0)
							END), 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END as dblTotalUnit
	,strUOMCode
	,[Primary Account]
	from RAWREPORT A
	Group By
	strCompanyName
	,intAccountId
	,strTransactionId
	,strAccountId
	,strAccountDescription
	,strDetailDescription
	,dtmDate
	,dblBeginBalance
	,dblBeginBalanceUnit
	,intAccountUnitId
	,strAccountType
	,strAccountGroup
	,strUOMCode
	,[Primary Account]
	 )'

	 SELECT @sqlCte += ',cteBase as(
	select * from cteBase1 ' + CASE WHEN @Where <> 'Where' THEN  @Where ELSE '' END + ')'
IF @dtmDateFrom IS NOT NULL
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
	DELETE FROM @filterTable WHERE fieldname = 'dtmDate'
	DECLARE @Where1 NVARCHAR(MAX) = dbo.fnConvertFilterTableToWhereExpression (@filterTable)
	IF @strAccountIdFrom <> '' or @strPrimaryCodeFrom <> '' SELECT @Where1 += CASE WHEN @Where1 <> 'Where' then  'AND ' ELSE ''  END + ' strAccountId NOT IN(SELECT strAccountId FROM cteBase)'
	--IF @strPrimaryCodeFrom <> '' SELECT @Where1 += CASE WHEN @Where1 <> 'Where' then  'AND ' ELSE ''  END  +  ' [Primary Account] NOT IN(SELECT [Primary Account] FROM cteBase)'
	SET @sqlCte +=',cteInactive (accountId,id) AS ( SELECT  strAccountId, MIN(intGLDetailId) FROM RAWREPORT ' + CASE WHEN @Where1 <> 'Where' THEN  @Where1 ELSE '' END + ' GROUP BY strAccountId),
		cte1  AS( SELECT * FROM RAWREPORT	A join cteInactive B ON B.accountId = A.strAccountId AND B.id = A.intGLDetailId)'
	SELECT @sqlCte +=	' select ' + @cols1  + ' FROM cte1 union all select ' + @cols + ' from cteBase '

END
ELSE
BEGIN
	SET @sqlCte += 'SELECT * FROM cteBase'
END
EXEC (@sqlCte)
--print @sqlCte
END