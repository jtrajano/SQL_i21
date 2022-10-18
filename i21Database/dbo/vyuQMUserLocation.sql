CREATE VIEW [dbo].[vyuQMUserLocation]
AS

SELECT strLocationName
	 , intEntityUserSecurityId
	 , intEntityId
	 , intUserRoleId
	 , CompanyLocation.intCompanyLocationId
FROM tblSMUserSecurityCompanyLocationRolePermission AS UserLocationRole
JOIN tblSMCompanyLocation AS CompanyLocation ON UserLocationRole.intCompanyLocationId = CompanyLocation.intCompanyLocationId