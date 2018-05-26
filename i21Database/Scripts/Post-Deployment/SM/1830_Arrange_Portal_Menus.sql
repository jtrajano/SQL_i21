GO

UPDATE tblSMUserRole SET strName = 'Portal Admin', strDescription = 'Portal Admin', strRoleType = 'Portal Admin' WHERE intUserRoleID = 999
DELETE FROM tblEMEntityToRole WHERE intEntityRoleId NOT IN (SELECT intEntityRoleId FROM tblEMEntityToContact WHERE intEntityRoleId IS NOT NULL)

UPDATE a SET a.ysnPortalAdmin = b.ysnAdmin
FROM [tblEMEntityToContact] a
	JOIN tblSMUserRole b
		ON a.intEntityRoleId = b.intUserRoleID
	JOIN tblEMEntity c
		ON a.intEntityId = c.intEntityId
	JOIN tblEMEntity d
		ON a.intEntityContactId = d.intEntityId
	LEFT JOIN [tblEMEntityCredential] e
		ON a.intEntityContactId = e.intEntityId

UPDATE tblEMEntityToContact SET intEntityRoleId = 999 WHERE intEntityRoleId IS NOT NULL
UPDATE tblEMEntityToRole SET intEntityRoleId = 999
UPDATE tblSMUserRoleMenu SET ysnVisible = 1 WHERE intUserRoleId = 999
DELETE FROM tblSMUserRole WHERE strRoleType IN ('Contact Admin', 'Contact')

GO