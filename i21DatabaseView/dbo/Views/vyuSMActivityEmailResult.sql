CREATE VIEW vyuSMActivityEmailResult
as

	select 
		b.intActivityEmailResultId as intId,
		a.intActivityId,
		a.strSubject,
		a.strActivityNo,
		a.strDetails,
		a.strStatus,
		b.strResult,
		b.dtmTransactionDate,
		c.strName,
		d.strTransactionNo,
		e.strScreenName,
		dbo.fnSMGetEmailRecipients(a.intActivityId) strRecipients
	from tblSMActivity a
	join tblSMActivityEmailResult b 
		on a.intActivityId = b.intActivityId
	join tblSMTransaction d
		on a.intTransactionId = d.intTransactionId
	join tblSMScreen e
		on d.intScreenId = e.intScreenId
	left join tblEMEntity c
		on b.intEntityUserId = c.intEntityId
	

GO