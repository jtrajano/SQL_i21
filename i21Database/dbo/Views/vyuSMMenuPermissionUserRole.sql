﻿CREATE VIEW [dbo].[vyuSMMenuPermissionUserRole]
AS
	SELECT 
		A.intUserRoleMenuId AS intScreenPermissionId,
		B.strCommand AS strNamespace,
		intUserRoleId, 
		'Full Access' COLLATE Latin1_General_CI_AS AS strPermission
	FROM tblSMUserRoleMenu A 
		INNER JOIN tblSMMasterMenu B ON A.intMenuId = B.intMenuID 
	WHERE ISNULL(A.ysnVisible, 0) = 1 AND B.strCommand LIKE '%.view.%'