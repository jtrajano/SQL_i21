CREATE VIEW [dbo].[vyuHDCustomerContact]
	AS 
	select
		intContactId = ec.intEntityId
		,c.strCustomerNumber
		,strCompanyName = e.strName
		,strContactName = eec.strName
		,eec.strEmail
		,ec.strTitle
		,ec.strPhone
		,ec.strMobile
		,el.strLocationName
		,ec.strTimezone
		,intConcurrencyId = 1
		,intTicketProductId = (select top 1 intProductId from tblARCustomerProductVersion where intCustomerId = c.intCustomerId)
		,intVersionId = (select top 1 intVersionId from tblARCustomerProductVersion where intCustomerId = c.intCustomerId)
		,ysnActive = c.ysnActive
	  from
		tblEntityContact ec
		inner join tblARCustomerToContact etc on etc.intContactId = ec.intContactId
		inner join tblARCustomer c on c.intCustomerId = etc.intCustomerId
		inner join tblEntity e on e.intEntityId = c.intEntityId
		inner join tblEntity eec on eec.intEntityId = ec.intEntityId
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