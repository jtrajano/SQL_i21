CREATE VIEW [dbo].[vyuHDTicketStatusWorkflowLink]
	AS
		select
			a.*
			,strFromStatus = b.strStatus
			,strToStatus = c.strStatus
		from
			tblHDTicketStatusWorkflow a
			left join tblHDTicketStatus b on b.intTicketStatusId = a.intFromStatusId
			left join tblHDTicketStatus c on c.intTicketStatusId = a.intToStatusId
