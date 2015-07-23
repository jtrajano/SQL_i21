CREATE VIEW [dbo].[vyuSMPortalPermission]
AS 
	SELECT 
		A.intEntityPortalPermissionId AS intScreenPermissionId,
		B.strCommand AS strNamespace, 
		C.intEntityContactId AS intUserRoleId,
		'Full Access' AS strPermission
	FROM tblEntityPortalPermission A
		INNER JOIN tblEntityPortalMenu B ON A.intEntityPortalMenuId = B.intPortalParentMenuId
		INNER JOIN tblEntityToContact C ON A.intEntityToContactId = C.intEntityToContactId