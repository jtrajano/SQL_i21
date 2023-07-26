CREATE PROCEDURE [dbo].[uspHDSyncTimeOffRequest]
(
	@TimeEntryPeriodDetailId INT
)
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  

BEGIN
			--Start Sync Time Off Request

		    DECLARE @intTimeEntryPeriodDetail INT = @TimeEntryPeriodDetailId,
					@dtmDateFrom DATE = NULL,
					@dtmDateTo DATE = NULL,
					@strFiscalYear NVARCHAR(10) = NULL

			SELECT TOP 1 @dtmDateFrom		 = a.dtmBillingPeriodStart 
						,@dtmDateTo			 = a.dtmBillingPeriodEnd
						,@strFiscalYear		 = b.strFiscalYear
			FROM tblHDTimeEntryPeriodDetail a
					INNER JOIN tblHDTimeEntryPeriod b
			ON a.intTimeEntryPeriodId = b.intTimeEntryPeriodId
			WHERE intTimeEntryPeriodDetailId = @intTimeEntryPeriodDetail

			DECLARE @intEntityEmployeeId INT

			DECLARE EmployeeLoop CURSOR 
			  LOCAL STATIC READ_ONLY FORWARD_ONLY
			FOR 

			--Get only employees that have a time off request within this period
			SELECT intEntityEmployeeId 
			FROM vyuPRTimeOffRequest TimeOffRequest
			WHERE ( 
					TimeOffRequest.dtmDateFrom <= @dtmDateTo AND 
					TimeOffRequest.dtmDateFrom >= @dtmDateFrom 
				  ) OR 
				  ( 
					TimeOffRequest.dtmDateTo <= @dtmDateTo AND 
					TimeOffRequest.dtmDateTo >= @dtmDateFrom 
				  ) OR
				  ( 
					TimeOffRequest.dtmDateFrom < @dtmDateFrom AND 
					TimeOffRequest.dtmDateTo > @dtmDateTo 
				  )
			GROUP BY intEntityEmployeeId

			OPEN EmployeeLoop
			FETCH NEXT FROM EmployeeLoop INTO @intEntityEmployeeId
			WHILE @@FETCH_STATUS = 0
			BEGIN 
  
				EXEC [dbo].[uspHDGenerateTimeOffRequest] @intEntityEmployeeId
				EXEC [dbo].[uspHDCreateUpdateAgentTimeEntryPeriodDetailSummary] @intEntityEmployeeId, @intTimeEntryPeriodDetail, 0

				FETCH NEXT FROM EmployeeLoop INTO @intEntityEmployeeId
			END
			CLOSE EmployeeLoop
			DEALLOCATE EmployeeLoop

			--End Sync Time Off Request
		
END
GO