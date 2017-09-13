CREATE VIEW [dbo].[vyuSMUserRoleMenuSubRole]
AS 
SELECT ISNULL(intUserRoleID, RoleMenu.intUserRoleId)  as intUserRoleId
,RoleMenu.intMenuId
,Menu.intParentMenuID as intParentMenuId
,[dbo].[fnSMHideOriginMenus] (strMenuName, CAST(MAX(CAST(RoleMenu.ysnVisible as INT)) as BIT)) as ysnVisible
,MIN(RoleMenu.intSort) as intSort
,Menu.intRow as intRow
,REPLACE(strMenuName, ' (Portal)', '') as strMenuName
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
WHERE ISNULL(ysnAvailable, 1) = 1
GROUP BY ISNULL(intUserRoleID, RoleMenu.intUserRoleId), RoleMenu.intMenuId, Menu.intParentMenuID, strMenuName, strModuleName, Menu.strDescription, Menu.strCategory, strType, strCommand, strIcon, ysnExpanded, ysnIsLegacy, ysnLeaf, intRow
