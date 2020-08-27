CREATE PROCEDURE [dbo].[uspMBILProcessInvoices]
	@Param				AS NVARCHAR(MAX)	= '',	
	@ysnPost			AS BIT				=  0,
	@ysnRecap			AS BIT				=  0,
	@UserId				AS INT					,	
	@BatchId			NVARCHAR(MAX)		= NULL,
	@SuccessfulCount	INT					= 0		 OUTPUT,
	@ErrorMessage		NVARCHAR(250)		= NULL	 OUTPUT,
	@CreatedInvoices	NVARCHAR(MAX)		= NULL	 OUTPUT,
	@UpdatedInvoices	NVARCHAR(MAX)		= NULL	 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

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

	DECLARE @EntriesForInvoice AS InvoiceStagingTable
	DECLARE @TaxDetails AS LineItemTaxDetailStagingTable

	INSERT INTO @EntriesForInvoice (
			  [intId]
			, [strTransactionType]
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
			--, [intSalesAccountId]
			, [strItemDescription]
			, [intTaxGroupId]
			, [intTermId]
			, [intTruckDriverId]
			--, [strMobileBillingShiftNo]
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
		 [intInvoiceId]
		,[strTransactionType] = 'Invoice'
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
		--,[intEntitySalespersonId] = CONVERT(INT,ISNULL(InvoiceItem.intDriverId,0))
		,[strItemDescription] = InvoiceItem.strItemDescription
		,[intTaxGroupId] = NULL
		,[intTermId] = InvoiceItem.intTermId
		,[intTruckDriverId] = CONVERT(INT,ISNULL(InvoiceItem.intDriverId,0))
		--,[strMobileBillingShiftNo] = InvoiceItem.intShiftNumber
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

	INSERT INTO @TaxDetails
					(
					[intDetailId] 
					,[intTaxGroupId]
					,[intTaxCodeId]
					,[intTaxClassId]
					,[strTaxableByOtherTaxes]
					,[strCalculationMethod]
					,[dblRate]
					,[intTaxAccountId]
					,[dblTax]
					,[dblAdjustedTax]
					,[ysnTaxAdjusted]
					,[ysnSeparateOnInvoice]
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnTaxOnly]
					,[strNotes]
					,[intTempDetailIdForTaxes]
					,[ysnClearExisting])
				SELECT
				 [intDetailId]				= ISNULL((SELECT TOP 1 intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = Invoice.intInvoiceId ORDER BY dblQtyShipped DESC),Invoice.intInvoiceId)
				,[intTaxGroupId]			= NULL
				,[intTaxCodeId]				= smTaxCode.intTaxCodeId
				,[intTaxClassId]			= smTaxCode.intTaxClassId
				,[strTaxableByOtherTaxes]	= smTaxCode.strTaxableByOtherTaxes
				,[strCalculationMethod]		= (select top 1 strCalculationMethod from tblSMTaxCodeRate where dtmEffectiveDate < Invoice.dtmInvoiceDate AND intTaxCodeId = InvoiceTaxCode.intTaxCodeId order by dtmEffectiveDate desc)
				,[dblRate]					= InvoiceTaxCode.dblRate
				,[intTaxAccountId]			= smTaxCode.intSalesTaxAccountId
				,[dblTax]					= ABS(InvoiceTaxCode.dblTax)
				,[dblAdjustedTax]			= ABS(InvoiceTaxCode.dblAdjustedTax)--(cfTransactionTax.dblTaxCalculatedAmount * cfTransaction.dblQuantity) -- REMOTE TAXES ARE NOT RECOMPUTED ON INVOICE
				,[ysnTaxAdjusted]			= 0
				,[ysnSeparateOnInvoice]		= 0 
				,[ysnCheckoffTax]			= smTaxCode.ysnCheckoffTax
				,[ysnTaxExempt]				= InvoiceTaxCode.ysnTaxExempt
				,[ysnTaxOnly]				= smTaxCode.[ysnTaxOnly]
				,[strNotes]					= ''
				,[intTempDetailIdForTaxes]	= Invoice.intInvoiceId
				,[ysnClearExisting]			= 1
				FROM 
				tblMBILInvoice Invoice
				INNER JOIN tblMBILInvoiceItem InvoiceItem
					ON Invoice.intInvoiceId = InvoiceItem.intInvoiceId
				INNER JOIN tblMBILInvoiceTaxCode InvoiceTaxCode
					ON InvoiceItem.intInvoiceId = InvoiceTaxCode.intInvoiceItemId
				INNER JOIN tblSMTaxCode smTaxCode
					ON InvoiceTaxCode.intTaxCodeId = smTaxCode.intTaxCodeId
				WHERE Invoice.intInvoiceId IN (select intInvoiceId from #TempMBILInvoice)


	DECLARE @LogId INT

	EXEC [dbo].[uspARProcessInvoicesByBatch]
			 @InvoiceEntries	= @EntriesForInvoice
			,@LineItemTaxEntries= @TaxDetails
			,@UserId			= @UserId
			,@GroupingOption	= 8
			,@RaiseError		= 1
			,@BatchId			= @BatchId
			,@ErrorMessage		= @ErrorMessage OUTPUT
			--,@CreatedIvoices	= @CreatedInvoices OUTPUT
			--,@UpdatedIvoices	= @UpdatedInvoices OUTPUT
			,@LogId				= @LogId OUTPUT


	IF (ISNULL(@ysnRecap,0) = 0 AND (@ysnPost = 1))
	BEGIN
		WHILE EXISTS(SELECT 1 FROM #TempMBILInvoice)
		BEGIN
			DECLARE @intInvoiceId INT = (SELECT TOP 1 intInvoiceId FROM #TempMBILInvoice)

			UPDATE Invoice
			SET 
				 Invoice.ysnPosted	     = (SELECT TOP 1 ysnPosted FROM tblARInvoice WHERE tblARInvoice.intEntityCustomerId = Invoice.intEntityCustomerId and tblARInvoice.intSourceId = @intInvoiceId and tblARInvoice.strType = 'Tank Delivery'  order by dtmDateCreated desc)
				,Invoice.inti21InvoiceId = (SELECT TOP 1 intInvoiceId FROM tblARInvoice WHERE tblARInvoice.intEntityCustomerId = Invoice.intEntityCustomerId and tblARInvoice.intSourceId = @intInvoiceId and tblARInvoice.strType = 'Tank Delivery' order by dtmDateCreated desc)
			FROM
			tblMBILInvoice Invoice
			WHERE Invoice.intInvoiceId = @intInvoiceId

			DELETE FROM #TempMBILInvoice WHERE intInvoiceId = @intInvoiceId
		END

	END

END







--select * from tblMBILInvoice
--update tblMBILInvoice set inti21InvoiceId = NULL, ysnPosted = 0, ysnVoided = 0 where intInvoiceId = 1047


--select * from tblMBILInvoice
--EXEC [uspMBILPostInvoice] 'select intInvoiceId from tblMBILInvoice where intInvoiceId = 6', 0, 1, 1
--select * from tblMBILInvoice
