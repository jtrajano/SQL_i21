CREATE VIEW [dbo].[vyuCPContactMenu]  
AS  
SELECT  
intUserSecurityMenuId = Permission.intCustomerPortalPermissionId,  
intUserSecurityId = Contact.intEntityContactId,  
intMenuId = Menu.intCustomerPortalMenuId,  
intParentMenuId = (CASE WHEN Menu.intCustomerPortalParentMenuId = 0 THEN 0 ELSE (
					SELECT intCustomerPortalPermissionId
					FROM tblARCustomerPortalPermission
					LEFT JOIN tblARCustomerToContact  ON tblARCustomerPortalPermission.intARCustomerToContactId = tblARCustomerToContact.intARCustomerToContactId
					LEFT JOIN tblEntityContact  ON tblARCustomerToContact.intEntityContactId = tblEntityContact.intEntityContactId
					WHERE tblEntityContact.intEntityContactId = Contact.intEntityContactId
					
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
LEFT JOIN tblARCustomerToContact CustomerToContact ON Permission.intARCustomerToContactId = CustomerToContact.intARCustomerToContactId
LEFT JOIN tblEntityContact Contact ON CustomerToContact.intEntityContactId = Contact.intEntityContactId