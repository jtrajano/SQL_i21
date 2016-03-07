﻿CREATE VIEW [dbo].[vyuEMEntityContact]
	AS 

SELECT       
	B.intEntityId,     
	strEntityName = B.strName,
	D.intEntityId intEntityContactId,   
	D.strName,   
	D.strEmail,   
	E.strLocationName,   
	D.strPhone,   
	D.strMobile,   
	D.strTimezone,   
	D.strTitle,
	C.ysnPortalAccess,  
	D.ysnActive,  	
	C.ysnDefaultContact,	
	F.Customer,  
	F.Vendor,  
	F.Employee,  
	F.Salesperson,  
	F.[User],  
	F.FuturesBroker,  
	F.ForwardingAgent,  
	F.Terminal,  
	F.ShippingLine,  
	F.Trucker ,
	D.strContactType,
	D.strEmailDistributionOption,
	B.imgPhoto,
	papit = g.strPassword
FROM dbo.tblEntity AS B 			
	INNER JOIN dbo.tblEntityToContact AS C 
			ON B.[intEntityId] = C.[intEntityId] 
	INNER JOIN dbo.tblEntity AS D 
			ON C.[intEntityContactId] = D.[intEntityId] 
	LEFT OUTER JOIN dbo.tblEntityLocation AS E 
			ON C.intEntityLocationId = E.intEntityLocationId
	JOIN vyuEMSearch F
		ON F.intEntityId = B.intEntityId
	LEFT JOIN tblEntityCredential g
		on g.intEntityId = D.intEntityId

