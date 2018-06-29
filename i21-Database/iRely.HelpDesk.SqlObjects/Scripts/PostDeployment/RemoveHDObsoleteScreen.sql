GO
	PRINT N'Begin removing Help Desk obsolete screen.';
GO

	declare @moduleName as nvarchar(100) = 'Help Desk';
	declare @nameSpace as nvarchar(150) = '';

	--1
	set @nameSpace = 'HelpDesk.view.Announcement';
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
	set @nameSpace = 'HelpDesk.view.AnnouncementBoard';
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
	
	--3
	set @nameSpace = 'HelpDesk.view.AnnouncementType';
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
	
	--4
	set @nameSpace = 'HelpDesk.view.AnnouncementViewer';
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
	
	--5
	set @nameSpace = 'HelpDesk.view.Campaign';
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
	
	--6
	set @nameSpace = 'HelpDesk.view.Chid';
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
	
	--7
	set @nameSpace = 'HelpDesk.view.CrmSignatureKeyword';
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
	
	--8
	set @nameSpace = 'HelpDesk.view.EditAnnouncement';
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
	
	--9
	set @nameSpace = 'HelpDesk.view.FilterForm';
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
	
	--10
	set @nameSpace = 'HelpDesk.view.HelpDeskEmailSetup';
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
	
	--11
	set @nameSpace = 'HelpDesk.view.HelpDeskSettings';
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
	
	--12
	set @nameSpace = 'HelpDesk.view.HoursWorkedOld';
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
	
	--13
	set @nameSpace = 'HelpDesk.view.LineOfBusiness';
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
	
	--14
	/*
	set @nameSpace = 'HelpDesk.view.MentionDetails';
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
	*/
	
	--15
	set @nameSpace = 'HelpDesk.view.Reminder';
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
	
	--15
	set @nameSpace = 'HelpDesk.view.ReminderList';
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
	
	--16
	set @nameSpace = 'HelpDesk.view.ReminderListOld';
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
	
	--17
	set @nameSpace = 'HelpDesk.view.ReminderPopUp';
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
	
	--18
	set @nameSpace = 'HelpDesk.view.SLAPlan_FutureVersion';
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
	
	--19
	set @nameSpace = 'HelpDesk.view.SalesPipeStatus';
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
	
	--20
	set @nameSpace = 'HelpDesk.view.SearchDetails';
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
	
	--21
	set @nameSpace = 'HelpDesk.view.SendTestEmail';
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
	
	--22
	set @nameSpace = 'HelpDesk.view.TicketNoteOld';
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
	PRINT N'End removing Help Desk obsolete screen.';
GO