CREATE TABLE [dbo].[tblHDProjectTask]
(
	[intProjectTaskId] [int] IDENTITY(1,1) NOT NULL,
	[intProjectId] [int] NOT NULL,
	[intTicketId] [int] NOT NULL,
	[ysnClosed] [bit] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDProjectTask] PRIMARY KEY CLUSTERED ([intProjectTaskId] ASC),
	CONSTRAINT [UNQ_Project_Ticket] UNIQUE ([intProjectId],[intTicketId]),
    CONSTRAINT [FK_ProjectTask_Project] FOREIGN KEY ([intProjectId]) REFERENCES [dbo].[tblHDProject] ([intProjectId]) on delete cascade,
    CONSTRAINT [FK_ProjectTask_Ticket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]) on delete cascade
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Project Task Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectTask',
    @level2type = N'COLUMN',
    @level2name = N'intProjectTaskId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Project Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectTask',
    @level2type = N'COLUMN',
    @level2name = N'intProjectId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectTask',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectTask',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Closed=1; Open=0;',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectTask',
    @level2type = N'COLUMN',
    @level2name = N'ysnClosed'
GO


CREATE TRIGGER [dbo].[trgAfterDeleteHDProjectTask]
    ON [dbo].[tblHDProjectTask]
    AFTER DELETE
    AS
declare
		@newProjectId  int = 0
		,@closedTicket  numeric(18,0) = 0
		,@openTicket  numeric(18,0) = 0
		,@totalTicket  int = 0
		,@percentComplete  numeric(18,0) = 0
		,@projectClosed bit = 0
		
	begin transaction;

		begin try			
			select
				@newProjectId = i.intProjectId
			from
				deleted i;
			
			set @closedTicket = (select COUNT(*) from tblHDProjectTask where ysnClosed = 1 and intProjectId = @newProjectId);
			set @openTicket = (select COUNT(*) from tblHDProjectTask where ysnClosed = 0 and intProjectId = @newProjectId);
			set @totalTicket = (@openTicket+@closedTicket);

			if (@closedTicket <> @totalTicket)
			begin
				set @percentComplete = (@closedTicket/@totalTicket)*100;
				set @projectClosed = 0;
			end
			else
			begin
				if (@totalTicket > 0)
				begin
					set @percentComplete = 100;
					set @projectClosed = 1;
				end
				else
				begin
					set @percentComplete = 0;
					set @projectClosed = 0;
				end
			end

			update tblHDProject set intPercentComplete = @percentComplete, ysnCompleted = @projectClosed where intProjectId = @newProjectId;

		end try
		begin catch
			rollback transaction;
		end catch

	commit transaction;
GO

CREATE TRIGGER [dbo].[trgAfterInsertHDProjectTask]
    ON [dbo].[tblHDProjectTask]
    AFTER INSERT
    AS
    declare
		@newProjectId  int = 0
		,@closedTicket  numeric(18,0) = 0
		,@openTicket  numeric(18,0) = 0
		,@totalTicket  int = 0
		,@percentComplete  numeric(18,0) = 0
		,@projectClosed bit = 0
		
	begin transaction;

		begin try			
			select
				@newProjectId = i.intProjectId
			from
				inserted i;
			
			set @closedTicket = (select COUNT(*) from tblHDProjectTask where ysnClosed = 1 and intProjectId = @newProjectId);
			set @openTicket = (select COUNT(*) from tblHDProjectTask where ysnClosed = 0 and intProjectId = @newProjectId);
			set @totalTicket = (@openTicket+@closedTicket);

			if (@closedTicket <> @totalTicket)
			begin
				set @percentComplete = (@closedTicket/@totalTicket)*100;
				set @projectClosed = 0;
			end
			else
			begin
				if (@totalTicket > 0)
				begin
					set @percentComplete = 100;
					set @projectClosed = 1;
				end
				else
				begin
					set @percentComplete = 0;
					set @projectClosed = 0;
				end
			end

			update tblHDProject set intPercentComplete = @percentComplete, ysnCompleted = @projectClosed where intProjectId = @newProjectId;

		end try
		begin catch
			rollback transaction;
		end catch

	commit transaction;
GO

CREATE TRIGGER [dbo].[trgAfterUpdateHDProjectTask]
    ON [dbo].[tblHDProjectTask]
    AFTER UPDATE
    AS
	declare
		@oldProjectId  int = 0
		,@oldClosedTicket  numeric(18,0) = 0
		,@oldOpenTicket  numeric(18,0) = 0
		,@oldTotalTicket  int = 0
		,@oldPercentComplete  numeric(18,0) = 0
		,@oldProjectClosed bit = 0
		
		,@newProjectId  int = 0
		,@newClosedTicket  numeric(18,0) = 0
		,@newOpenTicket  numeric(18,0) = 0
		,@newTotalTicket  int = 0
		,@newPercentComplete  numeric(18,0) = 0
		,@newProjectClosed bit = 0
		
	begin transaction;

		begin try	
			select
				@oldProjectId = d.intProjectId
			from
				deleted d;
			
			set @oldClosedTicket = (select COUNT(*) from tblHDProjectTask where ysnClosed = 1 and intProjectId = @oldProjectId);
			set @oldOpenTicket = (select COUNT(*) from tblHDProjectTask where ysnClosed = 0 and intProjectId = @oldProjectId);
			set @oldTotalTicket = (@oldOpenTicket+@oldClosedTicket);

			if (@oldClosedTicket <> @oldTotalTicket)
			begin
				set @oldPercentComplete = (@oldClosedTicket/@oldTotalTicket)*100;
				set @oldProjectClosed = 0;
			end
			else
			begin
				if (@oldTotalTicket > 0)
				begin
					set @oldPercentComplete = 100;
					set @oldProjectClosed = 1;
				end
				else
				begin
					set @oldPercentComplete = 0;
					set @oldProjectClosed = 0;
				end
			end

			update tblHDProject set intPercentComplete = @oldPercentComplete, ysnCompleted = @oldProjectClosed where intProjectId = @oldProjectId;

			
			select
				@newProjectId = i.intProjectId
			from
				inserted i;
			
			set @newClosedTicket = (select COUNT(*) from tblHDProjectTask where ysnClosed = 1 and intProjectId = @newProjectId);
			set @newOpenTicket = (select COUNT(*) from tblHDProjectTask where ysnClosed = 0 and intProjectId = @newProjectId);
			set @newTotalTicket = (@newOpenTicket+@newClosedTicket);

			if (@newClosedTicket <> @newTotalTicket)
			begin
				set @newPercentComplete = (@newClosedTicket/@newTotalTicket)*100;
				set @newProjectClosed = 0;
			end
			else
			begin
				if (@newTotalTicket > 0)
				begin
					set @newPercentComplete = 100;
					set @newProjectClosed = 1;
				end
				else
				begin
					set @newPercentComplete = 0;
					set @newProjectClosed = 0;
				end
			end

			update tblHDProject set intPercentComplete = @newPercentComplete, ysnCompleted = @newProjectClosed where intProjectId = @newProjectId;
			
		end try
		begin catch
			rollback transaction;
		end catch

	commit transaction;