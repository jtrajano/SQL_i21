CREATE FUNCTION [dbo].[fnCalculateInterestToDate]
(
	@NoteId Integer ,@CurrentDate Datetime, @HistoryType Int, @CheckNumber Nvarchar(10) = ''
)
RETURNS Decimal(18,4)
AS
BEGIN
	
	
Declare @prvdate datetime
	,@InterestRate decimal(18,2)
	,@CalcInterest decimal(18,4)
	,@Intdatediff int
	,@PrvAsOfDate datetime
	,@PrvPrincipal Decimal(18,2)
	,@LatestAsOfDate DateTime
	,@InterestCalcDate DateTime
	,@LastHistoryTypeID Int
	,@LastHistoryID Int
	,@MaturityDate  datetime
	,@Result decimal(18,2)
	,@WriteOff_Date DateTime  
	,@INTEREST_AFTER_MATURITY int

	Select @InterestRate = dblInterestRate from dbo.tblNRNote where intNoteId=@NoteId
	SELECT @MaturityDate=dtmMaturityDate from dbo.tblNRNote where intNoteId=@NoteId
	Select @WriteOff_Date = ISNULL(dtmWriteOffDate,0) from dbo.tblNRNote WHERE intNoteId=@NoteId
	
	SELECT @INTEREST_AFTER_MATURITY = strValue FROM dbo.tblSMPreferences WHERE RTRIM(strPreference) = 'CalculateInterestAfterMaturity'
	
	  Begin
		-- Get last interest calculate date
		select top 1 @InterestCalcDate = dtmAsOfDate from dbo.tblNRNoteTransaction where intNoteId=@NoteId and intNoteTransTypeId=3 Order By intNoteTransId DESC
		
		-- Get Previous transaction As Of Date and Principal for which As of date is less than the Current Date(Passes date)
		--SELECT @PrvAsOfDate = AsOf, @PrvPrincipal = Principal, @HistoryType = HistoryTypeID FROM dbo.tblNRNoteTransaction where NoteID = @NoteId and AsOf < @CurrentDate		
		
		-- Get Latest As Of Date 
		SELECT TOP 1 @LatestAsOfDate = dtmAsOfDate from dbo.tblNRNoteTransaction where intNoteId=@NoteId Order By intNoteTransId DESC
		
		-- To Check if the previous transaction was reversed
		IF @HistoryType <> 3
		BEGIN
			SELECT TOP 2 @LastHistoryTypeID = intNoteTransTypeId, @LastHistoryID = intNoteTransId from dbo.tblNRNoteTransaction where intNoteId=@NoteId Order By intNoteTransId DESC
		END
		ELSE
		BEGIN
			SELECT TOP 1 @LastHistoryTypeID = intNoteTransTypeId, @LastHistoryID = intNoteTransId from dbo.tblNRNoteTransaction where intNoteId=@NoteId Order By intNoteTransId DESC
		END
		
		IF @HistoryType = 6
		BEGIN
			DECLARE @NoteHistoryID Int, @Amount Decimal(18,2)
			
			SELECT @NoteHistoryID = intNoteTransId, @Amount = dblTransAmount FROM dbo.tblNRNoteTransaction WHERE intNoteId = @NoteId AND intNoteTransTypeId = 4 AND strCheckNumber = @CheckNumber
			
			-- Previous date should be the next day from the �Bad Payment� date. For example, if Bad payment date is 4/10/09. So use the next day 4/11/09. 
			SELECT @PrvAsOfDate = DateAdd(D,1,dtmAsOfDate) FROM dbo.tblNRNoteTransaction WHERE intNoteId = @NoteId AND intNoteTransId = (@NoteHistoryID) --<= @PrvAsOfDate AND HistoryTypeID = 4 and 	
			If @PrvAsOfDate > @LatestAsOfDate SET @PrvAsOfDate = @LatestAsOfDate --dateadd(D,-1,@PrvAsOfDate)
			
			--if Previous date and latest asof date are same then set latest asof date as current date
			If convert(nvarchar(10),@PrvAsOfDate,101) = Convert(nvarchar(10),@LatestAsOfDate ,101)
			SET @LatestAsOfDate =cast(convert(varchar(10), @CurrentDate, 110) as datetime)
			
			-- ADDED TO FOR WRITEOFF NOTES. WE NEED TO CALCUALTE INTEREST FOR NOTE TILL DATE WHEN THE NOTE MADE AS WRITEOFF
			 
			IF(@WriteOff_Date	<>'1900-01-01 00:00:00.000')
			BEGIN	
			   IF Cast (Convert (varchar(10),@WriteOff_Date,101) as Datetime) < Cast(Convert (Varchar(10),@CurrentDate,101) as DateTime )
			   BEGIN
					SET @LatestAsOfDate=Cast (Convert (varchar(10),@WriteOff_Date,101) as Datetime)
			   END
			END
			
			-- if maturity date is less than the current date then following code will be executed.
			If Cast (Convert (varchar(10),@MaturityDate,101) as Datetime) < Cast(Convert (Varchar(10),@CurrentDate,101) as DateTime )
				AND @INTEREST_AFTER_MATURITY <> 1
			BEGIN
				IF(@WriteOff_Date	<>'1900-01-01 00:00:00.000')
				BEGIN	
					IF Cast (Convert (varchar(10),@MaturityDate,101) as Datetime) < Cast(Convert (Varchar(10),@WriteOff_Date,101) as DateTime )
					BEGIN
						SET @LatestAsOfDate=Cast (Convert (varchar(10),@MaturityDate,101) as Datetime)
					END
				END
				ELSE
				BEGIN
					SET @LatestAsOfDate=Cast (Convert (varchar(10),@MaturityDate,101) as Datetime)
				END
			END
			
			
			IF(@WriteOff_Date	<>'1900-01-01 00:00:00.000')
			BEGIN	
			-- if maturity date is less than the last transaction date then interest will become zero.
				If (Cast (Convert (varchar(10),@MaturityDate,101) as Datetime) < Cast(Convert (Varchar(10),@PrvAsOfDate,101) as DateTime ) AND @INTEREST_AFTER_MATURITY <> 1)
					OR Cast (Convert (varchar(10),@WriteOff_Date,101) as Datetime) < Cast(Convert (Varchar(10),@PrvAsOfDate,101) as DateTime )
				BEGIN
					SET @Result=0
				END
				ELSE
				BEGIN
					SET @Intdatediff = DateDiff(d,@PrvAsOfDate, @LatestAsOfDate)
				
					SET @CalcInterest = @Amount * ((@InterestRate/100)/ 360)* @Intdatediff 
				
					SET @Result= @CalcInterest								
				END
			END
			ELSE
			BEGIN
				-- if maturity date is less than the last transaction date then interest will become zero.
				If Cast (Convert (varchar(10),@MaturityDate,101) as Datetime) < Cast(Convert (Varchar(10),@PrvAsOfDate,101) as DateTime ) AND (@INTEREST_AFTER_MATURITY <> 1)
				BEGIN
					SET @Result=0
				END
				ELSE
				BEGIN
					SET @Intdatediff = DateDiff(d,@PrvAsOfDate, @LatestAsOfDate)
				
					SET @CalcInterest = @Amount * ((@InterestRate/100)/ 360)* @Intdatediff 
				
					SET @Result= @CalcInterest				
					
				END
			END
		
			RETURN @Result
		END
		ELSE IF  @HistoryType= 3
		BEGIN
		IF EXISTS (Select  dtmAsOfDate FROM dbo.tblNRNoteFutureTransaction where intNoteId = @NoteId 
					and dtmAsOfDate = cast(convert(varchar(10), @CurrentDate, 110) as datetime))
				BEGIN
					IF EXISTS(SELECT  dblPrincipal FROM dbo.tblNRNoteFutureTransaction where intNoteId = @NoteId 
					and dtmAsOfDate < cast(convert(varchar(10), @CurrentDate, 110) as datetime))
						begin
						SELECT top 1 @PrvAsOfDate = dtmAsOfDate, @PrvPrincipal = dblPrincipal, @HistoryType = intNoteTransTypeId FROM dbo.tblNRNoteFutureTransaction where intNoteId = @NoteId 
							and dtmAsOfDate < cast(convert(varchar(10), @CurrentDate, 110) as datetime ) ORDER BY dtmAsOfDate DESC , intNoteFutureTransId DESC
						
					    end
					else
						begin
							SELECT top 1 @PrvAsOfDate = dtmAsOfDate, @PrvPrincipal = dblPrincipal, @HistoryType = intNoteTransTypeId FROM dbo.tblNRNoteTransaction where intNoteId = @NoteId 
							and dtmAsOfDate < cast(convert(varchar(10), @CurrentDate, 110) as datetime)ORDER BY dtmAsOfDate DESC, intNoteTransId DESC
					    end	
					    			    
					
					set @LatestAsOfDate= cast(convert(varchar(10), @CurrentDate, 110) as datetime)
				END
			ELSE
				bEGIN
				
			SELECT TOP 1 @PrvAsOfDate = dtmAsOfDate, @PrvPrincipal = dblPrincipal, @HistoryType = intNoteTransTypeId FROM dbo.tblNRNoteTransaction where intNoteId = @NoteId Order By intNoteTransId DESC--and AsOf < @CurrentDate
			END
		END
		ELSE
		BEGIN
			IF EXISTS (Select  dtmAsOfDate FROM dbo.tblNRNoteFutureTransaction where intNoteId = @NoteId 
					and dtmAsOfDate = cast(convert(varchar(10), @CurrentDate, 110) as datetime))
				BEGIN
					IF EXISTS(SELECT  dblPrincipal FROM dbo.tblNRNoteFutureTransaction where intNoteId = @NoteId 
					and dtmAsOfDate < cast(convert(varchar(10), @CurrentDate, 110) as datetime))
						begin
						SELECT top 1 @PrvAsOfDate = dtmAsOfDate, @PrvPrincipal = dblPrincipal, @HistoryType = intNoteTransTypeId FROM dbo.tblNRNoteFutureTransaction where intNoteId = @NoteId 
							and dtmAsOfDate < cast(convert(varchar(10), @CurrentDate, 110) as datetime ) ORDER BY dtmAsOfDate DESC , intNoteFutureTransId DESC
						
					    end
					else
						begin
							SELECT top 1 @PrvAsOfDate = dtmAsOfDate, @PrvPrincipal = dblPrincipal, @HistoryType = intNoteTransTypeId FROM dbo.tblNRNoteTransaction where intNoteId = @NoteId 
							and dtmAsOfDate < cast(convert(varchar(10), @CurrentDate, 110) as datetime)ORDER BY dtmAsOfDate DESC, intNoteTransId DESC
					    end	
					    			    
					
					set @LatestAsOfDate= cast(convert(varchar(10), @CurrentDate, 110) as datetime)
				END
			ELSE
				BEGIN
					SELECT  TOP 1 @PrvAsOfDate = dtmAsOfDate, @PrvPrincipal = dblPrincipal, @HistoryType = intNoteTransTypeId FROM dbo.tblNRNoteTransaction where intNoteId = @NoteId 
					and dtmAsOfDate < cast(convert(varchar(10), @CurrentDate, 110) as datetime)ORDER BY dtmAsOfDate DESC, intNoteTransId DESC
			--and CAST(CONVERT(nvarchar(10),dtmAsOfDate,101) as DateTime) <= CAST(CONVERT(nvarchar(10),@CurrentDate,101)AS DateTime)
					
				
				END
		END

		If convert(nvarchar(10),@PrvAsOfDate,101) = Convert(nvarchar(10),@LatestAsOfDate ,101)
		set @LatestAsOfDate =cast(convert(varchar(10), @CurrentDate, 110) as datetime)
		--If @PrvAsOfDate =@LatestAsOfDate 
		--set @LatestAsOfDate =@CurrentDate
		IF @LastHistoryTypeID = 6 
		BEGIN
			SELECT TOP 1 @PrvAsOfDate = dtmAsOfDate From dbo.tblNRNoteTransaction WHERE intNoteId = @NoteId AND intNoteTransId < @LastHistoryID and intNoteTransTypeId <> 6 ORDER By intNoteTransId DESC
		END
		
		-- ADDED TO FOR WRITEOFF NOTES. WE NEED TO CALCUALTE INTEREST FOR NOTE TILL DATE WHEN THE NOTE MADE AS WRITEOFF
			 
			 IF(@WriteOff_Date	<>'1900-01-01 00:00:00.000')
			 BEGIN	
			   IF Cast (Convert (varchar(10),@WriteOff_Date,101) as Datetime) < Cast(Convert (Varchar(10),@CurrentDate,101) as DateTime )
			   BEGIN
			   SET @LatestAsOfDate=Cast (Convert (varchar(10),@WriteOff_Date,101) as Datetime)
			   END
			END
			
			-- if maturity date is less than the current date then following code will be executed.
			If Cast (Convert (varchar(10),@MaturityDate,101) as Datetime) < Cast(Convert (Varchar(10),@CurrentDate,101) as DateTime ) AND @INTEREST_AFTER_MATURITY <> 1
			BEGIN
			IF(@WriteOff_Date	<>'1900-01-01 00:00:00.000')
			BEGIN	
				IF Cast (Convert (varchar(10),@MaturityDate,101) as Datetime) < Cast(Convert (Varchar(10),@WriteOff_Date,101) as DateTime )
				BEGIN
				SET @LatestAsOfDate=Cast (Convert (varchar(10),@MaturityDate,101) as Datetime)
				END
			END
			ELSE
			BEGIN
			SET @LatestAsOfDate=Cast (Convert (varchar(10),@MaturityDate,101) as Datetime)
			END
			End
			-- if maturity date is less than the last transaction date then interest will become zero.
			IF(@WriteOff_Date	<>'1900-01-01 00:00:00.000')
			BEGIN	
				-- if maturity date is less than the last transaction date then interest will become zero.
				If (Cast (Convert (varchar(10),@MaturityDate,101) as Datetime) < Cast(Convert (Varchar(10),@PrvAsOfDate,101) as DateTime ) AND @INTEREST_AFTER_MATURITY <> 1)
				OR Cast (Convert (varchar(10),@WriteOff_Date,101) as Datetime) < Cast(Convert (Varchar(10),@PrvAsOfDate,101) as DateTime )
				BEGIN
					SET @Result=0
				END
				ELSE
				BEGIN
					SET @Intdatediff = DateDiff(d,@PrvAsOfDate, @LatestAsOfDate)
					
					SET @CalcInterest = @PrvPrincipal*((@InterestRate/100)/ 360)* @Intdatediff 
					SET  @Result= @CalcInterest				
					
				END
			END
			ELSE
			BEGIN
				-- if maturity date is less than the last transaction date then interest will become zero.
			If Cast (Convert (varchar(10),@MaturityDate,101) as Datetime) < Cast(Convert (Varchar(10),@PrvAsOfDate,101) as DateTime )AND @INTEREST_AFTER_MATURITY <> 1
			BEGIN
				SET @Result=0
			END
			ELSE
			BEGIN
				SET @Intdatediff = DateDiff(d,@PrvAsOfDate, @LatestAsOfDate)
				
				SET @CalcInterest = @PrvPrincipal*((@InterestRate/100)/ 360)* @Intdatediff 
				SET  @Result= @CalcInterest		
				
			END
		END
	End
		 
	RETURN @Result


END
