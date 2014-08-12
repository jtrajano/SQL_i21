CREATE VIEW [dbo].[vyuHDCustomerContact]
	AS 
	SELECT 1 as a
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