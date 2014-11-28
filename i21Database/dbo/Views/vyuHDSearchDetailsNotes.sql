CREATE VIEW [dbo].[vyuHDSearchDetailsNotes]
	AS
	select
		t.intTicketId
		,tn.intTicketNoteId
		,t.strTicketNumber
		,t.strCustomerNumber
		,strNote = '<p>'+tn.strNote+'</p>'
	from
		tblHDTicket t
		inner join tblHDTicketNote tn on tn.intTicketId = t.intTicketId
