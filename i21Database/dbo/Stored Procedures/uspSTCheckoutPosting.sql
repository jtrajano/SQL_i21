CREATE PROCEDURE [dbo].[uspSTCheckoutPosting]
@intCheckoutId Int,
@strDirection NVARCHAR(50),
@strStatusMsg NVARCHAR(1000) OUTPUT,
@strNewCheckoutStatus NVARCHAR(100) OUTPUT
AS
BEGIN
	BEGIN TRY

		SET @strStatusMsg = 'Success'

		DECLARE @intEntityCustomerId INT = (SELECT intCheckoutCustomerId FROM tblSTStore 
											WHERE intStoreId = (
												SELECT intStoreId FROM tblSTCheckoutHeader
												WHERE intCheckoutId = @intCheckoutId
											))

		DECLARE @intCompanyLocationId INT = (SELECT intCompanyLocationId FROM tblSTStore 
											WHERE intStoreId = (
												SELECT intStoreId FROM tblSTCheckoutHeader
												WHERE intCheckoutId = @intCheckoutId
											))

		DECLARE @intCurrencyId INT = (SELECT intDefaultCurrencyId FROM tblSMCompanyPreference)
		DECLARE @intShipViaId INT = (SELECT TOP 1 1 intShipViaId FROM tblEMEntityLocation WHERE intEntityId = @intEntityCustomerId AND intShipViaId IS NOT NULL)
		DECLARE @intTaxGroupId INT = (SELECT intTaxGroupId FROM tblSTStore WHERE intStoreId = (SELECT intStoreId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId))
		DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
		DECLARE @CheckoutCurrentStatus NVARCHAR(50) = (SELECT strCheckoutStatus FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId)

		
		IF(@strDirection = 'Post' AND @CheckoutCurrentStatus = 'Manager Verified')
		BEGIN
		-- =========================================================================================================================
		-- (START) POST PUMP TOTALS

			INSERT INTO @EntriesForInvoice(
							 [strSourceTransaction]
							,[strTransactionType]
							,[intSourceId]
							,[strSourceId]
							,[intInvoiceId]
							,[intEntityCustomerId]
							,[intCompanyLocationId]
							,[intCurrencyId]
							,[intTermId]
							,[dtmDate]
							,[dtmDueDate]
							,[dtmShipDate]
							,[dtmCalculated]
							,[dtmPostDate]
							,[intEntitySalespersonId]
							,[intFreightTermId]
							,[intShipViaId]
							,[intPaymentMethodId]
							,[strInvoiceOriginId]
							,[strPONumber]
							,[strBOLNumber]
							,[strComments]
							,[intShipToLocationId]
							,[intBillToLocationId]
							,[ysnTemplate]
							,[ysnForgiven]
							,[ysnCalculated]
							,[ysnSplitted]
							,[intPaymentId]
							,[intSplitId]
							,[intLoadDistributionHeaderId]
							,[strActualCostId]
							,[intShipmentId]
							,[intTransactionId]
							,[intEntityId]
							,[ysnResetDetails]
							,[ysnPost]
							,[intInvoiceDetailId]
							,[intItemId]
							,[ysnInventory]
							,[strItemDescription]
							,[intOrderUOMId]
							,[dblQtyOrdered]
							,[intItemUOMId]
							,[dblQtyShipped]
							,[dblDiscount]
							,[dblPrice]
							,[ysnRefreshPrice]
							,[strMaintenanceType]
							,[strFrequency]
							,[dtmMaintenanceDate]
							,[dblMaintenanceAmount]
							,[dblLicenseAmount]
							,[intTaxGroupId]
							,[ysnRecomputeTax]
							,[intSCInvoiceId]
							,[strSCInvoiceNumber]
							,[intInventoryShipmentItemId]
							,[strShipmentNumber]
							,[intSalesOrderDetailId]
							,[strSalesOrderNumber]
							,[intContractHeaderId]
							,[intContractDetailId]
							,[intShipmentPurchaseSalesContractId]
							,[intTicketId]
							,[intTicketHoursWorkedId]
							,[intSiteId]
							,[strBillingBy]
							,[dblPercentFull]
							,[dblNewMeterReading]
							,[dblPreviousMeterReading]
							,[dblConversionFactor]
							,[intPerformerId]
							,[ysnLeaseBilling]
							,[ysnVirtualMeterReading]
							,[strImportFormat]
							,[dblCOGSAmount]
							,[intTempDetailIdForTaxes]
							,[intConversionAccountId]
							,[intCurrencyExchangeRateTypeId]
							,[intCurrencyExchangeRateId]
							,[dblCurrencyExchangeRate]
							,[intSubCurrencyId]
							,[dblSubCurrencyRate]
						)
						SELECT 
							 [strSourceTransaction]		= 'Invoice'
							,[strTransactionType]		= 'Invoice'
							,[intSourceId]				= @intCheckoutId
							,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
							,[intInvoiceId]				= NULL
							,[intEntityCustomerId]		= @intEntityCustomerId
							,[intCompanyLocationId]		= @intCompanyLocationId
							,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
							,[intTermId]				= NULL
							,[dtmDate]					= GETDATE()
							,[dtmDueDate]				= GETDATE()
							,[dtmShipDate]				= GETDATE()
							,[dtmCalculated]			= GETDATE()
							,[dtmPostDate]				= GETDATE()
							,[intEntitySalespersonId]	= NULL
							,[intFreightTermId]			= @intCompanyLocationId --@intEntityLocationId
							,[intShipViaId]				= @intShipViaId
							,[intPaymentMethodId]		= NULL
							,[strInvoiceOriginId]		= NULL -- not sure
							,[strPONumber]				= NULL -- not sure
							,[strBOLNumber]				= NULL -- not sure
							,[strComments]				= 'Sample Checkout'
							,[intShipToLocationId]		= NULL
							,[intBillToLocationId]		= NULL
							,[ysnTemplate]				= 0
							,[ysnForgiven]				= 0
							,[ysnCalculated]			= 0 -- not sure
							,[ysnSplitted]				= 0
							,[intPaymentId]				= NULL
							,[intSplitId]				= NULL
							,[intLoadDistributionHeaderId]	= NULL
							,[strActualCostId]			= NULL
							,[intShipmentId]			= NULL
							,[intTransactionId]			= NULL
							,[intEntityId]				= 1
							,[ysnResetDetails]			= 1
							,[ysnPost]					= 1
							,[intInvoiceDetailId]		= NULL
							,[intItemId]				= I.intItemId
							,[ysnInventory]				= 1
							,[strItemDescription]		= I.strDescription
							,[intOrderUOMId]			= NULL
							,[dblQtyOrdered]			= CPT.dblQuantity --(Select dblQuantity From tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
							,[intItemUOMId]				= NULL
							,[dblQtyShipped]			= CPT.dblQuantity --(Select dblQuantity From tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
							,[dblDiscount]				= 0
							,[dblPrice]					= CPT.dblPrice --(Select dblPrice From tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
							,[ysnRefreshPrice]			= 0
							,[strMaintenanceType]		= NULL
							,[strFrequency]				= NULL
							,[dtmMaintenanceDate]		= NULL
							,[dblMaintenanceAmount]		= NULL
							,[dblLicenseAmount]			= NULL
							,[intTaxGroupId]			= @intTaxGroupId
							,[ysnRecomputeTax]			= 0 -- not sure
							,[intSCInvoiceId]			= NULL
							,[strSCInvoiceNumber]		= NULL
							,[intInventoryShipmentItemId] = NULL
							,[strShipmentNumber]		= NULL
							,[intSalesOrderDetailId]	= NULL
							,[strSalesOrderNumber]		= NULL
							,[intContractHeaderId]		= NULL
							,[intContractDetailId]		= NULL
							,[intShipmentPurchaseSalesContractId]	= NULL
							,[intTicketId]				= NULL
							,[intTicketHoursWorkedId]	= NULL
							,[intSiteId]				= NULL -- not sure
							,[strBillingBy]				= NULL -- not sure
							,[dblPercentFull]			= NULL
							,[dblNewMeterReading]		= NULL
							,[dblPreviousMeterReading]	= NULL -- not sure
							,[dblConversionFactor]		= NULL -- not sure
							,[intPerformerId]			= NULL -- not sure
							,[ysnLeaseBilling]			= NULL
							,[ysnVirtualMeterReading]	= 0 --'Not Familiar'
							,[strImportFormat]			= 'Not Familiar'
							,[dblCOGSAmount]			= IP.dblSalePrice
							,[intTempDetailIdForTaxes]  = I.intItemId
							,[intConversionAccountId]	= NULL -- not sure
							,[intCurrencyExchangeRateTypeId]	= NULL
							,[intCurrencyExchangeRateId]		= NULL
							,[dblCurrencyExchangeRate]	= 1.000000
							,[intSubCurrencyId]			= NULL
							,[dblSubCurrencyRate]		= 1.000000
			FROM tblSTCheckoutPumpTotals CPT
			JOIN tblICItemUOM UOM ON CPT.intPumpCardCouponId = UOM.intItemUOMId
			JOIN tblSTCheckoutHeader CH ON CPT.intCheckoutId = CH.intCheckoutId
			JOIN tblICItem I ON UOM.intItemId = I.intItemId
			JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
			JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
									AND IL.intItemLocationId = IP.intItemLocationId
			JOIN tblSTStore ST ON IL.intLocationId = ST.intCompanyLocationId
								AND CH.intStoreId = ST.intStoreId
			WHERE CPT.intCheckoutId = @intCheckoutId
			AND CPT.dblAmount > 0

			DECLARE @ErrorMessage AS NVARCHAR(MAX) = ''
			DECLARE @CreatedIvoices AS NVARCHAR(MAX) = ''

			-- SELECT * FROM @EntriesForInvoice

			EXEC [dbo].[uspARProcessInvoices]
							 @InvoiceEntries	 = @EntriesForInvoice
							--,@LineItemTaxEntries = NULL
							,@UserId			 = 1
		 					,@GroupingOption	 = 11
							,@RaiseError		 = 1
							,@ErrorMessage		 = @ErrorMessage OUTPUT
							,@CreatedIvoices	 = @CreatedIvoices OUTPUT


			IF(@ErrorMessage IS NULL OR @ErrorMessage = '')
				BEGIN
					--UPDATE dbo.tblSTCheckoutHeader 
					--SET strCheckoutStatus = @strCheckoutStatus 
					--WHERE intCheckoutId = @intCheckoutId

					SET @strStatusMsg = 'Success'
				END
			ELSE
				BEGIN
					SET @strStatusMsg = @ErrorMessage
				END	
		-- (END) POST PUMP TOTALS
		-- =========================================================================================================================

		END
		
		
		
		IF(@strDirection = 'Post' AND @CheckoutCurrentStatus = 'Manager Verified')
			BEGIN
				SET @strNewCheckoutStatus = 'Posted'
			END
		ELSE IF(@strDirection = 'Post' AND @CheckoutCurrentStatus = 'Open')
			BEGIN
				SET @strNewCheckoutStatus = 'Manager Verified'
			END
		--ELSE IF (@strDirection = 'UnPost' AND @CheckoutCurrentStatus = 'Manager Verified')
		--	BEGIN
		--		SET @CheckoutUpdatedStatus = 'Manager Verified'
		--	END
		ELSE IF (@strDirection = 'UnPost' AND @CheckoutCurrentStatus = 'Posted')
			BEGIN
				SET @strNewCheckoutStatus = 'Manager Verified'
			END
		--ELSE IF (@strDirection = 'SendToOffice' AND @CheckoutCurrentStatus = 'Open')
		--	BEGIN
		--		SET @CheckoutUpdatedStatus = 'Send to Office'
		--	END
		ELSE IF (@strDirection = 'SendBackToStore' AND @CheckoutCurrentStatus = 'Manager Verified')
			BEGIN
				SET @strNewCheckoutStatus = 'Open'
			END



		IF(@strStatusMsg = 'Success')
			BEGIN
				  UPDATE dbo.tblSTCheckoutHeader 
				  SET strCheckoutStatus = @strNewCheckoutStatus 
				  WHERE intCheckoutId = @intCheckoutId
			END
	END TRY

	BEGIN CATCH
		SET @strStatusMsg = ERROR_MESSAGE()
	END CATCH
END