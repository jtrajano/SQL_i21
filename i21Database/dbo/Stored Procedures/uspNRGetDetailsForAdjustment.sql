CREATE PROCEDURE [dbo].[uspNRGetDetailsForAdjustment]
@intNoteId int
AS
BEGIN
	DECLARE @IntSum Decimal(18,5)  
	DECLARE @AmtAppInt decimal(18,5)      
	DECLARE @InterestAdjustment Decimal(18,2)  
 
	SELECT TOP 1 dtmNoteTranDate FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId AND intNoteTransTypeId = 3 ORDER BY intNoteTransId DESC
	
	SELECT @IntSum = SUM(dblInterestToDate) FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId  
   
	SELECT @AmtAppInt=SUM(dblAmtAppToInterest) FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId   AND intNoteTransTypeId = 4  
    
	SELECT TOP 1 intNoteTransId, dblPrincipal, dblPayOffBalance, (ISNULL(@IntSum,0) + ISNULL(@InterestAdjustment,0)---ISNULL (@AmtAppInt,0)  
	) as 'dblInterestSum' ,ISNULL (@AmtAppInt,0)AS 'dblAmtAppInt',dblUnpaidInterest  
	FROM dbo.tblNRNoteTransaction WHERE intNoteId= @intNoteId Order By intNoteTransId DESC      
	
	Select dtmCreated from dbo.tblNRNote Where intNoteId = @intNoteId
	
END
