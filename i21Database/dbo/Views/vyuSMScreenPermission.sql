CREATE VIEW [dbo].[vyuSMScreenPermission]
AS 
	SELECT 
		A.intUserRoleScreenPermissionId AS intScreenPermissionId,
		A.strPermission, 
		A.intUserRoleId, 
		C.strNamespace
	FROM tblSMUserRoleScreenPermission A 
		INNER JOIN tblSMScreen C ON A.intScreenId = C.intScreenId 