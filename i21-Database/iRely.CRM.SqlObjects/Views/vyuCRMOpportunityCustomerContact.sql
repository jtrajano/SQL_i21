CREATE VIEW [dbo].[vyuCRMOpportunityCustomerContact]
	AS
		select
			intEntityCustomerId = tblARCustomer.intEntityId
			,tblARCustomer.strCustomerNumber
			,tblEMEntity.intEntityId
			,tblEMEntity.strName
			,tblEMEntity.strTitle
			,tblEMEntity.strEmail
			,intEntityLocationId = (select top 1 [tblEMEntityLocation].intEntityLocationId from [tblEMEntityLocation] where [tblEMEntityLocation].intEntityLocationId = [tblEMEntityToContact].intEntityLocationId)
			,strLocationName = (select top 1 [tblEMEntityLocation].strLocationName from [tblEMEntityLocation] where [tblEMEntityLocation].intEntityLocationId = [tblEMEntityToContact].intEntityLocationId)
			,tblEMEntity.ysnActive
			,strEntityType = (select top 1 et.strType from [tblEMEntityType] et where et.intEntityId = tblARCustomer.intEntityId and et.strType in ('Customer','Prospect'))
			,tblEMEntityPhoneNumber.strPhone
			,strDirectionEntityType = 'Customer'
		from tblARCustomer
			,[tblEMEntityToContact]
			,tblEMEntity
			,tblEMEntityPhoneNumber
		where
			[tblEMEntityToContact].intEntityId = tblARCustomer.intEntityId
			and tblEMEntity.intEntityId = [tblEMEntityToContact].intEntityContactId
			and tblEMEntityPhoneNumber.intEntityId = tblEMEntity.intEntityId

		union all

		select
			intEntityCustomerId = tblAPVendor.intEntityId
			,strCustomerNumber = tblAPVendor.strVendorId
			,tblEMEntity.intEntityId
			,tblEMEntity.strName
			,tblEMEntity.strTitle
			,tblEMEntity.strEmail
			,intEntityLocationId = (select top 1 [tblEMEntityLocation].intEntityLocationId from [tblEMEntityLocation] where [tblEMEntityLocation].intEntityLocationId = [tblEMEntityToContact].intEntityLocationId)
			,strLocationName = (select top 1 [tblEMEntityLocation].strLocationName from [tblEMEntityLocation] where [tblEMEntityLocation].intEntityLocationId = [tblEMEntityToContact].intEntityLocationId)
			,tblEMEntity.ysnActive
			,strEntityType = 'Vendor'
			,tblEMEntityPhoneNumber.strPhone
			,strDirectionEntityType = 'Vendor'
		from tblAPVendor
			,[tblEMEntityToContact]
			,tblEMEntity
			,tblEMEntityPhoneNumber
		where
			[tblEMEntityToContact].intEntityId = tblAPVendor.intEntityId
			and tblEMEntity.intEntityId = [tblEMEntityToContact].intEntityContactId
			and tblEMEntityPhoneNumber.intEntityId = tblEMEntity.intEntityId
