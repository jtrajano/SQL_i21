CREATE VIEW [dbo].[vyuSMControlPermission]
AS 
	SELECT 
		A.intUserSecurityControlPermissionId AS intControlPermissionId,
		B.strControlId, 
		B.strControlType,
		A.strPermission, 
		A.intUserSecurityId, 
		C.strNamespace,
		A.intConcurrencyId
	FROM tblSMUserSecurityControlPermission A 
		INNER JOIN tblSMControl B ON A.intControlId = B.intControlId
		INNER JOIN tblSMScreen C ON B.intScreenId = C.intScreenId 