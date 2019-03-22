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
		left join tblSMApproval h on h.intTransactionId = g.intTransactionId and h.ysnCurrent = convert(bit,1)
