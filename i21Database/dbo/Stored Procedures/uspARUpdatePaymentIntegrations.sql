CREATE PROCEDURE [dbo].[uspARUpdatePaymentIntegrations]
	 @PaymentIDs			NVARCHAR(MAX)	= NULL	
	,@UserId				INT = NULL
	,@ForDelete				BIT = 0
AS  

DECLARE @InvoiceIds	InvoiceId

INSERT INTO @InvoiceIds(
	 intHeaderId
	,ysnForDelete
) 
SELECT 
	 intHeaderId 	= intInvoiceId
	,ysnForDelete	= ISNULL(@ForDelete, 0)
FROM tblARPaymentDetail
WHERE intPaymentId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@PaymentIDs))
AND dblPayment <> 0

EXEC dbo.[uspARProcessTradeFinanceLog] @InvoiceIds, @UserId, 'Payment', @ForDelete, 0, 1

RETURN 0