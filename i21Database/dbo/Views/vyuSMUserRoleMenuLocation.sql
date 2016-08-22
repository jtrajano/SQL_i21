CREATE VIEW [dbo].[vyuSMUserRoleMenuLocation]
AS 
SELECT DISTINCT
SubRolePermimssion.intCompanyLocationId,
SubRolePermimssion.intEntityUserSecurityId as intEntityId,
RoleMenu.intMenuId,
Menu.intParentMenuID as intParentMenuId,
RoleMenu.ysnVisible,
RoleMenu.intSort,
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
INNER JOIN vyuSMUserLocationSubRolePermission SubRolePermimssion ON SubRolePermimssion.intUserRoleId = RoleMenu.intUserRoleId