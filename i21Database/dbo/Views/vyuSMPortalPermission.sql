CREATE VIEW [dbo].[vyuSMPortalPermission]
AS 
	SELECT 
		A.intEntityPortalPermissionId AS intScreenPermissionId,
		B.strCommand AS strNamespace, 
		C.intEntityContactId AS intUserRoleId,
		'Full Access' COLLATE Latin1_General_CI_AS AS strPermission
	FROM [tblEMEntityPortalPermission] A
		INNER JOIN [tblEMEntityPortalMenu] B ON A.intEntityPortalMenuId = B.intPortalParentMenuId
		INNER JOIN [tblEMEntityToContact] C ON A.intEntityToContactId = C.intEntityToContactId