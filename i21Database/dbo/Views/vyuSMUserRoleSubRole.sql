CREATE VIEW [dbo].[vyuSMUserRoleSubRole]
AS
SELECT intUserRoleID,
SubRole.intUserRoleId,
strName,
strDescription,
strMenu,
strMenuPermission,
strForm,
strRoleType,
ysnAdmin FROM tblSMUserRole UserRole
INNER JOIN tblSMUserRoleSubRole SubRole ON UserRole.intUserRoleID = SubRole.intUserRoleId
UNION ALL
SELECT intUserRoleID,
SubRole.intUserRoleId,
strName,
strDescription,
strMenu,
strMenuPermission,
strForm,
strRoleType,
ysnAdmin FROM tblSMUserRole UserRole
INNER JOIN tblSMUserRoleSubRole SubRole ON UserRole.intUserRoleID = SubRole.intSubRoleId