GO
	PRINT N'Begin removing Credit Card Recon obsolete screen.';
GO

	declare @moduleName as nvarchar(100) = 'Credit Card Recon';
	declare @nameSpace as nvarchar(150) = '';

	--1
	set @nameSpace = 'CreditCardRecon.view.FileFieldMapping';
	if ((select count(*) from tblSMScreen where strModule = @moduleName and strNamespace = @nameSpace) > 0)
	begin
		begin transaction;
		begin try
			delete from tblSMScreen where strModule = @moduleName and strNamespace = @nameSpace;
			commit transaction;
		end try
		begin catch
			rollback transaction;
		end catch
	end
	
	--2
	set @nameSpace = 'CreditCardRecon.view.PreviewLayout';
	if ((select count(*) from tblSMScreen where strModule = @moduleName and strNamespace = @nameSpace) > 0)
	begin
		begin transaction;
		begin try
			delete from tblSMScreen where strModule = @moduleName and strNamespace = @nameSpace;
			commit transaction;
		end try
		begin catch
			rollback transaction;
		end catch
	end

GO
	PRINT N'End removing Credit Card Recon obsolete screen.';
GO