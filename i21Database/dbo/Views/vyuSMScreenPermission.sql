CREATE VIEW [dbo].[vyuSMScreenPermission]
AS 
	SELECT 
		A.intUserRoleScreenPermissionId AS intScreenPermissionId,
		A.strPermission, 
		--A.intUserRoleId, 
		C.strNamespace,
		P.intCompanyLocationId,
		P.intEntityId
	FROM tblSMUserRoleScreenPermission A 
		INNER JOIN tblSMScreen C ON A.intScreenId = C.intScreenId
		INNER JOIN tblSMUserSecurityCompanyLocationRolePermission P ON A.intUserRoleId = P.intUserRoleId