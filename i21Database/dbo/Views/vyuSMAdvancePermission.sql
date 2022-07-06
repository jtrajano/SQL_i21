CREATE VIEW [dbo].[vyuSMAdvancePermission]
	AS

SELECT 
A.intUserRoleAdvancePermissionId,
A.intUserRoleId,
B.intAdvancePermissionId,
B.strDescription,
A.strPermission, 
C.strModule,
P.intCompanyLocationId,
P.intEntityId
FROM tblSMUserRoleAdvancePermission A 
INNER JOIN tblSMAdvancePermission B ON A.intAdvancePermissionId = B.intAdvancePermissionId
INNER JOIN tblSMModule C ON B.intModuleId = C.intModuleId
LEFT OUTER JOIN vyuSMUserLocationSubRolePermission P ON P.intUserRoleId = A.intUserRoleId
