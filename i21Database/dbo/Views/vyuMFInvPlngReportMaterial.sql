CREATE VIEW vyuMFInvPlngReportMaterial
AS
SELECT IRM.intInvPlngReportMasterID
	,I.strItemNo 
	,IRM.dtmCreated
	,IRM.dtmLastModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblCTInvPlngReportMaterial IRM
JOIN tblICItem I on I.intItemId=IRM.intItemId 
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IRM.intCreatedUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IRM.intLastModifiedUserId