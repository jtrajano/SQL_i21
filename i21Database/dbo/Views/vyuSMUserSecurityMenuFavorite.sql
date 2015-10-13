CREATE VIEW [dbo].[vyuSMUserSecurityMenuFavorite]
AS
SELECT
intUserSecurityMenuFavoriteId,
Favorite.intMenuId,
intUserSecurityId,
UserSecurity.[intEntityUserSecurityId],
UserRoleMenuLocation.intCompanyLocationId,
Favorite.intSort,
UserRoleMenuLocation.strMenuName,
UserRoleMenuLocation.strModuleName,
UserRoleMenuLocation.strDescription,
UserRoleMenuLocation.strType,
UserRoleMenuLocation.strCommand,
UserRoleMenuLocation.strIcon,
UserRoleMenuLocation.ysnIsLegacy
FROM tblSMUserSecurityMenuFavorite Favorite
INNER JOIN tblSMUserSecurity UserSecurity ON Favorite.intUserSecurityId = UserSecurity.[intEntityUserSecurityId]
INNER JOIN vyuSMUserRoleMenuLocation UserRoleMenuLocation ON Favorite.intMenuId = UserRoleMenuLocation.intMenuId AND Favorite.intCompanyLocationId = UserRoleMenuLocation.intCompanyLocationId AND UserSecurity.[intEntityUserSecurityId] = UserRoleMenuLocation.intEntityId
WHERE UserRoleMenuLocation.ysnVisible = 1