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
SELECT @GLReportId = intReportId FROM tblRMReport WHERE strName = 'Trial Balance' and strGroup = 'General Ledger' 

DECLARE @GLReportOptions VARCHAR(MAX) = 
'DECLARE @tempTrialBalance TABLE
	(
		 intAccountId		INT
		,strAccountId		NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,dblBeginBalance	 NUMERIC(18, 6)
		,dblBeginBalanceUnit NUMERIC(18, 6)
		,dblDebit			NUMERIC(18, 6)
		,dblCredit			NUMERIC(18, 6)
		,dblDebitUnit		NUMERIC(18, 6)
		,dblCreditUnit		NUMERIC(18, 6)		
		,dblEndBalance		 NUMERIC(18, 6)
		,dblEndBalanceUnit	 NUMERIC(18, 6)
		,dtmDate			DATETIME	
		,strCode			NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,strDescription		NVARCHAR(500) COLLATE Latin1_General_CI_AS 
		,strAccountGroup	NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,strAccountType		NVARCHAR(200) COLLATE Latin1_General_CI_AS 
	)
	
DECLARE @tempTrialBalanceBegin TABLE
	(
		 intAccountId		INT
		,strAccountId		NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,dblBeginBalance	 NUMERIC(18, 6)
		,dblBeginBalanceUnit NUMERIC(18, 6)
		,dblDebit			NUMERIC(18, 6)
		,dblCredit			NUMERIC(18, 6)
		,dblDebitUnit		NUMERIC(18, 6)
		,dblCreditUnit		NUMERIC(18, 6)		
		,dblEndBalance		 NUMERIC(18, 6)
		,dblEndBalanceUnit	 NUMERIC(18, 6)
		,dtmDate			DATETIME	
		,strCode			NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,strDescription		NVARCHAR(500) COLLATE Latin1_General_CI_AS 
		,strAccountGroup	NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,strAccountType		NVARCHAR(200) COLLATE Latin1_General_CI_AS 
	)

DECLARE @tempTrialBalanceEnd TABLE
	(
		 intAccountId		 INT
		,strAccountId		 NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,dblBeginBalance	 NUMERIC(18, 6)
		,dblBeginBalanceUnit NUMERIC(18, 6)		
		,dblDebit			 NUMERIC(18, 6)
		,dblCredit			 NUMERIC(18, 6)
		,dblDebitUnit		 NUMERIC(18, 6)
		,dblCreditUnit		 NUMERIC(18, 6)
		,dblEndBalance		 NUMERIC(18, 6)
		,dblEndBalanceUnit	 NUMERIC(18, 6)
		,dtmDate			 DATETIME	
		,strCode			 NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,strDescription		 NVARCHAR(500) COLLATE Latin1_General_CI_AS 
		,strAccountGroup	 NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,strAccountType		 NVARCHAR(200) COLLATE Latin1_General_CI_AS 
	)		


SET FMTONLY OFF;
		
	
INSERT INTO @tempTrialBalance

SELECT 
	 B.intAccountId
	,B.strAccountId
	,0 as dblBeginBalance
	,0 as dblBeginBalanceUnit
	,dblDebit
	,dblCredit
	,dblDebitUnit
	,dblCreditUnit	
	,0 as dblEndBalance
	,0 as dblEndBalanceUnit
	,dtmDate						
	,strCode	
	,B.strDescription
	,strAccountGroup		
	,strAccountType		
	
FROM tblGLSummary A
LEFT JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
LEFT JOIN tblGLAccountGroup C ON C.intAccountGroupId = B.intAccountGroupId		
	WHERE cast(floor(cast(dtmDate as float)) as datetime) <= ''12/31/2100'' and
		1 = CASE WHEN strCode in (''CY'', ''RE'') and cast(floor(cast(dtmDate as float)) as datetime) = ''12/31/2100'' THEN 0 ELSE 1 END
		and strCode <> ''''
GROUP BY 
	 B.strAccountId
	,B.intAccountId
	,B.strDescription
	,dblDebit
	,dblCredit
	,dblDebitUnit
	,dblCreditUnit
	,A.dtmDate
	,A.strCode
	,C.strAccountType
	,C.strAccountGroup


INSERT INTO @tempTrialBalanceBegin (intAccountId,strAccountId,dblBeginBalance,dblBeginBalanceUnit,dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,dtmDate,strCode,strDescription,strAccountGroup,strAccountType)
SELECT 
	A.intAccountId,
	strAccountId,
	dblBeginBalance = SUM( 
				CASE WHEN B.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN dblDebit - dblCredit
					 ELSE dblCredit - dblDebit
				END),
	dblBeginBalanceUnit = SUM( 
				CASE WHEN B.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN dblDebitUnit - dblCreditUnit
					 ELSE dblCreditUnit - dblDebitUnit
				END)
	,0 as dblDebit, 0 as dblCredit, 0 as dblDebitUnit, 0 as dblCreditUnit, ''01/01/1900'' as dtmDate, '''' as strCode, strDescription, strAccountGroup, strAccountType				
