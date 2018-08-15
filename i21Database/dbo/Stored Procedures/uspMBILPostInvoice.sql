CREATE PROCEDURE [dbo].[uspMBILPostInvoice]
	@InvoiceId INT,
	@Preview BIT,
	@Post BIT,
	@UserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @CreatedInvoices NVARCHAR(MAX)
DECLARE @UpdatedInvoices NVARCHAR(MAX)

BEGIN TRY
	
	-------------------------------------------------------------
	------------------- Validate Invoices -----------------------
	-------------------------------------------------------------
	--IF EXISTS(SELECT * FROM vyu)
	-------------------------------------------------------------
	------------------- End of Validations ----------------------
	-------------------------------------------------------------

	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @TaxDetails AS LineItemTaxDetailStagingTable

	SELECT [strTransactionType] = 'Invoice'
		,[strType] = 'Mobile Billing'
		,[strSourceTransaction] = 'Mobile Billing'
		,[intSourceId] = InvoiceItem.intInvoiceId
		,[strSourceId] = InvoiceItem.strInvoiceNo
		,[intInvoiceId] = InvoiceItem.inti21InvoiceId
		,[intEntityCustomerId] = InvoiceItem.intEntityCustomerId
		,[intCompanyLocationId] = InvoiceItem.intLocationId
		,[intTermId] = InvoiceItem.intTermId
		,[dtmDate] = InvoiceItem.dtmInvoiceDate
		,[dtmShipDate] = InvoiceItem.dtmDeliveryDate
		,[intEntitySalespersonId] = InvoiceItem.intDriverId
		--,[intFreightTermId]						INT												NULL		-- Freight Term Id
		--,[intShipViaId]							INT												NULL		-- Entity Id of ShipVia
		,[strMobileBillingShiftNo] = InvoiceItem.intShiftNumber
		,[strComments] = InvoiceItem.strComments
		,[intEntityId] = InvoiceItem.intEntityCustomerId
		,[intTruckDriverId] = InvoiceItem.intDriverId
		,[ysnRecap] = @Preview
		,[ysnPost] = @Post
		
		--Detail																																															
		,[intInvoiceDetailId] = InvoiceItem.inti21InvoiceDetailId
		,[intItemId] = InvoiceItem.intItemId
		,[ysnInventory] = 1
		,[intItemUOMId] = InvoiceItem.intItemUOMId
		,[dblQtyShipped] = InvoiceItem.dblQuantity
		,[dblPrice] = InvoiceItem.dblPrice
		,[dblUnitPrice] = (InvoiceItem.dblPrice / InvoiceItem.dblQuantity)
		,[ysnRefreshPrice] = 0
		--,[intTaxGroupId]						INT												NULL		-- Key Value from tblSMTaxGroup (Taxes)
		,[ysnRecomputeTax] = 1
		,[intContractDetailId] = InvoiceItem.intContractDetailId
		,[intSiteId] = InvoiceItem.intSiteId
	FROM vyuMBILInvoiceItem InvoiceItem

	EXEC [dbo].[uspARProcessInvoices]
			 @InvoiceEntries	= @EntriesForInvoice
			,@LineItemTaxEntries= @TaxDetails
			,@UserId			= @UserId
			,@GroupingOption	= 8
			,@RaiseError		= 1
			,@ErrorMessage		= @ErrorMessage OUTPUT
			,@CreatedIvoices	= @CreatedInvoices OUTPUT
			,@UpdatedIvoices	= @UpdatedInvoices OUTPUT


END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH