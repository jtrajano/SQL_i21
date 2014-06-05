CREATE VIEW [dbo].[vyuCPContactMenu]
AS
SELECT
intUserSecurityMenuId = Permission.intCustomerPortalMenuId,
intUserSecurityId = Permission.intContactId,
intMenuId = Menu.intCustomerPortalMenuId,
intParentMenuId = Menu.intCustomerPortalParentMenuId,
strMenuName = Menu.strCustomerPortalMenuName,
strIcon = (CASE WHEN Menu.strType = 'Folder' THEN 'small-folder' ELSE 'small-screen' END),
strDescription = Menu.strCustomerPortalMenuName,
strType = Menu.strType,
strCommand = Menu.strCommand,
iconCls = Menu.strCustomerPortalMenuName,
ysnLeaf = (CASE WHEN Menu.strType = 'Folder' THEN 'small-folder' ELSE 'small-screen' END),
leaf = (CASE WHEN Menu.strType = 'Folder' THEN 'small-folder' ELSE 'small-screen' END),
expanded = 0,
ysnVisible = (CASE WHEN ISNULL(Permission.intCustomerPortalMenuId, 0) = 0 THEN 0 ELSE 1 END),
intSort = Menu.intCustomerPortalMenuId
FROM tblARCustomerPortalMenu Menu
LEFT JOIN tblARCustomerPortalPermission Permission ON Menu.intCustomerPortalMenuId = Permission.intCustomerPortalMenuId