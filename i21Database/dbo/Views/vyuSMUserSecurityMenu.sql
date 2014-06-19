CREATE VIEW [dbo].vyuSMUserSecurityMenu
AS 

SELECT 
intUserSecurityMenuId,
intUserSecurityId,
UserMenu.intMenuId,
UserMenu.intParentMenuId,
UserMenu.ysnVisible,
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
UserMenu.intConcurrencyId
FROM tblSMUserSecurityMenu UserMenu
LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = UserMenu.intMenuId