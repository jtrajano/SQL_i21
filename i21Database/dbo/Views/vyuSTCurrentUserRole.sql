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
FROM tblSMUserSecurityCompanyLocationRolePermission CLRP
INNER JOIN tblSMUserSecurity US
	ON CLRP.intEntityId = US.intEntityId
INNER JOIN tblSMUserRole UR
	ON CLRP.intUserRoleId = UR.intUserRoleID
INNER JOIN tblSMCompanyLocation CL
	ON CLRP.intCompanyLocationId = CL.intCompanyLocationId
	AND US.intCompanyLocationId = CL.intCompanyLocationId