CREATE VIEW [dbo].[vyuSMUserRoleMenuSubRole]
AS 
SELECT ISNULL(SubRole.intUserRoleID, RoleMenu.intUserRoleId)  AS intUserRoleId
,RoleMenu.intMenuId
,Menu.intParentMenuID AS intParentMenuId
,[dbo].[fnSMHideOriginMenus] (strMenuName, CAST(MAX(CAST(RoleMenu.ysnVisible AS INT)) AS BIT)) AS ysnVisible
,MIN(Menu.intSort) AS intSort
,Menu.intRow AS intRow
,REPLACE(strMenuName, ' (Portal)', '') AS strMenuName
,strModuleName
,Menu.strDescription
,Menu.strCategory
,strType
,CASE
	WHEN strMenuName = 'Time Off Calendar (Portal)' THEN strCommand + '?id=' + CAST((SELECT intCalendarId FROM tblSMCalendars WHERE strCalendarName = 'Time Off' AND strCalendarType = 'System') AS NVARCHAR(MAX))
	ELSE strCommand
END AS strCommand 
,strIcon
,ysnExpanded
,ysnIsLegacy
,ysnLeaf
FROM vyuSMUserRoleSubRole SubRole
RIGHT JOIN tblSMUserRoleMenu RoleMenu ON SubRole.intSubRoleId = RoleMenu.intUserRoleId
INNER JOIN tblSMMasterMenu Menu ON RoleMenu.intMenuId = Menu.intMenuID
WHERE ISNULL(ysnAvailable, 1) = 1
GROUP BY ISNULL(SubRole.intUserRoleID, RoleMenu.intUserRoleId), RoleMenu.intMenuId, Menu.intParentMenuID, strMenuName, strModuleName, Menu.strDescription, Menu.strCategory, strType, strCommand, strIcon, ysnExpanded, ysnIsLegacy, ysnLeaf, intRow