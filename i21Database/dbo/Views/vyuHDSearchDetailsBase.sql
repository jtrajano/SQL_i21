CREATE VIEW [dbo].[vyuHDSearchDetailsBase]
	AS 
		select
		intId = ROW_NUMBER() over (order by t.intTicketId)
		,intTicketId = t.intTicketId
		,strTicketNumber = t.strTicketNumber
		,strCustomerNumber = t.strCustomerNumber
		,strDetails = tc.strComment
		,strNotes = tn.strNote
	from
		tblHDTicket t
		left outer join tblHDTicketComment tc on tc.intTicketId = t.intTicketId
		left outer join tblHDTicketNote tn on tn.intTicketId = t.intTicketId
