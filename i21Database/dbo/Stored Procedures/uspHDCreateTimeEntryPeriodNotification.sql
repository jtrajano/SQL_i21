CREATE PROCEDURE [dbo].[uspHDCreateTimeEntryPeriodNotification]
AS
BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

DECLARE @FirstWarningDate DATETIME,
		@SencondWarningDate DATETIME,
		@LockoutDate DATETIME,
		@BillingStartDate DATETIME,
		@BillingEndDate DATETIME,
		@RequiredHours INT,
		@TimeEntryPeriodId INT,
		@TimeEntryPeriodDetailId INT,
		@strWarningType nvarchar(100) = NULL,
		@currentDate datetime = CONVERT(DATE,GETDATE())
SELECT TOP 1  @TimeEntryPeriodId = intTimeEntryPeriodId
FROM tblHDTimeEntryPeriod
WHERE strFiscalYear = DATEPART(YEAR, GETDATE())

SELECT TOP 1   @TimeEntryPeriodDetailId		= intTimeEntryPeriodDetailId
              ,@FirstWarningDate			= dtmFirstWarningDate
			  ,@SencondWarningDate			= dtmSecondWarningDate
			  ,@LockoutDate					= dtmLockoutDate
			  ,@BillingStartDate			= dtmBillingPeriodStart
			  ,@BillingEndDate				= dtmBillingPeriodEnd
			  ,@RequiredHours				= intRequiredHours
			  ,@strWarningType				= CASE WHEN dtmFirstWarningDate = @currentDate
														THEN 'First Reminder'
												  WHEN dtmSecondWarningDate = @currentDate
														THEN 'Second Reminder'
												  WHEN dtmLockoutDate = @currentDate
														THEN ''
												  ELSE NULL
											  END
FROM tblHDTimeEntryPeriodDetail
WHERE intTimeEntryPeriodId = @TimeEntryPeriodId AND
	  strBillingPeriodStatus = 'Open' AND
	  (
		dtmFirstWarningDate = @currentDate OR
		dtmSecondWarningDate = @currentDate OR
		dtmLockoutDate = @currentDate
	  )

--SELECT @FirstWarningDate, @SencondWarningDate, @LockoutDate, @BillingStartDate, @BillingEndDate, @strWarningType, @RequiredHours

--Start Sync Time Off Request

EXEC [dbo].[uspHDSyncTimeOffRequest] @TimeEntryPeriodDetailId

--End Sync Time Off Request


IF @strWarningType IS NULL
	RETURN

DECLARE @EntityId int

DECLARE EmployeeLoop CURSOR 
  LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR 

SELECT DISTINCT a.intEntityId 
FROM vyuHDAgentDetail a
	 INNER JOIN tblEMEntity b
ON a.intEntityId = b.intEntityId
	 INNER JOIN tblHDCoworkerGoal c
ON c.intEntityId = a.intEntityId 
	 CROSS APPLY
	 (
		SELECT TOP 1 ysnActive = CoworkerGoalDetail.ysnActive
		FROM tblHDCoworkerGoalDetail CoworkerGoalDetail
		WHERE CoworkerGoalDetail.intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId AND
			  CoworkerGoalDetail.intCoworkerGoalId = c.intCoworkerGoalId
	 ) CoworkerGoalDetail
WHERE ISNULL(a.strEmail, '') <> '' AND 
	  a.ysnVendor = CONVERT(BIT, 0) AND
	  a.ysnTimeEntryExempt = CONVERT(BIT, 0) AND
      c.strFiscalYear = DATEPART(YEAR, GETDATE()) AND
	  --c.ysnActive = CONVERT(bit, 1) AND
	  a.ysnDisabled = CONVERT(BIT, 0) AND
	  CoworkerGoalDetail.ysnActive = CONVERT(BIT, 1)

OPEN EmployeeLoop
FETCH NEXT FROM EmployeeLoop INTO @EntityId
WHILE @@FETCH_STATUS = 0
BEGIN 
    
	DECLARE @TotalHours INT = 0

	SELECT @TotalHours = SUM(intHours) from vyuHDTicketHoursWorked
	WHERE intAgentEntityId = @EntityId AND
		  dtmDate >= @BillingStartDate AND
		  dtmDate <= @BillingEndDate
		  

	IF ISNULL(@TotalHours, 0) < @RequiredHours
	BEGIN
	
		IF NOT EXISTS (
				SELECT TOP 1 ''
				FROM tblHDTimeEntryPeriodNotification
				WHERE intEntityId = @EntityId AND
					  intEntityRecipientId = @EntityId AND
					  dtmDateCreated = @currentDate
		)
		BEGIN	
			INSERT INTO tblHDTimeEntryPeriodNotification
				(
					 [intEntityId]			
					,[intEntityRecipientId]	
					,[dtmDateCreated]		
					,[dtmDateSent]			
					,[ysnSent]				
					,[strWarning]
					,[intTimeEntryPeriodDetailId]
					,[intConcurrencyId]		
				)
			 SELECT  [intEntityId]					= @EntityId
					,[intEntityRecipientId]		    = @EntityId
					,[dtmDateCreated]				= @currentDate
					,[dtmDateSent]					= NULL
					,[ysnSent]						= 0
					,[strWarning]					= @strWarningType
					,[intTimeEntryPeriodDetailId]   = @TimeEntryPeriodDetailId
					,[intConcurrencyId]				= 1
		END
	END

    FETCH NEXT FROM EmployeeLoop INTO @EntityId
END
CLOSE EmployeeLoop
DEALLOCATE EmployeeLoop

END
GO