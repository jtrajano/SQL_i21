﻿CREATE VIEW [dbo].[vyuEMSearchEntityCompetitor]
	AS 


	SELECT 
        a.intEntityId,   
        a.strEntityNo, 
        a.strName,  
        g.strPhone,  
        e.strAddress,  
        e.strCity,  
        e.strState,  
        e.strZipCode,
		b.strType,
		strLineOfBusiness = dbo.fnEMGetEntityLineOfBusiness(a.intEntityId),
		strContactName = g.strName
    FROM         
            tblEMEntity a
        join [tblEMEntityType] b
            on b.intEntityId = a.intEntityId and b.strType IN ('Competitor')
        left join [tblEMEntityLocation] e  
            on ( ysnDefaultLocation = 1 )AND a.intEntityId = e.intEntityId
        left join [tblEMEntityToContact] f  
            on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
        left join tblEMEntity g  
            on f.intEntityContactId = g.intEntityId  
