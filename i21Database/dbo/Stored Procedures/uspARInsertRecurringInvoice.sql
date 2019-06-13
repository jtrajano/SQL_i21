CREATE PROCEDURE [dbo].[uspARInsertRecurringInvoice]
	@InvoiceId			INT = 0,
	@UserId				INT = 0
AS
DECLARE @frequency			NVARCHAR(25)
	  , @startDate			DATETIME
	  ,	@responsibleUser	NVARCHAR(100)
	  , @monthsToAdd		INT

SELECT TOP 1 @frequency = CASE WHEN ISNULL(strFrequency, '') = '' THEN 'Monthly' ELSE strFrequency END
	       , @startDate = ISNULL(dtmMaintenanceDate, GETDATE())
FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId
	
SELECT @monthsToAdd = CASE WHEN @frequency = 'Monthly' THEN 1 
							WHEN @frequency = 'Bi-Monthly' THEN 2
							WHEN @frequency = 'Quarterly' THEN 4
							WHEN @frequency = 'Semi-Annually' THEN 6
							WHEN @frequency = 'Annually' THEN 12
							ELSE 0
						END
SELECT @responsibleUser = strName FROM tblEMEntity WHERE intEntityId = @UserId

INSERT INTO tblSMRecurringTransaction (
	  [intTransactionId]
	, [strTransactionNumber]
	, [strTransactionType]
	, [strResponsibleUser]
	, [intEntityId]
	, [strFrequency]
	, [dtmLastProcess]
	, [dtmNextProcess]
	, [ysnDue]
	, [strDayOfMonth]
	, [dtmStartDate]
	, [dtmEndDate]
	, [ysnActive]
	, [intIteration]
	, [intUserId]
)
SELECT [intTransactionId]		= @InvoiceId
	, [strTransactionNumber]	= [strInvoiceNumber]
	, [strTransactionType]		= [strTransactionType]
	, [strResponsibleUser]		= @responsibleUser
	, [intEntityId]				= @UserId
	, [strFrequency]			= @frequency
	, [dtmLastProcess]			= [dtmDate]
	, [dtmNextProcess]			= DATEADD(MONTH, @monthsToAdd, dtmDate)
	, [ysnDue]					= CASE WHEN dtmDate > dtmDueDate THEN 1 ELSE 0 END
	, [strDayOfMonth]			= CONVERT(NVARCHAR(2), DAY(dtmDate))
	, [dtmStartDate]			= @startDate
	, [dtmEndDate]				= DATEADD(MONTH, @monthsToAdd, @startDate)
	, [ysnActive]				= 1
	, [intIteration]			= 1
	, [intUserId]				= @UserId
FROM tblARInvoice
WHERE intInvoiceId = @InvoiceId

RETURN 0