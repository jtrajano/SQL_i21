CREATE VIEW [dbo].[vyuSMEntityMenuFavorite]
AS
SELECT 
intEntityMenuFavoriteId,
Favorite.intMenuId,
UserSecurity.intEntityUserSecurityId as intEntityId,
Favorite.intCompanyLocationId,
Favorite.intSort,
ISNULL(MasterMenu.strMenuName, Favorite.strMenuName) as strMenuName,
MasterMenu.strModuleName,
MasterMenu.strDescription,
ISNULL(MasterMenu.strType, 'Folder') as strType,
MasterMenu.strCommand,
MasterMenu.strIcon,
ISNULL(MasterMenu.ysnLeaf, 0) as ysnLeaf,
ISNULL(MasterMenu.ysnIsLegacy, 0) as ysnIsLegacy,
Favorite.intParentEntityMenuFavoriteId,
Favorite.intConcurrencyId
FROM tblSMEntityMenuFavorite Favorite
INNER JOIN tblSMUserSecurity UserSecurity on Favorite.intEntityId = UserSecurity.intEntityUserSecurityId
LEFT JOIN tblSMUserRoleMenu RoleMenu on UserSecurity.intUserRoleID = RoleMenu.intUserRoleId and Favorite.intMenuId = RoleMenu.intMenuId
LEFT JOIN tblSMMasterMenu MasterMenu on Favorite.intMenuId = MasterMenu.intMenuID
WHERE ISNULL(RoleMenu.ysnVisible, 0) = 1