CREATE PROCEDURE [dbo].[uspARCreateRecurrence]
	 @TransactionId			INT
	,@TransactionNumber		NVARCHAR(50)
	,@TransactionType		NVARCHAR(50)
	,@Reference				NVARCHAR(50)
	,@WarningDays			INT
	,@Frequency				NVARCHAR(50)
	,@LastProcess			DATETIME		= NULL
	,@NextProcess			DATETIME		= NULL
	,@RecurringGroup		NVARCHAR(50)
	,@DayOfMonth			NVARCHAR(50)
	,@StartDate				DATETIME		= NULL
	,@EndDate				DATETIME		= NULL
	,@Iteration				INT
	,@EntityId				INT
	,@NewRecordId			INT				= NULL OUTPUT	
AS

BEGIN

DECLARE @UserId INT
		,@ResponsibleUser NVARCHAR(100)
SELECT
	@ResponsibleUser = strFullName
	,@UserId = intUserSecurityID 
FROM
	tblSMUserSecurity
WHERE
	intEntityId = @EntityId


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

INSERT INTO [tblSMRecurringTransaction]
	([intTransactionId]
	,[strTransactionNumber]
	,[strTransactionType]
	,[strReference]
	,[strResponsibleUser]
	,[intWarningDays]
	,[strFrequency]
	,[dtmLastProcess]
	,[dtmNextProcess]
	,[ysnDue]
	,[strRecurringGroup]
	,[strDayOfMonth]
	,[dtmStartDate]
	,[dtmEndDate]
	,[ysnActive]
	,[intIteration]
	,[intUserId]
	,[ysnAvailable]
	,[intConcurrencyId])
VALUES
	(@TransactionId
	,@TransactionNumber
	,@TransactionType
	,@Reference
	,@ResponsibleUser
	,@WarningDays
	,@Frequency
	,@LastProcess
	,@NextProcess
	,0
	,@RecurringGroup
	,@DayOfMonth
	,@StartDate
	,@EndDate
	,1
	,@Iteration
	,@UserId
	,1
	,1)
	
	
DECLARE @NewId as int
SET @NewId = SCOPE_IDENTITY()
SET @NewRecordId = @NewId 

           
RETURN @NewId

END