FROM tblGLAccount A
	LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
	LEFT JOIN tblGLSummary C ON A.intAccountId = C.intAccountId
WHERE strAccountId IN (SELECT strAccountId FROM @tempTrialBalance) and dtmDate < cast(''01/01/1900'' as datetime) and strCode <> ''''
GROUP BY strAccountId,A.intAccountId, strDescription, strAccountGroup, strAccountType


INSERT INTO @tempTrialBalanceEnd (intAccountId,strAccountId,dblEndBalance,dblEndBalanceUnit,dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,dtmDate,strCode,strDescription,strAccountGroup,strAccountType)
SELECT 
	A.intAccountId,
	strAccountId,
	dblEndBalance = SUM( 
				CASE	WHEN B.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN dblDebit - dblCredit
						ELSE dblCredit - dblDebit
				END),
	dblEndBalanceUnit = SUM( 
				CASE	WHEN B.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN dblDebitUnit - dblCreditUnit
						ELSE dblCreditUnit - dblDebitUnit
				END) 
	,0 as dblDebit, 0 as dblCredit, 0 as dblDebitUnit, 0 as dblCreditUnit, ''01/01/1900'' as dtmDate, '''' as strCode, strDescription, strAccountGroup, strAccountType		
FROM tblGLAccount A
	LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
	LEFT JOIN tblGLSummary C ON A.intAccountId = C.intAccountId
