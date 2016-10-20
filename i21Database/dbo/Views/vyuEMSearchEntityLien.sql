CREATE VIEW [dbo].[vyuEMSearchEntityLien]
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
		strType = 'Lien'
    FROM         
            tblEMEntity a
        join vyuEMEntityType b
            on b.intEntityId = a.intEntityId and b.Lien = 1
        left join [tblEMEntityLocation] e  
            on ( ysnDefaultLocation = 1 )AND a.intEntityId = e.intEntityId
        left join [tblEMEntityToContact] f  
            on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
        left join tblEMEntity g  
            on f.intEntityContactId = g.intEntityId
		left join tblEMEntityPhoneNumber h
			on h.intEntityId = g.intEntityId
