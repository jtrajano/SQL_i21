CREATE VIEW [dbo].[vyuSMUserRoleMenuSubRole]
AS 
SELECT DISTINCT
ISNULL(SubRole.intUserRoleId, RoleMenu.intUserRoleId) AS intUserRoleId
,RoleMenu.intMenuId
,Menu.intParentMenuID as intParentMenuId
,RoleMenu.ysnVisible
,Sort.intSort--RoleMenu.intSort,
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
RIGHT JOIN tblSMUserRoleMenu RoleMenu ON SubRole.intUserRoleID = RoleMenu.intUserRoleId
LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
CROSS APPLY (SELECT intSort FROM tblSMUserRoleMenu WHERE intUserRoleId = ISNULL(SubRole.intUserRoleId, RoleMenu.intUserRoleId) AND intMenuId = RoleMenu.intMenuId) Sort
WHERE RoleMenu.ysnVisible = 1
