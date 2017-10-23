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
		E.strTimezone,   
		D.strTitle,
		ysnContactActive = D.ysnActive,  	
		C.ysnDefaultContact,
		strLineOfBusiness = dbo.fnEMGetEntityLineOfBusiness(B.intEntityId),

		 ysnVendor = CAST(X.Vendor AS BIT),  
		 ysnCustomer = CAST(X.Customer AS BIT),  
		 ysnSalesperson = CAST(X.Salesperson AS BIT),
		 ysnFuturesBroker = CAST(X.FuturesBroker AS BIT),  
		 ysnForwardingAgent = CAST(X.ForwardingAgent AS BIT),
		 ysnTerminal = CAST(X.Terminal AS BIT),  
		 ysnShippingLine = CAST(X.ShippingLine AS BIT),
		 ysnTrucker = CAST(X.Trucker AS BIT),
		 ysnShipVia = CAST(X.ShipVia AS BIT),
		 ysnInsurer = CAST(X.Insurer AS BIT),
		 ysnEmployee = CAST(X.Employee AS BIT),
		 ysnProducer = CAST(X.Producer AS BIT),
		 ysnUser = CAST(X.[User] AS BIT),  
		 ysnProspect = CAST(X.Prospect AS BIT),
		 ysnCompetitor = CAST(X.Competitor AS BIT),
		 ysnBuyer = CAST(X.Buyer AS BIT),
		 ysnPartner = CAST(X.[Partner] AS BIT),
		 ysnLead = CAST(X.Lead AS BIT),
		 ysnVeterinary = CAST(X.Veterinary AS BIT),
		 ysnLien = CAST(X.Lien AS BIT),
		 ysnBroker = CAST(X.[Broker] AS BIT)

	FROM dbo.tblEMEntity AS B 			
		INNER JOIN dbo.[tblEMEntityToContact] AS C 
				ON B.[intEntityId] = C.[intEntityId] 
		INNER JOIN dbo.tblEMEntity AS D 
				ON C.[intEntityContactId] = D.[intEntityId] 
		join vyuEMEntityType X
				on X.intEntityId = B.intEntityId
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


