CREATE PROCEDURE [dbo].[uspARPaymentIntegration]
	@InvoiceIds				InvoiceId	READONLY,
	@Post					BIT = NULL, 
	@PaymentStaging			PaymentIntegrationStagingTable READONLY
 
AS
	if @Post is not null
	begin
		exec uspARUpdateInvoiceTransactionHistory @InvoiceIds, @Post, 1, @PaymentStaging
	end

	
RETURN 0
