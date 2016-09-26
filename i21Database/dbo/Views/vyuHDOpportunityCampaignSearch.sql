CREATE VIEW [dbo].[vyuHDOpportunityCampaignSearch]
	AS
	select
		tblHDOpportunityCampaign.*
		,tblEMEntity.strName
		,[tblSMLineOfBusiness].strLineOfBusiness
		,tblHDTicketType.strType
		,[tblCRMCampainStatus].strStatus
	from
		tblHDOpportunityCampaign
		left outer join tblEMEntity on tblEMEntity.intEntityId = tblHDOpportunityCampaign.intEntityId
		left outer join [tblSMLineOfBusiness] on [tblSMLineOfBusiness].intLineOfBusinessId = tblHDOpportunityCampaign.intLineOfBusinessId
		left outer join tblHDTicketType on tblHDTicketType.intTicketTypeId = tblHDOpportunityCampaign.intTicketTypeId
		left outer join [tblCRMCampainStatus] on [tblCRMCampainStatus].intCampaignStatusId = tblHDOpportunityCampaign.intCampaignStatusId
