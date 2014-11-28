CREATE VIEW [dbo].[vyuHDSearchDetailsDetails]
	AS
	select
		t.intTicketId
		,tc.intTicketCommentId
		,t.strTicketNumber
		,t.strCustomerNumber
		,strComment = (case
					   when tc.ysnEncoded = 1
					   then dbo.fnHDDecodeComment(SUBSTRING(tc.strComment,4,len(tc.strComment)-3)) 
					   else tc.strComment
					   end)
	from
		tblHDTicket t
		inner join tblHDTicketComment tc on tc.intTicketId = t.intTicketId and tc.ysnSent = 1
