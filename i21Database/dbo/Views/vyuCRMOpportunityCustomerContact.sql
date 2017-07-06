﻿CREATE VIEW [dbo].[vyuCRMOpportunityCustomerContact]
	AS
		select
			tblARCustomer.intEntityCustomerId
			,tblARCustomer.strCustomerNumber
			,tblEMEntity.intEntityId
			,tblEMEntity.strName
			,tblEMEntity.strTitle
			,tblEMEntity.strEmail
			,intEntityLocationId = (select top 1 [tblEMEntityLocation].intEntityLocationId from [tblEMEntityLocation] where [tblEMEntityLocation].intEntityLocationId = [tblEMEntityToContact].intEntityLocationId)
			,strLocationName = (select top 1 [tblEMEntityLocation].strLocationName from [tblEMEntityLocation] where [tblEMEntityLocation].intEntityLocationId = [tblEMEntityToContact].intEntityLocationId)
			,tblEMEntity.ysnActive
			,strEntityType = (select top 1 et.strType from [tblEMEntityType] et where et.intEntityId = tblARCustomer.intEntityCustomerId and et.strType in ('Customer','Prospect'))
			,tblEMEntityPhoneNumber.strPhone
			,strDirectionEntityType = 'Customer'
		from tblARCustomer
			,[tblEMEntityToContact]
			,tblEMEntity
			,tblEMEntityPhoneNumber
		where
			[tblEMEntityToContact].intEntityId = tblARCustomer.intEntityCustomerId
			and tblEMEntity.intEntityId = [tblEMEntityToContact].intEntityContactId
			and tblEMEntityPhoneNumber.intEntityId = tblEMEntity.intEntityId

		union all

		select
			intEntityCustomerId = tblAPVendor.intEntityVendorId
			,strCustomerNumber = tblAPVendor.strVendorId
			,tblEMEntity.intEntityId
			,tblEMEntity.strName
			,tblEMEntity.strTitle
			,tblEMEntity.strEmail
			,intEntityLocationId = (select top 1 [tblEMEntityLocation].intEntityLocationId from [tblEMEntityLocation] where [tblEMEntityLocation].intEntityLocationId = [tblEMEntityToContact].intEntityLocationId)
			,strLocationName = (select top 1 [tblEMEntityLocation].strLocationName from [tblEMEntityLocation] where [tblEMEntityLocation].intEntityLocationId = [tblEMEntityToContact].intEntityLocationId)
			,tblEMEntity.ysnActive
			,strEntityType = (select top 1 et.strType from [tblEMEntityType] et where et.intEntityId = tblAPVendor.intEntityVendorId and et.strType in ('Vendor'))
			,tblEMEntityPhoneNumber.strPhone
			,strDirectionEntityType = 'Vendor'
		from tblAPVendor
			,[tblEMEntityToContact]
			,tblEMEntity
			,tblEMEntityPhoneNumber
		where
			[tblEMEntityToContact].intEntityId = tblAPVendor.intEntityVendorId
			and tblEMEntity.intEntityId = [tblEMEntityToContact].intEntityContactId
			and tblEMEntityPhoneNumber.intEntityId = tblEMEntity.intEntityId
