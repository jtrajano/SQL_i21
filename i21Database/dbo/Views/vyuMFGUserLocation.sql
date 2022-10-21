CREATE VIEW [dbo].[vyuMFGUserLocation]
AS 
SELECT intEntityUserSecurityId
	 , intEntityId
	 , intUserRoleId
	 , CompanyLocation.intCompanyLocationId
	 , CompanyLocation.strLocationName AS strCompanyLocationName
FROM tblSMUserSecurityCompanyLocationRolePermission AS UserLocationRole
JOIN tblSMCompanyLocation AS CompanyLocation ON UserLocationRole.intCompanyLocationId = CompanyLocation.intCompanyLocationId