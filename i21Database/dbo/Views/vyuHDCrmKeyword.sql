CREATE VIEW [dbo].[vyuHDCrmKeyword]
	AS
	select
		intId = ROW_NUMBER() over(order by intEntityId)
		,intEntityId
		,strKeyword
		,strDescription
		,strCurrentValue
		,imgCurrentValue
		,ysnActive = (case when ysnActive is null then convert(bit,0) else ysnActive end)
	from (
		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Sales Person}'
			,strDescription = 'Sales Person Name'
			,strCurrentValue = tblEMEntity.strName
			,imgCurrentValue = null
			,ysnActive = (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end)
		from
			tblEMEntity
			left outer join tblARSalesperson on tblARSalesperson.intEntitySalespersonId = tblEMEntity.intEntityId

		union all

		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Company}'
			,strDescription = 'Sales Person Company'
			,strCurrentValue = (select top 1 tblSMCompanySetup.strCompanyName from tblSMCompanySetup)
			,imgCurrentValue = null
			,ysnActive = (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end)
		from
			tblEMEntity
			left outer join tblARSalesperson on tblARSalesperson.intEntitySalespersonId = tblEMEntity.intEntityId

		union all

		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Enterprise Software Simplified}'
			,strDescription = 'Enterprise Software Simplified'
			,strCurrentValue = 'Enterprise Software Simplified'
			,imgCurrentValue = null
			,ysnActive = (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end)
		from
			tblEMEntity
			left outer join tblARSalesperson on tblARSalesperson.intEntitySalespersonId = tblEMEntity.intEntityId

		union all

		select
			intEntityId = a.intEntityId
			,strKeyword = '{Phone}'
			,strDescription = 'Sales Person Phone Number'
			,strCurrentValue = b.strPhone
			,imgCurrentValue = null
			,ysnActive = (select (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end) from tblARSalesperson where tblARSalesperson.intEntitySalespersonId = (select top 1 [tblEMEntityToContact].intEntityId from [tblEMEntityToContact] where [tblEMEntityToContact].intEntityContactId = a.intEntityId))
		from
			tblEMEntity a
			left join tblEMEntityPhoneNumber b on b.intEntityId = a.intEntityId

		union all

		select
			intEntityId = a.intEntityId
			,strKeyword = '{Mobile}'
			,strDescription = 'Sales Person Mobile Number'
			,strCurrentValue = b.strPhone
			,imgCurrentValue = null
			,ysnActive = (select (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end) from tblARSalesperson where tblARSalesperson.intEntitySalespersonId = (select top 1 [tblEMEntityToContact].intEntityId from [tblEMEntityToContact] where [tblEMEntityToContact].intEntityContactId = a.intEntityId))
		from
			tblEMEntity a
			left join tblEMEntityMobileNumber b on b.intEntityId = a.intEntityId

		union all

		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Email}'
			,strDescription = 'Sales Person Email Address'
			,strCurrentValue = tblEMEntity.strEmail
			,imgCurrentValue = null
			,ysnActive = (select (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end) from tblARSalesperson where tblARSalesperson.intEntitySalespersonId = (select top 1 [tblEMEntityToContact].intEntityId from [tblEMEntityToContact] where [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId))
		from
			tblEMEntity where tblEMEntity.intEntityId in (select intEntityContactId from tblEMEntityToContact)

		union all

		select
			intEntityId = a.intEntityId
			,strKeyword = '{Email}'
			,strDescription = 'Sales Person Email Address'
			,strCurrentValue = c.strEmail
			,imgCurrentValue = null
			,ysnActive = (select (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end) from tblARSalesperson where tblARSalesperson.intEntitySalespersonId = (select top 1 [tblEMEntityToContact].intEntityId from [tblEMEntityToContact] where [tblEMEntityToContact].intEntityContactId = a.intEntityId))
		from
			tblEMEntity a, tblEMEntityToContact b, tblEMEntity c
		where b.intEntityId = a.intEntityId and c.intEntityId = b.intEntityContactId

		union all

		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Logo}'
			,strDescription = 'Company Logo'
			,strCurrentValue = ''
			,imgCurrentValue = (select top 1 tblSMCompanySetup.imgCompanyLogo from tblSMCompanySetup)
			,ysnActive = (select (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end) from tblARSalesperson where tblARSalesperson.intEntitySalespersonId = (select top 1 [tblEMEntityToContact].intEntityId from [tblEMEntityToContact] where [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId))
		from
			tblEMEntity

		union all

		select
			intEntityId = tblEMEntity.intEntityId 
			,strKeyword = '{Address}'
			,strDescription = 'Sales Person Company Address'
			,strCurrentValue = (select top 1 tblSMCompanySetup.strAddress + '<br>' + tblSMCompanySetup.strCity + ', ' + tblSMCompanySetup.strState + ' ' + tblSMCompanySetup.strZip from tblSMCompanySetup)
			,imgCurrentValue = null
			,ysnActive = (select (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end) from tblARSalesperson where tblARSalesperson.intEntitySalespersonId = (select top 1 [tblEMEntityToContact].intEntityId from [tblEMEntityToContact] where [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId))
		from
			tblEMEntity

		) as keyword
