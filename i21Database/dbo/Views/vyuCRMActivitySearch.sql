CREATE VIEW [dbo].[vyuCRMActivitySearch]
	AS
		select
			strOpportunityName = a.strName
			,d.strActivityNo
			,d.strType
			,d.strSubject
			,d.strDetails
			,strCustomerName = cusE.strName
			,strContactName = conE.strName
			,d.strStatus
			,d.strPriority
			,d.strCategory
			,strAssignedTo = assE.strName
			,d.dtmCreated
			,a.intOpportunityId
			,d.intActivityId
			,d.intEntityId
			,d.intEntityContactId
			,d.intAssignedTo
			,d.ysnPrivate
			,d.intCreatedBy
		from
			tblCRMOpportunity a
			inner join tblSMTransaction b on 1=1
			inner join tblSMActivity d on d.intTransactionId = b.intTransactionId
			left join tblEMEntity conE on conE.intEntityId = d.intEntityContactId
			left join tblEMEntity cusE on cusE.intEntityId = d.intEntityId
			left join tblEMEntity assE on assE.intEntityId = d.intAssignedTo
		where
			b.intRecordId= convert(nvarchar(50), a.intOpportunityId)
			and b.intScreenId = (select top 1 c.intScreenId from tblSMScreen c where c.strModule = 'CRM' and c.strNamespace = 'CRM.view.Opportunity')
