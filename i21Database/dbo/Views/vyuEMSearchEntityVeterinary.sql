CREATE VIEW [dbo].[vyuEMSearchEntityVeterinary]
	AS 



	SELECT 
        a.intEntityId,   
        a.strEntityNo, 
        a.strName,  
        h.strPhone,  
        e.strAddress,  
        e.strCity,  
        e.strState,  
        e.strZipCode,
		strType = 'Veterinary'
    FROM         
            tblEMEntity a
        join vyuEMEntityType b
            on b.intEntityId = a.intEntityId and b.Veterinary = 1
        join tblVTVeterinary c
            on c.[intEntityId]= a.intEntityId
        left join [tblEMEntityLocation] e  
            on ( ysnDefaultLocation = 1 )AND a.intEntityId = e.intEntityId
        left join [tblEMEntityToContact] f  
            on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
        left join tblEMEntity g  
            on f.intEntityContactId = g.intEntityId
		left join tblEMEntityPhoneNumber h
			on h.intEntityId = g.intEntityId
