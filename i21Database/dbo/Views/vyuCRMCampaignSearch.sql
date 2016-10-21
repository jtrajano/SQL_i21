CREATE VIEW [dbo].[vyuCRMCampaignSearch]
	AS
	select
		[tblCRMCampaign].*
		,tblEMEntity.strName
		,[tblSMLineOfBusiness].strLineOfBusiness
		,tblCRMType.strType
		,[tblCRMCampainStatus].strStatus
	from
		[tblCRMCampaign]
		left outer join tblEMEntity on tblEMEntity.intEntityId = [tblCRMCampaign].intEntityId
		left outer join [tblSMLineOfBusiness] on [tblSMLineOfBusiness].intLineOfBusinessId = [tblCRMCampaign].intLineOfBusinessId
		left outer join tblCRMType on tblCRMType.intTypeId = [tblCRMCampaign].[intTypeId]
		left outer join [tblCRMCampainStatus] on [tblCRMCampainStatus].intCampaignStatusId = [tblCRMCampaign].intStatusId
