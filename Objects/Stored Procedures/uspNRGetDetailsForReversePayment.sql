CREATE PROCEDURE [dbo].[uspNRGetDetailsForReversePayment]
@intNoteId Int       
AS        
BEGIN            
    
 Declare @NoteType Nvarchar(100)
Select @NoteType = strNoteType FROM dbo.tblNRNote WHERE intNoteId = @intNoteId

IF Rtrim(@NoteType)='Scheduled Invoice'
BEGIN
	Select intNoteTransId, NT.intNoteId, strCheckNumber, strBatchNumber, strLocation, dblTransAmount, dtmNoteTranDate, intScheduleTransId from dbo.tblNRNoteTransaction NT 
	JOIN dbo.tblNRNoteSchedule NS ON NS.intNoteId = NT.intNoteId
	JOIN dbo.tblNRScheduleTransaction ST ON ST.intNoteId = ST.intNoteId 
	and CONVERT(nvarchar(10),ST.dtmPaidOn,101) = CONVERT(nvarchar(10),NT.dtmNoteTranDate,101)
	where NT.intNoteId = @intNoteId and NT.intNoteTransTypeId =4 
	and NT.strCheckNumber not in (Select strCheckNumber FRom dbo.tblNRNoteTransaction Where intNoteId = @intNoteId and intNoteTransTypeId =6)
END
ELSE	
	Select intNoteTransId, intNoteId, strCheckNumber, strBatchNumber, strLocation, dblTransAmount, dtmNoteTranDate, 0 [intScheduleTransId] from dbo.tblNRNoteTransaction 
	where intNoteId = @intNoteId	and intNoteTransTypeId =4 
	and strCheckNumber not in (Select strCheckNumber FRom dbo.tblNRNoteTransaction Where intNoteId = @intNoteId and intNoteTransTypeId =6)
  

End

