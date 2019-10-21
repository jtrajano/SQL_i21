﻿CREATE VIEW [dbo].[vyuETBEExportCustomer]
	AS 


	select
		account = a.strEntityNo,
		code =  a.strEntityNo,
		fullname = a.strName,
		lastname = '' COLLATE Latin1_General_CI_AS,
		firstname = '' COLLATE Latin1_General_CI_AS,
		address1 = dbo.fnEMSplitWithGetByIdx(c.strAddress,char(10),1) COLLATE Latin1_General_CI_AS,
		address2 = dbo.fnEMSplitWithGetByIdx(c.strAddress,char(10),2) COLLATE Latin1_General_CI_AS,
		city = c.strCity,
		[state] = c.strState,
		zip = c.strZipCode,
		country = c.strCountry,
		zone = 0,
		phone = f.strPhone,
		email = e.strEmail,
		applications = 'FFFF' COLLATE Latin1_General_CI_AS,	
		longitude = c.dblLongitude,
		latitude = c.dblLatitude,
		altitude = 0,
		directions = '' COLLATE Latin1_General_CI_AS
	from tblEMEntity a
		join tblEMEntityType b
			on a.intEntityId = b.intEntityId and b.strType = 'Customer'
	INNER JOIN tblARCustomer G
	ON b.intEntityId = G.[intEntityId]
		join tblEMEntityLocation c
			on a.intEntityId = c.intEntityId and c.ysnDefaultLocation = 1
		join tblEMEntityToContact d
			on d.intEntityId = a.intEntityId and ysnDefaultContact = 1
		join tblEMEntity e
			on d.intEntityContactId = e.intEntityId
		left join tblEMEntityPhoneNumber f
			on f.intEntityId = e.intEntityId
	WHERE G.ysnActive = 1
	
