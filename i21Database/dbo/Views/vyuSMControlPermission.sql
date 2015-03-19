CREATE VIEW [dbo].[vyuSMControlPermission]
AS 
	SELECT 
		A.intUserSecurityControlPermissionId AS intControlPermissionId,
		B.strControlId, 
		B.strControlType,
		A.strPermission, 
		A.strLabel,
		A.strDefaultValue,
		A.ysnRequired,
		A.intUserSecurityId, 
		C.strNamespace
	FROM tblSMUserSecurityControlPermission A 
		INNER JOIN tblSMControl B ON A.intControlId = B.intControlId
		INNER JOIN tblSMScreen C ON B.intScreenId = C.intScreenId 