CREATE VIEW vyuMFInvPlngReportAttributeValue
AS
SELECT AV.intInvPlngReportMasterID
	,AV.intReportAttributeID
	,I.strItemNo
	,AV.strFieldName
	,AV.strValue
	,MI.strItemNo AS strMainItemNo
	,AV.dtmCreated
	,AV.dtmLastModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblCTInvPlngReportAttributeValue AV
JOIN tblICItem I ON I.intItemId = AV.intItemId
LEFT JOIN tblICItem MI ON MI.intItemId = AV.intMainItemId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = AV.intCreatedUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = AV.intLastModifiedUserId
