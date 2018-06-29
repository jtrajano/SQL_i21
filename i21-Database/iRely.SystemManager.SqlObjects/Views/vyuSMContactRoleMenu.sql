CREATE VIEW [dbo].[vyuSMContactRoleMenu]
AS
SELECT intUserRoleMenuId
,intUserRoleId
,RoleMenu.intMenuId
,MasterMenu.intParentMenuID as intParentMenuId
,RoleMenu.ysnVisible as ysnVisible
,RoleMenu.intSort
,ISNULL(ContactMenu.strMenuName, MasterMenu.strMenuName) as strMenuName
,MasterMenu.strModuleName
,MasterMenu.strDescription
,MasterMenu.strCategory
,MasterMenu.strType
,MasterMenu.strCommand
,MasterMenu.strIcon
,MasterMenu.ysnExpanded
,MasterMenu.ysnIsLegacy
,MasterMenu.ysnLeaf
,ISNULL(ContactMenu.intRow, MasterMenu.intRow) as intRow
,RoleMenu.intConcurrencyId
FROM tblSMUserRoleMenu RoleMenu
LEFT JOIN tblSMMasterMenu MasterMenu ON MasterMenu.intMenuID = RoleMenu.intMenuId
LEFT JOIN tblSMContactMenu ContactMenu ON ContactMenu.intMasterMenuId = RoleMenu.intMenuId
LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId