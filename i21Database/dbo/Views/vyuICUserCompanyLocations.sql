CREATE VIEW dbo.vyuICUserCompanyLocations
AS

SELECT CAST(l.strLocationName AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS strLocationName, 
	CAST(su.strUserName AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS strUserName, l.intCompanyLocationId, su.intUserRoleID, su.intEntityId
FROM tblSMUserSecurity su
	INNER JOIN tblSMUserRole r ON r.intUserRoleID = su.intUserRoleID
	INNER JOIN tblSMUserSecurityCompanyLocationRolePermission cr ON cr.intEntityUserSecurityId = su.intEntityId
	INNER JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = cr.intCompanyLocationId