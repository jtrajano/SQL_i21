CREATE VIEW dbo.vyuApiUserCompanyLocations
AS
SELECT u.intEntityId, p.intCompanyLocationId, p.intUserSecurityCompanyLocationRolePermissionId
FROM tblSMUserSecurityCompanyLocationRolePermission p
OUTER APPLY (
	SELECT TOP 1 intEntityId
	FROM tblSMUserSecurity
	WHERE intEntityId = p.intEntityUserSecurityId
) u