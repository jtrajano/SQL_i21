CREATE VIEW [dbo].[vyuEMSearchEntityCustomer]
	AS 

	SELECT 
		b.intEntityId,   
		b.strEntityNo, 
		b.strName,
		phone.strPhone,  
		e.strAddress,  
		e.strCity,  
		e.strState,  
		e.strZipCode,
		intWarehouseId = isnull(e.intWarehouseId, -99),
		b.strFederalTaxId,
		c.ysnActive
	from tblEMEntity b			
		join tblARCustomer c
			on c.[intEntityId] =b.intEntityId --and c.ysnActive = 1
		join vyuEMEntityType d
			on d.intEntityId = b.intEntityId and Customer = 1
		left join [tblEMEntityLocation] e  
			on ( ysnDefaultLocation = 1 )AND b.intEntityId = e.intEntityId
		left join [tblEMEntityToContact] f  
			on f.intEntityId = b.intEntityId and f.ysnDefaultContact = 1  
		left join tblEMEntity g  
			on f.intEntityContactId = g.intEntityId
		LEFT JOIN tblEMEntityPhoneNumber phone
			ON phone.intEntityId = g.intEntityId
