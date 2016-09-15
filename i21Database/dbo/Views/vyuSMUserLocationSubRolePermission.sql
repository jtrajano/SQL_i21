CREATE VIEW [dbo].[vyuSMUserLocationSubRolePermission]
AS 
SELECT Permission.intUserSecurityCompanyLocationRolePermissionId, 
Permission.intEntityUserSecurityId, 
Permission.intEntityId, 
ISNULL(SubRole.intSubRoleId, Permission.intUserRoleId) as intUserRoleId,
Permission.intCompanyLocationId, 
Permission.intConcurrencyId
FROM tblSMUserSecurityCompanyLocationRolePermission Permission
LEFT JOIN vyuSMUserRoleSubRole SubRole ON Permission.intUserRoleId = SubRole.intUserRoleID

