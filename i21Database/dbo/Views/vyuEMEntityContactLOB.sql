CREATE VIEW [dbo].[vyuEMEntityContactLOB]
	AS 



	SELECT       
		B.intEntityId,     
		strEntityName = B.strName,
		intEntityContactId = D.intEntityId,   
		strContactName = D.strName,   
		strContactEmail = D.strEmail,   
		E.strLocationName,   
		phone.strPhone,   
		strMobile = mob.strPhone,   
		D.strTimezone,   
		D.strTitle,
		ysnContactActive = D.ysnActive,  	
		C.ysnDefaultContact,
		strLineOfBusiness = dbo.fnEMGetEntityLineOfBusiness(D.intEntityId)
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


