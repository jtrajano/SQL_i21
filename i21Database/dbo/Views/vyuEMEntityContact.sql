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
	C.ysnDefaultContact,
	case when F.intEntityVendorId is null then 0 else 1 end Vendor,    
	case when G.intEntityCustomerId is null then 0 else 1 end Customer
FROM dbo.tblEntity AS B 			
	INNER JOIN dbo.tblEntityToContact AS C 
			ON B.[intEntityId] = C.[intEntityId] 
	INNER JOIN dbo.tblEntity AS D 
			ON C.[intEntityContactId] = D.[intEntityId] 
	LEFT OUTER JOIN dbo.tblEntityLocation AS E 
			ON C.intEntityLocationId = E.intEntityLocationId
	LEFT JOIN tblAPVendor F
		ON C.intEntityId = F.intEntityVendorId
	LEFT JOIN tblARCustomer G
		ON C.intEntityId = G.intEntityCustomerId

