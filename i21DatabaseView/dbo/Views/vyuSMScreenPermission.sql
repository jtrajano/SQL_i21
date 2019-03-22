CREATE VIEW [dbo].[vyuSMScreenPermission]
AS 
SELECT DISTINCT
A.intUserRoleScreenPermissionId AS intScreenPermissionId,
A.strPermission, 
--A.intUserRoleId, 
C.strNamespace,
P.intCompanyLocationId,
P.intEntityId
FROM tblSMUserRoleScreenPermission A 
INNER JOIN tblSMScreen C ON A.intScreenId = C.intScreenId
INNER JOIN vyuSMUserLocationSubRolePermission P ON P.intUserRoleId = A.intUserRoleId