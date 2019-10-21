CREATE VIEW [dbo].[vyuSMMasterMenu]
AS 
SELECT intMenuID
,strMenuName
,strModuleName
,intParentMenuID
,strDescription
,strCategory
,strType
,strCommand
,strIcon
,ysnVisible
,ysnExpanded
,ysnIsLegacy
,ysnLeaf
,intSort
,intRow
,intConcurrencyId
FROM tblSMMasterMenu
WHERE intMenuID NOT IN (SELECT intMasterMenuId FROM tblSMContactMenu) AND strMenuName NOT IN ('DASHBOARD')