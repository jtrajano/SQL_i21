/*
--------------------------------------------------------------------------------------
Author				: Trajano, Jeffrey
Date Last Modified	: 6/24/2015
Description			: Updates Report Options/Datasource/Drilldowns for GL Reports
--------------------------------------------------------------------------------------
*/
GO
BEGIN -- Trial Balance Report
PRINT 'Begin updating Trial Balance Report'
DECLARE @GLReportId INT
SELECT @GLReportId = intReportId FROM tblRMReport WHERE strName = 'Trial Balance Detail' and strGroup = 'General Ledger' 

DECLARE @GLReportOptions NVARCHAR(MAX) = 
'WITH Units
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
			 ,ISNULL(dblDebit,0) as dblDebit
			 ,ISNULL(dblCredit,0) as dblCredit
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
		,strAccountId
        ,dblBeginBalance = dbo.fnGetBeginBalance(A.strAccountId,(SELECT MIN(dtmDate) FROM TrialBalanceDetails),'''')
		,dblBeginBalanceUnit =  dbo.fnGetBeginBalanceUnit(A.strAccountId,(SELECT MIN(dtmDate) FROM TrialBalanceDetails),'''')
	FROM tblGLAccount A
		LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
		LEFT JOIN tblGLDetail C ON A.intAccountId = C.intAccountId
	WHERE dtmDate < (SELECT MIN(dtmDate) FROM TrialBalanceDetails WHERE TrialBalanceDetails.intAccountId = A.intAccountId)
	GROUP BY A.intAccountId, strAccountId
)


	SELECT A.intAccountId
	,A.strTransactionId
	,A.strAccountId
	,A.strAccountDescription
	,A.strDetailDescription
	,A.strAccountGroup
	,A.strAccountType
	,SUM(dblDebit) AS dblDebit
	,SUM(dblCredit) AS dblCredit
	,[dblDebitUnit] = CASE WHEN (ISNULL(SUM(dblDebitUnit), 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0
			ELSE CAST(ISNULL(ISNULL(SUM(dblDebitUnit), 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
	,[dblCreditUnit] = CASE WHEN (ISNULL(SUM(dblCreditUnit), 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0
			ELSE CAST(ISNULL(ISNULL(SUM(dblCreditUnit), 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
	,A.dtmDate
	,ISNULL(B.dblBeginBalance,0) AS dblBeginBalance
	,[dblBeginBalanceUnit] = CASE WHEN (ISNULL(B.dblBeginBalanceUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0
			ELSE CAST(ISNULL(ISNULL(B.dblBeginBalanceUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
	,intAccountUnitId
	,dblTotal = SUM(
					CASE	WHEN A.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN isnull(dblDebit, 0 ) - isnull(dblCredit,0)
							ELSE isnull(dblCredit, 0 ) - isnull(dblDebit,0)
					END
				)
	,dblTotalUnit = CASE WHEN (ISNULL(SUM(
							CASE	WHEN A.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN isnull(dblDebitUnit, 0 ) - isnull(dblCreditUnit,0)
									ELSE isnull(dblCreditUnit, 0 ) - isnull(dblDebitUnit,0)
							END), 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0
					 ELSE CAST(ISNULL(ISNULL(SUM(
							CASE	WHEN A.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN isnull(dblDebitUnit, 0 ) - isnull(dblCreditUnit,0)
									ELSE isnull(dblCreditUnit, 0 ) - isnull(dblDebitUnit,0)
							END), 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
	,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = A.[intAccountId]) as strUOMCode

		FROM TrialBalanceDetails A
			LEFT JOIN BeginBalance B ON A.intAccountId = B.intAccountId
	Group By
	 A.intAccountId
	,A.strTransactionId
	,A.strAccountId
	,A.strAccountDescription
	,A.strDetailDescription
	,A.dtmDate
	,dblBeginBalance
	,dblBeginBalanceUnit
	,intAccountUnitId
	,strAccountType
	,strAccountGroup'

DECLARE @GLReportDrillDown NVARCHAR(MAX) =  '[{"Control":"labelEx1","DrillThroughType":0,"Name":"General Ledger by Account ID Detail","DrillThroughFilterType":0,"Filters":null,"id":null},{"Control":"labelEx2","DrillThroughType":0,"Name":"General Ledger by Account ID Detail","DrillThroughFilterType":0,"Filters":null,"id":null}]' 
DECLARE @GLReportDataSource NVARCHAR(MAX) = 
'WITH Units
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
			 ,ISNULL(dblDebit,0) as dblDebit
			 ,ISNULL(dblCredit,0) as dblCredit
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
,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = tblGLAccount.[intAccountId]) as strUOMCode
			FROM tblGLAccount
			INNER JOIN tblGLDetail on tblGLAccount.intAccountId = tblGLDetail.intAccountId
			INNER JOIN tblGLAccountGroup ON tblGLAccount.intAccountGroupId  = tblGLAccountGroup.intAccountGroupId
			LEFT JOIN tblGLTempCOASegment Segments ON tblGLAccount.intAccountId = Segments.intAccountId
			WHERE ysnIsUnposted = ''False'' and tblGLDetail.strCode != ''AA''
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
		,strAccountId
        ,dblBeginBalance = dbo.fnGetBeginBalance(A.strAccountId,(SELECT MIN(dtmDate) FROM TrialBalanceDetails),''AA'')
		,dblBeginBalanceUnit =  dbo.fnGetBeginBalanceUnit(A.strAccountId,(SELECT MIN(dtmDate) FROM TrialBalanceDetails),''AA'')
	FROM tblGLAccount A
		LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
		LEFT JOIN tblGLDetail C ON A.intAccountId = C.intAccountId
	WHERE dtmDate < (SELECT MIN(dtmDate) FROM TrialBalanceDetails WHERE TrialBalanceDetails.intAccountId = A.intAccountId)
	GROUP BY A.intAccountId, strAccountId
)


	SELECT A.intAccountId
	,A.strTransactionId
	,A.strAccountId
	,A.strAccountDescription
	,A.strDetailDescription
	,A.strAccountGroup
	,A.strAccountType
	,SUM(dblDebit) AS dblDebit
	,SUM(dblCredit) AS dblCredit
	,[dblDebitUnit] = CASE WHEN (ISNULL(SUM(dblDebitUnit), 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0
			ELSE CAST(ISNULL(ISNULL(SUM(dblDebitUnit), 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
	,[dblCreditUnit] = CASE WHEN (ISNULL(SUM(dblCreditUnit), 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0
			ELSE CAST(ISNULL(ISNULL(SUM(dblCreditUnit), 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
	,A.dtmDate
	,ISNULL(B.dblBeginBalance,0) AS dblBeginBalance
	,[dblBeginBalanceUnit] = CASE WHEN (ISNULL(B.dblBeginBalanceUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0
			ELSE CAST(ISNULL(ISNULL(B.dblBeginBalanceUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
	,intAccountUnitId
	,dblTotal = SUM(
					CASE	WHEN A.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN isnull(dblDebit, 0 ) - isnull(dblCredit,0)
							ELSE isnull(dblCredit, 0 ) - isnull(dblDebit,0)
					END
				)
	,dblTotalUnit = CASE WHEN (ISNULL(SUM(
							CASE	WHEN A.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN isnull(dblDebitUnit, 0 ) - isnull(dblCreditUnit,0)
									ELSE isnull(dblCreditUnit, 0 ) - isnull(dblDebitUnit,0)
							END), 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0
					 ELSE CAST(ISNULL(ISNULL(SUM(
							CASE	WHEN A.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN isnull(dblDebitUnit, 0 ) - isnull(dblCreditUnit,0)
									ELSE isnull(dblCreditUnit, 0 ) - isnull(dblDebitUnit,0)
							END), 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
	,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = A.[intAccountId]) as strUOMCode

	FROM TrialBalanceDetails A
		LEFT JOIN BeginBalance B ON A.intAccountId = B.intAccountId
	Group By
	 A.intAccountId
	,A.strTransactionId
	,A.strAccountId
	,A.strAccountDescription
	,A.strDetailDescription
	,A.dtmDate
	,dblBeginBalance
	,dblBeginBalanceUnit
	,intAccountUnitId
	,strAccountType
	,strAccountGroup'
--UPDATE THE OPTIONS
UPDATE o SET o.strSettings = @GLReportOptions
 from tblRMOption o join tblRMReport r on o.intReportId = r.intReportId
where r.intReportId = @GLReportId and o.strName ='Include Audit Adjustment'

UPDATE o SET o.strSettings = @GLReportOptions
 from tblRMDefaultOption o join tblRMReport r on o.intReportId = r.intReportId
where r.intReportId = @GLReportId and o.strName ='Include Audit Adjustment'

--UPDATE THE DRILL DOWN
UPDATE o SET strSettings = @GLReportDrillDown
from tblRMOption o INNER join tblRMReport r on o.intReportId = r.intReportId
where r.intReportId = @GLReportId and o.strName ='General Ledger by Account ID Detail'

UPDATE o SET strSettings = @GLReportDrillDown
from tblRMDefaultOption o INNER join tblRMReport r on o.intReportId = r.intReportId
where r.intReportId = @GLReportId and o.strName ='General Ledger by Account ID Detail'
--UPDATE THE DATASOURCE
UPDATE d SET strQuery = @GLReportDataSource
from tblRMDatasource d join tblRMReport r on d.intReportId = r.intReportId
where r.intReportId = @GLReportId
PRINT 'Finish updating Trial Balance Detail Report'
END
GO