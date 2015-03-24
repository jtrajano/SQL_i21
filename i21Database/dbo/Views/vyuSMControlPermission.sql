CREATE VIEW [dbo].[vyuSMControlPermission]
AS 
	SELECT 
		A.intUserRoleControlPermissionId AS intControlPermissionId,
		B.strControlId, 
		B.strControlType,
		A.strPermission, 
		A.strLabel,
		A.strDefaultValue,
		A.ysnRequired,
		A.intUserRoleId, 
		C.strNamespace
	FROM tblSMUserRoleControlPermission A 
		INNER JOIN tblSMControl B ON A.intControlId = B.intControlId
		INNER JOIN tblSMScreen C ON B.intScreenId = C.intScreenId 