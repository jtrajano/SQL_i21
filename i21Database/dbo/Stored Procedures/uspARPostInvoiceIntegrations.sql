CREATE PROCEDURE [dbo].[uspARPostInvoiceIntegrations]
	 @post			BIT = 0  
	,@TransactionId	INT = NULL   
	,@userId		INT  = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  



-- Get the details from the invoice 
BEGIN 
	DECLARE @ItemsFromInvoice AS dbo.[InvoiceItemTableType]
	INSERT INTO @ItemsFromInvoice (
		-- Header
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[intEntityCustomerId]
		,[dtmDate]
		,[intCurrencyId]
		,[intCompanyLocationId]
		,[intDistributionHeaderId]

		-- Detail 
		,[intInvoiceDetailId]
		,[intItemId]
		,[strItemDescription]
		,[intSCInvoiceId]
		,[strSCInvoiceNumber]
		,[intItemUOMId]
		,[dblQtyOrdered]
		,[dblQtyShipped]
		,[dblDiscount]
		,[dblPrice]
		,[dblTotalTax]
		,[dblTotal]
		,[intServiceChargeAccountId]
		,[intInventoryShipmentItemId]
		,[intSalesOrderDetailId]
		,[intSiteId]
		,[strBillingBy]
		,[dblPercentFull]
		,[dblNewMeterReading]
		,[dblPreviousMeterReading]
		,[dblConversionFactor]
		,[intPerformerId]
		,[intContractHeaderId]
		,[strMaintenanceType]
		,[strFrequency]
		,[dtmMaintenanceDate]
		,[dblMaintenanceAmount]
		,[dblLicenseAmount]
		,[intContractDetailId]
		,[intTicketId]
		,[ysnLeaseBilling]
	)
	EXEC dbo.[uspARGetItemsFromInvoice]
			@intInvoiceId = @TransactionId

	-- Change quantity to negative if doing a post. Otherwise, it should be the same value if doing an unpost. 
	UPDATE @ItemsFromInvoice
		SET [dblQtyShipped] = [dblQtyShipped] * CASE WHEN @post = 1 THEN -1 ELSE 1 END 
END

EXEC dbo.[uspCTInvoicePosted] @ItemsFromInvoice, @userId

EXEC dbo.[uspARUpdateSOStatusFromInvoice] @TransactionId

_Exit: 