WHERE strAccountId IN (SELECT strAccountId FROM @tempTrialBalance) and dtmDate <= cast(''12/31/2100'' as datetime)
	and 1 = CASE WHEN strCode in (''CY'', ''RE'') and cast(floor(cast(dtmDate as float)) as datetime) = cast(''12/31/2100'' as datetime) THEN 0 ELSE 1 END
	and strCode <> ''''
GROUP BY strAccountId,A.intAccountId, strDescription, strAccountGroup, strAccountType;


WITH Units 
AS 
(
	SELECT	A.[dblLbsPerUnit], B.[intAccountId] , A.[strUOMCode] 
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
)
--*SC*--
SELECT Segments.*	
		,ISNULL(dblBeginBalance,0) as dblBeginBalance
		,[dblBeginBalanceUnit]	= CASE WHEN (ISNULL(dblBeginBalanceUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0) = 0) THEN 0 
							ELSE CAST(ISNULL(ISNULL(dblBeginBalanceUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
		,ISNULL(dblDebit,0) as dblDebit
		,ISNULL(dblCredit,0) as dblCredit
		,[dblDebitUnit]	= CASE WHEN (ISNULL(dblDebitUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0) = 0) THEN 0 
							ELSE CAST(ISNULL(ISNULL(dblDebitUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
		,[dblCreditUnit] = CASE WHEN (ISNULL(dblCreditUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0) = 0) THEN 0 
							ELSE CAST(ISNULL(ISNULL(dblCreditUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
		,ISNULL(dblEndBalance,0) as dblEndBalance
		,[dblEndBalanceUnit]	= CASE WHEN (ISNULL(dblEndBalanceUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0) = 0) THEN 0 
							ELSE CAST(ISNULL(ISNULL(dblEndBalanceUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END		
		,dtmDate
		,strDescription
		,strAccountGroup
		,strAccountType
		--,strCode
		,ysnActive		
,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = Segments.[intAccountId]) as strUOMCode
FROM
(
	SELECT
		 intAccountId
		 ,dblBeginBalance
		 ,dblBeginBalanceUnit
		 ,dblDebit = case when cast(floor(cast(dtmDate as float)) as datetime) between ''01/01/1900'' and ''12/31/2100'' then SUM(ISNULL(dblDebit,0))  else 0 end
		 ,dblCredit = case when cast(floor(cast(dtmDate as float)) as datetime) between ''01/01/1900'' and ''12/31/2100'' then SUM(ISNULL(dblCredit,0))  else 0 end
		 ,dblDebitUnit = case when cast(floor(cast(dtmDate as float)) as datetime) between ''01/01/1900'' and ''12/31/2100'' then SUM(ISNULL(dblDebitUnit,0))  else 0 end
		 ,dblCreditUnit = case when cast(floor(cast(dtmDate as float)) as datetime) between ''01/01/1900'' and ''12/31/2100'' then SUM(ISNULL(dblCreditUnit,0))  else 0 end 
		 ,dblEndBalance
		 ,dblEndBalanceUnit 
		 ,dtmDate		 
		 ,strDescription
		 ,strAccountGroup
		 ,strAccountType
		 --,strCode
		 ,ysnActive = CASE WHEN SUM(dblDebit) = 0 and SUM(dblCredit) = 0 and dblBeginBalance = 0 and dblEndBalance = 0 THEN 0 ELSE 1 END					
	FROM
	(
		SELECT * FROM @tempTrialBalance
		UNION SELECT * FROM @tempTrialBalanceBegin
		UNION SELECT * FROM @tempTrialBalanceEnd	
	) tblA
	GROUP BY
		 strAccountId
		,intAccountId
		,strDescription
		,dtmDate
		--,strCode
		,strAccountType
		,strAccountGroup
		,dblBeginBalance
		,dblBeginBalanceUnit
		,dblEndBalance		
		,dblEndBalanceUnit
) tblB LEFT JOIN tblGLTempCOASegment Segments ON tblB.intAccountId = Segments.intAccountId
WHERE ysnActive = 1

 --*SCSTART*--'

DECLARE @GLReportDrillDown VARCHAR(MAX) =  '[{"Control":"lblAccountID","DrillThroughType":0,"Name":"General Ledger by Account ID Detail","DrillThroughFilterType":0,"Filters":null,"id":null}]' 

DECLARE @GLReportDataSource VARCHAR(MAX) = 
'DECLARE @tempTrialBalance TABLE
	(
		 intAccountId		INT
		,strAccountId		NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,dblBeginBalance	 NUMERIC(18, 6)
		,dblBeginBalanceUnit NUMERIC(18, 6)
		,dblDebit			NUMERIC(18, 6)
		,dblCredit			NUMERIC(18, 6)
		,dblDebitUnit		NUMERIC(18, 6)
		,dblCreditUnit		NUMERIC(18, 6)		
		,dblEndBalance		 NUMERIC(18, 6)
		,dblEndBalanceUnit	 NUMERIC(18, 6)
		,dtmDate			DATETIME	
		,strCode			NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,strDescription		NVARCHAR(500) COLLATE Latin1_General_CI_AS 
		,strAccountGroup	NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,strAccountType		NVARCHAR(200) COLLATE Latin1_General_CI_AS 
	)
	
DECLARE @tempTrialBalanceBegin TABLE
	(
		 intAccountId		INT
		,strAccountId		NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,dblBeginBalance	 NUMERIC(18, 6)
		,dblBeginBalanceUnit NUMERIC(18, 6)
		,dblDebit			NUMERIC(18, 6)
		,dblCredit			NUMERIC(18, 6)
		,dblDebitUnit		NUMERIC(18, 6)
		,dblCreditUnit		NUMERIC(18, 6)		
		,dblEndBalance		 NUMERIC(18, 6)
		,dblEndBalanceUnit	 NUMERIC(18, 6)
		,dtmDate			DATETIME	
		,strCode			NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,strDescription		NVARCHAR(500) COLLATE Latin1_General_CI_AS 
		,strAccountGroup	NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,strAccountType		NVARCHAR(200) COLLATE Latin1_General_CI_AS 
	)

DECLARE @tempTrialBalanceEnd TABLE
	(
		 intAccountId		 INT
		,strAccountId		 NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,dblBeginBalance	 NUMERIC(18, 6)
		,dblBeginBalanceUnit NUMERIC(18, 6)		
		,dblDebit			 NUMERIC(18, 6)
		,dblCredit			 NUMERIC(18, 6)
		,dblDebitUnit		 NUMERIC(18, 6)
		,dblCreditUnit		 NUMERIC(18, 6)
		,dblEndBalance		 NUMERIC(18, 6)
		,dblEndBalanceUnit	 NUMERIC(18, 6)
		,dtmDate			 DATETIME	
		,strCode			 NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,strDescription		 NVARCHAR(500) COLLATE Latin1_General_CI_AS 
		,strAccountGroup	 NVARCHAR(200) COLLATE Latin1_General_CI_AS 
		,strAccountType		 NVARCHAR(200) COLLATE Latin1_General_CI_AS 
	)		


SET FMTONLY OFF;
		
	
INSERT INTO @tempTrialBalance

SELECT 
	 B.intAccountId
	,B.strAccountId
	,0 as dblBeginBalance
	,0 as dblBeginBalanceUnit
	,dblDebit
	,dblCredit
	,dblDebitUnit
	,dblCreditUnit	
	,0 as dblEndBalance
	,0 as dblEndBalanceUnit
	,dtmDate						
	,strCode	
	,B.strDescription
	,strAccountGroup		
	,strAccountType		
	
FROM tblGLSummary A
LEFT JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
LEFT JOIN tblGLAccountGroup C ON C.intAccountGroupId = B.intAccountGroupId		
	WHERE cast(floor(cast(dtmDate as float)) as datetime) <= ''12/31/2100'' and
		1 = CASE WHEN strCode in (''CY'', ''RE'') and cast(floor(cast(dtmDate as float)) as datetime) = ''12/31/2100'' THEN 0 ELSE 1 END
		and strCode <> ''AA''
GROUP BY 
	 B.strAccountId
	,B.intAccountId
	,B.strDescription
	,dblDebit
	,dblCredit
	,dblDebitUnit
	,dblCreditUnit
	,A.dtmDate
	,A.strCode
	,C.strAccountType
	,C.strAccountGroup


INSERT INTO @tempTrialBalanceBegin (intAccountId,strAccountId,dblBeginBalance,dblBeginBalanceUnit,dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,dtmDate,strCode,strDescription,strAccountGroup,strAccountType)
SELECT 
	A.intAccountId,
	strAccountId,
	dblBeginBalance = SUM( 
				CASE WHEN B.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN dblDebit - dblCredit
					 ELSE dblCredit - dblDebit
				END),
	dblBeginBalanceUnit = SUM( 
				CASE WHEN B.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN dblDebitUnit - dblCreditUnit
					 ELSE dblCreditUnit - dblDebitUnit
				END)
	,0 as dblDebit, 0 as dblCredit, 0 as dblDebitUnit, 0 as dblCreditUnit, ''01/01/1900'' as dtmDate, '''' as strCode, strDescription, strAccountGroup, strAccountType				
