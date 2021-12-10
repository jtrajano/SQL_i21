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
CREATE TABLE #TempMBILInvoiceItem (
	[intInvoiceId]		int,
	[intItemId]			int,
	[intLocationId]		int,
	[strItemNo]			nvarchar(max),
	[strLocationName]		nvarchar(max)
);
	
	--=====================================================================================================================================
	-- 	POPULATE INVOICE TO POST TEMPORARY TABLE
	---------------------------------------------------------------------------------------------------------------------------------------
	IF (ISNULL(@Param, '') <> '') 
		INSERT INTO #TempMBILInvoice EXEC (@Param)
	ELSE
		INSERT INTO #TempMBILInvoice SELECT [intInvoiceId] FROM tblMBILInvoice WHERE ysnPosted = 0

	INSERT INTO #TempMBILInvoiceItem SELECT [intInvoiceId], [intItemId], [intLocationId], [strItemNo], [strLocationName] FROM vyuMBILInvoiceItem WHERE intInvoiceId IN (select intInvoiceId from #TempMBILInvoice)

	-------------------------------------------------------------
	------------------- Update Tax Detail-----------------------
	-------------------------------------------------------------
    UPDATE tblMBILInvoiceTaxCode 
	SET dblTax = CASE WHEN strCalculationMethod ='Percentage' THEN (item.dblQuantity * item.dblPrice * (tax.dblRate / 100)) ELSE item.dblQuantity * tax.dblRate END
	FROM tblMBILInvoiceItem item 
	INNER JOIN tblMBILInvoiceTaxCode tax ON item.intInvoiceItemId = tax.intInvoiceItemId
	WHERE item.intInvoiceId IN (select intInvoiceId from #TempMBILInvoice)
	-------------------------------------------------------------
	------------------- Validate Invoices -----------------------
	-------------------------------------------------------------
	IF NOT EXISTS(SELECT TOP 1 1 FROM vyuMBILInvoiceItem WHERE intInvoiceId IN (select intInvoiceId from #TempMBILInvoice))
	BEGIN
		SET @ErrorMessage = 'Record does not exists.'
		RETURN
	END
	--IF @BatchId IS NULL
	--BEGIN
	--	WHILE EXISTS(SELECT TOP 1 1 FROM #TempMBILInvoiceItem)
	--	BEGIN
	--		DECLARE @intItemInvoiceId INT
	--		DECLARE @intItemId INT
	--		DECLARE @intLocationId INT
	--		DECLARE @strItemNo NVARCHAR(MAX)
	--		DECLARE @strLocationName NVARCHAR(MAX)

	--		SELECT TOP 1 @intItemInvoiceId = intInvoiceId, @intItemId = intItemId, @strItemNo = strItemNo, @intLocationId = intLocationId, @strLocationName = strLocationName FROM #TempMBILInvoiceItem

	--		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItemLocation WHERE intLocationId = @intLocationId AND intItemId = @intItemId)
	--		BEGIN
	--			SET @ErrorMessage = 'The item(' + @strItemNo + ') was not set up to be available on the specified location(' + @strLocationName + ')!'
	--			RETURN
	--		END

	--		DELETE FROM #TempMBILInvoiceItem WHERE intInvoiceId = @intItemInvoiceId AND intItemId = @intItemId
	--	END
	--END

	IF EXISTS(SELECT TOP 1 1 FROM vyuMBILInvoiceItem WHERE intInvoiceId IN (select intInvoiceId from #TempMBILInvoice) AND inti21InvoiceId IS NOT NULL AND inti21InvoiceId IN (SELECT intInvoiceId FROM tblARInvoice))
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblARInvoice WHERE ysnPosted = 1 AND intInvoiceId = (SELECT TOP 1 inti21InvoiceId FROM vyuMBILInvoiceItem WHERE intInvoiceId IN (select intInvoiceId from #TempMBILInvoice) AND inti21InvoiceId IS NOT NULL))
		BEGIN
			UPDATE tblMBILInvoice SET ysnPosted = 1 WHERE intInvoiceId IN (select intInvoiceId from #TempMBILInvoice)
			SET @ErrorMessage = 'Record already posted.'
			RETURN
		END
		ELSE
		BEGIN			
			DECLARE @success BIT
			DECLARE @successCount INT
			DECLARE @invalidCount INT
			DECLARE @batchIdUsed NVARCHAR(MAX)
			DECLARE @recapId BIT
			DECLARE @RaiseError INT

			DECLARE @invoice NVARCHAR(MAX)
			SELECT TOP 1 @invoice = inti21InvoiceId FROM vyuMBILInvoiceItem WHERE intInvoiceId IN (select intInvoiceId from #TempMBILInvoice)

			BEGIN TRY
				BEGIN TRANSACTION

				EXEC uspARPostInvoice 
					@post = 1, 
					@recap = 0, 
					@param = @invoice, 
					@userId = @UserId, 
					@batchId = default,
					@exclude = N'',
					@success = @success output,
					@successfulCount = @successCount output,
					@invalidCount = @invalidCount output,
					@batchIdUsed = @batchIdUsed output,
					@recapId = @recapId output,
					@transType = default,
					@raiseError = @RaiseError,
					@accrueLicense = 0

				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				IF ISNULL(@RaiseError,0) = 1
				BEGIN
					SET @ErrorMessage = ERROR_MESSAGE();
					PRINT @ErrorMessage
					ROLLBACK TRANSACTION
					RETURN
				END	
				IF @@TRANCOUNT>0
				BEGIN
					SET @ErrorMessage = ERROR_MESSAGE();
					PRINT @ErrorMessage
					ROLLBACK TRANSACTION
					RETURN
				END
			END CATCH

			IF ISNULL(@success,0) = 1
			BEGIN
				UPDATE tblMBILInvoice SET ysnPosted = 1 WHERE intInvoiceId IN (select intInvoiceId from #TempMBILInvoice)
				SET @ErrorMessage = 'Invoice successfully posted';
				RETURN
			END	
			ELSE
			BEGIN
				SET @ErrorMessage = 'Unable to post transction. Kindly check the created invoice for details.';
				RETURN
			END					
		END
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
			, [strInvoiceOriginId]
			, [ysnUseOriginIdAsInvoiceNumber]
		)
	SELECT 
		 [intInvoiceId]
		,[strTransactionType] = InvoiceItem.strType
		,[strType] = 'Tank Delivery'
		,[strSourceTransaction] = 'Mobile Billing'
		,[intSourceId] = InvoiceItem.intInvoiceId
		,[strSourceId] = InvoiceItem.strInvoiceNo
		,[intEntityCustomerId] = InvoiceItem.intEntityCustomerId
		,[intCompanyLocationId] = InvoiceItem.intLocationId
		,[intCurrencyId] = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
		,[intEntityId] = InvoiceItem.intEntityCustomerId
		,[dtmDate] = InvoiceItem.dtmInvoiceDate
		,[dtmDueDate] = NULL
		,[dtmShipDate] = InvoiceItem.dtmDeliveryDate
		,[dtmPostDate] = InvoiceItem.dtmPostedDate
		,[strComments] = InvoiceItem.strComments
		,[ysnPost] = @ysnPost
		--,[intEntitySalespersonId] = CONVERT(INT,ISNULL(InvoiceItem.intDriverId,0))
		,[strItemDescription] = InvoiceItem.strItemDescription
		,[intTaxGroupId] = NULL
		,[intTermId] = InvoiceItem.intTermId
		,[intTruckDriverId] = CONVERT(INT,ISNULL(InvoiceItem.intDriverId,0))
		,[strPaymentInfo]
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
		,[strInvoiceOriginId] = InvoiceItem.strInvoiceNo
		,[ysnUseOriginIdAsInvoiceNumber] = 1

	FROM vyuMBILInvoiceItem InvoiceItem
	WHERE (inti21InvoiceId IS NULL OR inti21InvoiceId NOT IN (SELECT intInvoiceId FROM tblARInvoice)) AND intInvoiceId IN (select intInvoiceId from #TempMBILInvoice)

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
			,@RaiseError		= 0
			,@BatchId			= @BatchId
			,@ErrorMessage		= @ErrorMessage OUTPUT
			--,@CreatedIvoices	= @CreatedInvoices OUTPUT
			--,@UpdatedIvoices	= @UpdatedInvoices OUTPUT
			,@LogId				= @LogId OUTPUT


	IF (ISNULL(@ysnRecap,0) = 0 AND (@ysnPost = 1))
	BEGIN
		--SELECT @SuccessfulCount = COUNT(*) FROM #TempMBILInvoice

		CREATE TABLE #InvoiceTemp(intInvoiceId int)
		INSERT INTO #InvoiceTemp(intInvoiceId) SELECT intInvoiceId FROM #TempMBILInvoice
		
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

			--UPDATE tblARInvoice 
			--	SET strInvoiceNumber = (SELECT TOP 1 strInvoiceNo FROM tblMBILInvoice WHERE intInvoiceId = @intInvoiceId) 
			--	WHERE intInvoiceId   = (SELECT TOP 1 intInvoiceId FROM tblARInvoice A
			--							WHERE A.intEntityCustomerId = (SELECT TOP 1 intEntityCustomerId FROM tblMBILInvoice WHERE intInvoiceId = @intInvoiceId) 
			--							AND A.intSourceId = @intInvoiceId 
			--							AND A.strType = 'Tank Delivery' order by dtmDateCreated desc)
		END
		SELECT @SuccessfulCount  = count(1) FROM tblARInvoice ar INNER JOIN tblMBILInvoice mb ON ar.intInvoiceId = mb.inti21InvoiceId WHERE mb.intInvoiceId in(SELECT intInvoiceId FROM #InvoiceTemp) and ar.ysnPosted = 1
	END

	IF @BatchId IS NULL
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @LogId)
		BEGIN
			SELECT TOP 1 @ErrorMessage = ISNULL(strPostingMessage, strMessage) FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @LogId
			

			IF @ErrorMessage like '%was not set up to be available on the specified location%'
			BEGIN
				SET @ErrorMessage = @ErrorMessage
				RAISERROR(@ErrorMessage,16,1)
			END
			ELSE IF @ErrorMessage <> 'Transaction successfully posted.'
			BEGIN
				SET @ErrorMessage = @ErrorMessage + ' Kindly check the created invoice for details.'
				RAISERROR(@ErrorMessage,16,1)
			END
		END
	END
	

	IF @BatchId IS NULL
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @LogId)
		BEGIN
			SELECT TOP 1 @ErrorMessage = ISNULL(strPostingMessage, strMessage) FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @LogId
			

			IF @ErrorMessage like '%was not set up to be available on the specified location%'
			BEGIN
				SET @ErrorMessage = @ErrorMessage
				RAISERROR(@ErrorMessage,16,1)
			END
			ELSE IF @ErrorMessage <> 'Transaction successfully posted.'
			BEGIN
				SET @ErrorMessage = @ErrorMessage + ' Kindly check the created invoice for details.'
				RAISERROR(@ErrorMessage,16,1)
			END
		END
	END
	

END







--select * from tblMBILInvoice
--update tblMBILInvoice set inti21InvoiceId = NULL, ysnPosted = 0, ysnVoided = 0 where intInvoiceId = 1047


--select * from tblMBILInvoice
--EXEC [uspMBILPostInvoice] 'select intInvoiceId from tblMBILInvoice where intInvoiceId = 6', 0, 1, 1
--select * from tblMBILInvoice
