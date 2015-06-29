/*
--------------------------------------------------------------------------------------
Author				: Trajano, Jeffrey
Date Last Modified	: 6/24/2015
Description			: Updates Report Options/Datasource/Drilldowns for GL Reports
--------------------------------------------------------------------------------------
*/
GO
BEGIN -- Income Statement Standard Report
PRINT 'Begin updating Income Statement Standard Report'
DECLARE @GLReportId INT
SELECT @GLReportId = intReportId FROM tblRMReport WHERE strName = 'Income Statement Standard' and strGroup = 'General Ledger' 

DECLARE @GLReportOptions NVARCHAR(MAX) = 
'WITH Units 
AS 
(
	SELECT	A.[dblLbsPerUnit], B.[intAccountId], A.[strUOMCode] 
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
)
--*SC*--
select top 100 percent  
 temp.*
 ,Cast(Cast(tblGLDetail.dtmDate as Date) as DateTime) as dtmDate
,tblGLDetail.strTransactionId
,tblGLDetail.strCode
,tblGLDetail.strDescription as strGLDescription
,tblGLAccount.strAccountType 
,tblGLAccount.strAccountGroup
,tblGLAccount.intParentGroupId as intAccountGroupSort
,tblGLAccount.strDescription as strAccountDescription
, dblSubTotal=case when tblGLAccount.strAccountType = ''Asset'' then isnull(dblDebit,0) - isnull(dblCredit,0)
	when tblGLAccount.strAccountType = ''Liability'' then isnull(dblCredit,0) - isnull(dblDebit,0)
	when tblGLAccount.strAccountType = ''Equity'' then isnull(dblCredit,0) - isnull(dblDebit,0)
	when tblGLAccount.strAccountType = ''Revenue'' then isnull(dblCredit,0) - isnull(dblDebit,0)
	when tblGLAccount.strAccountType = ''Sales'' then isnull(dblCredit,0) - isnull(dblDebit,0)
	when tblGLAccount.strAccountType = ''Expense'' then isnull(dblDebit,0) - isnull(dblCredit,0)
	when tblGLAccount.strAccountType = ''Cost of Goods Sold'' then isnull(dblDebit,0) - isnull(dblCredit,0)
	else 0 end
