CREATE PROCEDURE [dbo].[uspNRCalculateInterest]
@intNoteId  int,
@dtmCurrentDate  Date,
@intTransTypeID  Int = 2,
@strCheckNumber  nvarchar(10) = ''
AS
BEGIN
	
	DECLARE @strNoteType nvarchar(50)
	Select @strNoteType = strNoteType from dbo.tblNRNote Where intNoteId = @intNoteId
	
	IF @strNoteType = 'Scheduled Invoice'
	BEGIN
		SELECT TOP 1 intNoteId
		, (Select SUM(dblInterest) FROM dbo.tblNRScheduleTransaction 
			WHERE intNoteId = @intNoteId AND dtmExpectedPayDate <= @dtmCurrentDate Group By intNoteId
			) [dblInterestToDate] 
		--, dtmExpectedPayDate [dtmPayDate],dblExpectedPayAmt [dblPayAmount]
		, dblPrincipal, dblInterest, dblBalance FROM dbo.tblNRScheduleTransaction 
		WHERE intNoteId = @intNoteId AND dtmExpectedPayDate <= @dtmCurrentDate 		
		ORDER BY intScheduleTransId DESC
	END
	ELSE 
	BEGIN
		 DECLARE @IntSum numeric(18,6)  
		 ,@AmtAppInt numeric(18,6)      
		 ,@InterestAdjustment numeric(18,6)   
		 ,@NoteCreationDate DateTime  
		 ,@InterestCalcDate DateTime
		 ,@dblUnpaidInterest numeric(18,6)   
		 , @dblInterestAcc numeric(18,6)  
		 , @dblPrincipal numeric(18,6)
		 , @dblCurrentInterest numeric(18,6)
		 , @dblInterestToDate numeric(18,6)
		 , @dblLatestInterest numeric(18,6)
		 , @dblTotalInterest numeric(18,6)
		 , @dblPayOffBalance numeric(18,6)
		  
		  
		 SELECT @InterestAdjustment = SUM(dblTransAmount) FROM dbo.tblNRNoteTransaction 
		 WHERE intNoteId = @intNoteId AND intNoteTransTypeId = 7 AND strAdjOnPrincOrInt = 'Interest'    
		 
		 SELECT @IntSum = SUM(dblInterestToDate) FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId
		   
		 select @AmtAppInt=SUM(dblAmtAppToInterest) FROM dbo.tblNRNoteTransaction 
		 WHERE intNoteId = @intNoteId   AND intNoteTransTypeId = 4  
		    
		 select @dblInterestAcc = (ISNULL(@IntSum,0) + ISNULL(@InterestAdjustment,0)---ISNULL (@AmtAppInt,0)  
		 ) , @dblUnpaidInterest = dblUnpaidInterest, @dblPrincipal = dblPrincipal  
		 from dbo.tblNRNoteTransaction where intNoteId= @intNoteId Order By intNoteTransId DESC      
		 
		DECLARE @FUTUREINTEREST numeric(18,6),@HISTORYINTEREST numeric(18,6)
		SELECT @dblCurrentInterest = dbo.fnCalculateInterestToDate(@intNoteId, @dtmCurrentDate, @intTransTypeID, @strCheckNumber)
		
		Select @dblTotalInterest = ISNULL(SUM(dblTransAmount),0) --as 'Total Interest' 
		FROM dbo.tblNRNoteTransaction a
		WHERE intNoteId = @intNoteId AND intNoteTransTypeId = 7 
		AND strAdjOnPrincOrInt = 'Interest' AND dtmAsOfDate <= @dtmCurrentDate


		--IF EXISTS (SELECT TOP 1 dtmAsOfDate FROM dbo.tblNRNoteFutureTransaction WHERE intNoteId=@intNoteId AND dtmAsOfDate <= @dtmCurrentDate)
		--	BEGIN
		--		SELECT TOP 1 dblPayOffBalance AS 'PayOff Balance' FROM dbo.tblNRNoteFutureTransaction 
		--		WHERE intNoteId=@intNoteId and dtmAsOfDate <=@dtmCurrentDate order by intNoteTransTypeId DESC
		--	END	
		--ELSE
		--	BEGIN
		--		SELECT NULL AS 'PayOff Balance' 
		--	End		

		IF EXISTS (SELECT TOP 1 dtmAsOfDate FROM dbo.tblNRNoteFutureTransaction 
					WHERE intNoteId=@intNoteId AND dtmAsOfDate <=cast(convert(varchar(10), @dtmCurrentDate, 110) as datetime))
		BEGIN
			SELECT  @FUTUREINTEREST = SUM(ISNULL(round(dblInterestToDate,2),0)) FROM dbo.tblNRNoteFutureTransaction 
			WHERE intNoteId = @intNoteId AND dtmAsOfDate <cast(convert(varchar(10), @dtmCurrentDate, 110) as datetime)
			--SELECT  SUM(ISNULL(round(NRHST_INT_DT,2),0))AS 'Latest Interest' FROM dbo.NRHPRMST WHERE NRHST_NOTE_ID = @NoteID AND NRHST_ASOF_DT <cast(convert(varchar(10), @CurrentDate, 110) as datetime)
			SELECT @HISTORYINTEREST = SUM(ISNULL(round(dblInterestToDate,2),0))  FROM dbo.tblNRNoteTransaction 
			WHERE intNoteId = @intNoteId  AND dtmAsOfDate <cast(convert(varchar(10), @dtmCurrentDate, 110) as datetime)
			
			SELECT @dblLatestInterest = ISNULL(ROUND(@FUTUREINTEREST,2),0) + ISNULL(ROUND(@HISTORYINTEREST,2),0) --AS 'Latest Interest'
		
		END
		ELSE
		BEGIN
			SELECT @dblLatestInterest = SUM(ISNULL(round(dblInterestToDate,2),0)) --AS 'Latest Interest' 
			FROM dbo.tblNRNoteTransaction 
			WHERE intNoteId = @intNoteId AND dtmAsOfDate <cast(convert(varchar(10), @dtmCurrentDate, 110) as datetime)
		END	
		
		IF @dblLatestInterest <> null
		BEGIN
			SET @dblInterestToDate = ISNULL(@dblCurrentInterest,0) + ISNULL(@dblTotalInterest,0) + ISNULL(@dblLatestInterest,0)
		END
		ELSE
		BEGIN
			IF ISNULL(@dblInterestAcc,0) = 0
			BEGIN
				SET @dblInterestToDate = ISNULL(@dblCurrentInterest,0) + ISNULL(@dblTotalInterest,0)
			END
			ELSE
			BEGIN
				SET @dblInterestToDate = ISNULL(@dblCurrentInterest,0) + ISNULL(@dblInterestAcc,0)
			END
		END
		
		SET @dblPayOffBalance = ISNULL(@dblPrincipal,0) + ISNULL(@dblUnpaidInterest,0)
		
				
		SELECT ISNULL(@intNoteId,0) [intNoteId]
		, ISNULL(@dblInterestToDate,0) as [dblInterestToDate] 
		--, dtmExpectedPayDate [dtmPayDate],dblExpectedPayAmt [dblPayAmount]
		, ISNULL(@dblPrincipal,0) [dblPrincipal]
		, ISNULL(@dblUnpaidInterest,0) [dblInterest]
		, ISNULL(@dblPayOffBalance,0) [dblBalance]
		 
	END
	
	
END
