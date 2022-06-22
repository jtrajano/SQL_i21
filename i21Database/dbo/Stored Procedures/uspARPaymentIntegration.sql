CREATE PROCEDURE [dbo].[uspARPaymentIntegration]
	@InvoiceIds				InvoiceId	READONLY,
	@Post					BIT = NULL, 
	@PaymentStaging			PaymentIntegrationStagingTable READONLY,
	@strSessionId			NVARCHAR(50) = NULL
 
AS
	if @Post is not null
	begin
		exec uspARUpdateInvoiceTransactionHistory @InvoiceIds, @Post, 1, @PaymentStaging, @strSessionId
	end

	
RETURN 0
