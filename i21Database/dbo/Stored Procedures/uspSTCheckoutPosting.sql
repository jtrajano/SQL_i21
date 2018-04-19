CREATE PROCEDURE [dbo].[uspSTCheckoutPosting]
@intCurrentUserId INT,
@intCheckoutId INT,
@strDirection NVARCHAR(50),
@strStatusMsg NVARCHAR(1000) OUTPUT,
@strNewCheckoutStatus NVARCHAR(100) OUTPUT
AS
BEGIN
	BEGIN TRY

		SET @strStatusMsg = 'Success'

		DECLARE @ysnUpdateCheckoutStatus BIT = 1

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
		DECLARE @ysnPost BIT = NULL
		DECLARE @intCurrentInvoiceId INT = (SELECT intInvoiceId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId)
		DECLARE @intCreatedInvoiceId INT = NULL


		----------------------------------------------------------------------
		-------------------- Check current Invoice status --------------------
		----------------------------------------------------------------------
		DECLARE @ysnCurrentInvoiceStatus BIT = NULL
		IF(@intCurrentInvoiceId IS NOT NULL)
			BEGIN
				IF EXISTS(SELECT intInvoiceId FROM tblARInvoice WHERE intInvoiceId = @intCurrentInvoiceId)
					BEGIN
						SET @ysnCurrentInvoiceStatus = (SELECT ysnPosted FROM tblARInvoice WHERE intInvoiceId = @intCurrentInvoiceId)
					END
				
			END
		----------------------------------------------------------------------
		------------------ End check current Invoice status ------------------
		----------------------------------------------------------------------


		----------------------------------------------------------------------
		-------------------- Verify Posting Direction ------------------------
		----------------------------------------------------------------------
		IF(@strDirection = 'Post' AND @CheckoutCurrentStatus = 'Manager Verified')
			BEGIN
				IF(@ysnCurrentInvoiceStatus = 0 OR @ysnCurrentInvoiceStatus IS NULL) -- The Invoice current status is 'UnPosted' OR not yet Created
					BEGIN
						SET @ysnPost = 1
					END
				ELSE IF(@ysnCurrentInvoiceStatus = 1) -- The Invoice is already been 'Posted' 
					BEGIN
						SET @ysnPost = NULL -- Set to Null so Posting will not continue
						SET @ysnUpdateCheckoutStatus = 1
						SET @strStatusMsg = 'Checkout already been Posted'
					END
			END
		ELSE IF (@strDirection = 'UnPost' AND @CheckoutCurrentStatus = 'Posted')
			BEGIN
				IF(@ysnCurrentInvoiceStatus = 1) -- The Invoice current status is 'Posted'
					BEGIN
						SET @ysnPost = 0
					END
				ELSE IF(@ysnCurrentInvoiceStatus = 0) -- The Invoice is already been 'UnPosted' 
					BEGIN
						SET @ysnPost = NULL -- Set to Null so UnPosting will not continue
						SET @ysnUpdateCheckoutStatus = 1
						SET @strStatusMsg = 'Checkout already been UnPosted'
					END
			END
		----------------------------------------------------------------------
		-------------------- End Verify Posting Direction --------------------
		----------------------------------------------------------------------


		----------------------------------------------------------------------
		--------------------- POST / UNPOST PUMP TOTALS ----------------------
		----------------------------------------------------------------------
		IF(@ysnPost IS NOT NULL)
		BEGIN
			IF EXISTS(SELECT * FROM tblSTCheckoutPumpTotals WHERE intCheckoutId = @intCheckoutId AND dblAmount > 0)
				BEGIN
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
									,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
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
									,[intEntityId]				= @intCurrentUserId
									,[ysnResetDetails]			= 1
									,[ysnPost]					= @ysnPost -- 1 = 'Post', 2 = 'UnPost'
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
										,@UserId			 = @intCurrentUserId
		 								,@GroupingOption	 = 11
										,@RaiseError		 = 1
										,@ErrorMessage		 = @ErrorMessage OUTPUT
										,@CreatedIvoices	 = @CreatedIvoices OUTPUT

						SET @intCreatedInvoiceId = CAST(@CreatedIvoices AS INT)

						IF(@ErrorMessage IS NULL OR @ErrorMessage = '')
							BEGIN
								SET @ysnUpdateCheckoutStatus = 1
								SET @strStatusMsg = 'Success'
							END
						ELSE
							BEGIN
								SET @ysnUpdateCheckoutStatus = 0
								SET @strStatusMsg = @ErrorMessage
							END	
				END
			ELSE
				BEGIN
					SET @ysnUpdateCheckoutStatus = 0
					SET @strStatusMsg = 'No records found to Post in Pump Totals'
				END
		END
		----------------------------------------------------------------------
		------------------- END POST / UNPOST PUMP TOTALS --------------------
		----------------------------------------------------------------------
		

		IF(@ysnUpdateCheckoutStatus = 1)
			BEGIN
				-- Determine Status
				IF(@strDirection = 'Post' AND @CheckoutCurrentStatus = 'Manager Verified')
					BEGIN
						SET @strNewCheckoutStatus = 'Posted'
					END
				ELSE IF(@strDirection = 'Post' AND @CheckoutCurrentStatus = 'Open')
					BEGIN
						SET @strNewCheckoutStatus = 'Manager Verified'
					END
				ELSE IF (@strDirection = 'UnPost' AND @CheckoutCurrentStatus = 'Posted')
					BEGIN
						SET @strNewCheckoutStatus = 'Manager Verified'
					END
				ELSE IF (@strDirection = 'SendBackToStore' AND @CheckoutCurrentStatus = 'Manager Verified')
					BEGIN
						SET @strNewCheckoutStatus = 'Open'
					END



				IF(@ysnPost IS NULL)
					BEGIN
						UPDATE dbo.tblSTCheckoutHeader 
						SET strCheckoutStatus = @strNewCheckoutStatus
						WHERE intCheckoutId = @intCheckoutId
					END
				ELSE IF(@ysnPost = 1) -- POST
					BEGIN
						IF(@intCurrentInvoiceId IS NOT NULL AND @intCreatedInvoiceId IS NULL)
							BEGIN
								-- This is a Re-Post
								-- If current invoice exist it will just update from UnPosted to Posted
								UPDATE dbo.tblSTCheckoutHeader 
								SET strCheckoutStatus = @strNewCheckoutStatus
									, intInvoiceId = @intCurrentInvoiceId -- Retail current Invoice Id
								WHERE intCheckoutId = @intCheckoutId
							END
						ELSE IF(@intCurrentInvoiceId IS NULL AND @intCreatedInvoiceId IS NOT NULL)
							BEGIN
								-- First time to Post
								-- New created invoice will be made
								UPDATE dbo.tblSTCheckoutHeader 
								SET strCheckoutStatus = @strNewCheckoutStatus
									, intInvoiceId = @intCreatedInvoiceId -- New Invoice Id
								WHERE intCheckoutId = @intCheckoutId
							END
					END
				ELSE IF(@ysnPost = 0) -- UNPOST
					BEGIN
						UPDATE dbo.tblSTCheckoutHeader 
						SET strCheckoutStatus = @strNewCheckoutStatus
							, intInvoiceId = @intCurrentInvoiceId -- Current Invoice
						WHERE intCheckoutId = @intCheckoutId
					END
			END
	END TRY

	BEGIN CATCH
		SET @strStatusMsg = ERROR_MESSAGE()
	END CATCH
END