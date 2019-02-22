print N'BEGIN Syncing Starting Number and Dispatch Id'

declare @currentStartingNumber int;
declare @lastDispatchId int;

set @lastDispatchId = (select max(intDispatchID) from tblTMDispatch);
set @currentStartingNumber = (select intNumber from tblSMStartingNumber where strModule = 'Tank Management' and strTransactionType = 'Will Call');

if (@lastDispatchId >= @currentStartingNumber)
begin
	set @lastDispatchId = (@lastDispatchId+1);
	update tblSMStartingNumber set intNumber = @lastDispatchId where strModule = 'Tank Management' and strTransactionType = 'Will Call';
end
else
begin
	set @currentStartingNumber = (@currentStartingNumber-1);
	DBCC CHECKIDENT ('[tblSMStartingNumber]', RESEED, @currentStartingNumber);
end

GO
print N'END Syncing Starting Number and Dispatch Id'
GO