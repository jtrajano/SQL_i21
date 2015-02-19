﻿CREATE PROCEDURE [dbo].[uspNRCalculateInterest]
@intNoteId  int,
@dtmCurrentDate  Date,
@intTransTypeID  Int = 2,
@strCheckNumber  nvarchar(10) = ''
AS
BEGIN
	
	DECLARE @strNoteType nvarchar(50), @dblInterestRate Decimal(18,2)
	Select @strNoteType = strNoteType, @dblInterestRate = dblInterestRate from dbo.tblNRNote Where intNoteId = @intNoteId
	
	IF @strNoteType = 'Scheduled Invoice'
	BEGIN
		SELECT TOP 1 intNoteId
		, (Select SUM(dblInterest) FROM dbo.tblNRScheduleTransaction 
			WHERE intNoteId = @intNoteId AND dtmExpectedPayDate < @dtmCurrentDate Group By intNoteId
			) [dblInterestToDate] 
		--, dtmExpectedPayDate [dtmPayDate],dblExpectedPayAmt [dblPayAmount]
		, dblPrincipal, dblInterest, dblBalance FROM dbo.tblNRScheduleTransaction 
		WHERE intNoteId = @intNoteId AND dtmExpectedPayDate <= @dtmCurrentDate 		
		ORDER BY intScheduleTransId DESC
	END
	ELSE 
	BEGIN
		
		DECLARE @dblAsOfInterest Decimal(18,2), @dtmLastAsOfDate Datetime, @dblPrevPrincipal Decimal(18,2)
		, @Days Int, @dblInterestToDate Decimal(18,2)
		
		SELECT TOP 1 @dtmLastAsOfDate = dtmAsOfDate, @dblPrevPrincipal = dblPrincipal FROM dbo.tblNRNoteTransaction ORDER BY intNoteTransId DESC
		
		IF (CONVERT(nvarchar(10), @dtmLastAsOfDate, 101) = CONVERT(nvarchar(10), @dtmCurrentDate, 101))
		BEGIN
			SELECT @dblInterestToDate = dblInterestToDate FROM dbo.tblNRNoteTransaction ORDER BY intNoteTransId DESC
		END
		ELSE
		BEGIN
			SET @Days = DATEDIFF(d, @dtmLastAsOfDate, @dtmCurrentDate)
			SET @dblInterestToDate = @dblPrevPrincipal * ((@dblInterestRate/100)/360) * @Days
		END
		
		SELECT TOP 1 ISNULL(@intNoteId,0) [intNoteId]
		, ISNULL(@dblInterestToDate,0) as [dblInterestToDate] 
		--, dtmExpectedPayDate [dtmPayDate],dblExpectedPayAmt [dblPayAmount]
		, ISNULL(dblPrincipal,0) [dblPrincipal]
		, ISNULL(dblUnpaidInterest,0) [dblInterest]
		, ISNULL(dblPayOffBalance,0) [dblBalance]
		FROM dbo.tblNRNoteTransaction 
		ORDER BY intNoteTransId DESC
		
		 
	END
	
	
END