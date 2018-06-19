CREATE PROCEDURE [dbo].[uspARPaymentIntegration]
	@InvoiceIds	InvoiceId	READONLY,
	@Post		BIT = NULL
 
AS
	if @Post is not null
	begin
		exec uspARUpdateInvoiceTransactionHistory @InvoiceIds, @Post, 1
	end

	
RETURN 0
