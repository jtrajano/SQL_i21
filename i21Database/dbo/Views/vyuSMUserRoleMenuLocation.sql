CREATE VIEW [dbo].[vyuSMUserRoleMenuLocation]
AS 
SELECT SubRolePermimssion.intCompanyLocationId
,SubRolePermimssion.intEntityUserSecurityId as intEntityId
,RoleMenu.intMenuId
,Menu.intParentMenuID as intParentMenuId
,[dbo].[fnSMHideOriginMenus] (strMenuName, CAST(MAX(CAST(RoleMenu.ysnVisible as INT)) as BIT)) as ysnVisible
,MIN(RoleMenu.intSort) as intSort
,strMenuName
,strModuleName
,strDescription
,Menu.strCategory
,strType
,strCommand
,strIcon
,ysnExpanded
,ysnIsLegacy
,ysnLeaf
FROM tblSMUserRoleMenu RoleMenu
LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
INNER JOIN vyuSMUserLocationSubRolePermission SubRolePermimssion ON SubRolePermimssion.intUserRoleId = RoleMenu.intUserRoleId
GROUP BY SubRolePermimssion.intCompanyLocationId, SubRolePermimssion.intEntityUserSecurityId, RoleMenu.intMenuId, Menu.intParentMenuID, strMenuName, strModuleName, strDescription, Menu.strCategory, strType, strCommand, strIcon, ysnExpanded, ysnIsLegacy, ysnLeaf