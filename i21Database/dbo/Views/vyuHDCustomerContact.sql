CREATE VIEW [dbo].[vyuHDCustomerContact]
	AS
with arhd as
(
	select distinct z.strCompany, z.intCustomerId,z.intProductId,y.strProduct, z.intModuleId, v.strModule, vv.strJIRAProject, z.intVersionId, w.strVersionNo, t.intEntityId, t.strName, u.intTicketGroupId
	from tblARCustomerProductVersion z
	join tblHDTicketProduct y on y.intTicketProductId = z.intProductId
	join tblHDModule x on x.intModuleId = z.intModuleId
	join tblSMModule v on v.intModuleId = x.intSMModuleId
	join tblHDModule vv on vv.intSMModuleId = v.intModuleId
	join  tblHDVersion w on w.intVersionId = z.intVersionId
	left join tblHDGroupUserConfig u on u.intTicketGroupId = x.intTicketGroupId and u.ysnOwner = convert(bit,1)
	left join tblEMEntity t on t.intEntityId = u.intUserSecurityEntityId
)
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
		  ,intTicketProductId = (case when (select count(*) from tblARCustomerProductVersion where tblARCustomerProductVersion.intCustomerId = c.intEntityId) = 1 then (select top 1 arhd.intProductId from arhd where arhd.intCustomerId = c.intEntityId) else null end)
		  ,intVersionId = (case when (select count(*) from tblARCustomerProductVersion where tblARCustomerProductVersion.intCustomerId = c.intEntityId) = 1 then (select top 1 arhd.intVersionId from arhd where arhd.intCustomerId = c.intEntityId) else null end)
		  ,intModuleId = (case when (select count(*) from tblARCustomerProductVersion where tblARCustomerProductVersion.intCustomerId = c.intEntityId) = 1 then (select top 1 arhd.intModuleId from arhd where arhd.intCustomerId = c.intEntityId) else null end)
		  ,strComapny = (case when (select count(*) from tblARCustomerProductVersion where tblARCustomerProductVersion.intCustomerId = c.intEntityId) = 1 then (select top 1 arhd.strCompany from arhd where arhd.intCustomerId = c.intEntityId) else null end)
		  ,ysnActive = c.ysnActive
		  ,ysnActiveContact = ec.ysnActive
		  ,ec.imgPhoto
		  ,ysnBillable = c.ysnHDBillableSupport
		  ,strEntityType = (select top 1 et.strType from tblEMEntityType et where et.intEntityId = c.[intEntityId] and et.strType in ('Customer','Prospect'))
		  ,strProjectionProduct = (case when (select count(*) from tblARCustomerProductVersion where tblARCustomerProductVersion.intCustomerId = c.intEntityId) = 1 then (select top 1 arhd.strProduct from arhd where arhd.intCustomerId = c.intEntityId) else null end)
		  ,strProjectionVersionNo = (case when (select count(*) from tblARCustomerProductVersion where tblARCustomerProductVersion.intCustomerId = c.intEntityId) = 1 then (select top 1 arhd.strVersionNo from arhd where arhd.intCustomerId = c.intEntityId) else null end)
		  ,strProjectionModule = (case when (select count(*) from tblARCustomerProductVersion where tblARCustomerProductVersion.intCustomerId = c.intEntityId) = 1 then (select top 1 arhd.strModule from arhd where arhd.intCustomerId = c.intEntityId) else null end)
		  ,strProjectionModuleJiraProject = (case when (select count(*) from tblARCustomerProductVersion where tblARCustomerProductVersion.intCustomerId = c.intEntityId) = 1 then (select top 1 arhd.strJIRAProject from arhd where arhd.intCustomerId = c.intEntityId) else null end)
		  ,intTicketGroupId = (case when (select count(*) from tblARCustomerProductVersion where tblARCustomerProductVersion.intCustomerId = c.intEntityId) = 1 then (select top 1 arhd.intTicketGroupId from arhd where arhd.intCustomerId = c.intEntityId) else null end)
		  ,intOwnerEntityId = (case when (select count(*) from tblARCustomerProductVersion where tblARCustomerProductVersion.intCustomerId = c.intEntityId) = 1 then (select top 1 arhd.intEntityId from arhd where arhd.intCustomerId = c.intEntityId) else null end)
		  ,strOwnerEntityName = (case when (select count(*) from tblARCustomerProductVersion where tblARCustomerProductVersion.intCustomerId = c.intEntityId) = 1 then (select top 1 arhd.strName from arhd where arhd.intCustomerId = c.intEntityId) else null end)
		from
			tblARCustomer c
		  inner join tblEMEntityToContact etc on etc.intEntityId = c.[intEntityId]
		  inner join tblEMEntity ec on ec.[intEntityId] = etc.[intEntityContactId]
		  inner join tblEMEntity e on e.intEntityId = c.[intEntityId]
		  left outer join tblEMEntityLocation el on el.intEntityLocationId = etc.intEntityLocationId
		  left outer join tblEMEntityToContact etcc on etcc.intEntityContactId = etc.intEntityContactId
		  left outer join tblEMEntityLocation elc on elc.intEntityLocationId = etcc.intEntityLocationId
		  left join tblEMEntityPhoneNumber ph on ec.intEntityId = ph.intEntityId
		  left join tblEMEntityMobileNumber mob on ec.intEntityId = mob.intEntityId
		  /*
		  left join tblARCustomerProductVersion cpv on cpv.intCustomerId = c.intEntityId
		  left join tblHDModule m on m.intModuleId = cpv.intModuleId
		  left join tblHDVersion v on v.intVersionId = cpv.intVersionId
		  left join tblHDTicketProduct p on p.intTicketProductId = cpv.intProductId
		  left join tblHDGroupUserConfig gu on gu.intTicketGroupId = m.intTicketGroupId and gu.ysnOwner = convert(bit,1)
		  left join tblEMEntity ow on ow.intEntityId = gu.intUserSecurityEntityId
		  */
