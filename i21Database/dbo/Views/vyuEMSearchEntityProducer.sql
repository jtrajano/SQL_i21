CREATE VIEW [dbo].[vyuEMSearchEntityProducer]
AS

SELECT 
		a.intEntityId,   
		a.strEntityNo, 
		a.strName,  
		phone.strPhone,  
		e.strAddress,  
		e.strCity,  
		e.strState,  
		e.strZipCode,
		a.ysnActive
	FROM 		
			tblEMEntity a
		join [tblEMEntityType] b
			on b.intEntityId = a.intEntityId and b.strType = 'Producer'		
		left join [tblEMEntityLocation] e  
			on ( ysnDefaultLocation = 1 )AND a.intEntityId = e.intEntityId
		left join [tblEMEntityToContact] f  
			on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
		left join tblEMEntity g  
			on f.intEntityContactId = g.intEntityId  
		LEFT JOIN tblEMEntityPhoneNumber phone
			ON phone.intEntityId = g.intEntityId
