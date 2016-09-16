CREATE FUNCTION [dbo].[fnGLGetAccountDetailSQL]
(
	@strAccountIdFrom NVARCHAR(50),
	@dtmDateFrom NVARCHAR(50),
	@dtmDateTo NVARCHAR(50),
	@filterTable1 FilterTableType READONLY
)
RETURNS NVARCHAR(MAX)
AS
 BEGIN
   DECLARE @Where NVARCHAR(MAX) 
   DECLARE @filterTable FilterTableType
   DECLARE @withFilterParam BIT = 0
   SELECT TOP 1 @withFilterParam= 1 FROM @filterTable1
   IF @withFilterParam = 0
      SET @Where  = ' WHERE dtmDate BETWEEN ''' + @dtmDateFrom  + ''' AND ''' + @dtmDateTo + ''' AND strAccountId = ''' + @strAccountIdFrom + ''''
   ELSE
   BEGIN
	  INSERT INTO @filterTable(fieldname,condition,[from],[to],[join],begingroup,endgroup,datatype)
	  SELECT fieldname,condition,[from],[to],[join],begingroup,endgroup,datatype 
	  FROM @filterTable1
	  SET @Where = dbo.fnConvertFilterTableToWhereExpression (@filterTable)
   END
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
   ,''Account ID: '' + Account.strAccountId + '' '' + RTRIM(ISNULL(Account.strDescription,'''')) + '' '' +  ISNULL(Grp.strAccountGroup,'''') + ''-'' + ISNULL(Grp.strAccountType,'''') as AccountHeader
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
				CASE	WHEN Grp.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN (ISNULL(ROUND(A.dblDebit,2), 0 ) - ISNULL(ROUND(A.dblCredit,2),0))
						ELSE ((ISNULL(ROUND(A.dblCredit,2), 0 ) - ISNULL(ROUND(A.dblDebit,2),0) ))*-1
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

   --DELETE FROM @filterTable WHERE fieldname = 'dtmDate'
   DECLARE @Where1 NVARCHAR(MAX)
   IF (@withFilterParam = 1)
   BEGIN
		DELETE FROM @filterTable WHERE fieldname = 'dtmDate'
		SET @Where1 = dbo.fnConvertFilterTableToWhereExpression (@filterTable)
   END
   ELSE
		SET @Where1 = ' WHERE strAccountId =''' + @strAccountIdFrom + '''' -- dbo.fnConvertFilterTableToWhereExpression (@filterTable)

   DECLARE @dtmFromDateRetain NVARCHAR(10), @dtmToDateRetain NVARCHAR(10), @intRetainAccount NVARCHAR(10),@strRetainAccount NVARCHAR(50), @multiFiscal BIT=0
   DECLARE @sqlRetain NVARCHAR(MAX)
   SELECT @sqlRetain = QueryString, @dtmFromDateRetain = DateTo, @multiFiscal = MultiFiscal FROM dbo.fnGLGetRetainedEarningSQLString(@dtmDateFrom,@dtmDateTo,'cteRetain2',@Where1)
   IF @multiFiscal <> 0 SELECT @sqlCte += @sqlRetain
   SELECT TOP 1  @intRetainAccount  = CONVERT(NVARCHAR(10), ISNULL(intRetainAccount,'')) ,@strRetainAccount = act.strAccountId FROM dbo.tblGLFiscalYear tgy JOIN tblGLAccount act ON tgy.intRetainAccount = act.intAccountId
   DECLARE @WhereExcludeRetain NVARCHAR(MAX) = @Where
   SELECT @WhereExcludeRetain += CASE WHEN @WhereExcludeRetain <>  'Where' THEN ' AND ' ELSE ' ' END
   SELECT @WhereExcludeRetain += 'intAccountId <>'
   SELECT @WhereExcludeRetain += @intRetainAccount
   SELECT @sqlCte += ',cteBase1 as(SELECT * from RAWREPORT ' +  @WhereExcludeRetain + ')'-- UNION ALL SELECT ' + @cols + ' from cteRetain2 )'
   SELECT @dtmToDateRetain = CASE WHEN @dtmDateTo = '' THEN '2100/01/01' ELSE @dtmDateTo END
   SELECT @sqlCte += ',cteRetainAccount as ( SELECT * FROM (SELECT * from RAWREPORT '  + CASE WHEN @Where <> 'Where' THEN @Where ELSE ' ' END + ') A
   Where A.dtmDate BETWEEN  ''' + isnull(@dtmDateFrom,'1900/01/01') + ''' AND ''' + @dtmToDateRetain + ''' AND intAccountId = ' + @intRetainAccount + ')'
   DECLARE @colsWithoutBalance NVARCHAR(MAX)
   SELECT @colsWithoutBalance = REPLACE(@cols,',strUOMCode',',ISNULL(U.strUOMCode,'''') strUOMCode')
   SELECT @colsWithoutBalance = REPLACE(@colsWithoutBalance,',dblBeginBalanceUnit',',Balance.Unit dblBeginBalanceUnit')
   SELECT @colsWithoutBalance = REPLACE(@colsWithoutBalance,',dblBeginBalance',',ISNULL(ROUND(B.beginBalance,2),0) dblBeginBalance')
   SELECT @colsWithoutBalance = REPLACE(@colsWithoutBalance,',dblDebitUnit,dblCreditUnit',', Debit.Unit dblDebitUnit,Credit.Unit dblCreditUnit')

   SELECT @sqlCte+= '
   ,MinDate as 
   (
		SELECT min(dtmDate) mDate from cteBase1
   )
   ,MinDate1 as (
		SELECT ISNULL(mDate,''' + @dtmDateFrom + ''') mDate from MinDate
   )
   ,cteBase as (	
	   SELECT '+ @colsWithoutBalance +' from cteBase1 A
	   OUTER APPLY (SELECT mDate from MinDate1) M
	   OUTER APPLY (SELECT dblLbsPerUnit,[strUOMCode] FROM Units WHERE [intAccountId] = A.[intAccountId]) U
	   OUTER APPLY (SELECT beginBalance,beginBalanceUnit from dbo.fnGLGetBeginningBalanceAndUnit( A.strAccountId,M.mDate)) B
	   OUTER APPLY dbo.fnGLGetAccountUnit(B.beginBalanceUnit, U.dblLbsPerUnit) Balance
	   OUTER APPLY dbo.fnGLGetAccountUnit(A.dblDebitUnit, U.dblLbsPerUnit) Debit
	   OUTER APPLY dbo.fnGLGetAccountUnit(A.dblCreditUnit, U.dblLbsPerUnit) Credit
	   ' +  CASE WHEN  @multiFiscal <> 0 THEN ' UNION ALL SELECT ' + REPLACE(@colsWithoutBalance ,', Debit.Unit dblDebitUnit,Credit.Unit dblCreditUnit',',dblDebitUnit,dblCreditUnit')
	   + ' FROM  cteRetain2 A
	   OUTER APPLY (SELECT mDate from MinDate1) M
	   OUTER APPLY (SELECT dblLbsPerUnit,[strUOMCode] FROM Units WHERE intAccountId = ' + @intRetainAccount + ') U
	   OUTER APPLY (SELECT TOP 1 convert(varchar(10), dtmDateFrom,111) dtmDateFrom from tblGLFiscalYear where ''' + @dtmFromDateRetain + ''' BETWEEN dtmDateFrom and dtmDateTo) F
	   OUTER APPLY (SELECT beginBalance,beginBalanceUnit from dbo.fnGLGetBeginningBalanceAndUnitRE( strAccountId,M.mDate,F.dtmDateFrom ,''' + CONVERT(VARCHAR(1),@multiFiscal) + ''' )) B
	   OUTER APPLY dbo.fnGLGetAccountUnit(B.beginBalanceUnit, U.dblLbsPerUnit) Balance
	   ' ELSE ' ' END +
	   'UNION ALL SELECT ' + @colsWithoutBalance + '
	   FROM cteRetainAccount A
	   OUTER APPLY (SELECT mDate from MinDate1) M
	   OUTER APPLY (SELECT dblLbsPerUnit,[strUOMCode] FROM Units WHERE [intAccountId] = A.[intAccountId]) U
	   OUTER APPLY (SELECT TOP 1 convert(varchar(10), dtmDateFrom,111) dtmDateFrom from tblGLFiscalYear where ''' + @dtmFromDateRetain + ''' BETWEEN dtmDateFrom and dtmDateTo) F
	   OUTER APPLY (SELECT beginBalance,beginBalanceUnit from dbo.fnGLGetBeginningBalanceAndUnitRE( A.strAccountId,M.mDate,F.dtmDateFrom ,''' + CONVERT(VARCHAR(1),@multiFiscal) + ''' )) B
	   OUTER APPLY dbo.fnGLGetAccountUnit(B.beginBalanceUnit, U.dblLbsPerUnit) Balance
	   OUTER APPLY dbo.fnGLGetAccountUnit(A.dblDebitUnit, U.dblLbsPerUnit) Debit
	   OUTER APPLY dbo.fnGLGetAccountUnit(A.dblCreditUnit, U.dblLbsPerUnit) Credit
   )'

   IF @dtmDateFrom = '' OR @dtmDateFrom IS NULL
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

	IF @strAccountIdFrom <> '' SELECT @Where1 += CASE WHEN @Where1 <> 'Where' then  'AND ' ELSE ''  END + ' strAccountId NOT IN(SELECT strAccountId FROM cteBase1 UNION ALL SELECT strAccountId FROM cteRetainAccount)'
	SET @sqlCte +=',cteInactive (accountId,id) AS ( SELECT  strAccountId, MIN(intGLDetailId) FROM RAWREPORT ' + CASE WHEN @Where1 <> 'Where' THEN  @Where1 ELSE '' END + ' GROUP BY strAccountId),
		cte1  AS( SELECT * FROM RAWREPORT	A join cteInactive B ON B.accountId = A.strAccountId AND B.id = A.intGLDetailId)'
	SELECT @sqlCte +=' , result as (select ' + @cols1  + '
	,ISNULL(ROUND( CASE WHEN ' + @intRetainAccount + '= A.intAccountId  THEN C.beginBalance ELSE B.beginBalance END,2),0) AS dblBeginBalance
	,[dblBeginBalanceUnit] = CASE WHEN (ISNULL( CASE WHEN ' + @intRetainAccount + '= A.intAccountId  THEN C.beginBalanceUnit ELSE B.beginBalanceUnit END, 0) = 0) OR (ISNULL(U.dblLbsPerUnit, 0) = 0) THEN 0
					ELSE CAST(ISNULL(ISNULL(CASE WHEN ' + @intRetainAccount + '= A.intAccountId  THEN C.beginBalanceUnit ELSE B.beginBalanceUnit END, 0) / ISNULL(U.dblLbsPerUnit, 0),0) AS NUMERIC(18, 6)) END
	 FROM cte1 A
	 OUTER APPLY (SELECT mDate from MinDate1) M
	 OUTER APPLY (SELECT beginBalance,beginBalanceUnit from dbo.fnGLGetBeginningBalanceAndUnit( A.strAccountId,M.mDate)) B
	 OUTER APPLY (SELECT TOP 1 convert(varchar(10), dtmDateFrom,111) dtmDateFrom from tblGLFiscalYear where ''' + @dtmFromDateRetain + ''' BETWEEN dtmDateFrom and dtmDateTo) F
	 OUTER APPLY (SELECT beginBalance,beginBalanceUnit from dbo.fnGLGetBeginningBalanceAndUnitRE( A.strAccountId,M.mDate,F.dtmDateFrom ,''' + CONVERT(VARCHAR(1),@multiFiscal) + ''' )) C
	 OUTER APPLY (SELECT dblLbsPerUnit,[strUOMCode] FROM Units WHERE [intAccountId] = A.[intAccountId]) U
	 UNION ALL SELECT ' + @cols + ' from cteBase )'
	END
	RETURN @sqlCte
END

GO

