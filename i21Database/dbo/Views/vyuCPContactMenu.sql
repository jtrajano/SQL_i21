CREATE VIEW [dbo].[vyuCPContactMenu]  
AS  
SELECT  
intUserSecurityMenuId = Permission.intCustomerPortalPermissionId,  
intUserSecurityId = Permission.intContactId,  
intMenuId = Menu.intCustomerPortalMenuId,  
intParentMenuId = (CASE WHEN Menu.intCustomerPortalParentMenuId = 0 THEN 0 ELSE (
					SELECT intCustomerPortalPermissionId
					FROM tblARCustomerPortalPermission
					WHERE tblARCustomerPortalPermission.intContactId = Permission.intContactId
					
					AND	tblARCustomerPortalPermission.intCustomerPortalMenuId = Menu.intCustomerPortalParentMenuId
					) END),
strMenuName = Menu.strCustomerPortalMenuName,  
strModuleName = 'Customer Portal',  
strIcon = (CASE WHEN Menu.strType = 'Folder' THEN 'small-folder' ELSE 'small-screen' END),  
strDescription = Menu.strCustomerPortalMenuName,  
strType = Menu.strType,  
strCommand = Menu.strCommand,  
iconCls = Menu.strCustomerPortalMenuName,  
ysnLeaf = (CASE WHEN Menu.strType = 'Folder' THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END),  
leaf = (CASE WHEN Menu.strType = 'Folder' THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END),  
expanded = CAST(0 AS BIT),  
ysnVisible = (CASE WHEN ISNULL(Permission.intCustomerPortalMenuId, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END),  
ysnIsLegacy = CAST(0 AS BIT),  
intSort = Menu.intCustomerPortalMenuId  
FROM tblARCustomerPortalMenu Menu  
LEFT JOIN tblARCustomerPortalPermission Permission ON Menu.intCustomerPortalMenuId = Permission.intCustomerPortalMenuId