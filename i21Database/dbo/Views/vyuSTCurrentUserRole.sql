CREATE VIEW [dbo].[vyuSTCurrentUserRole]
AS
SELECT
	CLRP.intUserSecurityCompanyLocationRolePermissionId
	, CL.strLocationName
	, CL.intCompanyLocationId
	, CLRP.intEntityId
	, UR.strRoleType
	, UR.ysnAdmin
	, US.intCompanyLocationId AS intDefaultCompanyLocationId
FROM tblSMUserSecurity US
LEFT JOIN tblSMUserSecurityCompanyLocationRolePermission CLRP
	ON US.intEntityId = CLRP.intEntityId
INNER JOIN tblSMUserRole UR
	ON US.intUserRoleID = UR.intUserRoleID
INNER JOIN tblSMCompanyLocation CL
	--ON CLRP.intCompanyLocationId = CL.intCompanyLocationId
	ON US.intCompanyLocationId = CL.intCompanyLocationId