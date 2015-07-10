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
		,tblHDTicket t
		,tblEntity e
	where
		t.intTicketId = r.intTicketId
		and e.intEntityId = t.intCustomerId
		and r.ysnActive = 1
