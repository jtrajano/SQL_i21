CREATE VIEW [dbo].[vyuSMUserLocationSubRolePermission]
AS 
SELECT Permission.intUserSecurityCompanyLocationRolePermissionId, 
Permission.intEntityUserSecurityId, 
Permission.intEntityId, 
ISNULL(SubRole.intSubRoleId, Permission.intUserRoleId) AS intUserRoleId,
ISNULL(MultiCompany.strCompanyCode, '') AS strCompanyCode,
Permission.intCompanyLocationId, 
Permission.intConcurrencyId
FROM tblSMUserSecurityCompanyLocationRolePermission Permission
LEFT JOIN vyuSMUserRoleSubRole SubRole ON Permission.intUserRoleId = SubRole.intUserRoleID
LEFT JOIN tblSMMultiCompany MultiCompany ON MultiCompany.intMultiCompanyId = Permission.intMultiCompanyId

