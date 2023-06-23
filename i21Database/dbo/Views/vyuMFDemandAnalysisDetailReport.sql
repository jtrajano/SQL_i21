CREATE VIEW [dbo].[vyuMFDemandAnalysisDetailReport]
AS 
/****************************************************************
 Title: Demand Analysis Detail View Report
 Description: Demand Analysis Detail View Report intended for Strauss 
 JIRA: MFG-4596 
 HD: HDTN-275494  
 Created By: Jonathan Valenzuela
 Date: 06/22/2023
 ***************************************************************/
SELECT strAttributeName			AS [Plan Detail]
	 , strItemNo				AS [Item No]
	 , CASE WHEN intReportAttributeID = 1 THEN PivotData.OpeningInv
		    ELSE ''
	   END						AS [On-Hand Inventory]
	 , CASE WHEN intReportAttributeID = 4 OR intReportAttributeID = 14 OR intReportAttributeID = 13 THEN PivotData.PastDue
			ELSE ''
	   END						AS [Past Due]
	 , PivotData.strMonth1
	 , PivotData.strMonth2
	 , PivotData.strMonth3
	 , PivotData.strMonth4
	 , PivotData.strMonth5
	 , PivotData.strMonth6
	 , PivotData.strMonth7
	 , PivotData.strMonth8
	 , PivotData.strMonth9
	 , PivotData.strMonth10
	 , PivotData.strMonth11
	 , PivotData.strMonth12
FROM 
(
	SELECT CASE WHEN DemandAttribute.intReportAttributeID = 1	THEN 'Months & Item'
				WHEN DemandAttribute.intReportAttributeID = 4	THEN 'Existing Purchases'
				WHEN DemandAttribute.intReportAttributeID = 13	THEN 'Open Purchases'
				WHEN DemandAttribute.intReportAttributeID = 14	THEN 'In-transit Purchases'
				ELSE DemandAttribute.strAttributeName
			END												AS strAttributeName
		 , CASE WHEN DemandAttribute.intReportAttributeID = 1 THEN Item.strItemNo + ' - ' + Item.strDescription 
				ELSE '' 
		   END												AS strItemNo
		 , CompanyLocation.strLocationName	
		 , ISNULL(NULLIF(DemandAnalysis.strValue, ''), 0)	AS strValue
		 , DemandAnalysis.strFieldName
		 , DemandAnalysis.intInvPlngReportMasterID
		 , DemandAttribute.intDisplayOrder
		 , DemandAnalysis.intItemId
		 , DemandAttribute.intReportAttributeID
	FROM tblCTInvPlngReportAttributeValue AS DemandAnalysis
	JOIN tblICItem AS Item ON DemandAnalysis.intItemId = Item.intItemId
	JOIN tblCTReportAttribute AS DemandAttribute ON DemandAnalysis.intReportAttributeID = DemandAttribute.intReportAttributeID
	OUTER APPLY (SELECT TOP 1 strLocationName
				 FROM tblSMCompanyLocation AS SMCompanyLocation
				 WHERE SMCompanyLocation.intCompanyLocationId = DemandAnalysis.intLocationId) AS CompanyLocation
) AS SourceData
PIVOT
(
	MAX(SourceData.strValue) FOR SourceData.strFieldName IN
	(
		OpeningInv
	, PastDue  
	, strMonth1
	, strMonth2
	, strMonth3
	, strMonth4
	, strMonth5
	, strMonth6
	, strMonth7
	, strMonth8
	, strMonth9
	, strMonth10
	, strMonth11
	, strMonth12
	)
) AS PivotData
ORDER BY intInvPlngReportMasterID ASC
		, intItemId ASC
		, intDisplayOrder ASC 
OFFSET 0 ROWS
