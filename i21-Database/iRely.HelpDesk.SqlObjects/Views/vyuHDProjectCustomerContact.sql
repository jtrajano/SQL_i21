CREATE VIEW [dbo].[vyuHDProjectCustomerContact]
	AS
			select
				intEntityCustomerId = b.intEntityId
				,strCustomerNumber = b.strEntityNo
				,intEntityId = d.intEntityId
				,d.strName
				,d.strTitle
				,d.strEmail
				,intEntityLocationId = e.intEntityLocationId
				,strLocationName = e.strLocationName
				,d.ysnActive
				,strEntityType = dbo.fnCRMCoalesceEntityType(b.intEntityId)
				,f.strPhone
			from
				tblEMEntity b
				left join tblEMEntityToContact c on c.intEntityId = b.intEntityId
				left join tblEMEntity d on d.intEntityId = c.intEntityContactId
				left join tblEMEntityLocation e on e.intEntityLocationId = c.intEntityLocationId
				left join tblEMEntityPhoneNumber f on f.intEntityId = d.intEntityId
			where
				b.intEntityId in (select distinct a.intEntityId from tblEMEntityType a where a.strType in ('Vendor','Customer', 'Prospect'))
	/*
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
			,strEntityType = (select top 1 et.strType from [tblEMEntityType] et where et.intEntityId = tblAPVendor.intEntityId and et.strType in ('Vendor'))
			,tblEMEntityPhoneNumber.strPhone
		from tblAPVendor
			,[tblEMEntityToContact]
			,tblEMEntity
			,tblEMEntityPhoneNumber
		where
			[tblEMEntityToContact].intEntityId = tblAPVendor.intEntityId
			and tblEMEntity.intEntityId = [tblEMEntityToContact].intEntityContactId
			and tblEMEntityPhoneNumber.intEntityId = tblEMEntity.intEntityId
			*/
