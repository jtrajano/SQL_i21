CREATE PROCEDURE [dbo].[uspARPOSReturn]
	@intInvoiceId AS INT,
	@intEntityId AS INT,
	@strPOSPaymentMethod AS VARCHAR(50) = NULL,
	@strMessage AS VARCHAR(50) OUTPUT 
AS
	DECLARE	@ysnReturned AS BIT = 0,
			@intSourceId AS INT = 0,
			@DateOnly	 AS DATETIME = CAST(GETDATE() AS DATE),
			@EntriesForCreditMemo AS InvoiceIntegrationStagingTable,
			@LineItemTaxes AS LineItemTaxDetailStagingTable,
			@errorMessage AS NVARCHAR(250),
			@createdCreditMemo NVARCHAR(MAX),
			@updatedCreditMemo NVARCHAR(MAX),
			@createdCreditMemoId AS INT = 0,
			@createdCreditMemoType AS VARCHAR(50),
			@createdCreditMemoTransactionType AS VARCHAR(20),
			@intCompanyLocationId AS INT,
			@intPaymentMethodID AS INT

	SELECT @ysnReturned = ysnReturned, @intSourceId = intSourceId
	FROM tblARInvoice
	WHERE intInvoiceId = @intInvoiceId

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
			,[strSourceTransaction]					= 'POS'--'Invoice'
			,[intSourceId]							= @intSourceId 
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
			,[ysnImpactInventory]					= 1 --ARI.[ysnImpactInventory]
			,[intPaymentId]							= ARI.[intPaymentId]
			,[intSplitId]							= ARI.[intSplitId]
			,[intLoadDistributionHeaderId]			= ARI.[intLoadDistributionHeaderId]
			,[strActualCostId]						= ARI.[strActualCostId]
			,[intShipmentId]						= ARI.[intShipmentId]
			,[intTransactionId]						= ARI.[intTransactionId]
			,[intMeterReadingId]					= ARI.[intMeterReadingId]
			,[intContractHeaderId]					= ARI.[intContractHeaderId]
			,[intLoadId]							= ARI.[intLoadId]
			,[intOriginalInvoiceId]					= NULL--ARI.[intInvoiceId]
			,[intEntityId]							= @intEntityId
			,[intTruckDriverId]						= ARI.[intTruckDriverId]
			,[intTruckDriverReferenceId]			= ARI.[intTruckDriverReferenceId]
			,[ysnResetDetails]						= 0
			,[ysnRecap]								= NULL
			,[ysnPost]								= NULL
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
			,[ysnTaxOnly]				= ARIDT.[ysnTaxOnly]
			,[strNotes]					= ARIDT.[strNotes]
			,[intTempDetailIdForTaxes]	= creditMemo.[intTempDetailIdForTaxes]
		FROM
			@EntriesForCreditMemo creditMemo
		INNER JOIN
			tblARInvoiceDetailTax ARIDT
				ON creditMemo.[intTempDetailIdForTaxes] = ARIDT.[intInvoiceDetailId] 
		ORDER BY 
			 creditMemo.[intInvoiceDetailId] ASC
			,ARIDT.[intInvoiceDetailTaxId] ASC


		Declare @ReceiptNumber NVARCHAR(25) = NULL
		Exec uspARGetReceiptNumber @strReceiptNumber = @ReceiptNumber output

		INSERT INTO tblARPOS (
				 [strReceiptNumber]
				,[intEntityCustomerId]
				,[intCompanyLocationId]
				,[intGLAccountId]
				,[intCurrencyId]
				,[dtmDate]
				,[intItemCount]
				,[dblShipping]
				,[dblDiscountPercent]
				,[dblDiscount]
				,[dblTax]
				,[dblSubTotal]
				,[dblTotal]
				,[intInvoiceId]
				,[ysnHold]
				,[intEntityUserId]
				,[intPOSLogId]
				,[intConcurrencyId]
				,[ysnReturn]
				,[strPONumber]
				,[strComment]
			)
			SELECT 
				@ReceiptNumber
				,[intEntityCustomerId]
				,[intCompanyLocationId]
				,[intGLAccountId]
				,[intCurrencyId]
				,[dtmDate]
				,[intItemCount]
				,[dblShipping]
				,[dblDiscountPercent]
				,[dblDiscount]
				,-[dblTax]
				,-[dblSubTotal]
				,-[dblTotal]
				,0
				,[ysnHold]
				,[intEntityUserId]
				,[intPOSLogId]
				,[intConcurrencyId]
				,1
				,[strPONumber]
				,[strComment]
			FROM tblARPOS WHERE intPOSId = @intSourceId

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

			EXEC uspARPostInvoice @param = @createdCreditMemoId, @post = 1

			-- SELECT @strPOSPaymentMethod = posPayment.strPaymentMethod
			-- FROM tblARPOSPayment posPayment
			-- INNER JOIN tblARPOS pos ON posPayment.intPOSId = pos.intPOSId
			-- WHERE pos.intInvoiceId = @intInvoiceId
			SELECT @intPaymentMethodID = intPaymentMethodID FROM tblSMPaymentMethod
			WHERE strPaymentMethod = @strPOSPaymentMethod 

			IF(@strPOSPaymentMethod != 'On Account')
			BEGIN
				EXEC uspARPOSCreateNegativeCashReceipts 
						 @intInvoiceId			= @createdCreditMemoId
						,@intUserId				= @intEntityId
						,@intCompanyLocationId	= @intCompanyLocationId
						,@intPaymentMethodID	= @intPaymentMethodID
						,@strErrorMessage		= @strMessage	OUTPUT
			END

			IF(LEN(ISNULL(@strMessage, '')) <= 0)
			BEGIN
				UPDATE tblARPOS
				SET ysnReturn = 1
				WHERE intInvoiceId = @intInvoiceId

				UPDATE tblARPOS    
				SET intInvoiceId = @createdCreditMemoId    
				WHERE strReceiptNumber = @ReceiptNumber  
				
				SET @strMessage = NULL
			END

		END

	END
	ELSE
	BEGIN
		SET @strMessage = 'Sales Receipt is already returned'
		RETURN 0;
	END