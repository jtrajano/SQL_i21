CREATE VIEW [dbo].[vyuHDProjectTickets]
	AS
		select
			t.intTicketId
			,t.intCustomerId
			,t.strCustomerNumber
			,t.intCustomerContactId
			,t.intTicketStatusId
			,t.strTicketNumber
			,t.strSubject
			,strCustomerName = ''--cusEnt.strName
			,strContactName = conEnt.strName
			,strModule = m.strModule
			,strAssignedTo = assEnt.strName
			,dtmDueDate = t.dtmCreated
			,strDueDate = CONVERT(nvarchar(10),t.dtmCreated,101)
			,ysnCompleted = Convert(bit,(case when t.intTicketStatusId = 2 then 1 else 0 end))
			,t.dblQuotedHours
			,t.dblActualHours
			,dblOverShort = (t.dblQuotedHours-t.dblActualHours)
		from
			tblHDTicket t
			/*
			left outer join tblARCustomer cus on cus.intCustomerId = t.intCustomerId
			left outer join tblEntity cusEnt on cusEnt.intEntityId = cus.intEntityId
			*/
			left outer join tblEntity conEnt on conEnt.intEntityId = t.intCustomerContactId
			left outer join tblHDModule m on m.intModuleId = t.intModuleId
			left outer join tblEntity assEnt on assEnt.intEntityId = t.intAssignedToEntity
