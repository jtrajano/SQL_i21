CREATE VIEW [dbo].[vyuSMUserRoleGroup]
AS
SELECT CAST (ROW_NUMBER() OVER (ORDER BY EntityToRole.intEntityId DESC) AS INT)	AS	intUserRoleGroupId, 
UserRole.strName AS strName, ISNULL(EntityToRole.intEntityId, 0) AS intGroupId, UserRole.intUserRoleID as intUserRoleId
FROM tblEMEntityToRole EntityToRole 
RIGHT JOIN tblSMUserRole UserRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID