CREATE VIEW [dbo].[vyuEMEntityContact2]
	AS 

SELECT       
	B.intEntityId,     
	strEntityName = B.strName,
	D.intEntityId intEntityContactId,   
	D.strName,   
	D.strEmail,   
	E.strLocationName,   
	phone.strPhone,
	strPhoneLookup = phone.strPhoneLookUp,
	strMobile = mob.strPhone,
	strMobileLookup = mob.strPhoneLookUp,
	D.strTimezone,   
	D.strTitle,
	C.ysnPortalAccess,  
	D.ysnActive,  	
	C.ysnDefaultContact,
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
	LEFT JOIN [tblEMEntityCredential] g
		on g.intEntityId = D.intEntityId

