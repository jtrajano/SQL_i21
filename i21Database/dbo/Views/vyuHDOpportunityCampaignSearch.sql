CREATE VIEW [dbo].[vyuHDOpportunityCampaignSearch]
	AS
	select
		tblHDOpportunityCampaign.*
		,tblEMEntity.strName
		,tblHDLineOfBusiness.strLineOfBusiness
	from
		tblHDOpportunityCampaign
		,tblEMEntity
		,tblHDLineOfBusiness
	where
		tblEMEntity.intEntityId = tblHDOpportunityCampaign.intEntityId
		and tblHDLineOfBusiness.intLineOfBusinessId = tblHDOpportunityCampaign.intLineOfBusinessId
