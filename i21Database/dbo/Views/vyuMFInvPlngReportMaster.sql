CREATE VIEW vyuMFInvPlngReportMaster
AS
SELECT IRM.intInvPlngReportMasterID,IRM.strInvPlngReportName
	,RM.strReportName
	,IRM.intNoOfMonths
	,IRM.ysnIncludeInventory
	,C.strCategoryCode
	,CL.strLocationName
	,UM.strUnitMeasure
	--,DH.strDemandName 
	,'' AS strDemandName
	,IRM.dtmDate
	,B.strBook
	,SB.strSubBook
	,IRM.ysnTest
	,IRM.strPlanNo
	,IRM.ysnAllItem
	,IRM.strComment
	,IRM.ysnPost
	,IRM.dtmCreated
	,IRM.dtmLastModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblCTInvPlngReportMaster IRM
JOIN tblCTReportMaster RM ON RM.intReportMasterID = IRM.intReportMasterID
JOIN tblICCategory C ON C.intCategoryId = IRM.intCategoryId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IRM.intCompanyLocationId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IRM.intUnitMeasureId
--Left JOIN tblMFDemandHeader DH ON DH.intDemandHeaderId = IRM.intDemandHeaderId
LEFT JOIN tblCTBook B ON B.intBookId = IRM.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = IRM.intSubBookId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IRM.intCreatedUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IRM.intLastModifiedUserId