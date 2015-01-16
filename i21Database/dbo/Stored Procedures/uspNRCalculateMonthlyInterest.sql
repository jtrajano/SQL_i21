CREATE PROCEDURE [dbo].[uspNRCalculateMonthlyInterest]
 @dtmCurrentDate DateTime  
,@intUserID int
AS  
BEGIN TRY    
 DECLARE   
  @idoc int  
 ,@ErrMsg nvarchar(max)  
 ,@intNoteId Int  
 , @intNoteTransId Int
 ,@strNoteNumber varchar(10)

   
 BEGIN TRANSACTION  
    DECLARE @InterestTable Table (intNoteId Int, dblAmount Decimal(18,2),strNoteNumber varchar(10))  
      
    --Interest to be calculated for all notes whose principal > 0  
 DECLARE curCalcInt CURSOR FOR  
 SELECT N.intNoteId FROM dbo.tblNRNote N
 JOIN dbo.tblNRNoteTransaction NH ON NH.intNoteId = N.intNoteId AND NH.intNoteTransTypeId = 2
 WHERE 
-- N.NRNOT_WR_OFF = 0  AND 
 CAST(CONVERT(nvarchar(10),@dtmCurrentDate,101)AS DateTime) >= CAST(CONVERT(nvarchar(10),NH.dtmAsOfDate,101)AS DateTime)
 AND rtrim(N.strNoteType) <> 'Scheduled Invoice'
 
 OPEN curCalcInt  
 FETCH NEXT FROM curCalcInt INTO @intNoteId 
 WHILE(@@FETCH_STATUS = 0)     
 BEGIN  
    
  DECLARE @dtmInterestCalcDate DateTime, @dtmNoteCreationDate DateTime, @dblInterestToDate Decimal(18,2), @dblIterestAmount Decimal(18,2)  
    , @dblLastPrincipal Decimal(18,2), @dblLastPayOffBal Decimal(18,2), @dtmLastAsOfDate DateTime, @intDaysDiff Int, @dblLastInterestToDate Decimal(18,2)  
  DECLARE @dblInterestAdjustment Decimal(18,2),@dblAmtAppInterest Decimal(18,2) 
  DECLARE @dtmLastTransactionDate DATETIME,@dblTotalInterestAdj DECIMAL(18,2) 
  SET @dblInterestAdjustment = 0   
    
  --Get Last Interest Calculation Date    
  SELECT TOP 1 @dtmInterestCalcDate = dtmAsOfDate FROM dbo.tblNRNoteTransaction WHERE intNoteId=@intNoteId and intNoteTransTypeId=3 ORDER BY intNoteTransId DESC  
  Select @strNoteNumber= strNoteNumber from dbo.tblNRNote WHERE intNoteId=@intNoteId
  SELECT TOP 1 @dtmLastTransactionDate = dtmAsOfDate FROM dbo.tblNRNoteTransaction WHERE intNoteId=@intNoteId Order By intNoteTransId DESC
  --If there is no last interest calculated, then Interest dblAmount(dblAmount for interest transaction) should be sum of all interest accured from dbo.tblNRNote creation date  
  -- otherwise it will be from last interest calculate date  
  IF @dtmInterestCalcDate IS NOT NULL  
  BEGIN  
   SELECT @dblIterestAmount = SUM(dblInterestToDate) FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId AND CAST(CONVERT(nvarchar(10),dtmAsOfDate,101) AS DateTime) > CAST(CONVERT(NVARCHAR(10),@dtmInterestCalcDate,101) AS DateTime)  
   SELECT @dblInterestAdjustment = SUM(dblTransAmount) FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId AND intNoteTransTypeId = 7 AND strAdjOnPrincOrInt = 'Interest' AND CAST(CONVERT(nvarchar(10),dtmAsOfDate,101) AS DateTime) > CAST(CONVERT(NVARCHAR(10),@dtmInterestCalcDate,101) AS DateTime) AND CAST(CONVERT(nvarchar(10),dtmAsOfDate,101) AS DateTime) <= CAST(CONVERT(NVARCHAR(10),@dtmCurrentDate,101) AS DateTime) 
  END  
  ELSE  
  BEGIN  
   SELECT TOP 1 @dtmNoteCreationDate = dtmNoteTranDate FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId ORDER BY intNoteTransId  
   SELECT @dblIterestAmount = SUM(dblInterestToDate) FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId AND CAST(CONVERT(nvarchar(10),dtmAsOfDate,101) AS DateTime) > CAST(CONVERT(NVARCHAR(10),@dtmNoteCreationDate,101) AS DateTime)  
   SELECT @dblInterestAdjustment = SUM(dblTransAmount) FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId AND intNoteTransTypeId = 7 AND strAdjOnPrincOrInt = 'Interest' AND CAST(CONVERT(nvarchar(10),dtmAsOfDate,101) AS DateTime) > CAST(CONVERT(NVARCHAR(10),@dtmNoteCreationDate,101) AS DateTime) AND CAST(CONVERT(nvarchar(10),dtmAsOfDate,101) AS DateTime) <= CAST(CONVERT(NVARCHAR(10),@dtmCurrentDate,101) AS DateTime)   
  END  
    
  SELECT TOP 1 @dblLastPrincipal = dblPrincipal, @dblLastPayOffBal = dblPayOffBalance, @dtmLastAsOfDate = dtmAsOfDate FROM dbo.tblNRNoteTransaction Where intNoteId = @intNoteId Order By intNoteTransId DESC  
  SELECT @dblLastInterestToDate = SUM(ISNULL(dblInterestToDate,0)) FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId  
  SELECT @dblAmtAppInterest = SUM(ISNULL(round(dblAmtAppToInterest,2),0)) FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId  AND intNoteTransTypeId = 4
   
   -- IF PRINCIPAL IS ZERO, INTEREST SHOULD NOT BE CALCULATED IF ALREADY CALCULATED IN PREVIOUS MONTH.
  IF NOT (@dblLastPrincipal =0 AND DATEPART(MM, @dtmCurrentDate) > DATEPART(MM, @dtmLastAsOfDate))
  BEGIN

		IF @dblLastPayOffBal <= 0 AND DATEPART(MM, @dtmLastAsOfDate)  = DATEPART(MM, @dtmCurrentDate)
		BEGIN
			--SET @dblInterestToDate = dbo.fnCalculateInterestToDate(@intNoteId, @dtmCurrentDate,3,'')  

			IF EXISTS (SELECT * FROM dbo.tblNRNoteTransaction WHERE intNoteId=@intNoteId and intNoteTransTypeId=3)
			SELECT TOP 1 @dtmLastAsOfDate = dtmAsOfDate FROM dbo.tblNRNoteTransaction WHERE intNoteId=@intNoteId AND intNoteTransTypeId=3 Order By intNoteTransId DESC
			ELSE
			SELECT TOP 1 @dtmLastAsOfDate = dtmAsOfDate FROM dbo.tblNRNoteTransaction WHERE intNoteId=@intNoteId --Order By intNoteTransId DESC

			SET @intDaysDiff = DATEDIFF(d,@dtmLastAsOfDate, @dtmCurrentDate)  

			--Records to be inserted for interest transaction:  
			-- dblAmount = Sum of interest accured from dbo.tblNRNote creation or last interest date;   
			-- INTERESTTODATE = Interest calculation from last transaction date till current date  
			-- PRINCIPAL = Last transaction Principal; PAYOFFBALANCE = Last transaction payoffbalance + Current Interest 
			if @dblLastPrincipal =0 AND DATEPART(MM, @dtmLastTransactionDate)  = DATEPART(MM, @dtmCurrentDate)
			BEGIN	
				SET @dblInterestToDate = dbo.fnCalculateInterestToDate(@intNoteId, @dtmCurrentDate,3,'')
				INSERT into dbo.tblNRNoteTransaction  
				SELECT   
				@intNoteId,@dtmCurrentDate,3,@intDaysDiff,ISNULL(@dblIterestAmount,0)+ isnull(@dblInterestToDate,0), @dblLastPrincipal
				, isnull(@dblInterestToDate,0), 0, 0, '', null, '', '', '', '', 0, 0, '', @dtmCurrentDate, '', '', '', '', null, @intUserID, 1
				
				SET @intNoteTransId = @@IDENTITY
				
				EXEC dbo.uspNRCreateGLJournalEntry @intNoteId, 3, @intNoteTransId, @intUserID, 0, 0, 0, ''
				
			END
			ELSE
			BEGIN
				INSERT into dbo.tblNRNoteTransaction  
				SELECT   
				@intNoteId, @dtmCurrentDate, 3, @intDaysDiff, 0, @dblLastPrincipal, 0, 0, 0, '', null, '', '', '', '', 0, 0, ''
				, @dtmCurrentDate, '', '', '', '', null, @intUserID, 1 
				 
				SET @intNoteTransId = @@IDENTITY
				
				EXEC dbo.uspNRCreateGLJournalEntry @intNoteId, 3, @intNoteTransId, @intUserID, 0, 0, 0, ''
				
			END	
			
		END
			
		ELSE IF @dblLastPayOffBal > 0
		BEGIN
			   SET @dblInterestToDate = dbo.fnCalculateInterestToDate(@intNoteId, @dtmCurrentDate,3,'')  
	  
				IF EXISTS (SELECT * FROM dbo.tblNRNoteTransaction WHERE intNoteId=@intNoteId and intNoteTransTypeId=3)
				SELECT TOP 1 @dtmLastAsOfDate = dtmAsOfDate FROM dbo.tblNRNoteTransaction WHERE intNoteId=@intNoteId AND intNoteTransTypeId=3 Order By intNoteTransId DESC
				ELSE
				SELECT TOP 1 @dtmLastAsOfDate = dtmAsOfDate FROM dbo.tblNRNoteTransaction WHERE intNoteId=@intNoteId --Order By intNoteTransId DESC

				SET @intDaysDiff = DATEDIFF(d,@dtmLastAsOfDate, @dtmCurrentDate) 
			
				--Records to be inserted for interest transaction:  
				-- dblAmount = Sum of interest accured from dbo.tblNRNote creation or last interest date;   
				-- INTERESTTODATE = Interest calculation from last transaction date till current date  
				-- PRINCIPAL = Last transaction Principal; PAYOFFBALANCE = Last transaction payoffbalance + Current Interest 
				 
				if @dblLastPrincipal =0 AND DATEPART(MM, @dtmLastTransactionDate)  = DATEPART(MM, @dtmCurrentDate)
				BEGIN				
					SELECT @dblTotalInterestAdj = SUM(dblTransAmount) FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId AND intNoteTransTypeId = 7 AND strAdjOnPrincOrInt = 'Interest'
					INSERT into dbo.tblNRNoteTransaction  
					SELECT   
					@intNoteId,@dtmCurrentDate,3, @intDaysDiff
					,ISNULL(@dblIterestAmount,0)+ isnull(@dblInterestToDate,0), @dblLastPrincipal, @dblInterestToDate
					, 0, IsNuLl(@dblLastPrincipal,0) + ISNULL(@dblInterestToDate,0) + ISNULL(@dblLastInterestToDate,0)+ ISNULL(@dblTotalInterestAdj,0)- ISNULL(@dblAmtAppInterest,0) 
					, '', null, '', '', '', '', 0, 0, '', @dtmCurrentDate, '', '', '', '', null, @intUserID, 1
					
					
				END
				ELSE
				BEGIN
					INSERT into dbo.tblNRNoteTransaction  
					SELECT   
					@intNoteId,@dtmCurrentDate,3, @intDaysDiff,ISNULL(@dblIterestAmount,0)+ isnull(@dblInterestToDate,0)
					, @dblLastPrincipal, @dblInterestToDate, 0, 
					IsNuLl(@dblLastPrincipal,0) + ISNULL(@dblInterestToDate,0) + ISNULL(@dblLastInterestToDate,0)+ ISNULL(@dblInterestAdjustment,0)- ISNULL(@dblAmtAppInterest,0) 
					, '', null, '', '', '', '', 0, 0, '', @dtmCurrentDate, '', '', '', '', null, @intUserID, 1
					
				END
				 
				SET @intNoteTransId = @@IDENTITY
				
				EXEC dbo.uspNRCreateGLJournalEntry @intNoteId, 3, @intNoteTransId, @intUserID, 0, 0, 0, ''
				
			
		END
		
	END
	
  --Commented for new requirement in payoff balance calculation  
  --INSERT into [dbo.tblNRNoteTransaction]   
  --SELECT   
  --@intNoteId,CURRENT_TIMESTAMP,3,ISNULL(@dblIterestAmount,0)+ isnull(@dblInterestToDate,0), IsNuLl(@dblLastPayOffBal,0) + ISNULL(@dblInterestToDate,0), '',CURRENT_TIMESTAMP,'','',@intDaysDiff,0,0,@dtmCurrentDate, @dblLastPrincipal, '','Test',CURRENT_TIMESTAMP,@dblInterestToDate,'','',''                      
  Fetch Next From curCalcInt Into @intNoteId        
          
 END     
   
 CLOSE curCalcInt            
 DEALLOCATE curCalcInt  
   
 SELECT * FROM @InterestTable  
 COMMIT TRANSACTION   
   
END TRY      
BEGIN CATCH         
 --IF XACT_STATE() != 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()        
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc        
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')        
END CATCH
