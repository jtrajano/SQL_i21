CREATE VIEW [dbo].[vyuSMEntityRole]
AS
SELECT CAST (ROW_NUMBER() OVER (ORDER BY intEntityId DESC) AS INT)	AS	intEntityRoleId, intEntityId, strName, intUserRoleId FROM 
(
	SELECT DISTINCT intEntityId, strName, intUserRoleId FROM 
	(
		SELECT Entity.intEntityId AS intEntityId, Entity.strName AS strName,  UserRole.intUserRoleID AS intUserRoleId FROM vyuSMUserLocationSubRolePermission UserSecurityCompanyLocationRolePermission
		INNER JOIN tblEMEntity Entity ON UserSecurityCompanyLocationRolePermission.intEntityUserSecurityId = Entity.intEntityId
		INNER JOIN tblSMUserRole UserRole ON UserSecurityCompanyLocationRolePermission.intUserRoleId = UserRole.intUserRoleID
		UNION ALL
		SELECT Entity.intEntityId AS intEntityId, Entity.strName AS strName,  UserRole.intUserRoleID AS intUserRoleId FROM tblSMUserSecurity UserSecurity
		INNER JOIN tblEMEntity Entity ON UserSecurity.[intEntityId] = Entity.intEntityId
		INNER JOIN tblSMUserRole UserRole ON UserSecurity.intUserRoleID = UserRole.intUserRoleID
		UNION ALL
		SELECT Entity.intEntityId AS intEntityId, Entity.strName AS strName, SubRole.intSubRoleId AS intUserRoleId FROM tblSMUserRoleSubRole SubRole
		INNER JOIN tblSMUserSecurity UserSecurity ON SubRole.intUserRoleId = UserSecurity.intUserRoleID
		INNER JOIN tblSMUserRole UserRole ON SubRole.intSubRoleId = UserRole.intUserRoleID
		INNER JOIN tblEMEntity Entity ON Entity.intEntityId = UserSecurity.[intEntityId]
	) EntityRoleSub
) EntityRoleMain
GO