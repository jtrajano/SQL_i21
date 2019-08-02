﻿CREATE VIEW vyuCTInventoryPlanList
AS
SELECT RM.intInvPlngReportMasterID
	,RM.strInvPlngReportName
	,RM.intCategoryId
	,C.strCategoryCode
	,RM.intDemandHeaderId
	,DH.strDemandName
	,dbo.fnCTGetItemNames(RM.intInvPlngReportMasterID) COLLATE Latin1_General_CI_AS AS strItemNames
	,RM.intNoOfMonths
	,RM.ysnIncludeInventory
	,RM.intCompanyLocationId
	,CL.strLocationName
	,RM.intUnitMeasureId
	,UOM.strUnitMeasure
	,RM.dtmDate
	,B.strBook
	,SB.strSubBook
	,RM.ysnTest
	,RM.strPlanNo
	,RM.ysnAllItem
	,RM.strComment
FROM tblCTInvPlngReportMaster AS RM
JOIN tblICCategory AS C ON C.intCategoryId = RM.intCategoryId
LEFT JOIN tblMFDemandHeader DH ON DH.intDemandHeaderId = RM.intDemandHeaderId
LEFT JOIN tblICUnitMeasure AS UOM ON UOM.intUnitMeasureId = RM.intUnitMeasureId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = RM.intCompanyLocationId
LEFT JOIN tblCTBook B ON B.intBookId = DH.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = DH.intSubBookId
