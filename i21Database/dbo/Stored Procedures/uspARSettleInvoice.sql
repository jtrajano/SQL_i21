CREATE PROCEDURE [dbo].[uspARSettleInvoice]
	 @PaymentDetailId	Id READONLY
	,@userId			INT
	,@post				BIT
	,@void				BIT
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @UserEntityID	INT = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @userId),@userId) 
	  , @ActionType		NVARCHAR(50) = CASE WHEN @post = 1 THEN 'Post Settlement' ELSE 'UnPost Settlement' END
	  , @ZeroDecimal	NUMERIC(18, 6) = 0
		
UPDATE ARI						
SET	ARI.[dblPayment] = ISNULL(ARI.[dblPayment], @ZeroDecimal) + ((CASE WHEN ARI.strTransactionType = 'Cash Refund' THEN APPD.[dblPayment] * -1 ELSE APPD.[dblPayment] END) * (CASE WHEN @post = 0 THEN 1 ELSE -1 END)) 
FROM @PaymentDetailId PID
INNER JOIN tblAPPaymentDetail APPD ON PID.[intId] = APPD.[intPaymentDetailId]
INNER JOIN tblARInvoice ARI ON ARI.intInvoiceId = (CASE WHEN @void = 0 THEN APPD.intInvoiceId ELSE APPD.intOrigInvoiceId END)
INNER JOIN tblAPPayment APP ON APPD.[intPaymentId] = APP.[intPaymentId]
WHERE ARI.[ysnPosted] = 1
  AND APPD.[dblPayment] <> @ZeroDecimal

UPDATE ARI						
SET	ARI.dblAmountDue 		= (ARI.dblInvoiceTotal + ARI.dblInterest) - (ARI.dblPayment + ARI.dblDiscount)
  , ARI.[ysnPaid] 			= CASE WHEN (ARI.dblInvoiceTotal + ARI.dblInterest) - (ARI.dblPayment + ARI.dblDiscount) = @ZeroDecimal THEN 1 ELSE 0 END
  , ARI.[intConcurrencyId]	= ISNULL(ARI.intConcurrencyId,0) + 1	
FROM @PaymentDetailId PID
INNER JOIN tblAPPaymentDetail APPD ON PID.[intId] = APPD.[intPaymentDetailId]
INNER JOIN tblARInvoice ARI ON ARI.intInvoiceId = (CASE WHEN @void = 0 THEN APPD.intInvoiceId ELSE APPD.intOrigInvoiceId END)
INNER JOIN tblAPPayment APP ON APPD.[intPaymentId] = APP.[intPaymentId]
WHERE ARI.[ysnPosted] = 1
  AND APPD.[dblPayment] <> @ZeroDecimal

DECLARE @InvoiceLog dbo.[AuditLogStagingTable]

INSERT INTO @InvoiceLog(
	 [strScreenName]
	,[intKeyValueId]
	,[intEntityId]
	,[strActionType]
	,[strDescription]
	,[strActionIcon]
	,[strChangeDescription]
	,[strFromValue]
	,[strToValue]
	,[strDetails]
)
SELECT DISTINCT
	 [strScreenName]			= 'AccountsReceivable.view.Invoice'
	,[intKeyValueId]			= ARI.[intInvoiceId]
	,[intEntityId]				= @UserEntityID
	,[strActionType]			= @ActionType
	,[strDescription]			= ''
	,[strActionIcon]			= NULL
	,[strChangeDescription]		= ''
	,[strFromValue]				= ''
	,[strToValue]				= ''
	,[strDetails]				= NULL
FROM @PaymentDetailId PID
INNER JOIN tblAPPaymentDetail APPD ON PID.[intId] = APPD.[intPaymentDetailId]
INNER JOIN tblARInvoice ARI ON ARI.intInvoiceId = (CASE WHEN @void = 0 THEN APPD.intInvoiceId ELSE APPD.intOrigInvoiceId END)
INNER JOIN tblAPPayment APP ON APPD.[intPaymentId] = APP.[intPaymentId]
WHERE ARI.[ysnPosted] = 1
  AND APPD.[dblPayment] <> @ZeroDecimal

EXEC [dbo].[uspARInsertAuditLogs] @LogEntries = @InvoiceLog, @intUserId = @UserEntityID