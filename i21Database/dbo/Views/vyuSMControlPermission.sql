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
--A.intUserRoleId, 
C.strNamespace,
P.intCompanyLocationId,
P.intEntityId
FROM tblSMUserRoleControlPermission A 
INNER JOIN tblSMControl B ON A.intControlId = B.intControlId
INNER JOIN tblSMScreen C ON B.intScreenId = C.intScreenId
INNER JOIN vyuSMUserLocationSubRolePermission P ON P.intUserRoleId = A.intUserRoleId
--INNER JOIN tblSMUserSecurityCompanyLocationRolePermission P ON A.intUserRoleId = P.intUserRoleId