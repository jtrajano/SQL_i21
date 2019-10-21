CREATE VIEW [dbo].[vyuHDSearchDetailsBase]
	AS 
		select
		intId = ROW_NUMBER() over (order by t.intTicketId)
		,intTicketId = t.intTicketId
		,strTicketNumber = t.strTicketNumber
		,strCustomerNumber = t.strCustomerNumber
		,strDetails = (case when tc.ysnEncoded = 1 then dbo.fnHDDecodeComment(substring(tc.strComment,4,(LEN(tc.strComment)-3))) else tc.strComment end)
		,strNotes = tn.strNote
	from
		tblHDTicket t
		left outer join tblHDTicketComment tc on tc.intTicketId = t.intTicketId
		left outer join tblHDTicketNote tn on tn.intTicketId = t.intTicketId
