CREATE VIEW [dbo].[vyuSMUserRoleMenuLocation]
AS 
SELECT DISTINCT
Permission.intCompanyLocationId,
Permission.intEntityId as intEntityId,
RoleMenu.intMenuId,
Menu.intParentMenuID as intParentMenuId,
RoleMenu.ysnVisible,
Menu.intSort,
strMenuName,
strModuleName,
strDescription,
Menu.strCategory,
strType,
strCommand,
strIcon,
ysnExpanded,
ysnIsLegacy,
ysnLeaf
FROM tblSMUserRoleMenu RoleMenu
LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
INNER JOIN tblSMUserSecurityCompanyLocationRolePermission Permission ON Permission.intUserRoleId = RoleMenu.intUserRoleId