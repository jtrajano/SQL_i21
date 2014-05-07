CREATE VIEW [dbo].vyuSMUserSecurityMenu
AS 

SELECT 
intUserSecurityMenuId,
intUserSecurityId,
intMenuId,
intParentMenuId,
UserMenu.ysnVisible,
UserMenu.intSort,
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