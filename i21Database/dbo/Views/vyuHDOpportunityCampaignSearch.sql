CREATE VIEW [dbo].[vyuHDOpportunityCampaignSearch]
	AS
	select
		tblHDOpportunityCampaign.*
		,tblEMEntity.strName
		,[tblSMLineOfBusiness].strLineOfBusiness
		,tblHDTicketType.strType
		,tblHDCampainStatus.strStatus
	from
		tblHDOpportunityCampaign
		left outer join tblEMEntity on tblEMEntity.intEntityId = tblHDOpportunityCampaign.intEntityId
		left outer join [tblSMLineOfBusiness] on [tblSMLineOfBusiness].intLineOfBusinessId = tblHDOpportunityCampaign.intLineOfBusinessId
		left outer join tblHDTicketType on tblHDTicketType.intTicketTypeId = tblHDOpportunityCampaign.intTicketTypeId
		left outer join tblHDCampainStatus on tblHDCampainStatus.intCampaignStatusId = tblHDOpportunityCampaign.intCampaignStatusId
