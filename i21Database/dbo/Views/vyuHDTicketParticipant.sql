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
			inner join vyuEMEntityContact2 b on b.intEntityContactId = a.intEntityContactId
		
			