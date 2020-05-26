CREATE VIEW [dbo].[vyuSMEntityMenuFavorite]
AS
SELECT DISTINCT
Favorite.intEntityMenuFavoriteId,
ISNULL(Favorite.intMenuId, Favorite.intCustomId) AS intMenuId,
UserSecurityCompanyLocationRolePermission.intEntityUserSecurityId AS intEntityId,
ISNULL(UserSecurityCompanyLocationRolePermission.intCompanyLocationId, 0) AS intCompanyLocationId,
Favorite.intSort,
ISNULL(MasterMenu.strMenuName, Favorite.strMenuName) AS strMenuName,
MasterMenu.strModuleName,
CASE WHEN Favorite.ysnMenuLink = 1 THEN 'MenuLink' ELSE MasterMenu.strDescription END AS strDescription,
CASE WHEN Favorite.ysnCustomView = 1 THEN 'Custom View' ELSE (CASE WHEN Favorite.ysnMenuLink = 1 THEN 'Screen' ELSE ISNULL(MasterMenu.strType, 'Folder') END) END AS strType,
CASE WHEN Favorite.ysnCustomView = 1 THEN ('GlobalComponentEngine.view.SystemDashboard?id=' + CAST(Favorite.intCustomId AS NVARCHAR)) ELSE (CASE WHEN Favorite.ysnMenuLink = 1 THEN Favorite.strMenuLinkCommand ELSE MasterMenu.strCommand END) END AS strCommand,
MasterMenu.strIcon,
CASE WHEN (Favorite.ysnCustomView = 1 OR Favorite.ysnMenuLink = 1) THEN CAST(1 AS BIT) ELSE ISNULL(MasterMenu.ysnLeaf, 0) END AS ysnLeaf,
ISNULL(MasterMenu.ysnIsLegacy, 0) AS ysnIsLegacy,
ISNULL(Favorite.intParentEntityMenuFavoriteId, 0) AS intParentEntityMenuFavoriteId,
Favorite.ysnCustomView as ysnCustomView,
Favorite.ysnMenuLink as ysnMenuLink,
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
LEFT JOIN tblSMMasterMenu MasterMenu ON Favorite.intMenuId = MasterMenu.intMenuID and Favorite.ysnCustomView = 0
WHERE (CASE ISNULL(MasterMenu.strType, 'Folder') WHEN 'Folder' THEN 1 ELSE ISNULL(RoleMenu.ysnVisible, 0) END) = 1