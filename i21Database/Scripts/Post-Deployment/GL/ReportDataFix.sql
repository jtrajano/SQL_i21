﻿/*
--------------------------------------------------------------------------------------
Author				: Trajano, Jeffrey
Date Last Modified	: 6/22/2015
Description			: Updates Report Options/Datasource/Drilldowns from GL Reports
--------------------------------------------------------------------------------------
*/
BEGIN -- General Ledger By Account Detail Report
PRINT 'Begin updating General Ledger Report'
--UPDATE THE OPTIONS
UPDATE o SET o.strSettings =
'WITH Units 
AS 
(
	SELECT	A.[dblLbsPerUnit], B.[intAccountId], A.[strUOMCode] 
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
),	
GLAccountDetails
AS
(

--*SC*--
select 
		 
		B.strDescription  as strAccountDescription-- account description
		,C.strAccountType
		,C.strAccountGroup
		,Cast(Cast(A.dtmDate as Date)as DateTime )as dtmDate
		,A.strBatchId
		,ISNULL(A.dblDebit,0) as dblDebit
		,ISNULL(A.dblCredit,0) as dblCredit
		,[dblDebitUnit]	= CASE WHEN (ISNULL(dblDebitUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0 
					ELSE CAST(ISNULL(ISNULL(dblDebitUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END
		,[dblCreditUnit] = CASE WHEN (ISNULL(dblCreditUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0 
					ELSE CAST(ISNULL(ISNULL(dblCreditUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END			
		,A.strDescription as strDetailDescription-- detail description
		,A.strTransactionId
		,A.intTransactionId
		,A.strTransactionType
		,A.strTransactionForm
		,A.strModuleName
		,A.strReference
		, strReferenceDetail = (select top 1
								y.strReference
								from tblGLJournal x 
								inner join tblGLJournalDetail y on x.intJournalId = y.intJournalId
								where x.strJournalId = A.strTransactionId)
,strDocument = (select			strDocument 
								from tblGLJournalDetail B 
								where B.intJournalId =
								(select intJournalId from tblGLJournal C where C.strJournalId = A.strTransactionId) 
								and B.intJournalDetailId = A.intJournalLineNo and B.intAccountId =  A.intAccountId)	
		,dblTotal = ( 
				CASE	WHEN C.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN isnull(dblDebit, 0 ) - isnull(dblCredit,0) 
						ELSE isnull(dblCredit, 0 ) - isnull(dblDebit,0) 
				END
				)  
		,B.intAccountUnitId 
		,A.strCode
		,A.intGLDetailId
		,A.ysnIsUnposted
		,D.*
		,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = A.[intAccountId]) as strUOMCode
from tblGLDetail A 
inner join tblGLAccount B on A.intAccountId = B.intAccountId
inner join tblGLAccountGroup C on B.intAccountGroupId = C.intAccountGroupId
INNER JOIN tblGLTempCOASegment D ON A.intAccountId = D.intAccountId
Where ysnIsUnposted = 0

--*SCSTART*--
--Special Case--

),

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
)
AS
(

	SELECT 
		A.intAccountId
		,A.strAccountId
		,A.strDescription as strAccountDescription
		,(select strAccountType from tblGLAccountGroup where intAccountGroupId = A.intAccountGroupId) as strAccountType
		,(select strAccountGroup from tblGLAccountGroup where intAccountGroupId = A.intAccountGroupId) as strAccountGroup

		,dblBeginBalance = dbo.fnGetBeginBalance(A.strAccountId,(SELECT MIN(dtmDate) FROM GLAccountDetails),'''')
		,dblBeginBalanceUnit =  dbo.fnGetBeginBalanceUnit(A.strAccountId,(SELECT MIN(dtmDate) FROM GLAccountDetails),'''')
		,B.[Primary Account]
		,B.[Location] 
		
		FROM tblGLAccount A
		INNER JOIN tblGLTempCOASegment B ON B.intAccountId = A.intAccountId
	    INNER JOIN GLAccountDetails  C
        ON A.strAccountId = C.strAccountId
	
		
)
--*CountStart*--
SELECT 
(CASE WHEN A.strAccountDescription  is  NULL  then B.strAccountDescription else A.strAccountDescription END) as strAccountDescripion
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
,(CASE WHEN A.ysnIsUnposted  is  NULL  then '''' else A.ysnIsUnposted END) as ysnIsUnposted
,(CASE WHEN A.strAccountId  is  NULL  then B.strAccountId else A.strAccountId END) as strAccountId
,B.[Primary Account]
,B.Location
,(CASE WHEN A.strUOMCode is  NULL  then '''' else A.strUOMCode END) as strUOMCode
,ISNULL(B.dblBeginBalance,0) AS dblBeginBalance
,[dblBeginBalanceUnit] = CASE WHEN (ISNULL(B.dblBeginBalanceUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0 
					ELSE CAST(ISNULL(ISNULL(B.dblBeginBalanceUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END	
	
	FROM GLAccountBalance B
	LEFT JOIN GLAccountDetails A ON B.intAccountId = A.intAccountId 
	

--*CountEnd*--' from tblRMOption o join tblRMReport r on o.intReportId = r.intReportId
where r.strName = 'General Ledger by Account ID Detail' and strGroup = 'General Ledger' and o.strName ='Include Audit Adjustment'
--UPDATE THE DRILL DOWN
UPDATE o SET strSettings = '[{"Control":"labelEx1","DrillThroughType":1,"Name":"GeneralLedger.Global.GLGlobalDrillDown","DrillThroughFilterType":0,"Filters":null,"id":"Reports.model.DrillThrough-1","DrillThroughValue":"strTransactionId,intTransactionId,strModuleName,strTransactionForm,strTransactionType"}]' 
from tblRMOption o join tblRMReport r on o.intReportId = r.intReportId
where r.strName = 'General Ledger by Account ID Detail' and strGroup = 'General Ledger' and o.strName ='Drill Down'
--UPDATE THE DATASOURCE
UPDATE d SET strQuery = 
'WITH Units   AS   (   SELECT A.[dblLbsPerUnit], B.[intAccountId], A.[strUOMCode]    
FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]  ),   
GLAccountDetails  AS  (    
--*SC*--  
select         
B.strDescription  as strAccountDescription-- account description    
,C.strAccountType    
,C.strAccountGroup    
,Cast(Cast(A.dtmDate as Date)as DateTime )as dtmDate    
,A.strBatchId    
,ISNULL(A.dblDebit,0) as dblDebit    
,ISNULL(A.dblCredit,0) as dblCredit    
,[dblDebitUnit] = CASE WHEN (ISNULL(dblDebitUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units 
WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0        
ELSE CAST(ISNULL(ISNULL(dblDebitUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units 
WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END    
,[dblCreditUnit] = CASE WHEN (ISNULL(dblCreditUnit, 0) = 0) OR (ISNULL((SELECT [dblLbsPerUnit] FROM Units 
WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0        
ELSE CAST(ISNULL(ISNULL(dblCreditUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units 
WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) END       
,A.strDescription as strDetailDescription-- detail description    
,A.strTransactionId    
,A.intTransactionId    
,A.strTransactionType    
,A.strTransactionForm    
,A.strModuleName    
,A.strReference    
, strReferenceDetail = (select top 1          
y.strReference          
from tblGLJournal x           
inner join tblGLJournalDetail y on x.intJournalId = y.intJournalId          
where x.strJournalId = A.strTransactionId)  ,strDocument = (select   strDocument           
from tblGLJournalDetail B           
where B.intJournalId =          
(select intJournalId from tblGLJournal C where C.strJournalId = A.strTransactionId)           
and B.intJournalDetailId = A.intJournalLineNo and B.intAccountId =  A.intAccountId)     
,dblTotal = (       
CASE WHEN C.strAccountType in (''Asset'', ''Expense'',''Cost of Goods Sold'') THEN isnull(dblDebit, 0 ) - isnull(dblCredit,0)         
ELSE isnull(dblCredit, 0 ) - isnull(dblDebit,0)       END      )      
,B.intAccountUnitId     
,A.strCode    
,A.intGLDetailId    
,A.ysnIsUnposted    
,D.*    
,(SELECT [strUOMCode] FROM Units WHERE [intAccountId] = A.[intAccountId]) as strUOMCode  from tblGLDetail A   
inner join tblGLAccount B on A.intAccountId = B.intAccountId  inner join tblGLAccountGroup C on B.intAccountGroupId = C.intAccountGroupId  
INNER JOIN tblGLTempCOASegment D ON A.intAccountId = D.intAccountId  Where ysnIsUnposted = 0 and strCode != ''AA''      
--*SCSTART*--  --Special Case--    
),    
GLAccountBalance  (  intAccountId  ,strAccountId  ,strAccountDescription  ,strAccountType  ,strAccountGroup  ,dblBeginBalance  ,dblBeginBalanceUnit  
,[Primary Account]  ,[Location]   )  
AS  (    
 SELECT    
  A.intAccountId    
  ,A.strAccountId    
  ,A.strDescription as strAccountDescription    
  ,(select strAccountType from tblGLAccountGroup where intAccountGroupId = A.intAccountGroupId) as strAccountType    
  ,(select strAccountGroup from tblGLAccountGroup where intAccountGroupId = A.intAccountGroupId) as strAccountGroup      
  ,dblBeginBalance = dbo.fnGetBeginBalance(A.strAccountId,(SELECT MIN(dtmDate) FROM GLAccountDetails),'''')    
  ,dblBeginBalanceUnit =  dbo.fnGetBeginBalanceUnit(A.strAccountId,(SELECT MIN(dtmDate) FROM GLAccountDetails),'''')    
  ,B.[Primary Account]    
  ,B.[Location]         
  FROM tblGLAccount A    INNER JOIN tblGLTempCOASegment B ON B.intAccountId = A.intAccountId         
  INNER JOIN GLAccountDetails  C          
  ON A.strAccountId = C.strAccountId)  
  --*CountStart*--  
  SELECT   
  (CASE WHEN A.strAccountDescription  is  NULL  THEN B.strAccountDescription ELSE A.strAccountDescription END) as strAccountDescripion  
  ,(CASE WHEN A.strAccountType  is  NULL  THEN B.strAccountType ELSE A.strAccountType END) as strAccountType  
  ,(CASE WHEN A.strAccountGroup  is  NULL  THEN B.strAccountGroup ELSE A.strAccountGroup END) as strAccountGroup  ,A.dtmDate  
  ,(CASE WHEN A.strBatchId  is  NULL  THEN '''' ELSE A.strBatchId END) as strBatchId  
  ,(CASE WHEN A.dblDebit  is  NULL  THEN 0.00 ELSE A.dblDebit END) as dblDebit  
  ,(CASE WHEN A.dblCredit  is  NULL  THEN 0.00 ELSE A.dblCredit END) as dblCredit  
  ,(CASE WHEN A.dblDebitUnit  is  NULL  THEN 0.00 ELSE A.dblDebitUnit END) as dblDebitUnit  
  ,(CASE WHEN A.dblCreditUnit  is  NULL  THEN 0.00 ELSE A.dblCreditUnit END) as dblCreditUnit  
  ,(CASE WHEN A.strDetailDescription  is  NULL  THEN '''' ELSE A.strDetailDescription END) as strDetailDescription  
  ,(CASE WHEN A.strTransactionId  is  NULL  THEN '''' ELSE A.strTransactionId END) as strTransactionId  
  ,(CASE WHEN A.intTransactionId  is  NULL  THEN '''' ELSE A.intTransactionId END) as intTransactionId  
  ,(CASE WHEN A.strTransactionType  is  NULL  THEN '''' ELSE A.strTransactionType END) as strTransactionType  
  ,(CASE WHEN A.strTransactionForm  is  NULL  THEN '''' ELSE A.strTransactionForm END) as strTransactionType  
  ,(CASE WHEN A.strModuleName  is  NULL  THEN '''' ELSE A.strModuleName END) as strModuleName  
  ,(CASE WHEN A.strReference  is  NULL  THEN '''' ELSE A.strReference END) as strReference  
  ,(CASE WHEN A.strReferenceDetail  is  NULL  THEN '''' else A.strReferenceDetail END) as strReferenceDetail  
  ,(CASE WHEN A.strDocument  is  NULL  THEN '''' ELSE A.strDocument END) as strDocument  
  ,(CASE WHEN A.dblTotal  is  NULL  THEN 0.00 ELSE A.dblTotal END) as dblTotal  
  ,(CASE WHEN A.intAccountUnitId  is  NULL  THEN '''' ELSE A.intAccountUnitId END) as intAccountUnitId  
  ,(CASE WHEN A.strCode  is  NULL  THEN '''' else A.strCode END) as strCode  
  ,(CASE WHEN A.intGLDetailId  is  NULL  THEN '''' ELSE A.intGLDetailId END) as intGLDetailId  
  ,(CASE WHEN A.ysnIsUnposted  is  NULL  THEN '''' ELSE A.ysnIsUnposted END) as ysnIsUnposted  
  ,(CASE WHEN A.strAccountId  is  NULL  THEN B.strAccountId else A.strAccountId END) as strAccountId  ,B.[Primary Account]  ,B.Location  
  ,(CASE WHEN A.strUOMCode is  NULL  THEN '''' ELSE A.strUOMCode END) as strUOMCode    
  ,ISNULL(B.dblBeginBalance,0) AS dblBeginBalance  
  ,[dblBeginBalanceUnit] = CASE WHEN (ISNULL(B.dblBeginBalanceUnit, 0) = 0) OR 
  (ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) = 0) THEN 0        
  ELSE CAST(ISNULL(ISNULL(B.dblBeginBalanceUnit, 0) / ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),0) AS NUMERIC(18, 6)) 
  END       
  FROM GLAccountBalance B   
  LEFT JOIN GLAccountDetails A ON B.intAccountId = A.intAccountId        
  --*CountEnd*-- ' 
from tblRMDatasource d join tblRMReport r on d.intReportId = r.intReportId
where r.strName = 'General Ledger by Account ID Detail' and strGroup = 'General Ledger' 
PRINT 'Finish updating General Ledger Report'
END
GO