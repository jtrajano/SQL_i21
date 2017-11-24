CREATE VIEW vyuCTInventoryPlanList
AS
SELECT RM.intInvPlngReportMasterID
	,RM.strInvPlngReportName
	,RM.intCategoryId
	,C.strCategoryCode
	,dbo.fnCTGetItemNames(RM.intInvPlngReportMasterID) AS strItemNames
	,RM.intNoOfMonths
	,RM.ysnIncludeInventory
	,RM.intCompanyLocationId
	,CL.strLocationName
FROM tblCTInvPlngReportMaster AS RM
JOIN tblICCategory AS C ON C.intCategoryId = RM.intCategoryId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = RM.intCompanyLocationId
