CREATE VIEW [dbo].[vyuHDTicketCustomerContact]
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
		  ,el.strTimezone
		  ,intConcurrencyId = 1
		  ,intTicketProductId = null
		  ,intVersionId = null
		  ,intModuleId = null
		  ,strComapny = null
		  ,ysnActive = c.ysnActive
		  ,ysnActiveContact = ec.ysnActive
		  ,ec.imgPhoto
		  ,ysnBillable = c.ysnHDBillableSupport
		  ,strEntityType = (select top 1 et.strType from tblEMEntityType et where et.intEntityId = c.[intEntityId] and et.strType in ('Customer','Prospect'))
		  ,strProjectionProduct = null
		  ,strProjectionVersionNo = null
		  ,strProjectionModule = null
		  ,intTicketGroupId = null
		  ,intOwnerEntityId = null
		  ,strOwnerEntityName = null
		from
			tblARCustomer c
			inner join tblEMEntity e on e.intEntityId = c.[intEntityId]
			inner join tblEMEntityToContact etc on etc.intEntityId = c.[intEntityId]
			left join tblEMEntityLocation el on el.intEntityLocationId = etc.intEntityLocationId
			inner join tblEMEntity ec on ec.[intEntityId] = etc.[intEntityContactId]
			left join tblEMEntityPhoneNumber ph on ec.intEntityId = ph.intEntityId
			left join tblEMEntityMobileNumber mob on ec.intEntityId = mob.intEntityId
