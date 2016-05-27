CREATE VIEW [dbo].[vyuEMEntityContact]
	AS 

SELECT       
	B.intEntityId,     
	strEntityName = B.strName,
	D.intEntityId intEntityContactId,   
	D.strName,   
	D.strEmail,   
	E.strLocationName,   
	phone.strPhone,   
	strMobile = mob.strPhone,   
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
FROM dbo.tblEMEntity AS B 			
	INNER JOIN dbo.[tblEMEntityToContact] AS C 
			ON B.[intEntityId] = C.[intEntityId] 
	INNER JOIN dbo.tblEMEntity AS D 
			ON C.[intEntityContactId] = D.[intEntityId] 
	LEFT JOIN tblEMEntityPhoneNumber phone
			ON phone.intEntityId = D.intEntityId
	LEFT JOIN tblEMEntityMobileNumber mob
			ON mob.intEntityId = D.intEntityId
	LEFT OUTER JOIN dbo.[tblEMEntityLocation] AS E 
			ON C.intEntityLocationId = E.intEntityLocationId
	JOIN vyuEMSearch F
		ON F.intEntityId = B.intEntityId
	LEFT JOIN [tblEMEntityCredential] g
		on g.intEntityId = D.intEntityId

