CREATE VIEW [dbo].[vyuSMUserRoleMenuLocationMVC]
AS 
SELECT        SubRolePermimssion.intCompanyLocationId, SubRolePermimssion.intEntityUserSecurityId AS intEntityId, RoleMenu.intMenuId, Menu.intParentMenuID, dbo.fnSMHideOriginMenus(Menu.strMenuName, 
                         CAST(MAX(CAST(RoleMenu.ysnVisible AS INT)) AS BIT)) AS ysnVisible, MIN(Menu.intSort) AS intSort, Menu.intRow, Menu.strMenuName, Menu.strModuleName, Menu.strCategory, Menu.strType, Menu.strCommand, 
                         Menu.ysnIsLegacy, SubRolePermimssion.strCompanyCode
FROM            dbo.tblSMUserRoleMenu AS RoleMenu LEFT OUTER JOIN
                         dbo.tblSMMasterMenu AS Menu ON Menu.intMenuID = RoleMenu.intMenuId INNER JOIN
                         dbo.vyuSMUserLocationSubRolePermission AS SubRolePermimssion ON SubRolePermimssion.intUserRoleId = RoleMenu.intUserRoleId
WHERE        (ISNULL(RoleMenu.ysnAvailable, 1) = 1) AND (RoleMenu.ysnVisible = 1)
GROUP BY SubRolePermimssion.intCompanyLocationId, SubRolePermimssion.intEntityUserSecurityId, RoleMenu.intMenuId, Menu.intParentMenuID, Menu.intRow, Menu.strMenuName, Menu.strModuleName, Menu.strCategory, 
                         Menu.strType, Menu.strCommand, Menu.ysnIsLegacy, SubRolePermimssion.strCompanyCode