CREATE PROCEDURE [dbo].[uspARPOSReturn]
	@intPOSId AS INT,
	@strMessage AS VARCHAR(50) OUTPUT 
AS

	DECLARE @intOriginalPOSTransactionId INT = NULL,
			@intEntityId				 INT = NULL,
			@intInvoiceId				 INT = NULL,
			@intCompanyLocationId		 INT = NULL,
			@ysnReturned				 BIT = 0,
			@DateOnly					 DATETIME = CAST(GETDATE() AS DATE),
			@errorMessage				 NVARCHAR(250),
			@createdCreditMemo			 NVARCHAR(MAX),
			@updatedCreditMemo			 NVARCHAR(MAX),
			@createdCreditMemoId		 INT = NULL,
			@createdCreditMemoType		 VARCHAR(50),
			@createdCreditMemoTransactionType	VARCHAR(20),

			@EntriesForCreditMemo AS InvoiceIntegrationStagingTable,
			@LineItemTaxes AS LineItemTaxDetailStagingTable

	--SET Variables
	SELECT TOP 1
		@intOriginalPOSTransactionId = intOriginalPOSTransactionId,
		@intEntityId				 = intEntityUserId
	FROM tblARPOS
	WHERE intPOSId = @intPOSId

	SELECT TOP 1
		@intInvoiceId = intInvoiceId
	FROM tblARPOS
	WHERE intPOSId = @intOriginalPOSTransactionId

	SELECT TOP 1
		@ysnReturned = ysnReturned
	FROM tblARInvoice
	WHERE intInvoiceId = @intInvoiceId
	
	IF(OBJECT_ID('tempdb..#POSRETURNPAYMENTS') IS NOT NULL)
	BEGIN
		DROP TABLE #POSRETURNPAYMENTS
	END

	SELECT intPOSId			= intPOSId
		 , intPOSPaymentId	= intPOSPaymentId
		 , strPaymentMethod	= CASE WHEN strPaymentMethod ='Credit Card' THEN 'Manual Credit Card' ELSE strPaymentMethod END
		 , strReferenceNo	= strReferenceNo
		 , dblAmount		= dblAmount
		 , ysnComputed		= CAST(0 AS BIT)
	INTO #POSRETURNPAYMENTS
	FROM dbo.tblARPOSPayment WITH (NOLOCK)
	WHERE intPOSId = @intPOSId
	  AND ISNULL(strPaymentMethod, '')  <> 'On Account'


	--CREATE ENTRIES FOR INVOICE
	IF(@ysnReturned = 0)
	BEGIN
	BEGIN TRANSACTION
		INSERT INTO @EntriesForCreditMemo(
			 [strTransactionType]
			,[strType]
			,[strSourceTransaction]
			,[intSourceId]
			,[strSourceId]
			,[intInvoiceId]
			,[intEntityCustomerId]
			,[intCompanyLocationId]
			,[intAccountId]
			,[intCurrencyId]
			,[intTermId]
			,[dtmDate]
			,[dtmDueDate]
			,[dtmShipDate]
			,[dtmPostDate]
			,[intEntitySalespersonId]
			,[intFreightTermId]
			,[intShipViaId]
			,[intPaymentMethodId]
			,[strInvoiceOriginId]
			,[ysnUseOriginIdAsInvoiceNumber]
			,[strPONumber]
			,[strComments]
			,[intShipToLocationId]
			,[intBillToLocationId]
			,[ysnTemplate]
			,[ysnForgiven]
			,[ysnCalculated]
			,[ysnSplitted]
			,[ysnImpactInventory]
			,[intPaymentId]
			,[intSplitId]
			,[intLoadDistributionHeaderId]
			,[strActualCostId]
			,[intShipmentId]
			,[intTransactionId]
			,[intMeterReadingId]
			,[intContractHeaderId]
			,[intLoadId]
			,[intOriginalInvoiceId]
			,[intEntityId]
			,[intTruckDriverId]
			,[intTruckDriverReferenceId]
			,[ysnResetDetails]
			,[ysnRecap]
			,[ysnPost]
			,[ysnUpdateAvailableDiscount]

			--Details
			,[intInvoiceDetailId]
			,[intItemId]
			,[intPrepayTypeId]
			,[dblPrepayRate]
			,[ysnInventory]
			,[strDocumentNumber]
			,[strItemDescription]
			,[intOrderUOMId]
			,[dblQtyOrdered]
			,[intItemUOMId]
			,[dblQtyShipped]
			,[dblDiscount]
			,[dblItemTermDiscount]
			,[strItemTermDiscountBy]
			,[dblItemWeight]
			,[intItemWeightUOMId]
			,[dblPrice]
			,[dblUnitPrice]
			,[strPricing]
			,[strVFDDocumentNumber]
			,[ysnRefreshPrice]
			,[strMaintenanceType]
			,[strFrequency]
			,[dtmMaintenanceDate]
			,[dblMaintenanceAmount]
			,[dblLicenseAmount]
			,[intTaxGroupId]
			,[intStorageLocationId]
			,[intCompanyLocationSubLocationId]
			,[ysnRecomputeTax]
			,[intSCInvoiceId]
			,[strSCInvoiceNumber]
			,[intSCBudgetId]
			,[strSCBudgetDescription]
			,[intInventoryShipmentItemId]
			,[intInventoryShipmentChargeId]
			,[strShipmentNumber]
			,[intRecipeItemId]
			,[intRecipeId]
			,[intSubLocationId]
			,[intCostTypeId]
			,[intMarginById]
			,[intCommentTypeId]
			,[dblMargin]
			,[dblRecipeQuantity]
			,[intSalesOrderDetailId]
			,[strSalesOrderNumber]
			,[intContractDetailId]
			,[intShipmentPurchaseSalesContractId]
			,[dblShipmentGrossWt]
			,[dblShipmentTareWt]
			,[dblShipmentNetWt]
			,[intTicketId]
			,[intTicketHoursWorkedId]
			,[intCustomerStorageId]
			,[intSiteDetailId]
			,[intLoadDetailId]
			,[intLotId]
			,[intOriginalInvoiceDetailId]
			,[intSiteId]
			,[strBillingBy]
			,[dblPercentFull]
			,[dblNewMeterReading]
			,[dblPreviousMeterReading]
			,[dblConversionFactor]
			,[intPerformerId]
			,[ysnLeaseBilling]
			,[ysnVirtualMeterReading]
			,[ysnClearDetailTaxes]
			,[intTempDetailIdForTaxes]
			,[intCurrencyExchangeRateTypeId]
			,[intCurrencyExchangeRateId]
			,[dblCurrencyExchangeRate]
			,[intSubCurrencyId]
			,[dblSubCurrencyRate]
			,[ysnBlended]
			,[strImportFormat]
			,[dblCOGSAmount]
			,[intConversionAccountId]
			,[intSalesAccountId]
			,[intStorageScheduleTypeId]
			,[intDestinationGradeId]
			,[intDestinationWeightId]
		)
		SELECT
			[strTransactionType]					= 'Credit Memo'
			,[strType]								= 'POS'
			,[strSourceTransaction]					= 'POS'
			,[intSourceId]							= @intPOSId 
			,[strSourceId]							= ARI.[strInvoiceNumber]
			,[intInvoiceId]							= NULL
			,[intEntityCustomerId]					= ARI.[intEntityCustomerId]
			,[intCompanyLocationId]					= ARI.[intCompanyLocationId]
			,[intAccountId]							= ARI.[intAccountId]
			,[intCurrencyId]						= ARI.[intCurrencyId]
			,[intTermId]							= ARI.[intTermId]
			,[dtmDate]								= @DateOnly
			,[dtmDueDate]							= NULL
			,[dtmShipDate]							= @DateOnly
			,[dtmPostDate]							= @DateOnly
			,[intEntitySalespersonId]				= ARI.[intEntitySalespersonId]
			,[intFreightTermId]						= ARI.[intFreightTermId]
			,[intShipViaId]							= ARI.[intShipViaId]
			,[intPaymentMethodId]					= ARI.[intPaymentMethodId]
			,[strInvoiceOriginId]					= ARI.[strInvoiceNumber]
			,[ysnUseOriginIdAsInvoiceNumber]		= 0
			,[strPONumber]							= ARI.[strPONumber]
			,[strComments]							= ARI.[strComments]
			,[intShipToLocationId]					= ARI.[intShipToLocationId]
			,[intBillToLocationId]					= ARI.[intBillToLocationId]
			,[ysnTemplate]							= 0
			,[ysnForgiven]							= ARI.[ysnForgiven]
			,[ysnCalculated]						= ARI.[ysnCalculated]
			,[ysnSplitted]							= ARI.[ysnSplitted]
			,[ysnImpactInventory]					= 1
			,[intPaymentId]							= ARI.[intPaymentId]
			,[intSplitId]							= ARI.[intSplitId]
			,[intLoadDistributionHeaderId]			= ARI.[intLoadDistributionHeaderId]
			,[strActualCostId]						= ARI.[strActualCostId]
			,[intShipmentId]						= ARI.[intShipmentId]
			,[intTransactionId]						= ARI.[intTransactionId]
			,[intMeterReadingId]					= ARI.[intMeterReadingId]
			,[intContractHeaderId]					= ARI.[intContractHeaderId]
			,[intLoadId]							= ARI.[intLoadId]
			,[intOriginalInvoiceId]					= NULL
			,[intEntityId]							= @intEntityId
			,[intTruckDriverId]						= ARI.[intTruckDriverId]
			,[intTruckDriverReferenceId]			= ARI.[intTruckDriverReferenceId]
			,[ysnResetDetails]						= 0
			,[ysnRecap]								= 0
			,[ysnPost]								= 1
			,[ysnUpdateAvailableDiscount]			= 0
			--Detail																																															
			,[intInvoiceDetailId]					= NULL
			,[intItemId]							= ARID.[intItemId]
			,[intPrepayTypeId]						= ARID.[intPrepayTypeId]
			,[dblPrepayRate]						= ARID.[dblPrepayRate]
			,[ysnInventory]							= NULL
			,[strDocumentNumber]					= ARI.[strInvoiceNumber]
			,[strItemDescription]					= ARID.[strItemDescription]
			,[intOrderUOMId]						= ARID.[intOrderUOMId]
			,[dblQtyOrdered]						= ARID.[dblQtyOrdered]
			,[intItemUOMId]							= ARID.[intItemUOMId]
			,[dblQtyShipped]						= ARID.[dblQtyShipped]
			,[dblDiscount]							= ARID.[dblDiscount]
			,[dblItemTermDiscount]					= ARID.[dblItemTermDiscount]
			,[strItemTermDiscountBy]				= ARID.[strItemTermDiscountBy]
			,[dblItemWeight]						= ARID.[dblItemWeight]
			,[intItemWeightUOMId]					= ARID.[intItemWeightUOMId]
			,[dblPrice]								= ARID.[dblPrice]
			,[dblUnitPrice]							= ARID.[dblUnitPrice]
			,[strPricing]							= ARID.[strPricing]
			,[strVFDDocumentNumber]					= ARID.[strVFDDocumentNumber]
			,[ysnRefreshPrice]						= 0
			,[strMaintenanceType]					= ARID.[strMaintenanceType]
			,[strFrequency]							= ARID.[strFrequency]
			,[dtmMaintenanceDate]					= ARID.[dtmMaintenanceDate]
			,[dblMaintenanceAmount]					= ARID.[dblMaintenanceAmount]
			,[dblLicenseAmount]						= ARID.[dblLicenseAmount]
			,[intTaxGroupId]						= ARID.[intTaxGroupId]
			,[intStorageLocationId]					= ARID.[intStorageLocationId]
			,[intCompanyLocationSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
			,[ysnRecomputeTax]						= 0
			,[intSCInvoiceId]						= ARID.[intSCInvoiceId]
			,[strSCInvoiceNumber]					= ARID.[strSCInvoiceNumber]
			,[intSCBudgetId]						= ARID.[intSCBudgetId]
			,[strSCBudgetDescription]				= ARID.[strSCBudgetDescription]
			,[intInventoryShipmentItemId]			= ARID.[intInventoryShipmentItemId]
			,[intInventoryShipmentChargeId]			= ARID.[intInventoryShipmentChargeId]
			,[strShipmentNumber]					= ARID.[strShipmentNumber]
			,[intRecipeItemId]						= ARID.[intRecipeItemId]
			,[intRecipeId]							= ARID.[intRecipeId]
			,[intSubLocationId]						= ARID.[intSubLocationId]
			,[intCostTypeId]						= ARID.[intCostTypeId]
			,[intMarginById]						= ARID.[intMarginById]
			,[intCommentTypeId]						= ARID.[intCommentTypeId]
			,[dblMargin]							= ARID.[dblMargin]
			,[dblRecipeQuantity]					= ARID.[dblRecipeQuantity]
			,[intSalesOrderDetailId]				= ARID.[intSalesOrderDetailId]
			,[strSalesOrderNumber]					= ARID.[strSalesOrderNumber]
			,[intContractDetailId]					= ARID.[intContractDetailId]
			,[intShipmentPurchaseSalesContractId]	= ARID.[intShipmentPurchaseSalesContractId]
			,[dblShipmentGrossWt]					= ARID.[dblShipmentGrossWt]
			,[dblShipmentTareWt]					= ARID.[dblShipmentTareWt]
			,[dblShipmentNetWt]						= ARID.[dblShipmentNetWt]
			,[intTicketId]							= ARID.[intTicketId]
			,[intTicketHoursWorkedId]				= ARID.[intTicketHoursWorkedId]
			,[intCustomerStorageId]					= ARID.[intCustomerStorageId]
			,[intSiteDetailId]						= ARID.[intSiteDetailId]
			,[intLoadDetailId]						= ARID.[intLoadDetailId]
			,[intLotId]								= ARID.[intLotId]
			,[intOriginalInvoiceDetailId]			= ARID.[intInvoiceDetailId]
			,[intSiteId]							= ARID.[intSiteId]
			,[strBillingBy]							= ARID.[strBillingBy]
			,[dblPercentFull]						= ARID.[dblPercentFull]
			,[dblNewMeterReading]					= ARID.[dblNewMeterReading]
			,[dblPreviousMeterReading]				= ARID.[dblPreviousMeterReading]
			,[dblConversionFactor]					= ARID.[dblConversionFactor]
			,[intPerformerId]						= ARID.[intPerformerId]
			,[ysnLeaseBilling]						= ARID.[ysnLeaseBilling]
			,[ysnVirtualMeterReading]				= ARID.[ysnVirtualMeterReading]
			,[ysnClearDetailTaxes]					= 0
			,[intTempDetailIdForTaxes]				= ARID.[intInvoiceDetailId]
			,[intCurrencyExchangeRateTypeId]		= ARID.[intCurrencyExchangeRateTypeId]
			,[intCurrencyExchangeRateId]			= ARID.[intCurrencyExchangeRateId]
			,[dblCurrencyExchangeRate]				= ARID.[dblCurrencyExchangeRate]
			,[intSubCurrencyId]						= ARID.[intSubCurrencyId]
			,[dblSubCurrencyRate]					= ARID.[dblSubCurrencyRate]
			,[ysnBlended]							= ARID.[ysnBlended]
			,[strImportFormat]						= NULL
			,[dblCOGSAmount]						= 0.000000
			,[intConversionAccountId]				= ARID.[intConversionAccountId]
			,[intSalesAccountId]					= ARID.[intSalesAccountId]
			,[intStorageScheduleTypeId]				= ARID.[intStorageScheduleTypeId]
			,[intDestinationGradeId]				= ARID.[intDestinationGradeId]
			,[intDestinationWeightId]				= ARID.[intDestinationWeightId]

		FROM tblARInvoiceDetail ARID
		INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId
		WHERE
			ARI.intInvoiceId = @intInvoiceId

		INSERT INTO @LineItemTaxes(
			 [intDetailId]
			,[intDetailTaxId]
			,[intTaxGroupId]
			,[intTaxCodeId]
			,[intTaxClassId]
			,[strTaxableByOtherTaxes]
			,[strCalculationMethod]
			,[dblRate]
			,[dblBaseRate]
			,[intTaxAccountId]
			,[dblTax]
			,[dblAdjustedTax]
			,[ysnTaxAdjusted]
			,[ysnSeparateOnInvoice]
			,[ysnCheckoffTax]
			,[ysnTaxExempt]
			,[ysnInvalidSetup]
			,[ysnTaxOnly]
			,[strNotes]
			,[intTempDetailIdForTaxes]
		)
		SELECT
			 [intDetailId]				= NULL
			,[intDetailTaxId]			= NULL
			,[intTaxGroupId]			= ARIDT.[intTaxGroupId]
			,[intTaxCodeId]				= ARIDT.[intTaxCodeId]
			,[intTaxClassId]			= ARIDT.[intTaxClassId]
			,[strTaxableByOtherTaxes]	= ARIDT.[strTaxableByOtherTaxes] 
			,[strCalculationMethod]		= ARIDT.[strCalculationMethod]
			,[dblRate]					= ARIDT.[dblRate]
			,[dblBaseRate]				= ISNULL(ARIDT.[dblBaseRate], ARIDT.[dblRate])
			,[intTaxAccountId]			= ARIDT.[intSalesTaxAccountId]
			,[dblTax]					= ARIDT.[dblTax]
			,[dblAdjustedTax]			= ARIDT.[dblAdjustedTax]
			,[ysnTaxAdjusted]			= ARIDT.[ysnTaxAdjusted]
			,[ysnSeparateOnInvoice]		= ARIDT.[ysnSeparateOnInvoice]
			,[ysnCheckoffTax]			= ARIDT.[ysnCheckoffTax]
			,[ysnTaxExempt]				= ARIDT.[ysnTaxExempt]
			,[ysnInvalidSetup]			= ARIDT.[ysnInvalidSetup]
			,[ysnTaxOnly]				= ARIDT.[ysnTaxOnly]
			,[strNotes]					= ARIDT.[strNotes]
			,[intTempDetailIdForTaxes]	= creditMemo.[intTempDetailIdForTaxes]
		FROM
			@EntriesForCreditMemo creditMemo
		INNER JOIN
			tblARInvoiceDetailTax ARIDT
				ON creditMemo.[intTempDetailIdForTaxes] = ARIDT.[intInvoiceDetailId]
		INNER JOIN tblARInvoiceDetail INVDETAIL
				ON creditMemo.[intTempDetailIdForTaxes] = INVDETAIL.intInvoiceDetailId
		WHERE INVDETAIL.intInvoiceId = @intInvoiceId
		ORDER BY 
			 creditMemo.[intTempDetailIdForTaxes] ASC
			,ARIDT.[intInvoiceDetailTaxId] ASC
		

		EXEC uspARProcessInvoices
			 @InvoiceEntries		= @EntriesForCreditMemo
			,@LineItemTaxEntries	= @LineItemTaxes
			,@UserId				= @intEntityId
			,@GroupingOption		= 1
			,@RaiseError			= 1
			,@ErrorMessage			= @errorMessage OUTPUT
			,@CreatedIvoices		= @createdCreditMemo OUTPUT
			,@UpdatedIvoices		= @updatedCreditMemo OUTPUT

		IF (LEN(ISNULL(@errorMessage, '')) > 0)
		BEGIN
			DELETE FROM tblARPOS
			WHERE intPOSId = @intPOSId

			DELETE FROM tblARPOSPayment
			WHERE intPOSId = @intPOSId

			ROLLBACK TRANSACTION
			SET @strMessage = @errorMessage
			RETURN 0;
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION
			UPDATE I
			SET dblDiscountAvailable = 0.000000
				,dblBaseDiscountAvailable = 0.000000
			FROM tblARInvoice I 
			INNER JOIN (
				SELECT intID
				FROM fnGetRowsFromDelimitedValues(@createdCreditMemo)
			)CI ON I.intInvoiceId = CI.intID

			UPDATE tblARInvoice
			SET ysnReturned = 1
			WHERE intInvoiceId = @intInvoiceId

			SELECT TOP 1
				@createdCreditMemoId				= intInvoiceId,
				@createdCreditMemoType				= strType,
				@createdCreditMemoTransactionType	= strTransactionType,
				@intCompanyLocationId				= intCompanyLocationId 
			FROM tblARInvoice
			WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@createdCreditMemo))

			UPDATE tblARPOS    
			SET intInvoiceId = @createdCreditMemoId    
			WHERE intPOSId = @intPOSId

			IF EXISTS(SELECT TOP 1 NULL FROM #POSRETURNPAYMENTS)
			BEGIN
				EXEC uspARPOSCreateNegativeCashReceipts 
						 @intInvoiceId			= @createdCreditMemoId
						,@intUserId				= @intEntityId
						,@intCompanyLocationId	= @intCompanyLocationId
						,@strErrorMessage		= @strMessage	OUTPUT
			END

			IF(LEN(ISNULL(@strMessage, '')) <= 0)
			BEGIN
				UPDATE tblARPOS
				SET ysnReturn = 1
				WHERE intPOSId = @intOriginalPOSTransactionId

				DECLARE @dblCashReturns DECIMAL(18,6) = 0.00000
				SELECT @dblCashReturns = SUM(dblAmount)
				FROM #POSRETURNPAYMENTS
				WHERE intPOSId = @intPOSId
				AND strPaymentMethod IN ('Cash', 'Check')

				
				UPDATE tblARPOSEndOfDay
				SET dblCashReturn = ISNULL(dblCashReturn ,0) + ISNULL(@dblCashReturns,0)
				FROM tblARPOSEndOfDay EOD
				INNER JOIN (
					SELECT
							intPOSLogId,
							intPOSEndOfDayId
					FROM tblARPOSLog
				)POSLOG ON EOD.intPOSEndOfDayId = POSLOG.intPOSEndOfDayId
				INNER JOIN (
					SELECT
						intPOSLogId,
						intPOSId
					FROM tblARPOS
				)POS ON POSLOG.intPOSLogId  = POS.intPOSLogId
				WHERE intPOSId = @intPOSId

				UPDATE tblARInvoice
				SET strComments = '<p><span style="font-family: Arial;">' + (SELECT strComment from tblARPOS WHERE intInvoiceId = @createdCreditMemoId) + '</span></p>'
				WHERE intInvoiceId = @createdCreditMemoId

			END
			ELSE
			BEGIN
				DELETE FROM tblARPOS
				WHERE intPOSId = @intPOSId

				DELETE FROM tblARPOSPayment
				WHERE intPOSId = @intPOSId

				RETURN 0;
			END
		END

	END
	ELSE
	BEGIN
		SET @strMessage = 'Sales Receipt is already returned'
		RAISERROR(@strMessage, 16, 1)
		RETURN 0;
	END