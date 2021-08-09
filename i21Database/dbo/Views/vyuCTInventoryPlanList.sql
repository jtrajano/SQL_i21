﻿CREATE VIEW vyuCTInventoryPlanList
AS
SELECT RM.intInvPlngReportMasterID
	,RM.strInvPlngReportName
	,RM.intCategoryId
	,C.strCategoryCode
	,RM.intDemandHeaderId
	,DH.strDemandName
	,CASE 
		WHEN ISNULL(RM.ysnAllItem, 0) = 0
			THEN dbo.fnCTGetItemNames(RM.intInvPlngReportMasterID) COLLATE Latin1_General_CI_AS
		ELSE ''
		END AS strItemNames
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
	,RM.ysnPost
	,RM.strExternalGroup
	,RM.intDayLeftInMonth
FROM tblCTInvPlngReportMaster AS RM
LEFT JOIN tblICCategory AS C ON C.intCategoryId = RM.intCategoryId
LEFT JOIN tblMFDemandHeader DH ON DH.intDemandHeaderId = RM.intDemandHeaderId
LEFT JOIN tblICUnitMeasure AS UOM ON UOM.intUnitMeasureId = RM.intUnitMeasureId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = RM.intCompanyLocationId
LEFT JOIN tblCTBook B ON B.intBookId = RM.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = RM.intSubBookId
