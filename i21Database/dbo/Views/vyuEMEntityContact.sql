CREATE VIEW [dbo].[vyuEMEntityContact]
	AS 

SELECT       
	B.intEntityId,   
	D.intEntityId intEntityContactId,   
	D.strName,   
	D.strEmail,   
	E.strLocationName,   
	D.strPhone,   
	D.strTimezone,   
	D.strTitle,   
	C.ysnPortalAccess,  
	D.ysnActive,  	
	C.ysnDefaultContact   
FROM dbo.tblEntity AS B 			
	INNER JOIN dbo.tblEntityToContact AS C 
			ON B.[intEntityId] = C.[intEntityId] 
	INNER JOIN dbo.tblEntity AS D 
			ON C.[intEntityContactId] = D.[intEntityId] 
	LEFT OUTER JOIN dbo.tblEntityLocation AS E 
			ON C.intEntityLocationId = E.intEntityLocationId
