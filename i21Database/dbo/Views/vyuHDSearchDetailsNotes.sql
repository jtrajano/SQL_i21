CREATE VIEW [dbo].[vyuHDSearchDetailsNotes]
	AS
	select
		t.intTicketId
		,tn.intTicketNoteId
		,t.strTicketNumber
		,t.strCustomerNumber
		,strNote = '<p>'+tn.strNote+'</p>' COLLATE Latin1_General_CI_AS
		,dtmCreated = tn.dtmCreated
	from
		tblHDTicket t
		inner join tblHDTicketNote tn on tn.intTicketId = t.intTicketId
