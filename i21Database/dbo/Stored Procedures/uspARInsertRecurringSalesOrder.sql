CREATE PROCEDURE [dbo].[uspARInsertRecurringSalesOrder]
	@SalesOrderId			INT = 0,
	@UserId				INT = 0
AS
	DECLARE @frequency			NVARCHAR(25),
			@startDate			DATETIME,
			@responsibleUser	NVARCHAR(100),
			@monthsToAdd		INT

	SELECT TOP 1
		   @frequency = CASE WHEN strFrequency IS NULL OR strFrequency = '' THEN 'Monthly' ELSE strFrequency END
	      ,@startDate = ISNULL(dtmMaintenanceDate, GETDATE())
		  FROM tblSOSalesOrderDetail WHERE intSalesOrderId = @SalesOrderId
	
	SELECT @monthsToAdd = CASE WHEN @frequency = 'Monthly' THEN 1 
							   WHEN @frequency = 'Bi-Monthly' THEN 2
							   WHEN @frequency = 'Quarterly' THEN 4
							   WHEN @frequency = 'Semi-Annually' THEN 6
							   WHEN @frequency = 'Annually' THEN 12
							   ELSE 0
						  END
	SELECT @responsibleUser = strName FROM tblEMEntity WHERE intEntityId = @UserId

	INSERT INTO [tblSMRecurringTransaction]
		([intTransactionId]
		,[strTransactionNumber]
		,[strTransactionType]
		,[strResponsibleUser]
		,[intEntityId]
		,[strFrequency]
		,[dtmLastProcess]
		,[dtmNextProcess]
		,[ysnDue]
		,[strDayOfMonth]
		,[dtmStartDate]
		,[dtmEndDate]
		,[ysnActive]
		,[intIteration]
		,[intUserId])
	SELECT 
		 @SalesOrderId																							--intTransactionId
		,[strSalesOrderNumber]																					--strTransactionNumber
		,CASE WHEN [strTransactionType]	= 'Order' 
			THEN 'Sales Order' ELSE [strTransactionType] END													--strTransactionType
		,@responsibleUser																						--strResponsibleUser
		,@UserId																								--intEntityId
		,@frequency																								--strFrequency
		,dtmDate																								--dtmLastProcess
		,DATEADD(MONTH, @monthsToAdd, dtmDate)																	--dtmNextProcess
		,CASE WHEN dtmDate > dtmDueDate 
			THEN 1 ELSE 0 END																					--ysnDue
		,CONVERT(NVARCHAR(2), DAY(dtmDate))																		--strDayOfMonth
		,@startDate																							    --dtmStartDate
		,DATEADD(MONTH, @monthsToAdd, @startDate)                                                               --dtmEndDate
		,1																										--ysnActive
		,1																										--intIteration
		,@UserId																								--intUserId
	FROM tblSOSalesOrder						   
		WHERE intSalesOrderId = @SalesOrderId

RETURN 0