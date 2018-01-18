CREATE VIEW [dbo].[vyuEMSearchEntitySalesEntityContact]
	AS

select 
		a.intEntityId,   
        a.strEntityNo, 
        a.strName,  
		strContactName = g.strName,
		intEntityContactId,
        strPhone = h.strPhone,          
		strLineOfBusiness = dbo.fnEMGetEntityLineOfBusiness(a.intEntityId),		
		strType = 
			case when Vendor = 1 then 'Vendor, ' else '' end + 
			case when Customer = 1 then 'Customer, ' else '' end +
			case when Competitor = 1 then 'Competitor, ' else '' end +
			case when [Partner] = 1 then 'Partner, ' else '' end +
			case when Prospect = 1 then 'Prospect, ' else '' end,
		intTicketIdDate = (select top 1 cast(intTicketId as nvarchar) + '|^|' + CONVERT(nvarchar(24),dtmCreated,101) + '|^|' + strTicketNumber from tblHDTicket where intCustomerId = a.intEntityId order by dtmCreated DESC),
		
		--Contact Information
		strContactSuffix = g.strSuffix,
		strContactTitle = g.strTitle,
		strContactNickName = g.strNickName,
		strContactEmail = g.strEmail,
		strContactPhone = h.strPhone,
		strContactMobile = i.strPhone,
		--Contact Location
		strContactLocationName = j.strLocationName,
		strContactLocationAddress = j.strAddress,
		strContactLocationZip = j.strZipCode,
		strContactLocationState = j.strState,
		strContactLocationCountry = j.strCountry,
		strContactLocationCity = j.strCity,
		strContactLocationTimezone = j.strTimezone,
		strContactMethod = g.strContactMethod,
		strContactDept = g.strDepartment,
		strContactEmailDistribution = g.strEmailDistributionOption,
		strContactType = g.strContactType,
		--
		strEntityLocationName = m.strLocationName,
		strEntityLocationAddress = m.strAddress,
		strEntityLocationZip = m.strZipCode,
		strEntityLocationState = m.strState,
		strEntityLocationCountry = m.strCountry,
		strEntityLocationCity = m.strCity,


		strMobile = i.strPhone,
		f.ysnPortalAccess,
		
		strEntityAssociation = l.strName,
		strContactLineOfBusiness = dbo.fnEMGetEntityLineOfBusiness(g.intEntityId),		
		strContactAreaOfInterest = dbo.fnEMGetEntityAreaOfInterest(g.intEntityId),
		strEntityCurrentSystem = dbo.fnEMGetEntityCompetitors(a.intEntityId),
		strEntityLineOfBusinessSalesperson = dbo.fnEMGetEntityLineOfBusinessSalesperson(a.intEntityId),
		k.ysnOutOfAdvertising,
		k.dtmOutDate
    FROM         
            tblEMEntity a
        join vyuEMEntityType b
            on b.intEntityId = a.intEntityId --and b.strType IN ('Buyer')        
		
        join [tblEMEntityToContact] f  
            on f.intEntityId = a.intEntityId --and f.ysnDefaultContact = 1  
        join tblEMEntity g  
            on f.intEntityContactId = g.intEntityId and g.ysnActive = convert(bit,1)
		left join tblEMEntityPhoneNumber h
			on h.intEntityId = g.intEntityId
		left join tblEMEntityMobileNumber i
			on i.intEntityId = g.intEntityId
		left join tblEMEntityLocation j
			on f.intEntityLocationId = j.intEntityLocationId
		left join tblEMEntityCRMInformation k
			on g.intEntityId = k.intEntityId
		left join tblEMEntity l
			on k.intEntityId = l.intEntityId
		left join tblEMEntityLocation m
			on m.intEntityId = a.intEntityId and m.ysnDefaultLocation = 1

	where Vendor = 1 or Customer = 1 or Competitor = 1 or [Partner] = 1 or Prospect = 1
