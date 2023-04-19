CREATE VIEW [dbo].[vyuQMUserLocation]
AS
/*
 * Title: User Location
 * Description: Returns list of company location that user have permissions.
 * Created By: Jonathan Valenzuela
 * Created Date: 01/24/2023
 * JIRA: QC-941 
*/
SELECT intEntityUserSecurityId
	 , intEntityId
	 , intUserRoleId
	 , CompanyLocation.intCompanyLocationId
	 , CompanyLocation.strLocationName AS strCompanyLocationName
FROM tblSMUserSecurityCompanyLocationRolePermission AS UserLocationRole
JOIN tblSMCompanyLocation AS CompanyLocation ON UserLocationRole.intCompanyLocationId = CompanyLocation.intCompanyLocationId