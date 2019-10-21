CREATE VIEW [dbo].vyuSMUserRoleMenu
AS
SELECT intUserRoleMenuId
,intUserRoleId
,RoleMenu.intMenuId
,Menu.intParentMenuID as intParentMenuId
,RoleMenu.ysnVisible as ysnVisible
,RoleMenu.intSort
,REPLACE(strMenuName, ' (Portal)', '') as strMenuName
,strModuleName
,strDescription
,Menu.strCategory
,strType
,strCommand
,strIcon
,ysnExpanded
,ysnIsLegacy
,ysnLeaf
,Menu.intRow as intRow
,RoleMenu.intConcurrencyId
FROM tblSMUserRoleMenu RoleMenu
LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
WHERE ISNULL(ysnAvailable, 1) = 1 AND (ysnIsLegacy = 0 OR ((SELECT COUNT(*) FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1) = 1 AND ysnIsLegacy = 1))
--WHERE  strMenuName NOT IN  (CASE  (SELECT TOP 1 ysnLegacyIntegration FROM tblSMCompanyPreference) WHEN 0 THEN ('Import GL from Subledger') ELSE ('')  END)
