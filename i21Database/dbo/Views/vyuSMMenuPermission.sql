CREATE VIEW [dbo].[vyuSMMenuPermission]
AS 
	SELECT 
		A.intUserRoleMenuId AS intScreenPermissionId,
		B.strCommand AS strNamespace,
		--intUserRoleId, 
		P.intCompanyLocationId,
		P.intEntityId,
		'Full Access' AS strPermission
	FROM tblSMUserRoleMenu A 
		INNER JOIN tblSMMasterMenu B ON A.intMenuId = B.intMenuID 
		INNER JOIN vyuSMUserLocationSubRolePermission P ON A.intUserRoleId = P.intUserRoleId
	WHERE ISNULL(A.ysnVisible, 0) = 1 AND B.strCommand LIKE '%.view.%'