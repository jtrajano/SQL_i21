CREATE VIEW [dbo].[vyuHDCustomerContactList]
	AS
		select
			  c.strCustomerNumber
			  ,strCompanyName = e.strName
			  ,strContactName = ec.strName
			  ,ec.strEmail
			  ,ec.strTitle
			  ,strPhone = ph.strPhone
			  ,el.strLocationName
			  ,el.strTimezone
			  ,intContactId = ec.[intEntityId]
			  ,intCustomerId = c.[intEntityId]
			  ,ysnActiveContact = ec.ysnActive
			  ,strMobile = ''
			  ,intConcurrencyId = 1
			  ,intTicketProductId = null
			  ,intVersionId = null
			  ,ysnActive = convert(bit, 1)
			  ,imgPhoto = null
			  ,ysnBillable = convert(bit, 0)
			  ,strEntityType = null
			  ,intModuleId = null
			  ,strComapny = null
			from
			  tblARCustomer c
			  inner join tblEMEntity e on e.intEntityId = c.[intEntityId]
			  inner join tblEMEntityToContact etc on etc.intEntityId = c.[intEntityId]
			  inner join tblEMEntity ec on ec.[intEntityId] = etc.[intEntityContactId]
			  left join tblEMEntityPhoneNumber ph on ec.intEntityId = ph.intEntityId
			  inner join tblEMEntityToContact etcc on etcc.intEntityContactId = ec.intEntityId
			  left join tblEMEntityLocation el on el.intEntityLocationId = etcc.intEntityLocationId
