CREATE TRIGGER [dbo].[trgHDTicketHistory]
    ON [dbo].[tblHDTicket]
    AFTER UPDATE
    AS
	declare
		@oldCustomerContactId  int = 0
		,@oldTypeId  int = 0
		,@oldStatusId  int = 0
		,@oldPriorityId  int = 0
		,@oldModuleId  int = 0
		,@oldAssignToId  int = 0
		
		,@newCustomerContactId  int = 0
		,@newTypeId  int = 0
		,@newStatusId  int = 0
		,@newPriorityId  int = 0
		,@newModuleId  int = 0
		,@newAssignToId  int = 0
		
		,@newChangeByEntityId  int = 0
		,@newTicketId  int = 0
		,@newDateModified  datetime = getDate()
		
	begin transaction;

		begin try
			select
				@oldCustomerContactId = d.intCustomerContactId
				,@oldTypeId = d.intTicketTypeId
				,@oldStatusId = d.intTicketStatusId
				,@oldPriorityId = d.intTicketPriorityId
				,@oldModuleId = d.intModuleId
				,@oldAssignToId = d.intAssignedToEntity
			from deleted d;
			
			select
				@newCustomerContactId = i.intCustomerContactId
				,@newTypeId = i.intTicketTypeId
				,@newStatusId = i.intTicketStatusId
				,@newPriorityId = i.intTicketPriorityId
				,@newModuleId = i.intModuleId
				,@newAssignToId = i.intAssignedToEntity
				,@newChangeByEntityId = i.intLastModifiedUserEntityId
				,@newTicketId = i.intTicketId
				,@newDateModified = i.dtmLastModified
			from inserted i;
			
			/*@oldCustomerContactId*/
			if (@oldCustomerContactId <> @newCustomerContactId)
			begin
				insert into tblHDTicketHistory
				(
					intTicketId
					,strField
					,strLabel
					,strOldValue
					,strNewValue
					,dtmChangeDate
					,intChangeByEntityId
					,intConcurrencyId
				)values(
					@newTicketId
					,'intCustomerContactId'
					,'Change Customer Contact'
					,convert(nvarchar(255),@oldCustomerContactId)
					,convert(nvarchar(255),@newCustomerContactId)
					,@newDateModified
					,@newChangeByEntityId
					,1
				)
			end
			
			/*@oldTypeId*/
			if (@oldTypeId <> @newTypeId)
			begin
				insert into tblHDTicketHistory
				(
					intTicketId
					,strField
					,strLabel
					,strOldValue
					,strNewValue
					,dtmChangeDate
					,intChangeByEntityId
					,intConcurrencyId
				)values(
					@newTicketId
					,'intTicketTypeId'
					,'Change Ticket Type'
					,convert(nvarchar(255),@oldTypeId)
					,convert(nvarchar(255),@newTypeId)
					,@newDateModified
					,@newChangeByEntityId
					,1
				)
			end
			
			/*@oldStatusId*/
			if (@oldStatusId <> @newStatusId)
			begin
				insert into tblHDTicketHistory
				(
					intTicketId
					,strField
					,strLabel
					,strOldValue
					,strNewValue
					,dtmChangeDate
					,intChangeByEntityId
					,intConcurrencyId
				)values(
					@newTicketId
					,'intTicketStatusId'
					,'Change Ticket Status'
					,convert(nvarchar(255),@oldStatusId)
					,convert(nvarchar(255),@newStatusId)
					,@newDateModified
					,@newChangeByEntityId
					,1
				)
			end
			
			/*@oldPriorityId*/
			if (@oldPriorityId <> @newPriorityId)
			begin
				insert into tblHDTicketHistory
				(
					intTicketId
					,strField
					,strLabel
					,strOldValue
					,strNewValue
					,dtmChangeDate
					,intChangeByEntityId
					,intConcurrencyId
				)values(
					@newTicketId
					,'intTicketPriorityId'
					,'Change Ticket Priority'
					,convert(nvarchar(255),@oldPriorityId)
					,convert(nvarchar(255),@newPriorityId)
					,@newDateModified
					,@newChangeByEntityId
					,1
				)
			end
			
			/*@oldModuleId*/
			if (@oldModuleId <> @newModuleId)
			begin
				insert into tblHDTicketHistory
				(
					intTicketId
					,strField
					,strLabel
					,strOldValue
					,strNewValue
					,dtmChangeDate
					,intChangeByEntityId
					,intConcurrencyId
				)values(
					@newTicketId
					,'intModuleId'
					,'Change Ticket Module'
					,convert(nvarchar(255),@oldModuleId)
					,convert(nvarchar(255),@newModuleId)
					,@newDateModified
					,@newChangeByEntityId
					,1
				)
			end
			
			/*@oldAssignToId*/
			if (@oldAssignToId <> @newAssignToId)
			begin
				insert into tblHDTicketHistory
				(
					intTicketId
					,strField
					,strLabel
					,strOldValue
					,strNewValue
					,dtmChangeDate
					,intChangeByEntityId
					,intConcurrencyId
				)values(
					@newTicketId
					,'intAssignedToEntity'
					,'Change Ticket Assign To'
					,convert(nvarchar(255),@oldAssignToId)
					,convert(nvarchar(255),@newAssignToId)
					,@newDateModified
					,@newChangeByEntityId
					,1
				)
			end
			

		end try
		begin catch
			rollback transaction;
		end catch

	commit transaction;
GO