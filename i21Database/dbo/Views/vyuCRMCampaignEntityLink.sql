CREATE VIEW [dbo].[vyuCRMCampaignEntityLink]
	AS
		select * from (
			select
				intEntityId = a.intEntityContactId
				,strContactName = b.strName
				,strEntityName = c.strName
				,strEntityType = (select top 1 d.strType from tblEMEntityType d where d.intEntityId = a.intEntityId)
				,strEmail = b.strEmail
				,d.intActivityId
				,strActivityType = d.strType
				,d.strActivityNo
				,intEntityEntityId = c.intEntityId
			from tblEMEntityToContact a
			join tblEMEntity b on b.intEntityId = a.intEntityContactId
			join tblEMEntity c on c.intEntityId = a.intEntityId
			left join tblSMActivity d on d.intActivityId = (select max(d.intActivityId) from tblSMActivity d where d.intEntityContactId = a.intEntityContactId)
		) as link where strEntityType is not null
