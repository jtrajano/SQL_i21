CREATE VIEW [dbo].[vyuCRMCampaignSearch]
	AS
	select
		a.intCampaignId
		,a.strCampaignName
		,a.strDescription
		,a.intTypeId
		,a.intLineOfBusinessId
		,a.dtmStartDate
		,a.dtmEndDate
		,a.dblOpenRate
		,a.dblBaseCost
		,a.dblTotalCost
		,a.dblExpectedRevenue
		,a.dtmCreateDate
		,a.intStatusId
		,a.ysnHold
		,a.ysnActive
		,a.intEntityId
		,a.strRetrospective
		,a.strImageId
		,a.intNumberOfAttendee
		,a.strURL
		,a.intConcurrencyId
		,b.strName
		,c.strLineOfBusiness
		,d.strType
		,e.strStatus
		,strApprovalStatus = h.strStatus
	from
		tblCRMCampaign a
		left join tblEMEntity b on b.intEntityId = a.intEntityId
		left join tblSMLineOfBusiness c on c.intLineOfBusinessId = a.intLineOfBusinessId
		left join tblCRMType d on d.intTypeId = a.intTypeId
		left join tblCRMStatus e on e.intStatusId = a.intStatusId
		left join tblSMScreen f on f.strModule = 'CRM' and f.strNamespace = 'CRM.view.Campaign'
		left join tblSMTransaction g on g.intRecordId = a.intCampaignId and g.intScreenId = f.intScreenId
		left join tblSMApproval h on h.intTransactionId = g.intTransactionId
	/*
	select
		[tblCRMCampaign].*
		,tblEMEntity.strName
		,[tblSMLineOfBusiness].strLineOfBusiness
		,tblCRMType.strType
		,[tblCRMStatus].strStatus
	from
		[tblCRMCampaign]
		left outer join tblEMEntity on tblEMEntity.intEntityId = [tblCRMCampaign].intEntityId
		left outer join [tblSMLineOfBusiness] on [tblSMLineOfBusiness].intLineOfBusinessId = [tblCRMCampaign].intLineOfBusinessId
		left outer join tblCRMType on tblCRMType.intTypeId = [tblCRMCampaign].[intTypeId]
		left outer join [tblCRMStatus] on [tblCRMStatus].intStatusId = [tblCRMCampaign].intStatusId
		*/
