GO
	PRINT N'Begin renaming CRM screens.';
GO

	declare @moduleName as nvarchar(100) = 'CRM';
	declare @nameSpace as nvarchar(150) = '';

	--1
	set @nameSpace = 'CRM.view.AddToCampaign';
	if ((select count(*) from tblSMScreen where replace(strModule,' ','') = @moduleName and strNamespace = @nameSpace) > 0)
	begin
		begin transaction;
		begin try
			update tblSMScreen set strScreenName = 'Campaigns' where replace(strModule,' ','') = @moduleName and strNamespace = @nameSpace;
			commit transaction;
		end try
		begin catch
			rollback transaction;
		end catch
	end

	--2
	set @nameSpace = 'CRM.view.LostRevenue';
	if ((select count(*) from tblSMScreen where replace(strModule,' ','') = @moduleName and strNamespace = @nameSpace) > 0)
	begin
		begin transaction;
		begin try
			update tblSMScreen set strScreenName = 'Lost Revenues / Missing Sales' where replace(strModule,' ','') = @moduleName and strNamespace = @nameSpace;
			commit transaction;
		end try
		begin catch
			rollback transaction;
		end catch
	end

	--3
	set @nameSpace = 'CRM.view.WinLossReason';
	if ((select count(*) from tblSMScreen where replace(strModule,' ','') = @moduleName and strNamespace = @nameSpace) > 0)
	begin
		begin transaction;
		begin try
			update tblSMScreen set strScreenName = 'Win/Loss Reasons' where replace(strModule,' ','') = @moduleName and strNamespace = @nameSpace;
			commit transaction;
		end try
		begin catch
			rollback transaction;
		end catch
	end

GO
	PRINT N'End renaming CRM screens.';
GO