CREATE VIEW [dbo].[vyuCRMCampaignEntityLink]
	AS
		select * from (
			select
				intEntityId = a.intEntityContactId
				,strContactName = b.strName
				,strEntityName = c.strName
				,strEntityType = (select top 1 d.strType from tblEMEntityType d where d.intEntityId = a.intEntityId)
				,strEmail = b.strEmail
			from tblEMEntityToContact a, tblEMEntity b, tblEMEntity c
			where
				b.intEntityId = a.intEntityContactId
				and c.intEntityId = a.intEntityId
		) as link where strEntityType is not null
