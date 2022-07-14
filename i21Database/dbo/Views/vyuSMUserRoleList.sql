CREATE VIEW [dbo].[vyuSMUserRoleList]
AS

SELECT		a.intEntityId,
			strLocation = (SELECT strLocationName FROM dbo.tblSMCompanyLocation WHERE intCompanyLocationId = c.intCompanyLocationId),
			strRole = (SELECT strName FROM dbo.tblSMUserRole WHERE intUserRoleID = c.intUserRoleId)
FROM		dbo.tblEMEntity AS a
INNER JOIN	dbo.tblEMEntityType AS b
ON			a.intEntityId = b.intEntityId
		AND b.strType = 'User'
INNER JOIN	dbo.tblSMUserSecurityCompanyLocationRolePermission AS c
ON			a.intEntityId = c.intEntityId