CREATE VIEW [dbo].vyuSMUserRoleMenu
AS 

SELECT 
intUserRoleMenuId,
intUserRoleId,
RoleMenu.intMenuId,
RoleMenu.intParentMenuId,
RoleMenu.ysnVisible,
Menu.intSort,
strMenuName,
strModuleName,
strDescription,
strType,
strCommand,
strIcon,
ysnExpanded,
ysnIsLegacy,
ysnLeaf,
RoleMenu.intConcurrencyId
FROM tblSMUserRoleMenu RoleMenu
LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId