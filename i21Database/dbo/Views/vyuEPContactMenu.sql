CREATE VIEW vyuEPContactMenu
AS
SELECT    
intUserSecurityMenuId = Permission.intEntityPortalPermissionId,
intUserSecurityId = Contact.[intEntityId],    
intMenuId = Menu.intEntityPortalMenuId,    
intParentMenuId = ISNULL((CASE WHEN Menu.intPortalParentMenuId = 0 THEN 0 ELSE (  
     SELECT intEntityPortalPermissionId  
     FROM tblEntityPortalPermission  
     LEFT JOIN tblEntityToContact  ON tblEntityPortalPermission.intEntityToContactId = tblEntityToContact.intEntityToContactId       
     LEFT JOIN tblEntity  ON tblEntityToContact.[intEntityContactId] = tblEntity.[intEntityId]       
     WHERE tblEntity.[intEntityId] = Contact.[intEntityId]  
  
       
     AND tblEntityPortalPermission.intEntityPortalMenuId = Menu.intPortalParentMenuId  
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
FROM tblEntityPortalMenu Menu    
	LEFT JOIN tblEntityPortalPermission Permission 
		ON Menu.intEntityPortalMenuId = Permission.intEntityPortalMenuId  
	LEFT JOIN tblEntityToContact EntityToContact 
		ON Permission.intEntityToContactId = EntityToContact.intEntityToContactId  
	LEFT JOIN tblEntity Contact 
		ON EntityToContact.[intEntityContactId] = Contact.[intEntityId]