FROM tblGLAccount A
	LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
	LEFT JOIN tblGLSummary C ON A.intAccountId = C.intAccountId
WHERE strAccountId IN (SELECT strAccountId FROM @tempTrialBalance) and dtmDate < cast(''01/01/1900'' as datetime) and strCode <> ''AA''
GROUP BY strAccountId,A.intAccountId, strDescription, strAccountGroup, strAccountType


INSERT INTO @tempTrialBalanceEnd (intAccountId,strAccountId,dblEndBalance,dblEndBalanceUnit,dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,dtmDate,strCode,strDescription,strAccountGroup,strAccountType)
SELECT 
	A.intAccountId,
	strAccountId,
	dblEndBalance = SUM( 
				CASE	WHEN B.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN dblDebit - dblCredit
						ELSE dblCredit - dblDebit
				END),
	dblEndBalanceUnit = SUM( 
				CASE	WHEN B.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN dblDebitUnit - dblCreditUnit
						ELSE dblCreditUnit - dblDebitUnit
				END) 
	,0 as dblDebit, 0 as dblCredit, 0 as dblDebitUnit, 0 as dblCreditUnit, ''01/01/1900'' as dtmDate, '''' as strCode, strDescription, strAccountGroup, strAccountType		
FROM tblGLAccount A
	LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
	LEFT JOIN tblGLSummary C ON A.intAccountId = C.intAccountId
WHERE strAccountId IN (SELECT strAccountId FROM @tempTrialBalance) and dtmDate <= cast(''12/31/2100'' as datetime)
	and 1 = CASE WHEN strCode in (''CY'', ''RE'') and cast(floor(cast(dtmDate as float)) as datetime) = cast(''12/31/2100'' as datetime) THEN 0 ELSE 1 END
	and strCode <> ''AA''
GROUP BY strAccountId,A.intAccountId, strDescription, strAccountGroup, strAccountType;


WITH Units 
AS 
(
	SELECT	A.[dblLbsPerUnit], B.[intAccountId], A.[strUOMCode] 
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
)
--*SC*--
SELECT Segments.*
		,ISNULL(dblBeginBalance,0) as dblBeginBalance
		,[dblBeginBalanceUnit]	= CASE WHEN (ISNULL(dblBeginBalanceUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0) = 0) THEN 0 
							ELSE CAST(ISNULL(ISNULL(dblBeginBalanceUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
		,ISNULL(dblDebit,0) as dblDebit
		,ISNULL(dblCredit,0) as dblCredit
		,[dblDebitUnit]	= CASE WHEN (ISNULL(dblDebitUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0) = 0) THEN 0 
							ELSE CAST(ISNULL(ISNULL(dblDebitUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
		,[dblCreditUnit] = CASE WHEN (ISNULL(dblCreditUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0) = 0) THEN 0 
							ELSE CAST(ISNULL(ISNULL(dblCreditUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
		,ISNULL(dblEndBalance,0) as dblEndBalance
		,[dblEndBalanceUnit] = CASE WHEN (ISNULL(dblEndBalanceUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0) = 0) THEN 0 
							ELSE CAST(ISNULL(ISNULL(dblEndBalanceUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = Segments.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
		,dtmDate
		,strDescription
		,strAccountGroup
		,strAccountType
		,ysnActive		
		,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = Segments.[intAccountId]) as strUOMCode
FROM
(
	SELECT
		 intAccountId
		 ,dblBeginBalance
		 ,dblBeginBalanceUnit
		 ,dblDebit = case when cast(floor(cast(dtmDate as float)) as datetime) between ''01/01/1900'' and ''12/31/2100'' then SUM(ISNULL(dblDebit,0))  else 0 end
		 ,dblCredit = case when cast(floor(cast(dtmDate as float)) as datetime) between ''01/01/1900'' and ''12/31/2100'' then SUM(ISNULL(dblCredit,0))  else 0 end
		 ,dblDebitUnit = case when cast(floor(cast(dtmDate as float)) as datetime) between ''01/01/1900'' and ''12/31/2100'' then SUM(ISNULL(dblDebitUnit,0))  else 0 end
		 ,dblCreditUnit = case when cast(floor(cast(dtmDate as float)) as datetime) between ''01/01/1900'' and ''12/31/2100'' then SUM(ISNULL(dblCreditUnit,0))  else 0 end 
		 ,dblEndBalance
		 ,dblEndBalanceUnit 
		 ,dtmDate		 
		 ,strDescription
		 ,strAccountGroup
		 ,strAccountType
		 ,ysnActive = CASE WHEN SUM(dblDebit) = 0 and SUM(dblCredit) = 0 and dblBeginBalance = 0 and dblEndBalance = 0 THEN 0 ELSE 1 END					
	FROM
	(
		SELECT * FROM @tempTrialBalance
		UNION SELECT * FROM @tempTrialBalanceBegin
		UNION SELECT * FROM @tempTrialBalanceEnd	
	) tblA
	GROUP BY
		 strAccountId
		,intAccountId
		,strDescription
		,dtmDate
		,strAccountType
		,strAccountGroup
		,dblBeginBalance
		,dblBeginBalanceUnit
		,dblEndBalance		
		,dblEndBalanceUnit
) tblB LEFT JOIN tblGLTempCOASegment Segments ON tblB.intAccountId = Segments.intAccountId
WHERE ysnActive = 1

 --*SCSTART*--'
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
where r.intReportId = @GLReportId and o.strName ='General Ledger by Account ID Details'

UPDATE o SET strSettings = @GLReportDrillDown
from tblRMDefaultOption o INNER join tblRMReport r on o.intReportId = r.intReportId
where r.intReportId = @GLReportId and o.strName ='General Ledger by Account ID Details' 
--UPDATE THE DATASOURCE
UPDATE d SET strQuery = @GLReportDataSource
from tblRMDatasource d join tblRMReport r on d.intReportId = r.intReportId
where r.intReportId = @GLReportId
PRINT 'Finish updating Trial Balance Report'
END
GO