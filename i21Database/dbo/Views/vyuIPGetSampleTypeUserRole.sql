﻿CREATE VIEW vyuIPGetSampleTypeUserRole
AS
SELECT STU.intSampleTypeUserRoleId
	,STU.intSampleTypeId
	,STU.intUserRoleID
	,STU.intConcurrencyId
	,STU.intCreatedUserId
	,STU.dtmCreated
	,STU.intLastModifiedUserId
	,STU.dtmLastModified
	,STU.intSampleTypeUserRoleRefId
	,UR.strName
FROM tblQMSampleTypeUserRole STU WITH (NOLOCK)
LEFT JOIN tblSMUserRole UR WITH (NOLOCK) ON UR.intUserRoleID = STU.intUserRoleID