,dblSubTotalUnit = CASE WHEN (ISNULL(case when tblGLAccount.strAccountType = ''Asset'' then isnull(dblDebitUnit,0) - isnull(dblCreditUnit,0)
					when tblGLAccount.strAccountType = ''Liability'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Equity'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Revenue'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Sales'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Expense'' then isnull(dblDebitUnit,0) - isnull(dblCreditUnit,0)
					when tblGLAccount.strAccountType = ''Cost of Goods Sold'' then isnull(dblDebitUnit,0) - isnull(dblCreditUnit,0)
					end, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = tblGLDetail.[intAccountId]), 0) = 0) THEN 0 
				ELSE CAST(ISNULL(ISNULL(case when tblGLAccount.strAccountType = ''Asset'' then isnull(dblDebitUnit,0) - isnull(dblCreditUnit,0)
					when tblGLAccount.strAccountType = ''Liability'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Equity'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Revenue'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Sales'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Expense'' then isnull(dblDebitUnit,0) - isnull(dblCreditUnit,0)
					when tblGLAccount.strAccountType = ''Cost of Goods Sold'' then isnull(dblDebitUnit,0) - isnull(dblCreditUnit,0)
					end, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = tblGLDetail.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END		
, intSort=case when tblGLAccount.strAccountType = ''Sales'' then 1
	when tblGLAccount.strAccountType = ''Cost of Goods Sold'' then 2
	when tblGLAccount.strAccountType = ''Revenue'' then 3
	when tblGLAccount.strAccountType = ''Expense'' then 4
	else 100 end
, tblGLDetail.strReference
,intAccountUnitId
,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = tblGLDetail.[intAccountId]) as strUOMCode
from  tblGLDetail
	left join (select 
				 A.intAccountId
				,A.strDescription
				,A.intAccountUnitId
				,B.strAccountType
				,B.strAccountGroup
				,B.intParentGroupId
				,dblOpeningBalance
				from tblGLAccount A 
					left join tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId )as tblGLAccount
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
where tblGLDetail.ysnIsUnposted = 0 and tblGLAccount.strAccountType in (''Revenue'', ''Expense'', ''Cost of Goods Sold'',''Sales'') 
  --*SCSTART*--
--Special Case--
order by intSort'

DECLARE @GLReportDrillDown NVARCHAR(MAX) =  '[{"id":"Reports.model.DrillThrough-23","Control":"lblAccountType","DrillThroughType":0,"DrillThroughValue":"lblAccountType value","Name":"General Ledger by Account ID Detail"},{"id":"Reports.model.DrillThrough-25","Control":"labelEx2","DrillThroughType":0,"DrillThroughValue":"labelEx2 value","Name":"General Ledger by Account ID Detail"},{"id":"Reports.model.DrillThrough-27","Control":"labelEx3","DrillThroughType":0,"DrillThroughValue":"labelEx3 value","Name":"General Ledger by Account ID Detail"}]' 
DECLARE @GLReportDataSource NVARCHAR(MAX) = 
'WITH Units
AS
(
	SELECT	A.[dblLbsPerUnit], B.[intAccountId], A.[strUOMCode]
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
)
--*SC*--
select top 100 percent
 temp.*
 ,Cast(Cast(tblGLDetail.dtmDate as Date) as DateTime) as dtmDate
,tblGLDetail.strTransactionId
,tblGLDetail.strCode
,tblGLDetail.strDescription as strGLDescription
,tblGLAccount.strAccountType
,tblGLAccount.strAccountGroup
,tblGLAccount.intParentGroupId as intAccountGroupSort
,tblGLAccount.strDescription as strAccountDescription
, dblSubTotal=case when tblGLAccount.strAccountType = ''Asset'' then isnull(dblDebit,0) - isnull(dblCredit,0)
	when tblGLAccount.strAccountType = ''Liability'' then isnull(dblCredit,0) - isnull(dblDebit,0)
	when tblGLAccount.strAccountType = ''Equity'' then isnull(dblCredit,0) - isnull(dblDebit,0)
	when tblGLAccount.strAccountType = ''Revenue'' then isnull(dblCredit,0) - isnull(dblDebit,0)
	when tblGLAccount.strAccountType = ''Sales'' then isnull(dblCredit,0) - isnull(dblDebit,0)
	when tblGLAccount.strAccountType = ''Expense'' then isnull(dblDebit,0) - isnull(dblCredit,0)
	when tblGLAccount.strAccountType = ''Cost of Goods Sold'' then isnull(dblDebit,0) - isnull(dblCredit,0)
	else 0 end
,dblSubTotalUnit = CASE WHEN (ISNULL(case when tblGLAccount.strAccountType = ''Asset'' then isnull(dblDebitUnit,0) - isnull(dblCreditUnit,0)
					when tblGLAccount.strAccountType = ''Liability'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Equity'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Revenue'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Sales'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Expense'' then isnull(dblDebitUnit,0) - isnull(dblCreditUnit,0)
					when tblGLAccount.strAccountType = ''Cost of Goods Sold'' then isnull(dblDebitUnit,0) - isnull(dblCreditUnit,0)
					end, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = tblGLDetail.[intAccountId]), 0) = 0) THEN 0
				ELSE CAST(ISNULL(ISNULL(case when tblGLAccount.strAccountType = ''Asset'' then isnull(dblDebitUnit,0) - isnull(dblCreditUnit,0)
					when tblGLAccount.strAccountType = ''Liability'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Equity'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Revenue'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Sales'' then isnull(dblCreditUnit,0) - isnull(dblDebitUnit,0)
					when tblGLAccount.strAccountType = ''Expense'' then isnull(dblDebitUnit,0) - isnull(dblCreditUnit,0)
					when tblGLAccount.strAccountType = ''Cost of Goods Sold'' then isnull(dblDebitUnit,0) - isnull(dblCreditUnit,0)
					end, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = tblGLDetail.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
, intSort=case when tblGLAccount.strAccountType = ''Sales'' then 1
	when tblGLAccount.strAccountType = ''Cost of Goods Sold'' then 2
	when tblGLAccount.strAccountType = ''Revenue'' then 3
	when tblGLAccount.strAccountType = ''Expense'' then 4
	else 100 end
, tblGLDetail.strReference
,intAccountUnitId
,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = tblGLDetail.[intAccountId]) as strUOMCode
from  tblGLDetail
	left join (select
				 A.intAccountId
				,A.strDescription
				,A.intAccountUnitId
				,B.strAccountType
				,B.strAccountGroup
				,B.intParentGroupId
				,dblOpeningBalance
				from tblGLAccount A
					left join tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId )as tblGLAccount
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
where tblGLDetail.ysnIsUnposted = 0 and tblGLAccount.strAccountType in (''Revenue'', ''Expense'', ''Cost of Goods Sold'',''Sales'') and tblGLDetail.strCode != ''AA''
  --*SCSTART*--
--Special Case--
order by intSort'
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
PRINT 'Finish updating Income Statement Standard'
END
GO