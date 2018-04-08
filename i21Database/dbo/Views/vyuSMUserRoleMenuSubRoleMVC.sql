CREATE VIEW [dbo].[vyuSMUserRoleMenuSubRoleMVC]
AS 
SELECT        ISNULL(SubRole.intUserRoleID, RoleMenu.intUserRoleId) AS intUserRoleId, RoleMenu.intMenuId, Menu.intParentMenuID, dbo.fnSMHideOriginMenus(Menu.strMenuName, CAST(MAX(CAST(RoleMenu.ysnVisible AS INT)) AS BIT)) 
                         AS ysnVisible, MIN(Menu.intSort) AS intSort, Menu.intRow, REPLACE(Menu.strMenuName, ' (Portal)', '') AS strMenuName, Menu.strModuleName, Menu.strCategory, Menu.strType, 
                         CASE WHEN strMenuName = 'Time Off Calendar (Portal)' THEN strCommand + '?id=' + CAST
                             ((SELECT        intCalendarId
                                 FROM            tblSMCalendars
                                 WHERE        strCalendarName = 'Time Off' AND strCalendarType = 'System') AS NVARCHAR(MAX)) ELSE strCommand END AS strCommand, Menu.ysnIsLegacy
FROM            dbo.vyuSMUserRoleSubRole AS SubRole RIGHT OUTER JOIN
                         dbo.tblSMUserRoleMenu AS RoleMenu ON SubRole.intSubRoleId = RoleMenu.intUserRoleId INNER JOIN
                         dbo.tblSMMasterMenu AS Menu ON RoleMenu.intMenuId = Menu.intMenuID
WHERE        (ISNULL(RoleMenu.ysnAvailable, 1) = 1) AND (RoleMenu.ysnVisible = 1)
GROUP BY ISNULL(SubRole.intUserRoleID, RoleMenu.intUserRoleId), RoleMenu.intMenuId, Menu.intParentMenuID, Menu.intRow, Menu.strMenuName, Menu.strModuleName, Menu.strCategory, Menu.strType, Menu.strCommand, 
                         Menu.ysnIsLegacy
