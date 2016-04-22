CREATE VIEW [dbo].[vyuSMEntityRole]
AS
SELECT CAST (ROW_NUMBER() OVER (ORDER BY intEntityId DESC) AS INT)	AS	intEntityRoleId, intEntityId, strName, intUserRoleId FROM 
(
	SELECT DISTINCT intEntityId, strName, intUserRoleId FROM 
	(
		SELECT Entity.intEntityId AS intEntityId, Entity.strName AS strName,  UserRole.intUserRoleID AS intUserRoleId FROM tblSMUserSecurityCompanyLocationRolePermission UserSecurityCompanyLocationRolePermission
		INNER JOIN tblEMEntity Entity ON UserSecurityCompanyLocationRolePermission.intEntityUserSecurityId = Entity.intEntityId
		INNER JOIN tblSMUserRole UserRole ON UserSecurityCompanyLocationRolePermission.intUserRoleId = UserRole.intUserRoleID
		UNION ALL
		SELECT Entity.intEntityId AS intEntityId, Entity.strName AS strName,  UserRole.intUserRoleID AS intUserRoleId FROM tblSMUserSecurity UserSecurity
		INNER JOIN tblEMEntity Entity ON UserSecurity.intEntityUserSecurityId = Entity.intEntityId
		INNER JOIN tblSMUserRole UserRole ON UserSecurity.intUserRoleID = UserRole.intUserRoleID
	) EntityRoleSub
) EntityRoleMain
GO