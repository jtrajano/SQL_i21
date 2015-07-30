CREATE PROCEDURE [dbo].[uspARInsertRecurringInvoice]
	@InvoiceId			INT = 0,
	@UserId				INT = 0
AS
	DECLARE @frequency NVARCHAR(25),
			@startDate DATETIME,
			@responsibleUser NVARCHAR(100)

	SELECT TOP 1
		   @frequency = strFrequency
	      ,@startDate = ISNULL(dtmMaintenanceDate, GETDATE())
		  FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId

	SELECT @responsibleUser = strName FROM tblEntity WHERE intEntityId = @UserId

	INSERT INTO [tblSMRecurringTransaction]
		([intTransactionId]
		,[strTransactionNumber]
		,[strTransactionType]
		,[strResponsibleUser]
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
		 @InvoiceId					             --intTransactionId
		,[strInvoiceNumber]			             --strTransactionNumber
		,[strTransactionType]		             --strTransactionType
		,@responsibleUser
		,@frequency					             --strFrequency
		,@startDate					             --dtmLastProcess
		,DATEADD(MONTH, 1, @startDate)           --dtmNextProcess
		,CASE WHEN GETDATE() > [dtmDueDate] 
			THEN 1 ELSE 0 END                    --ysnDue
		,CONVERT(NVARCHAR(2), DAY(@startDate))   --strDayOfMonth
		,DATEADD(MONTH, 1, @startDate)		     --dtmStartDate
		,DATEADD(MONTH, 1, @startDate)           --dtmEndDate
		,1									     --ysnActive
		,1									     --intIteration
		,@UserId							     --intUserId
	FROM tblARInvoice						   
		WHERE intInvoiceId = @InvoiceId

RETURN 0