GO
	PRINT N'Begin removing Transports obsolete screen.';
GO

	if ((select count(*) from tblSMScreen where strModule = 'Transports' and strNamespace = 'Transports.view.Quote') > 0)
	begin
		begin transaction;
		begin try
			delete from tblSMScreen where strModule = 'Transports' and strNamespace = 'Transports.view.TransportItemTaxDetail';
			commit transaction;
		end try
		begin catch
			rollback transaction;
		end catch
	end

GO
	PRINT N'End removing Transports obsolete screen.';
GO