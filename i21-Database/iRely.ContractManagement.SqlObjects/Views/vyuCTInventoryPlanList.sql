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
	,RM.intUnitMeasureId
	,UOM.strUnitMeasure
FROM tblCTInvPlngReportMaster AS RM
JOIN tblICCategory AS C ON C.intCategoryId = RM.intCategoryId
LEFT JOIN tblICUnitMeasure AS UOM ON UOM.intUnitMeasureId = RM.intUnitMeasureId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = RM.intCompanyLocationId
