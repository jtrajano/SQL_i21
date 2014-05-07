CREATE VIEW [dbo].vyuSMUserRoleMenu
AS 

SELECT 
intUserRoleMenuId,
intUserRoleId,
intMenuId,
intParentMenuId,
RoleMenu.ysnVisible,
RoleMenu.intSort,
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