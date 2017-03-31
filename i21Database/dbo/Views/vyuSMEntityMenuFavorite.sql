CREATE VIEW [dbo].[vyuSMEntityMenuFavorite]
AS
SELECT DISTINCT
Favorite.intEntityMenuFavoriteId,
Favorite.intMenuId,
UserSecurityCompanyLocationRolePermission.intEntityUserSecurityId AS intEntityId,
UserSecurityCompanyLocationRolePermission.intCompanyLocationId,
Favorite.intSort,
ISNULL(MasterMenu.strMenuName, Favorite.strMenuName) AS strMenuName,
MasterMenu.strModuleName,
MasterMenu.strDescription,
ISNULL(MasterMenu.strType, 'Folder') AS strType,
MasterMenu.strCommand,
MasterMenu.strIcon,
ISNULL(MasterMenu.ysnLeaf, 0) AS ysnLeaf,
ISNULL(MasterMenu.ysnIsLegacy, 0) AS ysnIsLegacy,
Favorite.intParentEntityMenuFavoriteId,
Favorite.intConcurrencyId
FROM tblSMEntityMenuFavorite Favorite
INNER JOIN
(
	SELECT DISTINCT ISNULL(UserLocationRole.intEntityId, UserSecurity.[intEntityId]) AS intEntityUserSecurityId, ISNULL(UserLocationRole.intUserRoleId, UserSecurity.intUserRoleID) AS intUserRoleId, UserLocationRole.intCompanyLocationId AS intCompanyLocationId 
	FROM tblSMUserSecurity UserSecurity 
	LEFT JOIN tblSMUserSecurityCompanyLocationRolePermission UserLocationRole ON UserLocationRole.intEntityId = UserSecurity.[intEntityId]
	UNION ALL
	SELECT intEntityContactId AS intEntityUserSecurityId, intEntityRoleId AS intUserRoleId, NULL AS intCompanyLocationId FROM tblEMEntityToContact WHERE intEntityRoleId IS NOT NULL
) UserSecurityCompanyLocationRolePermission ON Favorite.intEntityId = UserSecurityCompanyLocationRolePermission.intEntityUserSecurityId --AND ISNULL(UserSecurityCompanyLocationRolePermission.intCompanyLocationId, 0) = ISNULL(Favorite.intCompanyLocationId, 0)
LEFT JOIN tblSMUserRoleMenu RoleMenu ON UserSecurityCompanyLocationRolePermission.intUserRoleId = RoleMenu.intUserRoleId and Favorite.intMenuId = RoleMenu.intMenuId
LEFT JOIN tblSMMasterMenu MasterMenu ON Favorite.intMenuId = MasterMenu.intMenuID
WHERE (CASE ISNULL(MasterMenu.strType, 'Folder') WHEN 'Folder' THEN 1 ELSE ISNULL(RoleMenu.ysnVisible, 0) END) = 1

