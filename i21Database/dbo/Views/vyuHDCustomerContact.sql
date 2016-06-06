CREATE VIEW [dbo].[vyuHDCustomerContact]
	AS 
		select
		  intContactId = ec.[intEntityId]
		  ,intCustomerId = c.[intEntityCustomerId]
		  ,c.strCustomerNumber
		  ,strCompanyName = e.strName
		  ,strContactName = ec.strName
		  ,ec.strEmail
		  ,ec.strTitle
		  ,strPhone = ph.strPhone
		  ,strMobile = mob.strPhone
		  ,el.strLocationName
		  ,ec.strTimezone
		  ,intConcurrencyId = 1
		  ,intTicketProductId = (select top 1 intProductId from tblARCustomerProductVersion where intCustomerId = c.[intEntityCustomerId])
		  ,intVersionId = (select top 1 intVersionId from tblARCustomerProductVersion where intCustomerId = c.[intEntityCustomerId])
		  ,ysnActive = c.ysnActive
		  ,ysnActiveContact = ec.ysnActive
		  ,ec.imgPhoto
		  ,ysnBillable = c.ysnHDBillableSupport
		  ,strEntityType = (select top 1 et.strType from tblEMEntityType et where et.intEntityId = c.[intEntityCustomerId] and et.strType in ('Customer','Prospect'))
		  ,intModuleId = (select top 1 intModuleId from tblARCustomerProductVersion where intCustomerId = c.[intEntityCustomerId])
		  ,strComapny = (select top 1 strCompany from tblARCustomerProductVersion where intCustomerId = c.[intEntityCustomerId])
		from
			tblARCustomer c
		  inner join tblEMEntityToContact etc on etc.intEntityId = c.intEntityCustomerId
		  inner join tblEMEntity ec on ec.[intEntityId] = etc.[intEntityContactId]
		  inner join tblEMEntity e on e.intEntityId = c.[intEntityCustomerId]
		  left outer join tblEMEntityLocation el on el.intEntityLocationId = etc.intEntityLocationId
		  left join tblEMEntityPhoneNumber ph 
		   on ec.intEntityId = ph.intEntityId
		  left join tblEMEntityMobileNumber mob
		   on ec.intEntityId = mob.intEntityId
