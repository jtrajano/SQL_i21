CREATE TRIGGER [dbo].[trgHDAfterUpdateProjectTask]
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