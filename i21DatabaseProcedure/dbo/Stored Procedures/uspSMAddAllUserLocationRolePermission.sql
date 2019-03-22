CREATE PROCEDURE [dbo].[uspSMAddAllUserLocationRolePermission]
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT,	
	@OutputMessage NVARCHAR(4000) = '' OUTPUT
AS
BEGIN
	set @OutputMessage = ''
	IF @Checking = 1
	BEGIN
		--For Now just use the same query as below
		SELECT @Total = count(b.intEntityId)
		FROM tblSMCompanyLocation a
		CROSS JOIN tblSMUserSecurity b
		LEFT JOIN tblSMUserSecurityCompanyLocationRolePermission c 
			ON c.intCompanyLocationId = a.intCompanyLocationId AND c.intEntityId = b.intEntityId AND c.intUserRoleId = b.intUserRoleID
		WHERE c.intUserSecurityCompanyLocationRolePermissionId IS NULL AND b.intUserRoleID IS NOT NULL
	END	
	ELSE 
	BEGIN
		UPDATE tblSMUserSecurity SET intCompanyLocationId = (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation)
		WHERE intCompanyLocationId IS NULL

		--any modification from this select query. please modify the above as well.
		--if the query will be a lot of joining, may be assigning this to a temp table then get the count will be faster
		INSERT INTO tblSMUserSecurityCompanyLocationRolePermission (intEntityUserSecurityId,intEntityId,intUserRoleId,intCompanyLocationId)
		SELECT b.intEntityId, b.intEntityId, b.intUserRoleID, a.intCompanyLocationId
		FROM tblSMCompanyLocation a
		CROSS JOIN tblSMUserSecurity b
		LEFT JOIN tblSMUserSecurityCompanyLocationRolePermission c 
			ON c.intCompanyLocationId = a.intCompanyLocationId AND c.intEntityId = b.intEntityId AND c.intUserRoleId = b.intUserRoleID
		WHERE c.intUserSecurityCompanyLocationRolePermissionId IS NULL AND b.intUserRoleID IS NOT NULL

		set @Total = @@ROWCOUNT
	END
	
END