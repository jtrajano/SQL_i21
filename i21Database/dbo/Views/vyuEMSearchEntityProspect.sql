﻿CREATE VIEW [dbo].[vyuEMSearchEntityProspect]
	AS 
	
	
SELECT 
        a.intEntityId,   
        a.strEntityNo, 
        a.strName,  
        g.strPhone,  
        e.strAddress,  
        e.strCity,  
        e.strState,  
        e.strZipCode
    FROM         
            tblEntity a
        join tblEntityType b
            on b.intEntityId = a.intEntityId and b.strType = 'Prospect'
        join tblARCustomer c
            on c.intEntityCustomerId= a.intEntityId
        left join tblEntityLocation e  
            on ( ysnDefaultLocation = 1 )AND a.intEntityId = e.intEntityId
        left join tblEntityToContact f  
            on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
        left join tblEntity g  
            on f.intEntityContactId = g.intEntityId  
