CREATE VIEW [dbo].[vyuSMUserRoleMenuSubRole]
AS 
SELECT DISTINCT
ISNULL(SubRole.intUserRoleId, RoleMenu.intUserRoleId) AS intUserRoleId,
RoleMenu.intMenuId,
Menu.intParentMenuID as intParentMenuId,
RoleMenu.ysnVisible,
Menu.intSort,
strMenuName,
strModuleName,
Menu.strDescription,
Menu.strCategory,
strType,
strCommand,
strIcon,
ysnExpanded,
ysnIsLegacy,
ysnLeaf
FROM vyuSMUserRoleSubRole SubRole
RIGHT JOIN tblSMUserRoleMenu RoleMenu ON SubRole.intUserRoleID = RoleMenu.intUserRoleId
LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
WHERE RoleMenu.ysnVisible = 1
