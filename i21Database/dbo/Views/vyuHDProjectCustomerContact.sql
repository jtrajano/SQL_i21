CREATE VIEW [dbo].[vyuHDProjectCustomerContact]
	AS
		select
			tblARCustomer.intEntityCustomerId
			,tblARCustomer.strCustomerNumber
			,tblEntity.intEntityId
			,tblEntity.strName
			,tblEntity.strTitle
			,tblEntity.strEmail
			,tblEntityLocation.intEntityLocationId
			,tblEntityLocation.strLocationName
			,tblEntity.ysnActive
			,strEntityType = (select top 1 et.strType from tblEntityType et where et.intEntityId = tblARCustomer.intEntityCustomerId and et.strType in ('Customer','Prospect'))
		from tblARCustomer
			,tblEntityToContact
			,tblEntity
			,tblEntityLocation
		where
			tblEntityToContact.intEntityId = tblARCustomer.intEntityCustomerId
			and tblEntity.intEntityId = tblEntityToContact.intEntityContactId
			and tblEntityLocation.intEntityLocationId = tblEntityToContact.intEntityLocationId
