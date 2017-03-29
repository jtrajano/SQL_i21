CREATE VIEW [dbo].[vyuEMSearchEntityProspect]
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
		intTicketIdDate = (select top 1 cast(intTicketId as nvarchar) + '|^|' + CONVERT(nvarchar(24),dtmCreated,101) + '|^|' + strTicketNumber from tblHDTicket where intCustomerId = a.intEntityId order by dtmCreated DESC)
    FROM         
            tblEMEntity a
        join [tblEMEntityType] b
            on b.intEntityId = a.intEntityId and b.strType IN ('Prospect', 'Customer')
        join tblARCustomer c
            on c.[intEntityId]= a.intEntityId
        left join [tblEMEntityLocation] e  
            on ( ysnDefaultLocation = 1 )AND a.intEntityId = e.intEntityId
        left join [tblEMEntityToContact] f  
            on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
        left join tblEMEntity g  
            on f.intEntityContactId = g.intEntityId

