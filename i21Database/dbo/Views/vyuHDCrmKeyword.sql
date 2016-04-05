CREATE VIEW [dbo].[vyuHDCrmKeyword]
	AS
	select
		intId = ROW_NUMBER() over(order by intEntityId)
		,intEntityId
		,strKeyword
		,strDescription
		,strCurrentValue
		,ysnActive = (case when ysnActive is null then convert(bit,0) else ysnActive end)
	from (
		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Sales Person}'
			,strDescription = 'Sales Person Name'
			,strCurrentValue = tblEMEntity.strName
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
			,ysnActive = (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end)
		from
			tblEMEntity
			left outer join tblARSalesperson on tblARSalesperson.intEntitySalespersonId = tblEMEntity.intEntityId

		union all

		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Phone}'
			,strDescription = 'Sales Person Phone Number'
			,strCurrentValue = tblEMEntity.strPhone
			,ysnActive = (select (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end) from tblARSalesperson where tblARSalesperson.intEntitySalespersonId = (select top 1 [tblEMEntityToContact].intEntityId from [tblEMEntityToContact] where [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId))
		from
			tblEMEntity

		union all

		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Mobile}'
			,strDescription = 'Sales Person Mobile Number'
			,strCurrentValue = tblEMEntity.strMobile
			,ysnActive = (select (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end) from tblARSalesperson where tblARSalesperson.intEntitySalespersonId = (select top 1 [tblEMEntityToContact].intEntityId from [tblEMEntityToContact] where [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId))
		from
			tblEMEntity

		union all

		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Email}'
			,strDescription = 'Sales Person Email Address'
			,strCurrentValue = tblEMEntity.strEmail
			,ysnActive = (select (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end) from tblARSalesperson where tblARSalesperson.intEntitySalespersonId = (select top 1 [tblEMEntityToContact].intEntityId from [tblEMEntityToContact] where [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId))
		from
			tblEMEntity
		) as keyword
