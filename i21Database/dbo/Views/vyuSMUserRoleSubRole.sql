CREATE VIEW [dbo].[vyuSMUserRoleSubRole]
AS
SELECT DISTINCT intUserRoleID, intSubRoleId, strName, strDescription, strMenu, strMenuPermission, strForm, strRoleType, ysnAdmin
FROM
(
	SELECT intUserRoleID,
	SubRole.intUserRoleId as intSubRoleId,
	strName,
	strDescription,
	strMenu,
	strMenuPermission,
	strForm,
	strRoleType,
	ysnAdmin FROM tblSMUserRole UserRole
	INNER JOIN tblSMUserRoleSubRole SubRole ON UserRole.intUserRoleID = SubRole.intUserRoleId
	UNION ALL
	SELECT SubRole.intUserRoleId,
	intUserRoleID as intSubRoleId,
	strName,
	strDescription,
	strMenu,
	strMenuPermission,
	strForm,
	strRoleType,
	ysnAdmin FROM tblSMUserRole UserRole
	INNER JOIN tblSMUserRoleSubRole SubRole ON UserRole.intUserRoleID = SubRole.intSubRoleId
	UNION ALL
	SELECT 
	intUserRoleID as intSubRoleId,
	SubRole.intSubRoleId,
	strName,
	strDescription,
	strMenu,
	strMenuPermission,
	strForm,
	strRoleType,
	ysnAdmin FROM tblSMUserRole UserRole
	INNER JOIN tblSMUserRoleSubRole SubRole ON UserRole.intUserRoleID = SubRole.intSubRoleId
) t