CREATE VIEW [dbo].[vyuHDOpportunityCampaignSearch]
	AS
	select
		[tblCRMCampaign].*
		,tblEMEntity.strName
		,[tblSMLineOfBusiness].strLineOfBusiness
		,tblHDTicketType.strType
		,[tblCRMCampainStatus].strStatus
	from
		[tblCRMCampaign]
		left outer join tblEMEntity on tblEMEntity.intEntityId = [tblCRMCampaign].intEntityId
		left outer join [tblSMLineOfBusiness] on [tblSMLineOfBusiness].intLineOfBusinessId = [tblCRMCampaign].intLineOfBusinessId
		left outer join tblHDTicketType on tblHDTicketType.intTicketTypeId = [tblCRMCampaign].[intTypeId]
		left outer join [tblCRMCampainStatus] on [tblCRMCampainStatus].intCampaignStatusId = [tblCRMCampaign].intCampaignStatusId
