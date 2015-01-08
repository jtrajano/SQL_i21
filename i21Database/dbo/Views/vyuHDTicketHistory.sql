CREATE VIEW [dbo].[vyuHDTicketHistory]
	AS
			select
			intId = ROW_NUMBER() over (order by th.intTicketId)
			,th.intTicketId
			,th.strLabel
			,th.dtmChangeDate
			,strChangeBy = (select top 1 e.strName from tblEntity e where e.intEntityId = th.intChangeByEntityId)
			,strOldValue = (case
								when th.strField = 'intTicketTypeId' then (select top 1 t.strType from tblHDTicketType t where t.intTicketTypeId = convert(int, th.strOldValue))
								when th.strField = 'intTicketStatusId' then (select top 1 t.strStatus from tblHDTicketStatus t where t.intTicketStatusId = convert(int, th.strOldValue))
								when th.strField = 'intTicketPriorityId' then (select top 1 t.strPriority from tblHDTicketPriority t where t.intTicketPriorityId = convert(int, th.strOldValue))
								when th.strField = 'intModuleId' then (select top 1 t.strModule from tblHDModule t where t.intModuleId = convert(int, th.strOldValue))
								when th.strField = 'intAssignedToEntity' then (select top 1 t.strName from tblEntity t where t.intEntityId = convert(int, th.strOldValue))
								when th.strField = 'intCustomerContactId' then (select top 1 t.strName from tblEntity t where t.intEntityId = convert(int, th.strOldValue))
							else ''
							end)
			,strNewValue = (case
								when th.strField = 'intTicketTypeId' then (select top 1 t.strType from tblHDTicketType t where t.intTicketTypeId = convert(int, th.strNewValue))
								when th.strField = 'intTicketStatusId' then (select top 1 t.strStatus from tblHDTicketStatus t where t.intTicketStatusId = convert(int, th.strNewValue))
								when th.strField = 'intTicketPriorityId' then (select top 1 t.strPriority from tblHDTicketPriority t where t.intTicketPriorityId = convert(int, th.strNewValue))
								when th.strField = 'intModuleId' then (select top 1 t.strModule from tblHDModule t where t.intModuleId = convert(int, th.strNewValue))
								when th.strField = 'intAssignedToEntity' then (select top 1 t.strName from tblEntity t where t.intEntityId = convert(int, th.strNewValue))
								when th.strField = 'intCustomerContactId' then (select top 1 t.strName from tblEntity t where t.intEntityId = convert(int, th.strNewValue))
							else ''
							end)

		from tblHDTicketHistory th
