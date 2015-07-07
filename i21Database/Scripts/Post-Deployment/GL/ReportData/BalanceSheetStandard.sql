﻿/*
--------------------------------------------------------------------------------------
Author				: Trajano, Jeffrey
Date Last Modified	: 6/24/2015
Description			: Updates Report Options/Datasource/Drilldowns for GL Reports
--------------------------------------------------------------------------------------
*/
GO
BEGIN -- Balance Sheet Standard
PRINT 'Begin updating Balance Sheet Standard Report'
DECLARE @GLReportId INT
SELECT @GLReportId = intReportId FROM tblRMReport WHERE strName = 'Balance Sheet Standard' and strGroup = 'General Ledger' 
DECLARE @GLReportOptions VARCHAR(MAX) = 
'WITH Units 
AS 
(
	SELECT	A.[dblLbsPerUnit], B.[intAccountId], A.[strUOMCode] 
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
)
--*SC*--
select top 100 percent
	Cast(Cast(tblGLDetail.dtmDate as Date)as DateTime )as dtmDate
    ,temp.*
    ,tblGLAccount.intAccountUnitId
	,tblGLAccount.strAccountType
	,tblGLAccount.strAccountGroup
    ,tblGLAccount.strDescription as strAccountDescription
	,dblTotal = case when tblGLAccount.strAccountType=''Asset'' then isnull(dblDebit,0)-isnull(dblCredit,0)
			when tblGLAccount.strAccountType=''Liability'' then isnull(dblCredit,0)-isnull(dblDebit,0)
			when tblGLAccount.strAccountType=''Equity'' then isnull(dblCredit,0)-isnull(dblDebit,0)
                        when tblGLAccount.strAccountType=''Revenue'' then isnull(dblCredit,0)-isnull(dblDebit,0)
                        when tblGLAccount.strAccountType=''Expense'' then isnull(dblDebit,0)-isnull(dblCredit,0)
                        when tblGLAccount.strAccountType=''Sales'' then isnull(dblCredit,0)-isnull(dblDebit,0)
                        when tblGLAccount.strAccountType=''Cost of Goods Sold'' then isnull(dblDebit,0)-isnull(dblCredit,0)
                        
			else 0 end
	,dblTotalUnit = CASE WHEN (ISNULL(case when tblGLAccount.strAccountType=''Asset'' then dblDebitUnit-dblCreditUnit
						when tblGLAccount.strAccountType=''Liability'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Equity'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Revenue'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Expense'' then dblDebitUnit-dblCreditUnit
						when tblGLAccount.strAccountType=''Sales'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Cost of Goods Sold'' then dblDebitUnit-dblCreditUnit
						else 0 end, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = tblGLDetail.[intAccountId]), 0) = 0) THEN 0 
					ELSE CAST(ISNULL(ISNULL(case when tblGLAccount.strAccountType=''Asset'' then dblDebitUnit-dblCreditUnit
						when tblGLAccount.strAccountType=''Liability'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Equity'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Revenue'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Expense'' then dblDebitUnit-dblCreditUnit
						when tblGLAccount.strAccountType=''Sales'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Cost of Goods Sold'' then dblDebitUnit-dblCreditUnit
						else 0 end, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = tblGLDetail.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
	, intSort=case when tblGLAccount.strAccountType = ''Asset'' then 1
	when tblGLAccount.strAccountType = ''Liability'' then 2
	when tblGLAccount.strAccountType = ''Equity'' then 3
	when tblGLAccount.strAccountType  = ''Revenue'' then 4		
	when tblGLAccount.strAccountType  = ''Expense'' then 5
	when tblGLAccount.strAccountType  = ''Sales'' then 6
         when tblGLAccount.strAccountType  = ''Cost of Goods Sold'' then 7
	else 100 end
	,tblGLAccount.intSort as intSortGroup
	,tblGLDetail.strCode
	,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = tblGLDetail.[intAccountId]) as strUOMCode
from  tblGLDetail
	left join (select 
				 A.intAccountId
				,A.intAccountUnitId
				,A.strDescription
				,B.strAccountType
				,B.strAccountGroup
				,B.intSort	
				,dblOpeningBalance
				from tblGLAccount A 
					 join tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId )as tblGLAccount
	on tblGLDetail.intAccountId = tblGLAccount.intAccountId
	left join tblGLTempCOASegment temp on tblGLDetail.intAccountId = temp.intAccountId
LEFT JOIN (SELECT NULL as strAccountId, intLength, intLocation
FROM (SELECT SUM(intLength)+1 AS intLocation
FROM tblGLAccountStructure
WHERE intSort < (SELECT TOP 1 intSort 
FROM tblGLAccountStructure 
WHERE strType=''Segment'')) A,
(SELECT TOP 1 intLength 
FROM tblGLAccountStructure 
WHERE strType=''Segment'') B) AS tblStruct
ON ISNULL(tblStruct.strAccountId,tblGLDetail.intAccountId)=tblGLDetail.intAccountId
where tblGLDetail.ysnIsUnposted = 0
and (cast(floor(cast(dtmDate as float)) as datetime) <= ''12/31/2100'' and
		1 = CASE WHEN strCode in (''CY'', ''RE'') and cast(floor(cast(dtmDate as float)) as datetime) = ''12/31/2100'' THEN 0 ELSE 1 END)
--*SCSTART*--
--Special Case--
order by strAccountId'
DECLARE @GLReportDrillDown VARCHAR(MAX) =  '[{"Control":"lblAccountType","DrillThroughType":0,"Name":"General Ledger by Account ID Detail","DrillThroughFilterType":0,"Filters":null,"id":null},{"Control":"lblAccountGroup","DrillThroughType":0,"Name":"General Ledger by Account ID Detail","DrillThroughFilterType":0,"Filters":null,"id":null},{"Control":"lblAcctDesc","DrillThroughType":0,"Name":"General Ledger by Account ID Detail","DrillThroughFilterType":0,"Filters":null,"id":null}]' 
DECLARE @GLReportDataSource VARCHAR(MAX) = 
'WITH Units 
AS 
(
	SELECT	A.[dblLbsPerUnit], B.[intAccountId], A.[strUOMCode] 
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
)
--*SC*--
select top 100 percent
	Cast(Cast(tblGLDetail.dtmDate as Date)as DateTime )as dtmDate
    ,temp.*
    ,tblGLAccount.intAccountUnitId
	,tblGLAccount.strAccountType
	,tblGLAccount.strAccountGroup
    ,tblGLAccount.strDescription as strAccountDescription
	,dblTotal = case when tblGLAccount.strAccountType=''Asset'' then isnull(dblDebit,0)-isnull(dblCredit,0)
			when tblGLAccount.strAccountType=''Liability'' then isnull(dblCredit,0)-isnull(dblDebit,0)
			when tblGLAccount.strAccountType=''Equity'' then isnull(dblCredit,0)-isnull(dblDebit,0)
                        when tblGLAccount.strAccountType=''Revenue'' then isnull(dblCredit,0)-isnull(dblDebit,0)
                        when tblGLAccount.strAccountType=''Expense'' then isnull(dblDebit,0)-isnull(dblCredit,0)
                        when tblGLAccount.strAccountType=''Sales'' then isnull(dblCredit,0)-isnull(dblDebit,0)
                        when tblGLAccount.strAccountType=''Cost of Goods Sold'' then isnull(dblDebit,0)-isnull(dblCredit,0)
                        
			else 0 end			
	,dblTotalUnit = CASE WHEN (ISNULL(case when tblGLAccount.strAccountType=''Asset'' then dblDebitUnit-dblCreditUnit
						when tblGLAccount.strAccountType=''Liability'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Equity'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Revenue'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Expense'' then dblDebitUnit-dblCreditUnit
						when tblGLAccount.strAccountType=''Sales'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Cost of Goods Sold'' then dblDebitUnit-dblCreditUnit
						else 0 end, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = tblGLDetail.[intAccountId]), 0) = 0) THEN 0 
					ELSE CAST(ISNULL(ISNULL(case when tblGLAccount.strAccountType=''Asset'' then dblDebitUnit-dblCreditUnit
						when tblGLAccount.strAccountType=''Liability'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Equity'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Revenue'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Expense'' then dblDebitUnit-dblCreditUnit
						when tblGLAccount.strAccountType=''Sales'' then dblCreditUnit-dblDebitUnit
						when tblGLAccount.strAccountType=''Cost of Goods Sold'' then dblDebitUnit-dblCreditUnit
						else 0 end, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = tblGLDetail.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END							
	, intSort=case when tblGLAccount.strAccountType = ''Asset'' then 1
	when tblGLAccount.strAccountType = ''Liability'' then 2
	when tblGLAccount.strAccountType = ''Equity'' then 3
	when tblGLAccount.strAccountType  = ''Revenue'' then 4		
	when tblGLAccount.strAccountType  = ''Expense'' then 5
	when tblGLAccount.strAccountType  = ''Sales'' then 6
         when tblGLAccount.strAccountType  = ''Cost of Goods Sold'' then 7
	else 100 end
	,tblGLAccount.intSort as intSortGroup
	,tblGLDetail.strCode
	,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = tblGLDetail.[intAccountId]) as strUOMCode
from  tblGLDetail
	left join (select 
				 A.intAccountId
				,A.intAccountUnitId
				,A.strDescription
				,B.strAccountType
				,B.strAccountGroup
				,B.intSort	
				,dblOpeningBalance
				from tblGLAccount A 
					 join tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId )as tblGLAccount
	on tblGLDetail.intAccountId = tblGLAccount.intAccountId
	left join tblGLTempCOASegment temp on tblGLDetail.intAccountId = temp.intAccountId
LEFT JOIN (SELECT NULL as strAccountId, intLength, intLocation
FROM (SELECT SUM(intLength)+1 AS intLocation
FROM tblGLAccountStructure
WHERE intSort < (SELECT TOP 1 intSort 
FROM tblGLAccountStructure 
WHERE strType=''Segment'')) A,
(SELECT TOP 1 intLength 
FROM tblGLAccountStructure 
WHERE strType=''Segment'') B) AS tblStruct
ON ISNULL(tblStruct.strAccountId,tblGLDetail.intAccountId)=tblGLDetail.intAccountId
where tblGLDetail.ysnIsUnposted = 0 and tblGLDetail.strCode != ''AA''
and (cast(floor(cast(dtmDate as float)) as datetime) <= ''12/31/2100'' and
		1 = CASE WHEN strCode in (''CY'', ''RE'') and cast(floor(cast(dtmDate as float)) as datetime) = ''12/31/2100'' THEN 0 ELSE 1 END)
--*SCSTART*--
--Special Case--
order by strAccountId'
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
PRINT 'Finish updating Balance Sheet Standard Report'
END
GO