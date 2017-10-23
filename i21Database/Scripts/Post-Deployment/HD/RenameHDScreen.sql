GO
	PRINT N'Begin renaming Help Desk screen.';
GO

	declare @moduleName as nvarchar(100) = 'Help Desk';
	declare @nameSpace as nvarchar(150) = '';

	--1
	set @nameSpace = 'HelpDesk.view.CreateMultipleActivity';
	if ((select count(*) from tblSMScreen where strModule = @moduleName and strNamespace = @nameSpace) > 0)
	begin
		begin transaction;
		begin try
			update tblSMScreen set strScreenName = 'Create Multiple Tickets' where strModule = @moduleName and strNamespace = @nameSpace;
			commit transaction;
		end try
		begin catch
			rollback transaction;
		end catch
	end

	--2
	set @nameSpace = 'HelpDesk.view.JIRAIssue';
	if ((select count(*) from tblSMScreen where strModule = @moduleName and strNamespace = @nameSpace) > 0)
	begin
		begin transaction;
		begin try
			update tblSMScreen set strScreenName = 'Link JIRA Issue' where strModule = @moduleName and strNamespace = @nameSpace;
			commit transaction;
		end try
		begin catch
			rollback transaction;
		end catch
	end

	--3
	set @nameSpace = 'HelpDesk.view.JiraCreateIssue';
	if ((select count(*) from tblSMScreen where strModule = @moduleName and strNamespace = @nameSpace) > 0)
	begin
		begin transaction;
		begin try
			update tblSMScreen set strScreenName = 'Create JIRA Issue' where strModule = @moduleName and strNamespace = @nameSpace;
			commit transaction;
		end try
		begin catch
			rollback transaction;
		end catch
	end

	--4
	set @nameSpace = 'HelpDesk.view.MentionDetails';
	if ((select count(*) from tblSMScreen where strModule = @moduleName and strNamespace = @nameSpace) > 0)
	begin
		begin transaction;
		begin try
			update tblSMScreen set strScreenName = 'User Details' where strModule = @moduleName and strNamespace = @nameSpace;
			commit transaction;
		end try
		begin catch
			rollback transaction;
		end catch
	end

	--5
	set @nameSpace = 'HelpDesk.view.PrintReportSelection';
	if ((select count(*) from tblSMScreen where strModule = @moduleName and strNamespace = @nameSpace) > 0)
	begin
		begin transaction;
		begin try
			update tblSMScreen set strScreenName = 'Report Selection' where strModule = @moduleName and strNamespace = @nameSpace;
			commit transaction;
		end try
		begin catch
			rollback transaction;
		end catch
	end

GO
	PRINT N'End renaming Help Desk screen.';
GO