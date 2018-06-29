CREATE VIEW vyuEPContactMenu
AS
SELECT DISTINCT
intUserSecurityMenuId = Permission.intEntityPortalPermissionId,
intEntityUserSecurityId = Contact.[intEntityId],    
intMenuId = Menu.intEntityPortalMenuId,    
intParentMenuId = ISNULL((CASE WHEN Menu.intPortalParentMenuId = 0 THEN 0 ELSE (  
     SELECT intEntityPortalPermissionId  
     FROM [tblEMEntityPortalPermission]  
     LEFT JOIN [tblEMEntityToContact]  ON [tblEMEntityPortalPermission].intEntityToContactId = [tblEMEntityToContact].intEntityToContactId       
     LEFT JOIN tblEMEntity  ON [tblEMEntityToContact].[intEntityContactId] = tblEMEntity.[intEntityId]       
     WHERE tblEMEntity.[intEntityId] = Contact.[intEntityId]  
  
       
     AND [tblEMEntityPortalPermission].intEntityPortalMenuId = Menu.intPortalParentMenuId  
     ) END), 0),  
strMenuName = Menu.strPortalMenuName,    
strModuleName = 'Customer Portal',    
strIcon = (CASE WHEN Menu.strType = 'Folder' THEN 'small-folder' ELSE 'small-screen' END),    
strDescription = Menu.strPortalMenuName,    
strType = Menu.strType,    
strCommand = Menu.strCommand,    
iconCls = Menu.strPortalMenuName,    
ysnLeaf = (CASE WHEN Menu.strType = 'Folder' THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END),    
leaf = (CASE WHEN Menu.strType = 'Folder' THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END),    
expanded = CAST(0 AS BIT),    
ysnVisible = (CASE WHEN ISNULL(Permission.intEntityPortalMenuId, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END),    
ysnIsLegacy = CAST(0 AS BIT),    
intSort = Menu.intEntityPortalMenuId    
FROM [tblEMEntityPortalMenu] Menu    
	JOIN [tblEMEntityPortalPermission] Permission 
		ON Menu.intEntityPortalMenuId = Permission.intEntityPortalMenuId  
	JOIN [tblEMEntityToContact] EntityToContact 
		ON Permission.intEntityToContactId = EntityToContact.intEntityToContactId  
	JOIN tblEMEntity Contact 
		ON EntityToContact.[intEntityContactId] = Contact.[intEntityId]
	JOIN [tblEMEntityType] EntType
		ON EntType.intEntityId =  EntityToContact.intEntityId 
			and (
					EntType.strType = Menu.strEntityType
					or Menu.strEntityType = ''
				)
			and EntType.strType in ('Vendor','Customer')
