CREATE VIEW [dbo].[vyuCRMActivitySearch2]
	AS
		select
			a.intActivityId
			,a.strType
			,a.strActivityNo
			,a.dtmCreated
			,a.strSubject
			,a.dtmStartDate
			,strContactName = c.strName
			,strEntityName = b.strName
			,strRelatedTo = e.strScreenName
			,strRecordNo = d.intRecordId
			,strCreatedBy = f.strName
			,strAssignedTo = g.strName
			,a.strStatus
			,a.strPriority
			,a.strCategory
			,intEntityId = a.intEntityId
			,intEntityContactId = a.intEntityContactId
			,a.intAssignedTo
			,a.ysnPrivate
			,a.intCreatedBy
			,intAttachment = (	SELECT		CONVERT(int, COUNT(b.intAttachmentId)) 
								FROM		tblSMAttachment AS b
								INNER JOIN	tblSMTransaction AS c
								ON			b.intTransactionId = c.intTransactionId
								INNER JOIN	tblSMScreen AS d
								ON			c.intScreenId = d.intScreenId
								WHERE		d.strNamespace = 'SystemManager.view.Activity' 
										AND CONVERT(int, c.intRecordId) = a.intActivityId)
			,a.strDetails
		from tblSMActivity a
			left join tblEMEntity b on b.intEntityId = a.intEntityId
			left join tblEMEntity c on c.intEntityId = a.intEntityContactId
			left join tblSMTransaction d on d.intTransactionId = a.intTransactionId
			left join tblSMScreen e on e.intScreenId = d.intScreenId-- and e.strNamespace = 'CRM.view.Opportunity' and e.strScreenName = 'Opportunity'
			left join tblEMEntity f on f.intEntityId = a.intCreatedBy
			left join tblEMEntity g on g.intEntityId = a.intAssignedTo
