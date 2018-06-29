CREATE TRIGGER [dbo].[trgHDTicketStatus]
    ON [dbo].[tblHDTicketStatus]
    AFTER UPDATE
    AS
	declare
		@newTicketStatusId  int = 0
		,@newStatus  nvarchar(100) = null
		
	begin transaction;

		begin try			
			select
				@newTicketStatusId = i.intTicketStatusId
				,@newStatus = i.strStatus
			from inserted i;

			update tblHDProject set tblHDProject.strProjectStatus = @newStatus where tblHDProject.intTicketStatusId = @newTicketStatusId;

			update [tblCRMSalesPipeStatus] set [tblCRMSalesPipeStatus].strProjectStatus = @newStatus where [tblCRMSalesPipeStatus].intStatusId = @newTicketStatusId;
			

		end try
		begin catch
			rollback transaction;
		end catch

	commit transaction;