CREATE VIEW [dbo].[vyuEMSearchEntityLead]
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
		strType = 'Lead'
    FROM         
            tblEMEntity a
        join vyuEMEntityType b
            on b.intEntityId = a.intEntityId and b.Lead = 1
        join tblARLead c
            on c.[intEntityId]= a.intEntityId
        left join [tblEMEntityLocation] e  
            on ( ysnDefaultLocation = 1 )AND a.intEntityId = e.intEntityId
        left join [tblEMEntityToContact] f  
            on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
        left join tblEMEntity g  
            on f.intEntityContactId = g.intEntityId
		left join tblEMEntityPhoneNumber h
			on h.intEntityId = g.intEntityId