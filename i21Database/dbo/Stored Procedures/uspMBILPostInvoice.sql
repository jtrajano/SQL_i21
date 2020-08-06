CREATE PROCEDURE [dbo].[uspMBILPostInvoice]
	@Param				AS NVARCHAR(MAX)	= '',	
	@ysnPost			AS BIT				= 0,
	@ysnRecap			AS BIT				= 0,
	@UserId				AS INT					,	
	@ErrorMessage		AS NVARCHAR(MAX)	= ''	 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @CreatedInvoices NVARCHAR(MAX)
DECLARE @UpdatedInvoices NVARCHAR(MAX)
SET @ErrorMessage = NULL

CREATE TABLE #TempMBILInvoice (
	[intInvoiceId]		int
);
	
	--=====================================================================================================================================
	-- 	POPULATE INVOICE TO POST TEMPORARY TABLE
	---------------------------------------------------------------------------------------------------------------------------------------
	IF (ISNULL(@Param, '') <> '') 
		INSERT INTO #TempMBILInvoice EXEC (@Param)
	ELSE
		INSERT INTO #TempMBILInvoice SELECT [intInvoiceId] FROM tblMBILInvoice WHERE ysnPosted = 0

	-------------------------------------------------------------
	------------------- Validate Invoices -----------------------
	-------------------------------------------------------------
	IF NOT EXISTS(SELECT TOP 1 1 FROM vyuMBILInvoiceItem WHERE intInvoiceId IN (select intInvoiceId from #TempMBILInvoice))
	BEGIN
		SET @ErrorMessage = 'Record does not exists.'
		RETURN
	END

	IF EXISTS(SELECT TOP 1 1 FROM vyuMBILInvoiceItem WHERE intInvoiceId IN (select intInvoiceId from #TempMBILInvoice) AND inti21InvoiceId IS NOT NULL)
	BEGIN
		SET @ErrorMessage = 'Record already posted.'
		RETURN
	END
	-------------------------------------------------------------
	------------------- End of Validations ----------------------
	-------------------------------------------------------------

	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @TaxDetails AS LineItemTaxDetailStagingTable

	INSERT INTO @EntriesForInvoice (
			  [strTransactionType]
			, [strType]
			, [strSourceTransaction]
			, [intSourceId]
			, [strSourceId]
			, [intEntityCustomerId]
			, [intCompanyLocationId]			
			, [intCurrencyId]
			, [intEntityId]
			, [dtmDate]
			, [dtmDueDate]
			, [dtmShipDate]
			, [dtmPostDate]
			, [strComments]
			, [ysnPost]
			, [intSalesAccountId]
			, [strItemDescription]
			, [intTaxGroupId]
			, [intTermId]
			, [intTruckDriverId]
			, [strMobileBillingShiftNo]
			, [ysnRecap]

			, [intInvoiceDetailId]
			, [intItemId]
			, [ysnInventory] 
			, [intItemUOMId]
			, [dblQtyShipped]
			, [dblPrice]
			, [dblUnitPrice]
			, [dblPercentFull]
			, [ysnRefreshPrice]
			, [ysnRecomputeTax]
			, [intContractDetailId]
			, [intSiteId] 
		)
	SELECT 
		 [strTransactionType] = 'Invoice'
		,[strType] = 'Tank Delivery'
		,[strSourceTransaction] = 'Mobile Billing'
		,[intSourceId] = InvoiceItem.intInvoiceId
		,[strSourceId] = InvoiceItem.strInvoiceNo
		,[intEntityCustomerId] = InvoiceItem.intEntityCustomerId
		,[intCompanyLocationId] = InvoiceItem.intLocationId
		,[intCurrencyId] = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
		,[intEntityId] = InvoiceItem.intEntityCustomerId
		,[dtmDate] = InvoiceItem.dtmInvoiceDate
		,[dtmDueDate] = InvoiceItem.dtmInvoiceDate
		,[dtmShipDate] = InvoiceItem.dtmDeliveryDate
		,[dtmPostDate] = InvoiceItem.dtmPostedDate
		,[strComments] = InvoiceItem.strComments
		,[ysnPost] = @ysnPost
		,[intEntitySalespersonId] = CONVERT(INT,ISNULL(InvoiceItem.intDriverId,0))
		,[strItemDescription] = InvoiceItem.strItemDescription
		,[intTaxGroupId] = NULL
		,[intTermId] = InvoiceItem.intTermId
		,[intTruckDriverId] = CONVERT(INT,ISNULL(InvoiceItem.intDriverId,0))
		,[strMobileBillingShiftNo] = InvoiceItem.intShiftNumber
		,[ysnRecap] = @ysnRecap
		
		--Detail																																															
		,[intInvoiceDetailId] = InvoiceItem.inti21InvoiceDetailId
		,[intItemId] = InvoiceItem.intItemId
		,[ysnInventory] = 1
		,[intItemUOMId] = InvoiceItem.intItemUOMId
		,[dblQtyShipped] = InvoiceItem.dblQuantity
		,[dblPrice] = InvoiceItem.dblPrice
		,[dblUnitPrice] = (InvoiceItem.dblPrice / InvoiceItem.dblQuantity)
		,[dblPercentFull] = InvoiceItem.dblPercentageFull
		,[ysnRefreshPrice] = 0
		,[ysnRecomputeTax] = 1
		,[intContractDetailId] = InvoiceItem.intContractDetailId
		,[intSiteId] = InvoiceItem.intSiteId

	FROM vyuMBILInvoiceItem InvoiceItem
	WHERE inti21InvoiceId IS NULL and intInvoiceId IN (select intInvoiceId from #TempMBILInvoice)

	select * from @EntriesForInvoice

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
	DECLARE @InvoiceId  INT

	SELECT @CreatedInvoices
	SELECT @ErrorMessage
	SELECT @UpdatedInvoices

	--IF (@CreatedInvoices IS NOT NULL AND @ErrorMessage IS NULL)
	--BEGIN
	--	SET @ErrorMessage = @ErrorMessage
	--	RETURN
	--END

	IF (@CreatedInvoices IS NOT NULL AND @ErrorMessage IS NULL)
	BEGIN
		
		SELECT Item INTO #tmpCreated FROM [fnSplitStringWithTrim](@CreatedInvoices,',')
		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpCreated)
		BEGIN
			SELECT TOP 1 @i21Invoice = CAST(Item AS INT) FROM #tmpCreated
			SELECT TOP 1 @InvoiceId = intInvoiceId from #TempMBILInvoice

			UPDATE tblMBILInvoice
			SET inti21InvoiceId = @i21Invoice
				, ysnPosted = @ysnPost
			WHERE intInvoiceId = @InvoiceId

			DELETE FROM #tmpCreated WHERE CAST(Item AS INT) = @i21Invoice
			DELETE FROM #TempMBILInvoice WHERE CAST(intInvoiceId AS INT) = @InvoiceId
		END
	END

	IF (@UpdatedInvoices IS NOT NULL AND @ErrorMessage IS NULL)
	BEGIN
		SELECT Item INTO #tmpUpdated FROM [fnSplitStringWithTrim](@UpdatedInvoices,',')
		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUpdated)
		BEGIN
			SELECT TOP 1 @i21Invoice = CAST(Item AS INT) FROM #tmpUpdated
			SELECT TOP 1 @InvoiceId = intInvoiceId from #TempMBILInvoice

			UPDATE tblMBILInvoice
			SET inti21InvoiceId = @i21Invoice
				, ysnPosted = @ysnPost
			WHERE intInvoiceId = @InvoiceId

			DELETE FROM #tmpUpdated WHERE CAST(Item AS INT) = @i21Invoice
			DELETE FROM #TempMBILInvoice WHERE CAST(intInvoiceId AS INT) = @InvoiceId
		END
	END



END







--select * from tblMBILInvoice
--update tblMBILInvoice set inti21InvoiceId = NULL, ysnPosted = 0, ysnVoided = 0


--select * from tblMBILInvoice
--EXEC [uspMBILPostInvoice] 'select intInvoiceId from tblMBILInvoice where intInvoiceId = 6', 0, 1, 1
--select * from tblMBILInvoice
