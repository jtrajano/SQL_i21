CREATE VIEW [dbo].[vyuHDSearchDetails]
	AS
	select
		t.intTicketId
		,t.strTicketNumber
		,t.strCustomerNumber
		,strComment = (case
					   when tc.ysnEncoded = 1
					   then dbo.fnHDDecodeComment(SUBSTRING(tc.strComment,4,len(tc.strComment)-3)) 
					   else tc.strComment
					   end)+'</br><hr></br>'
		,ysnComment = 1
	from
		tblHDTicket t
		inner join tblHDTicketComment tc on tc.intTicketId = t.intTicketId

	union all

	select
		t.intTicketId
		,t.strTicketNumber
		,t.strCustomerNumber
		,strNote = '<p>'+tn.strNote+'</p></br><hr></br>'
		,ysnComment = 0
	from
		tblHDTicket t
		inner join tblHDTicketNote tn on tn.intTicketId = t.intTicketId
