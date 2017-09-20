CREATE VIEW [dbo].[vyuEMSearchEntitySalesEntity]
	AS


	select 
		a.intEntityId,   
        a.strEntityNo, 
        a.strName,  
        strPhone = h.strPhone,  
        e.strAddress,  
        e.strCity,  
        e.strState,  
        e.strZipCode,	
		strLineOfBusiness = j.strLineOfBusiness,
		strEntityLineOfBusinessSalesperson  = k.strName,
		--strLineOfBusiness = dbo.fnEMGetEntityLineOfBusiness(a.intEntityId),		
		--strEntityLineOfBusinessSalesperson = dbo.fnEMGetEntityLineOfBusinessSalesperson(a.intEntityId),
		strContactName = g.strName,
		strType = 
			case when Vendor = 1 then 'Vendor, ' else '' end + 
			case when Customer = 1 then 'Customer, ' else '' end +
			case when Competitor = 1 then 'Competitor, ' else '' end +
			case when [Partner] = 1 then 'Partner, ' else '' end +
			case when Prospect = 1 then 'Prospect, ' else '' end+
			case when Buyer = 1 then 'Buyer, ' else '' end,
		intTicketIdDate = (select top 1 cast(intTicketId as nvarchar) + '|^|' + CONVERT(nvarchar(24),dtmCreated,101) + '|^|' + strTicketNumber from tblHDTicket where intCustomerId = a.intEntityId order by dtmCreated DESC),
		intEntitySalespersonId = m.intEntityId,
		strEntitySalespersonName = m.strName

    FROM         
            tblEMEntity a
        join vyuEMEntityType b
            on b.intEntityId = a.intEntityId --and b.strType IN ('Buyer')
        left join [tblEMEntityLocation] e  
            on ( ysnDefaultLocation = 1 )AND a.intEntityId = e.intEntityId
        left join [tblEMEntityToContact] f  
            on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
        left join tblEMEntity g  
            on f.intEntityContactId = g.intEntityId
		left join tblEMEntityPhoneNumber h
			on h.intEntityId = g.intEntityId
		left join tblEMEntityLineOfBusiness i
			on i.intEntityId = a.intEntityId
		left join tblSMLineOfBusiness j
			on j.intLineOfBusinessId = i.intLineOfBusinessId
		left join tblEMEntity k
			on k.intEntityId = i.intEntitySalespersonId
		left join tblARCustomer l
			on l.intEntityId = a.intEntityId
		left join tblEMEntity m
			on m.intEntityId = l.intSalespersonId
	where Vendor = 1 or Customer = 1 or Competitor = 1 or [Partner] = 1 or Prospect = 1 or Buyer = 1





