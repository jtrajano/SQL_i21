CREATE VIEW [dbo].[vyuSMUserSecurityMenuFavorite]
AS
SELECT
intUserSecurityMenuFavoriteId,
Favorite.intMenuId,
--Favorite.intEntityUserSecurityId,
UserSecurity.[intEntityId],
--THIS IS THE ORIGINAL BEFORE THE MERGE PLEASE CHECK
--Favorite.intUserSecurityId,
--UserSecurity.intEntityId,
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
INNER JOIN tblSMUserSecurity UserSecurity ON Favorite.intEntityUserSecurityId = UserSecurity.[intEntityId]
INNER JOIN vyuSMUserRoleMenuLocation UserRoleMenuLocation ON Favorite.intMenuId = UserRoleMenuLocation.intMenuId AND Favorite.intCompanyLocationId = UserRoleMenuLocation.intCompanyLocationId AND UserSecurity.[intEntityId] = UserRoleMenuLocation.intEntityId
WHERE UserRoleMenuLocation.ysnVisible = 1