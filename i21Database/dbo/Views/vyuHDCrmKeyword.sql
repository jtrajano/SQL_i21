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
			,strKeyword = '{Sales Person}' COLLATE Latin1_General_CI_AS
			,strDescription = 'Sales Person Name' COLLATE Latin1_General_CI_AS
			,strCurrentValue = tblEMEntity.strName
			,imgCurrentValue = null
			,ysnActive = (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end)
		from
			tblEMEntity
			left outer join tblARSalesperson on tblARSalesperson.[intEntityId] = tblEMEntity.intEntityId

		union all

		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Company}' COLLATE Latin1_General_CI_AS
			,strDescription = 'Sales Person Company' COLLATE Latin1_General_CI_AS
			,strCurrentValue = (select top 1 tblSMCompanySetup.strCompanyName from tblSMCompanySetup)
			,imgCurrentValue = null
			,ysnActive = (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end)
		from
			tblEMEntity
			left outer join tblARSalesperson on tblARSalesperson.[intEntityId] = tblEMEntity.intEntityId

		union all

		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Enterprise Software Simplified}' COLLATE Latin1_General_CI_AS
			,strDescription = 'Enterprise Software Simplified' COLLATE Latin1_General_CI_AS
			,strCurrentValue = 'Enterprise Software Simplified' COLLATE Latin1_General_CI_AS
			,imgCurrentValue = null
			,ysnActive = (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end)
		from
			tblEMEntity
			left outer join tblARSalesperson on tblARSalesperson.[intEntityId] = tblEMEntity.intEntityId

		union all

		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Phone}' COLLATE Latin1_General_CI_AS
			,strDescription = 'Sales Person Phone Number' COLLATE Latin1_General_CI_AS
			,strCurrentValue = tblEMEntity.strPhone
			,imgCurrentValue = null
			,ysnActive = (select (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end) from tblARSalesperson where tblARSalesperson.[intEntityId] = (select top 1 [tblEMEntityToContact].intEntityId from [tblEMEntityToContact] where [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId))
		from
			tblEMEntity

		union all

		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Mobile}' COLLATE Latin1_General_CI_AS
			,strDescription = 'Sales Person Mobile Number' COLLATE Latin1_General_CI_AS
			,strCurrentValue = tblEMEntity.strMobile
			,imgCurrentValue = null
			,ysnActive = (select (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end) from tblARSalesperson where tblARSalesperson.[intEntityId] = (select top 1 [tblEMEntityToContact].intEntityId from [tblEMEntityToContact] where [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId))
		from
			tblEMEntity

		union all

		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Email}' COLLATE Latin1_General_CI_AS
			,strDescription = 'Sales Person Email Address' COLLATE Latin1_General_CI_AS
			,strCurrentValue = tblEMEntity.strEmail
			,imgCurrentValue = null
			,ysnActive = (select (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end) from tblARSalesperson where tblARSalesperson.[intEntityId] = (select top 1 [tblEMEntityToContact].intEntityId from [tblEMEntityToContact] where [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId))
		from
			tblEMEntity

		union all

		select
			intEntityId = tblEMEntity.intEntityId
			,strKeyword = '{Logo}' COLLATE Latin1_General_CI_AS
			,strDescription = 'Company Logo' COLLATE Latin1_General_CI_AS
			,strCurrentValue = '' COLLATE Latin1_General_CI_AS
			,imgCurrentValue = (select top 1 tblSMCompanySetup.imgCompanyLogo from tblSMCompanySetup)
			,ysnActive = (select (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end) from tblARSalesperson where tblARSalesperson.[intEntityId] = (select top 1 [tblEMEntityToContact].intEntityId from [tblEMEntityToContact] where [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId))
		from
			tblEMEntity

		union all

		select
			intEntityId = tblEMEntity.intEntityId 
			,strKeyword = '{Address}' COLLATE Latin1_General_CI_AS
			,strDescription = 'Sales Person Company Address' COLLATE Latin1_General_CI_AS
			,strCurrentValue = (select top 1 tblSMCompanySetup.strAddress + '<br>' + tblSMCompanySetup.strCity + ', ' + tblSMCompanySetup.strState + ' ' + tblSMCompanySetup.strZip from tblSMCompanySetup)
			,imgCurrentValue = null
			,ysnActive = (select (case when tblARSalesperson.ysnActive is null then convert(bit, 0) else tblARSalesperson.ysnActive end) from tblARSalesperson where tblARSalesperson.[intEntityId] = (select top 1 [tblEMEntityToContact].intEntityId from [tblEMEntityToContact] where [tblEMEntityToContact].intEntityContactId = tblEMEntity.intEntityId))
		from
			tblEMEntity

		) as keyword
