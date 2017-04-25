CREATE VIEW [dbo].[vyuSMUserRoleMenuSubRole]
AS 
SELECT ISNULL(intUserRoleID, RoleMenu.intUserRoleId)  as intUserRoleId
,RoleMenu.intMenuId
,Menu.intParentMenuID as intParentMenuId
,[dbo].[fnSMHideOriginMenus] (strMenuName, CAST(MAX(CAST(RoleMenu.ysnVisible as INT)) as BIT)) as ysnVisible
,MIN(RoleMenu.intSort) as intSort
,strMenuName
,strModuleName
,Menu.strDescription
,Menu.strCategory
,strType
,strCommand
,strIcon
,ysnExpanded
,ysnIsLegacy
,ysnLeaf
FROM vyuSMUserRoleSubRole SubRole
RIGHT JOIN tblSMUserRoleMenu RoleMenu ON SubRole.intSubRoleId = RoleMenu.intUserRoleId
INNER JOIN tblSMMasterMenu Menu ON RoleMenu.intMenuId = Menu.intMenuID
GROUP BY ISNULL(intUserRoleID, RoleMenu.intUserRoleId), RoleMenu.intMenuId, Menu.intParentMenuID, strMenuName, strModuleName, Menu.strDescription, Menu.strCategory, strType, strCommand, strIcon, ysnExpanded, ysnIsLegacy, ysnLeaf