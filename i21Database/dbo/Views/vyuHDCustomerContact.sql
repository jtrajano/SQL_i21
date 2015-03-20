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
	  from
		--tblEntityContact ec
		tblEntity ec
		inner join tblARCustomerToContact etc on etc.[intEntityContactId] = ec.[intEntityId]
		--inner join tblARCustomerToContact etc on etc.[intEntityContactId] = ec.[intEntityContactId]
		inner join tblARCustomer c on c.[intEntityCustomerId] = etc.[intEntityCustomerId]
		inner join tblEntity e on e.intEntityId = c.[intEntityCustomerId]
		--inner join tblEntity eec on eec.intEntityId = ec.[intEntityContactId]
		left outer join tblEntityLocation el on el.intEntityLocationId = etc.intEntityLocationId
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
	--	tblEntityContact ec
	--	inner join tblEntityToContact etc on etc.intContactId = ec.intEntityId
	--	inner join tblARCustomer c on c.intEntityId = etc.intEntityId
	--	inner join tblEntity e on e.intEntityId = c.intEntityId
	--	inner join tblEntity eec on eec.intEntityId = ec.intEntityId
	--	left outer join tblEntityLocation el on el.intEntityLocationId = etc.intLocationId