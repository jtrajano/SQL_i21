CREATE VIEW [dbo].[vyuHDCrmKeyword]
	AS
	select
		intId = ROW_NUMBER() over(order by intEntityId)
		,intEntityId
		,strKeyword
		,strDescription
		,strCurrentValue
		,ysnActive
	from (
		select
			intEntityId = tblEntity.intEntityId
			,strKeyword = '{Sales Person}'
			,strDescription = 'Sales Person Name'
			,strCurrentValue = tblEntity.strName
			,ysnActive = (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end)
		from
			tblEntity
			left outer join tblARSalesperson on tblARSalesperson.intEntitySalespersonId = tblEntity.intEntityId

		union all

		select
			intEntityId = tblEntity.intEntityId
			,strKeyword = '{Company}'
			,strDescription = 'Sales Person Company'
			,strCurrentValue = (select top 1 tblSMCompanySetup.strCompanyName from tblSMCompanySetup)
			,ysnActive = (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end)
		from
			tblEntity
			left outer join tblARSalesperson on tblARSalesperson.intEntitySalespersonId = tblEntity.intEntityId

		union all

		select
			intEntityId = tblEntity.intEntityId
			,strKeyword = '{Enterprise Software Simplified}'
			,strDescription = 'Enterprise Software Simplified'
			,strCurrentValue = 'Enterprise Software Simplified'
			,ysnActive = (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end)
		from
			tblEntity
			left outer join tblARSalesperson on tblARSalesperson.intEntitySalespersonId = tblEntity.intEntityId

		union all

		select
			intEntityId = tblEntity.intEntityId
			,strKeyword = '{Phone}'
			,strDescription = 'Sales Person Phone Number'
			,strCurrentValue = (select top 1 e.strPhone from tblEntity e where e.intEntityId in (select ec.intEntityContactId from tblEntityToContact ec where ec.intEntityId = tblEntity.intEntityId))
			,ysnActive = (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end)
		from
			tblEntity
			left outer join tblARSalesperson on tblARSalesperson.intEntitySalespersonId = tblEntity.intEntityId

		union all

		select
			intEntityId = tblEntity.intEntityId
			,strKeyword = '{Mobile}'
			,strDescription = 'Sales Person Mobile Number'
			,strCurrentValue = (select top 1 e.strMobile from tblEntity e where e.intEntityId in (select ec.intEntityContactId from tblEntityToContact ec where ec.intEntityId = tblEntity.intEntityId))
			,ysnActive = (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end)
		from
			tblEntity
			left outer join tblARSalesperson on tblARSalesperson.intEntitySalespersonId = tblEntity.intEntityId

		union all

		select
			intEntityId = tblEntity.intEntityId
			,strKeyword = '{Email}'
			,strDescription = 'Sales Person Email Address'
			,strCurrentValue = (select top 1 e.strEmail from tblEntity e where e.intEntityId in (select ec.intEntityContactId from tblEntityToContact ec where ec.intEntityId = tblEntity.intEntityId))
			,ysnActive = (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end)
		from
			tblEntity
			left outer join tblARSalesperson on tblARSalesperson.intEntitySalespersonId = tblEntity.intEntityId
			) as keyword
