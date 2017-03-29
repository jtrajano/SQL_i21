CREATE VIEW [dbo].[vyuHDCustomerContact]
	AS 
		select
		  intContactId = ec.[intEntityId]
		  ,intCustomerId = c.[intEntityId]
		  ,c.strCustomerNumber
		  ,strCompanyName = e.strName
		  ,strContactName = ec.strName
		  ,ec.strEmail
		  ,ec.strTitle
		  ,strPhone = ph.strPhone
		  ,strMobile = mob.strPhone
		  ,el.strLocationName
		  ,elc.strTimezone
		  ,intConcurrencyId = 1
		  ,intTicketProductId = (select top 1 intProductId from tblARCustomerProductVersion where intCustomerId = c.[intEntityId])
		  ,intVersionId = (select top 1 intVersionId from tblARCustomerProductVersion where intCustomerId = c.[intEntityId])
		  ,ysnActive = c.ysnActive
		  ,ysnActiveContact = ec.ysnActive
		  ,ec.imgPhoto
		  ,ysnBillable = c.ysnHDBillableSupport
		  ,strEntityType = (select top 1 et.strType from tblEMEntityType et where et.intEntityId = c.[intEntityId] and et.strType in ('Customer','Prospect'))
		  ,intModuleId = (select top 1 intModuleId from tblARCustomerProductVersion where intCustomerId = c.[intEntityId])
		  ,strComapny = (select top 1 strCompany from tblARCustomerProductVersion where intCustomerId = c.[intEntityId])
		from
			tblARCustomer c
		  inner join tblEMEntityToContact etc on etc.intEntityId = c.[intEntityId]
		  inner join tblEMEntity ec on ec.[intEntityId] = etc.[intEntityContactId]
		  inner join tblEMEntity e on e.intEntityId = c.[intEntityId]
		  left outer join tblEMEntityLocation el on el.intEntityLocationId = etc.intEntityLocationId
		  left outer join tblEMEntityToContact etcc on etcc.intEntityContactId = etc.intEntityContactId
		  left outer join tblEMEntityLocation elc on elc.intEntityLocationId = etcc.intEntityLocationId
		  left join tblEMEntityPhoneNumber ph 
		   on ec.intEntityId = ph.intEntityId
		  left join tblEMEntityMobileNumber mob
		   on ec.intEntityId = mob.intEntityId
