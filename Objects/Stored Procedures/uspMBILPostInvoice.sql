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

	DECLARE @i21Invoice INT

	IF (@CreatedInvoices IS NOT NULL AND @ErrorMessage IS NULL)
	BEGIN
		
		SELECT Item INTO #tmpCreated FROM [fnSplitStringWithTrim](@CreatedInvoices,',')
		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpCreated)
		BEGIN
			SELECT TOP 1 @i21Invoice = CAST(Item AS INT) FROM #tmpCreated

			UPDATE tblMBILInvoice
			SET inti21InvoiceId = @i21Invoice
				, ysnPosted = @Post
			WHERE intInvoiceId = @InvoiceId

			DELETE FROM #tmpCreated WHERE CAST(Item AS INT) = @InvoiceId
		END
	END

	IF (@UpdatedInvoices IS NOT NULL AND @ErrorMessage IS NULL)
	BEGIN
		SELECT Item INTO #tmpUpdated FROM [fnSplitStringWithTrim](@UpdatedInvoices,',')
		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUpdated)
		BEGIN
			SELECT TOP 1 @InvoiceId = CAST(Item AS INT) FROM #tmpUpdated

			UPDATE tblMBILInvoice
			SET inti21InvoiceId = @i21Invoice
				, ysnPosted = @Post
			WHERE intInvoiceId = @InvoiceId

			DELETE FROM #tmpUpdated WHERE CAST(Item AS INT) = @InvoiceId
		END
	END

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