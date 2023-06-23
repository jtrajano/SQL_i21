CREATE VIEW [dbo].[vyuMFDemandDetailReport]
AS 
/****************************************************************
	Title: Demand Detail View Report
	Description: Demand Detail View Report intended for Strauss 
	JIRA: MFG-4596 
	HD: HDTN-275494  
	Created By: Jonathan Valenzuela
	Date: 06/22/2023
*****************************************************************/
SELECT strItemNo				AS [Item]
	 , strSubstituteItemNo		AS [Substitute Item]
	 , dtmDemandDate			AS [Demand Date]
	 , dblQuantity				AS [Quantity]
	 , strItemUOM				AS [Item UOM]
	 , strLocationName			AS [Location]
FROM vyuMFGetDemandEntry