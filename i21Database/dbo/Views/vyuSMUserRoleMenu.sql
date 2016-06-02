CREATE VIEW [dbo].vyuSMUserRoleMenu
AS
SELECT DISTINCT
intUserRoleMenuId,
ISNULL(SubRole.intUserRoleId, RoleMenu.intUserRoleId) AS intUserRoleId,
ISNULL(SubRole.intUserRoleID, RoleMenu.intUserRoleId) AS intSubRoleId,
RoleMenu.intMenuId,
RoleMenu.intParentMenuId,
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
ysnLeaf,
RoleMenu.intConcurrencyId
FROM vyuSMUserRoleSubRole SubRole
RIGHT JOIN tblSMUserRoleMenu RoleMenu ON SubRole.intUserRoleID = RoleMenu.intUserRoleId
LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
