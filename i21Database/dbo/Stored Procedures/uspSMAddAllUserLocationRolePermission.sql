CREATE PROCEDURE [dbo].[uspSMAddAllUserLocationRolePermission]
AS
BEGIN
	
	UPDATE tblSMUserSecurity SET intCompanyLocationId = (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation)
	WHERE intCompanyLocationId IS NULL

	INSERT INTO tblSMUserSecurityCompanyLocationRolePermission (intEntityUserSecurityId,intEntityId,intUserRoleId,intCompanyLocationId)
	SELECT b.intEntityId, b.intEntityId, b.intUserRoleID, a.intCompanyLocationId
	FROM tblSMCompanyLocation a
	CROSS JOIN tblSMUserSecurity b
	LEFT JOIN tblSMUserSecurityCompanyLocationRolePermission c 
		ON c.intCompanyLocationId = a.intCompanyLocationId AND c.intEntityId = b.intEntityId AND c.intUserRoleId = b.intUserRoleID
	WHERE c.intUserSecurityCompanyLocationRolePermissionId IS NULL AND b.intUserRoleID IS NOT NULL

END
