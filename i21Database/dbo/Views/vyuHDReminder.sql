CREATE VIEW [dbo].[vyuHDReminder]
	AS
	select
		t.strTicketNumber
		,strTicketSubject = t.strSubject
		,e.strName
		,r.dtmDate
		,r.intRemindAdvance
		,dtmDateTo = DATEADD(MINUTE, r.intRemindAdvance, r.dtmDate)
		,r.strSubject
		,r.intReminderId
		,r.intEntityId
	from
		tblHDReminder r
		inner join tblHDTicket t on t.intTicketId = r.intTicketId
		inner join tblEMEntity e on e.intEntityId = t.intCustomerId
	where
		r.ysnActive = 1
