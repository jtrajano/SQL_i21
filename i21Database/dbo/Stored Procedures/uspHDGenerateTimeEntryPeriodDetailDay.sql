CREATE PROCEDURE [dbo].[uspHDGenerateTimeEntryPeriodDetailDay]
	 @TimeEntryPeriodDetailId int  
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

DECLARE @dtmBillingPeriodStart DATETIME,
		@dtmBillingPeriodEnd DATETIME,
		@intTimeEntryPeriodDetailId INT,
		@intRange int

SET @intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId

SELECT TOP 1 @dtmBillingPeriodStart = dtmBillingPeriodStart
			,@dtmBillingPeriodEnd   = dtmBillingPeriodEnd
			,@intRange			    = DATEDIFF(DAY, @dtmBillingPeriodStart, @dtmBillingPeriodEnd)
FROM tblHDTimeEntryPeriodDetail
WHERE intTimeEntryPeriodDetailId = @intTimeEntryPeriodDetailId

IF @intTimeEntryPeriodDetailId IS NULL OR @dtmBillingPeriodStart IS NULL OR @dtmBillingPeriodEnd IS NULL
	RETURN

--Already exist in this table
IF EXISTS (
	SELECT TOP 1 ''
	FROM tblHDTimeEntryPeriodDetailDay
	WHERE [dtmBillingPeriodStart]		 = @dtmBillingPeriodStart AND
	      [dtmBillingPeriodEnd]			 = @dtmBillingPeriodEnd AND
		  [intTimeEntryPeriodDetailId]   = @TimeEntryPeriodDetailId	
)
BEGIN
	RETURN
END

--Billing Period Date is changed. Delete records
IF EXISTS (
	SELECT TOP 1 ''
	FROM tblHDTimeEntryPeriodDetailDay
	WHERE ( [dtmBillingPeriodStart]		 <> @dtmBillingPeriodStart OR
	      [dtmBillingPeriodEnd]			 <> @dtmBillingPeriodEnd ) AND
		  [intTimeEntryPeriodDetailId]   = @TimeEntryPeriodDetailId	
)
BEGIN
	DELETE FROM tblHDTimeEntryPeriodDetailDay
	WHERE [intTimeEntryPeriodDetailId]   = @TimeEntryPeriodDetailId	
END

--Create records
IF NOT EXISTS (
	SELECT TOP 1 ''
	FROM tblHDTimeEntryPeriodDetailDay
	WHERE intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId	
)
BEGIN 

		INSERT INTO tblHDTimeEntryPeriodDetailDay
		(
			 [intTimeEntryPeriodDetailId]
			,[strDaysDisplay]
			,[dtmBillingPeriodStart]
			,[dtmBillingPeriodEnd]
			,[intConcurrencyId]
		)
		SELECT  [intTimeEntryPeriodDetailId]	= @TimeEntryPeriodDetailId
				,[strDaysDisplay]				= 'This Period'
				,[dtmBillingPeriodStart]		= @dtmBillingPeriodStart
				,[dtmBillingPeriodEnd]			= @dtmBillingPeriodEnd
				,[intConcurrencyId]				= 1

	DECLARE @counter INT = 0
	WHILE ( @counter <= @intRange)
	BEGIN
		
		DECLARE @strDaysToInsert NVARCHAR(250) = dbo.fnConvertDateToReportDateFormat(DATEADD(DAY, -@counter, @dtmBillingPeriodEnd), 0) 

	
		INSERT INTO tblHDTimeEntryPeriodDetailDay
		(
			 [intTimeEntryPeriodDetailId]
			,[strDaysDisplay]
			,[dtmBillingPeriodStart]
			,[dtmBillingPeriodEnd]
			,[intConcurrencyId]
		)
		SELECT  [intTimeEntryPeriodDetailId]	= @TimeEntryPeriodDetailId
				,[strDaysDisplay]				= @strDaysToInsert
				,[dtmBillingPeriodStart]		= @dtmBillingPeriodStart
				,[dtmBillingPeriodEnd]			= @dtmBillingPeriodEnd
				,[intConcurrencyId]				= 1
		
		SET @counter= @counter + 1

	END

END
ELSE
BEGIN
	RETURN
END
GO