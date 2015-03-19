CREATE VIEW [dbo].[vyuSMScreenPermission]
AS 
	SELECT 
		A.intUserSecurityScreenPermissionId AS intScreenPermissionId,
		A.strPermission, 
		A.intUserSecurityId, 
		C.strNamespace
	FROM tblSMUserSecurityScreenPermission A 
		INNER JOIN tblSMScreen C ON A.intScreenId = C.intScreenId 