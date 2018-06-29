CREATE TRIGGER [dbo].[trgHDAfterDeleteProjectTask]
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