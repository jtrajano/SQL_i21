CREATE VIEW vyuCTInventoryPlanList
AS
SELECT RM.intInvPlngReportMasterID
	,RM.strInvPlngReportName
	,RM.intCategoryId
	,C.strCategoryCode
	,dbo.fnCTGetItemNames(RM.intInvPlngReportMasterID) COLLATE Latin1_General_CI_AS AS strItemNames
	,RM.intNoOfMonths
	,RM.ysnIncludeInventory
FROM tblCTInvPlngReportMaster AS RM
JOIN tblICCategory AS C ON C.intCategoryId = RM.intCategoryId
