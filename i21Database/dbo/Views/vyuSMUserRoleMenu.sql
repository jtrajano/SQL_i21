CREATE VIEW [dbo].vyuSMUserRoleMenu
AS
SELECT intUserRoleMenuId
,intUserRoleId
,RoleMenu.intMenuId
,Menu.intParentMenuID as intParentMenuId
,RoleMenu.ysnVisible as ysnVisible
,RoleMenu.intSort
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
,RoleMenu.intConcurrencyId
FROM tblSMUserRoleMenu RoleMenu
LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
WHERE  strMenuName NOT IN  (CASE  (SELECT TOP 1 ysnLegacyIntegration FROM tblSMCompanyPreference) WHEN 0 THEN ('Import GL from Subledger') ELSE ('')  END)
