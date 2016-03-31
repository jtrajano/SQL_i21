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
		,ec.strPhone
		,ec.strMobile
		,el.strLocationName
		,ec.strTimezone
		,intConcurrencyId = 1
		,intTicketProductId = (select top 1 intProductId from tblARCustomerProductVersion where intCustomerId = c.[intEntityCustomerId])
		,intVersionId = (select top 1 intVersionId from tblARCustomerProductVersion where intCustomerId = c.[intEntityCustomerId])
		,ysnActive = c.ysnActive
		,ysnActiveContact = ec.ysnActive
		,ec.imgPhoto
		,ysnBillable = c.ysnHDBillableSupport
		,strEntityType = (select top 1 et.strType from [tblEMEntityType] et where et.intEntityId = c.[intEntityCustomerId] and et.strType in ('Customer','Prospect'))
	  from
	  	tblARCustomer c
		inner join [tblEMEntityToContact] etc on etc.intEntityId = c.intEntityCustomerId
		inner join tblEMEntity ec on ec.[intEntityId] = etc.[intEntityContactId]
		inner join tblEMEntity e on e.intEntityId = c.[intEntityCustomerId]
		left outer join [tblEMEntityLocation] el on el.intEntityLocationId = etc.intEntityLocationId
		/*
		--tblEMEntityContact ec
		tblARCustomerToContact etc 		
		inner join tblEMEntity ec on ec.[intEntityId] = etc.[intEntityContactId]
		--inner join tblARCustomerToContact etc on etc.[intEntityContactId] = ec.[intEntityContactId]
		inner join tblARCustomer c on c.[intEntityCustomerId] = etc.[intEntityCustomerId]
		inner join tblEMEntity e on e.intEntityId = c.[intEntityCustomerId]
		--inner join tblEMEntity eec on eec.intEntityId = ec.[intEntityContactId]
		left outer join tblEMEntityLocation el on el.intEntityLocationId = etc.intEntityLocationId
		*/
	--select
	--	intContactId = ec.intEntityId
	--	,c.strCustomerNumber
	--	,strCompanyName = e.strName
	--	,strContactName = eec.strName
	--	,eec.strEmail
	--	,ec.strTitle
	--	,ec.strPhone
	--	,ec.strMobile
	--	,el.strLocationName
	--	,ec.strTimezone
	--	,intConcurrencyId = 1
	--  from
	--	tblEMEntityContact ec
	--	inner join tblEMEntityToContact etc on etc.intContactId = ec.intEntityId
	--	inner join tblARCustomer c on c.intEntityId = etc.intEntityId
	--	inner join tblEMEntity e on e.intEntityId = c.intEntityId
	--	inner join tblEMEntity eec on eec.intEntityId = ec.intEntityId
	--	left outer join tblEMEntityLocation el on el.intEntityLocationId = etc.intLocationId
