CREATE VIEW [dbo].[vyuSMUserSecurityMenuFavoriteUserRole]
AS 
SELECT 
intUserSecurityMenuFavoriteId,
Favorite.intMenuId,
UserSecurity.intEntityUserSecurityId,
NULL intCompanyLocationId,
Favorite.intSort,
MasterMenu.strMenuName,
MasterMenu.strModuleName,
MasterMenu.strDescription,
MasterMenu.strType,
MasterMenu.strCommand,
MasterMenu.strIcon,
MasterMenu.ysnIsLegacy
FROM tblSMUserSecurityMenuFavorite Favorite
INNER JOIN tblSMUserSecurity UserSecurity on Favorite.intEntityUserSecurityId = UserSecurity.intEntityUserSecurityId
INNER JOIN tblSMUserRoleMenu RoleMenu on UserSecurity.intUserRoleID = RoleMenu.intUserRoleId and Favorite.intMenuId = RoleMenu.intMenuId
INNER JOIN tblSMMasterMenu MasterMenu on Favorite.intMenuId = MasterMenu.intMenuID
WHERE RoleMenu.ysnVisible = 1