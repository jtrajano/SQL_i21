CREATE VIEW [dbo].[vyuEMBEExportCustomer]
	AS 


	select
		account = a.strEntityNo,
		code =  a.strEntityNo,
		fullname = a.strName,
		lastname = '',
		firstname = '',
		address1 = dbo.fnEMSplitWithGetByIdx(c.strAddress,char(10),1),
		address2 = dbo.fnEMSplitWithGetByIdx(c.strAddress,char(10),2),
		city = c.strCity,
		[state] = c.strState,
		zip = c.strZipCode,
		country = c.strCountry,
		zone = 0,
		phone = f.strPhone,
		email = e.strEmail,
		applications = 'FFFF',	
		longitude = c.dblLongitude,
		latitude = c.dblLatitude,
		altitude = 0,
		directions = ''
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
	
