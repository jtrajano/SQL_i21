﻿CREATE VIEW vyuMFGetSanitizationWorkOrder
AS
SELECT W.intWorkOrderId
	,W.strWorkOrderNo
	,W.dtmOrderDate
	,W.dtmExpectedDate
	,W.intCreatedUserId
	,US.strUserName AS strCreatedUserName
	,W.intExecutionOrder
	,W.strComment
	,WS.intStatusId
	,WS.strName
	,W.dtmStartedDate
	,W.dtmLastModified
	,W.intLastModifiedUserId
	,US1.strUserName AS strLastModifiedUserName
	,W.intOrderHeaderId
	,W.strBOLNo
	,OS.strOrderStatus
	,W.dtmPlannedDate
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderStatus WS ON W.intStatusId = WS.intStatusId
	AND W.intOrderHeaderId IS NOT NULL
JOIN dbo.tblSMUserSecurity US ON US.intEntityUserSecurityId = W.intCreatedUserId
JOIN dbo.tblSMUserSecurity US1 ON US1.intEntityUserSecurityId = W.intLastModifiedUserId
LEFT JOIN dbo.tblWHOrderHeader OH ON OH.intOrderHeaderId = W.intOrderHeaderId
LEFT JOIN dbo.tblWHOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
WHERE W.intStatusId <> 13
