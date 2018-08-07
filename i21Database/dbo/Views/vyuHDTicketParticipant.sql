CREATE VIEW [dbo].[vyuHDTicketParticipant]
	AS
		select
			a.intTicketParticipantId
			,a.intTicketId
			,a.intEntityId
			,a.intEntityContactId
			,a.ysnAddCalendarEvent
			,a.intConcurrencyId
			,strName = b.strName
			,strEmail = b.strEmail
			,strPhone = b.strPhone
			,strMobile = b.strMobile
		from
			tblHDTicketParticipant a
			,vyuEMEntityContact2 b
		where
			b.intEntityContactId = a.intEntityContactId