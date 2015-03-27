CREATE TABLE [dbo].[tblHDTicket]
(
	[intTicketId] [int] IDENTITY(1,1) NOT NULL,
	[strTicketNumber] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSubject] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCustomerNumber] [nvarchar](15) COLLATE Latin1_General_CI_AS NULL,
	[intCustomerContactId] [int] NULL,
	[intCustomerId] [int] NULL,
	[intMilestoneId] [int] NULL,
	[intTicketTypeId] [int] NOT NULL,
	[intTicketStatusId] [int] NOT NULL,
	[intTicketPriorityId] [int] NOT NULL,
	[intTicketProductId] [int] NULL,
	[intModuleId] [int] NULL,
	[intVersionId] [int] NULL,
	[intAssignedTo] [int] NULL,
	[intAssignedToEntity] [int] NULL,
	[intCreatedUserId] [int] NULL,
	[intCreatedUserEntityId] [int] NULL,
	[dtmCreated] [datetime] NULL,
	[intLastModifiedUserId] [int] NULL,
	[intLastModifiedUserEntityId] [int] NULL,
	[dtmLastModified] [datetime] NULL,
	[dblQuotedHours] [numeric](18, 6) NULL,
	[dblActualHours] [numeric](18, 6) NULL,
	[strJiraKey] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicket] PRIMARY KEY CLUSTERED ([intTicketId] ASC),
	CONSTRAINT [UNQ_tblHDTicketNumber] UNIQUE ([strTicketNumber]),
	--CONSTRAINT [UNQ_tblHDTicket] UNIQUE ([strSubject],[intCreatedUserId]),
	CONSTRAINT [FK_Ticket_Milestone] FOREIGN KEY ([intMilestoneId]) REFERENCES [dbo].[tblHDMilestone] ([intMilestoneId]),
    CONSTRAINT [FK_Ticket_TicketType] FOREIGN KEY ([intTicketTypeId]) REFERENCES [dbo].[tblHDTicketType] ([intTicketTypeId]),
    CONSTRAINT [FK_Ticket_TicketStatus] FOREIGN KEY ([intTicketStatusId]) REFERENCES [dbo].[tblHDTicketStatus] ([intTicketStatusId]),
    CONSTRAINT [FK_Ticket_TicketPriority] FOREIGN KEY ([intTicketPriorityId]) REFERENCES [dbo].[tblHDTicketPriority] ([intTicketPriorityId]),
    CONSTRAINT [FK_Ticket_TicketProduct] FOREIGN KEY ([intTicketProductId]) REFERENCES [dbo].[tblHDTicketProduct] ([intTicketProductId]),
    CONSTRAINT [FK_Ticket_Module] FOREIGN KEY ([intModuleId]) REFERENCES [dbo].[tblHDModule] ([intModuleId]),
    CONSTRAINT [FK_Ticket_Version] FOREIGN KEY ([intVersionId]) REFERENCES [dbo].[tblHDVersion] ([intVersionId]),
    CONSTRAINT [FK_Ticket_Customer] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Number (Unique)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'strTicketNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Subject',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'strSubject'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'strCustomerNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Contact Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerContactId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTicketTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Status Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTicketStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Priority Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTicketPriorityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Product Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTicketProductId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Module Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intModuleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Version Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intVersionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assigned To (User Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intAssignedTo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assigned To (Entity Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intAssignedToEntity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Created By (User Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intCreatedUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Created By (Entity Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intCreatedUserEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Created',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'dtmCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Modified By (User Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intLastModifiedUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Modified By (Entity Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intLastModifiedUserEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Last Modified',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastModified'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO


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
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quoted Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblQuotedHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Actual Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblActualHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Milestone Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intMilestoneId'
