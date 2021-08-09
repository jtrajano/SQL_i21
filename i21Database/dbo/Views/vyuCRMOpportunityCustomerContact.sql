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
			,strDirectionEntityType = 'Customer' COLLATE Latin1_General_CI_AS
		from tblARCustomer
			inner join [tblEMEntityToContact] on [tblEMEntityToContact].intEntityId = tblARCustomer.intEntityId
			inner join tblEMEntity on tblEMEntity.intEntityId = [tblEMEntityToContact].intEntityContactId
			inner join tblEMEntityPhoneNumber on tblEMEntityPhoneNumber.intEntityId = tblEMEntity.intEntityId
		
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
			,strEntityType = 'Vendor' COLLATE Latin1_General_CI_AS
			,tblEMEntityPhoneNumber.strPhone
			,strDirectionEntityType = 'Vendor' COLLATE Latin1_General_CI_AS
		from tblAPVendor
			inner join [tblEMEntityToContact] on [tblEMEntityToContact].intEntityId = tblAPVendor.intEntityId
			inner join tblEMEntity on tblEMEntity.intEntityId = [tblEMEntityToContact].intEntityContactId
			inner join tblEMEntityPhoneNumber on tblEMEntityPhoneNumber.intEntityId = tblEMEntity.intEntityId