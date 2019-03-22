CREATE VIEW [dbo].[vyuSMEntityRole]
AS
SELECT CAST (ROW_NUMBER() OVER (ORDER BY intEntityId DESC) AS INT) AS intEntityRoleId, intEntityId, strEntityNo, strEntityName, strName, intUserRoleId FROM 
(
	SELECT DISTINCT intEntityId, strEntityNo, strEntityName, strName, intUserRoleId FROM 
	(

		SELECT Entity.intEntityId AS intEntityId, Entity.strEntityNo, Entity.strName AS strEntityName, Entity.strName AS strName, UserRole.intUserRoleID AS intUserRoleId 
		FROM vyuSMUserLocationSubRolePermission UserSecurityCompanyLocationRolePermission
		INNER JOIN tblEMEntity Entity ON UserSecurityCompanyLocationRolePermission.intEntityUserSecurityId = Entity.intEntityId
		INNER JOIN tblSMUserRole UserRole ON UserSecurityCompanyLocationRolePermission.intUserRoleId = UserRole.intUserRoleID
		UNION ALL
		SELECT Entity.intEntityId AS intEntityId, Entity.strEntityNo, Entity.strName AS strEntityName, Entity.strName AS strName, UserRole.intUserRoleID AS intUserRoleId 
		FROM tblSMUserSecurity UserSecurity
		INNER JOIN tblEMEntity Entity ON UserSecurity.intEntityId = Entity.intEntityId
		INNER JOIN tblSMUserRole UserRole ON UserSecurity.intUserRoleID = UserRole.intUserRoleID
		UNION ALL
		SELECT Entity.intEntityId AS intEntityId, Entity.strEntityNo, Entity.strName AS strEntityName, Entity.strName AS strName, SubRole.intSubRoleId AS intUserRoleId 
		FROM tblSMUserRoleSubRole SubRole
		INNER JOIN tblSMUserSecurity UserSecurity ON SubRole.intUserRoleId = UserSecurity.intUserRoleID
		INNER JOIN tblSMUserRole UserRole ON SubRole.intSubRoleId = UserRole.intUserRoleID
		INNER JOIN tblEMEntity Entity ON Entity.intEntityId = UserSecurity.intEntityId
		UNION ALL
		SELECT Entity.intEntityId AS intEntityId, Company.strEntityNo, Company.strName AS strEntityName, Entity.strName AS strName, EntityToContact.intEntityRoleId AS intUserRoleId
		FROM tblEMEntityToContact EntityToContact
		INNER JOIN tblSMUserRole UserRole ON EntityToContact.intEntityRoleId = UserRole.intUserRoleID
		INNER JOIN tblEMEntity Entity ON Entity.intEntityId = EntityToContact.intEntityContactId
		INNER JOIN tblEMEntity Company ON Company.intEntityId = EntityToContact.intEntityId
	) EntityRoleSub
) EntityRoleMain
GO