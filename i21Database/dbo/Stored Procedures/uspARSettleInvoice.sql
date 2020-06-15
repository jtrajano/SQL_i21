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
	  , @InvoiceIds		NVARCHAR(MAX) = NULL
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

SELECT @InvoiceIds = COALESCE(@InvoiceIds + ',' ,'') + CAST(ARI.[intInvoiceId] AS NVARCHAR(250))
FROM @PaymentDetailId PID
INNER JOIN tblAPPaymentDetail APPD ON PID.[intId] = APPD.[intPaymentDetailId]
INNER JOIN tblARInvoice ARI ON ARI.intInvoiceId = (CASE WHEN @void = 0 THEN APPD.intInvoiceId ELSE APPD.intOrigInvoiceId END)
INNER JOIN tblAPPayment APP ON APPD.[intPaymentId] = APP.[intPaymentId]
WHERE ARI.[ysnPosted] = 1
  AND APPD.[dblPayment] <> @ZeroDecimal

--Audit Log          
EXEC dbo.uspSMAuditLog 
		@keyValue			= @InvoiceIds						-- Primary Key Value of the Invoice. 
		,@screenName		= 'AccountsReceivable.view.Invoice'	-- Screen Namespace
		,@entityId			= @UserEntityID						-- Entity Id.
		,@actionType		= @ActionType						-- Action Type
		,@changeDescription	= ''								-- Description
		,@fromValue			= ''								-- Previous Value
		,@toValue			= ''								-- New Value
