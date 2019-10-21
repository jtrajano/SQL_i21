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
					   end)+'</br><hr></br>' COLLATE Latin1_General_CI_AS
		,ysnComment = 1
		,dtmCreated = tc.dtmCreated
	from
		tblHDTicket t
		inner join tblHDTicketComment tc on tc.intTicketId = t.intTicketId

	union all

	select
		t.intTicketId
		,t.strTicketNumber
		,t.strCustomerNumber
		,strNote = '<p>'+tn.strNote+'</p></br><hr></br>' COLLATE Latin1_General_CI_AS
		,ysnComment = 0
		,dtmCreated = tn.dtmCreated
	from
		tblHDTicket t
		inner join tblHDTicketNote tn on tn.intTicketId = t.intTicketId
