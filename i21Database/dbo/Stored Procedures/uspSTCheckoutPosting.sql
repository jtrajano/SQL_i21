CREATE PROCEDURE [dbo].[uspSTCheckoutPosting]
	@intCurrentUserId INT,
	@intCheckoutId INT,
	@strDirection NVARCHAR(50),
	@strStatusMsg NVARCHAR(1000) OUTPUT,
	@strNewCheckoutStatus NVARCHAR(100) OUTPUT,
	@ysnInvoiceStatus BIT OUTPUT,
	@ysnCustomerChargesInvoiceStatus BIT OUTPUT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	BEGIN TRY

		-- OUT Params
		SET @strStatusMsg = 'Success'
		SET @ysnInvoiceStatus = 0
		SET @ysnCustomerChargesInvoiceStatus = 0
		SET @strNewCheckoutStatus = ''

		DECLARE @LineItems AS LineItemTaxDetailStagingTable -- Dummy Table

		DECLARE @ysnUpdateCheckoutStatus BIT = 1

		DECLARE @intEntityCustomerId INT
		DECLARE @intCompanyLocationId INT
		DECLARE @intTaxGroupId INT
		DECLARE @intStoreId INT
		DECLARE @strComments NVARCHAR(MAX) = 'Store Checkout' -- All comments should be same to create a single Invoice
		DECLARE @strInvoiceType AS NVARCHAR(50) = 'Store Checkout'

		SELECT @intCompanyLocationId = intCompanyLocationId
			   , @intEntityCustomerId = intCheckoutCustomerId
			   , @intTaxGroupId = intTaxGroupId
			   , @intStoreId = intStoreId
		FROM tblSTStore 
		WHERE intStoreId = (
				SELECT intStoreId FROM tblSTCheckoutHeader
				WHERE intCheckoutId = @intCheckoutId
		)

		-- For Mark Up Down Posting
		DECLARE @intMarkUpDownId AS INT = (SELECT intMarkUpDownId FROM tblSTMarkUpDown WHERE intCheckoutId = @intCheckoutId)
		DECLARE @strMarkUpDownPostingStatusMsg AS NVARCHAR(1000) = ''
		DECLARE @strBatchId AS NVARCHAR(1000) = ''
		DECLARE @ysnIsPosted AS BIT

		DECLARE @intCurrencyId INT = (SELECT intDefaultCurrencyId FROM tblSMCompanyPreference)
		DECLARE @intShipViaId INT = (SELECT TOP 1 1 intShipViaId FROM tblEMEntityLocation WHERE intEntityId = @intEntityCustomerId AND intShipViaId IS NOT NULL)
		DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
		DECLARE @LineItemTaxEntries AS LineItemTaxDetailStagingTable
		DECLARE @ysnPost BIT = NULL
		-- DECLARE @CheckoutCurrentStatus NVARCHAR(50) = ''

		DECLARE @intCurrentInvoiceId INT
		DECLARE @strCurrentAllInvoiceIdList NVARCHAR(1000)
		DECLARE @dtmCheckoutDate AS DATETIME

		SELECT @intCurrentInvoiceId = intInvoiceId
				, @strCurrentAllInvoiceIdList = strAllInvoiceIdList
				, @dtmCheckoutDate = dtmCheckoutDate 
		FROM tblSTCheckoutHeader 
		WHERE intCheckoutId = @intCheckoutId


		DECLARE @intCreatedInvoiceId INT = NULL
		DECLARE @strAllCreatedInvoiceIdList NVARCHAR(1000)

		-- FOR UNPOST
		DECLARE @strInvoiceIdList NVARCHAR(50) = ''
		DECLARE @strCustomerChargesInvoiceId NVARCHAR(50) = ''
		DECLARE @ysnInvoiceIsPosted BIT = NULL
		DECLARE @intSuccessfullCount INT
		DECLARE @intInvalidCount INT
		DECLARE @ysnSuccess BIT
		DECLARE @strBatchIdUsed NVARCHAR(40)
		DECLARE @ysnError BIT = 1

		DECLARE @tblTempItems TABLE
		(
			intItemId INT
			, strItemNo NVARCHAR(100)
		)

		-- Create the temp table for the intInvoiceId's.
		IF OBJECT_ID('tempdb..#tmpCustomerInvoiceIdList') IS NOT NULL  
			BEGIN
				DROP TABLE #tmpCustomerInvoiceIdList
			END
		IF OBJECT_ID('tempdb..#tmpCustomerInvoiceIdList') IS NULL  
			BEGIN
				CREATE TABLE #tmpCustomerInvoiceIdList (
				intInvoiceId INT
			);
			END
			

		----------------------------------------------------------------------
		-------------------- Check current Invoice status --------------------
		----------------------------------------------------------------------
		DECLARE @ysnCurrentInvoiceStatus BIT = NULL
		IF(@intCurrentInvoiceId IS NOT NULL)
			BEGIN
				IF EXISTS(SELECT intInvoiceId FROM tblARInvoice WHERE intInvoiceId = @intCurrentInvoiceId)
					BEGIN
						SET @ysnCurrentInvoiceStatus = (SELECT ysnPosted FROM tblARInvoice WHERE intInvoiceId = @intCurrentInvoiceId)
						
						SET @ysnInvoiceStatus = @ysnCurrentInvoiceStatus
					END
			END
		ELSE
			BEGIN
				SET @ysnInvoiceStatus = 0 -- Set to false
			END
		----------------------------------------------------------------------
		------------------ End check current Invoice status ------------------
		----------------------------------------------------------------------



		----------------------------------------------------------------------
		-------------------- Verify Posting Direction ------------------------
		----------------------------------------------------------------------
		IF(@strDirection = 'Post')
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
		ELSE IF (@strDirection = 'UnPost')
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
		------------------------- POST / UNPOST ------------------------------
		----------------------------------------------------------------------
		IF(@ysnPost = 1)
			BEGIN
				----------------------------------------------------------------------
				---------------------------- PUMP TOTALS -----------------------------
				----------------------------------------------------------------------
				IF EXISTS(SELECT * FROM tblSTCheckoutPumpTotals WHERE intCheckoutId = @intCheckoutId AND dblAmount > 0)	
					BEGIN
						
						-- For own tax computation
						INSERT INTO @LineItemTaxEntries(
							 [intId]
							,[intDetailId]
							,[intDetailTaxId]
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
							,[dblCurrencyExchangeRate]
							,[ysnClearExisting]
							,[strTransactionType]
							,[strType]
							,[strSourceTransaction]
							,[intSourceId]
							,[strSourceId]
							,[intHeaderId]
							,[dtmDate]
						)
					SELECT
							 [intId] = CPT.intPumpTotalsId
							,[intDetailId] = NULL
							,[intDetailTaxId] = NULL
							,[intTaxGroupId] = TAX.intTaxGroupId
							,[intTaxCodeId] = TAX.intTaxCodeId
							,[intTaxClassId] = TAX.intTaxClassId
							,[strTaxableByOtherTaxes] = TAX.strTaxableByOtherTaxes
							,[strCalculationMethod] = TAX.strCalculationMethod
							,[dblRate] = TAX.dblRate
							,[intTaxAccountId] = TAX.intTaxAccountId
							,[dblTax] = TAX.dblTax
							,[dblAdjustedTax] = TAX.dblAdjustedTax
							,[ysnTaxAdjusted] = 1
							,[ysnSeparateOnInvoice] = 0
							,[ysnCheckoffTax] = TAX.ysnCheckoffTax
							,[ysnTaxExempt] = TAX.ysnTaxExempt
							,[ysnTaxOnly] = TAX.ysnTaxOnly
							,[strNotes] = TAX.strNotes
							,[intTempDetailIdForTaxes] = CPT.intPumpTotalsId
							,[dblCurrencyExchangeRate] = 0
							,[ysnClearExisting] = 0
							,[strTransactionType] = ''
							,[strType] = ''
							,[strSourceTransaction] = ''
							,[intSourceId] = @intCheckoutId
							,[strSourceId] = @intCheckoutId
							,[intHeaderId] = @intCheckoutId
							,[dtmDate] = GETDATE()
						FROM tblSTCheckoutPumpTotals CPT
							JOIN tblICItemUOM UOM ON CPT.intPumpCardCouponId = UOM.intItemUOMId
							JOIN tblSTCheckoutHeader CH ON CPT.intCheckoutId = CH.intCheckoutId
							JOIN tblICItem I ON UOM.intItemId = I.intItemId
							JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
							JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
													AND IL.intItemLocationId = IP.intItemLocationId
							JOIN tblSTStore ST ON IL.intLocationId = ST.intCompanyLocationId
												AND CH.intStoreId = ST.intStoreId	
							JOIN vyuEMEntityCustomerSearch vC ON ST.intCheckoutCustomerId = vC.intEntityId
							OUTER APPLY dbo.fnConstructLineItemTaxDetail (
																			ISNULL(CPT.dblQuantity, 0)						-- Qty
																			, ISNULL(CAST(CPT.dblAmount AS DECIMAL(18,2)), 0) --[dbo].[fnRoundBanker](CPT.dblPrice, 2) --CAST([dbo].fnRoundBanker(CPT.dblPrice, 2) AS DECIMAL(18,6))	-- Gross Amount
																			, @LineItems
																			, 1										-- is Reversal
																			, I.intItemId							-- Item Id
																			, ST.intCheckoutCustomerId				-- Customer Id
																			, ST.intCompanyLocationId				-- Company Location Id
																			, ST.intTaxGroupId						-- Tax Group Id
																			, 0										-- 0 Price if not reversal
																			, GETDATE()
																			, vC.intShipToId						-- Ship to Location
																			, 1
																			, NULL
																			, vC.intFreightTermId					-- FreightTermId
																			, NULL
																			, NULL
																			, 0
																			, 0
																			, UOM.intItemUOMId
																			,NULL									--@CFSiteId
																			,0										--@IsDeliver
																			,NULL
																			,NULL
																			,NULL
																		) TAX

							WHERE CPT.intCheckoutId = @intCheckoutId
							AND CPT.dblAmount > 0
							AND UOM.ysnStockUnit = CAST(1 AS BIT)

							
							
							
																																																																																																																																																																																											BEGIN
						INSERT INTO @EntriesForInvoice(
										 [strSourceTransaction]
										,[strTransactionType]
										,[strType]
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
										--,[ysnImportedFromOrigin]
										--,[ysnImportedAsPosted]
									)
									SELECT 
										 [strSourceTransaction]		= 'Invoice'
										,[strTransactionType]		= 'Invoice'
										,[strType]					= @strInvoiceType
										,[intSourceId]				= @intCheckoutId
										,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
										,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
										,[intEntityCustomerId]		= @intEntityCustomerId
										,[intCompanyLocationId]		= @intCompanyLocationId
										,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
										,[intTermId]				= vC.intTermsId						--ADDED
										,[dtmDate]					= @dtmCheckoutDate --GETDATE()
										,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
										,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
										,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
										,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
										,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
										,[intFreightTermId]			= vC.intFreightTermId				--ADDED
										,[intShipViaId]				= vC.intShipViaId					--ADDED
										,[intPaymentMethodId]		= vC.intPaymentMethodId				--ADDED
										,[strInvoiceOriginId]		= NULL -- not sure
										,[strPONumber]				= NULL -- not sure
										,[strBOLNumber]				= NULL -- not sure
										,[strComments]				= @strComments
										,[intShipToLocationId]		= vC.intShipToId					--ADDED
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
										,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	  END
										,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
										,[intInvoiceDetailId]		= NULL
										,[intItemId]				= I.intItemId
										,[ysnInventory]				= 1
										,[strItemDescription]		= I.strDescription
										,[intOrderUOMId]			= UOM.intItemUOMId
										,[dblQtyOrdered]			= 0 -- CPT.dblQuantity --(Select dblQuantity From tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
										,[intItemUOMId]				= UOM.intItemUOMId
										,[dblQtyShipped]			= ISNULL(CPT.dblQuantity, 0) --(Select dblQuantity From tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
										,[dblDiscount]				= 0
										
										, [dblPrice]				= (ISNULL(CAST(CPT.dblAmount AS DECIMAL(18,2)), 0) - Tax.[dblAdjustedTax]) / CPT.dblQuantity

										,[ysnRefreshPrice]			= 0
										,[strMaintenanceType]		= NULL
										,[strFrequency]				= NULL
										,[dtmMaintenanceDate]		= NULL
										,[dblMaintenanceAmount]		= NULL
										,[dblLicenseAmount]			= NULL
										,[intTaxGroupId]			= @intTaxGroupId
										,[ysnRecomputeTax]			= 0 -- Should recompute tax only for Pump Total Items
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
										,[dblCOGSAmount]			= 0 --IP.dblSalePrice
										,[intTempDetailIdForTaxes]  = CPT.intPumpTotalsId
										,[intConversionAccountId]	= NULL -- not sure
										,[intCurrencyExchangeRateTypeId]	= NULL
										,[intCurrencyExchangeRateId]		= NULL
										,[dblCurrencyExchangeRate]	= 1.000000
										,[intSubCurrencyId]			= @intCurrencyId
										,[dblSubCurrencyRate]		= 1.000000
										--,0
										--,1
							FROM tblSTCheckoutPumpTotals CPT
							JOIN tblICItemUOM UOM ON CPT.intPumpCardCouponId = UOM.intItemUOMId
							JOIN tblSTCheckoutHeader CH ON CPT.intCheckoutId = CH.intCheckoutId
							JOIN tblICItem I ON UOM.intItemId = I.intItemId
							JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
							JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
													AND IL.intItemLocationId = IP.intItemLocationId
							JOIN tblSTStore ST ON IL.intLocationId = ST.intCompanyLocationId
												AND CH.intStoreId = ST.intStoreId	
							JOIN vyuEMEntityCustomerSearch vC ON ST.intCheckoutCustomerId = vC.intEntityId
							LEFT OUTER JOIN
							(
							SELECT 
							 [dblAdjustedTax] = SUM ([dblAdjustedTax])
							 ,[intTempDetailIdForTaxes]
							FROM
								@LineItemTaxEntries
							GROUP BY
								[intTempDetailIdForTaxes]
							) Tax
								ON CPT.intPumpTotalsId = Tax.intTempDetailIdForTaxes
							WHERE CPT.intCheckoutId = @intCheckoutId
							AND CPT.dblAmount > 0
							AND UOM.ysnStockUnit = CAST(1 AS BIT)

					END
				END
				--ELSE
				--	BEGIN
				--		SET @ysnUpdateCheckoutStatus = 0
				--		SET @strStatusMsg = @strStatusMsg + '<BR>' + 'No records found to Post Pump Totals'
				--	END
				----------------------------------------------------------------------
				------------------------- END PUMP TOTALS ----------------------------
				----------------------------------------------------------------------


				----------------------------------------------------------------------
				---------------------------- ITEM MOVEMENTS --------------------------
				----------------------------------------------------------------------
				IF EXISTS(SELECT * FROM tblSTCheckoutItemMovements WHERE intCheckoutId = @intCheckoutId AND dblTotalSales > 0)
					BEGIN																																																																																																																																																																																						BEGIN
							INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
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
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= 'Invoice'
											,[strType]					= @strInvoiceType
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
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
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= UOM.intItemUOMId
											,[dblQtyOrdered]			= 0 -- IM.intQtySold
											,[intItemUOMId]				= UOM.intItemUOMId
											,[dblQtyShipped]			= ISNULL(IM.intQtySold, 0)
											,[dblDiscount]				= CASE
																				WHEN ISNULL(IM.dblDiscountAmount, 0) > 0 THEN 
																				    -- (8 / 88) * 100
																					(ISNULL(IM.dblDiscountAmount, 0) / (ISNULL(IM.dblTotalSales, 0) + ISNULL(IM.dblDiscountAmount, 0))) * 100 --((((ISNULL(IM.dblTotalSales, 0) + ISNULL(IM.dblDiscountAmount, 0)) / ISNULL(IM.intQtySold, 0)) * ISNULL(IM.intQtySold, 0)) * ISNULL(IM.dblDiscountAmount, 0) / 100)
																				ELSE 0
																		  END
											,[dblPrice]					= (ISNULL(IM.dblTotalSales, 0) + ISNULL(IM.dblDiscountAmount, 0)) / ISNULL(IM.intQtySold, 0) -- ISNULL(IM.dblCurrentPrice, 0) --
											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
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
											,[dblCOGSAmount]			= 0 --IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = I.intItemId
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTCheckoutItemMovements IM
								JOIN tblICItemUOM UOM ON IM.intItemUPCId = UOM.intItemUOMId
								JOIN tblSTCheckoutHeader CH ON IM.intCheckoutId = CH.intCheckoutId
								JOIN tblICItem I ON UOM.intItemId = I.intItemId
								JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
								JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
														AND IL.intItemLocationId = IP.intItemLocationId
								JOIN tblSTStore ST ON IL.intLocationId = ST.intCompanyLocationId
													AND CH.intStoreId = ST.intStoreId
								JOIN vyuEMEntityCustomerSearch vC ON ST.intCheckoutCustomerId = vC.intEntityId
								WHERE IM.intCheckoutId = @intCheckoutId
								AND IM.dblTotalSales > 0
								AND UOM.ysnStockUnit = CAST(1 AS BIT)
					END
				END
				--ELSE 
				--	BEGIN
				--		SET @ysnUpdateCheckoutStatus = 0
				--		SET @strStatusMsg = @strStatusMsg + '<BR>' + 'No records found to Post Item Movements'
				--	END
				----------------------------------------------------------------------
				---------------------------- ITEM MOVEMENTS --------------------------
				----------------------------------------------------------------------



				----------------------------------------------------------------------
				------------------------- DEPARTMENT TOTALS --------------------------
				----------------------------------------------------------------------
				IF EXISTS(SELECT * FROM tblSTCheckoutDepartmetTotals WHERE intCheckoutId = @intCheckoutId AND dblTotalSalesAmount > 0)
					BEGIN																																																																																																																																																																																						BEGIN
							INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
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
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= 'Invoice'
											,[strType]					= @strInvoiceType
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
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
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= UOM.intItemUOMId
											,[dblQtyOrdered]			= 0
											--,[dblQtyOrdered]			= CASE 
											--								WHEN 
											--									(
											--										CAST((DT.dblTotalSalesAmount - (
											--																			SELECT SUM(dblTotalSales)
											--																			FROM tblSTCheckoutItemMovements IM
											--																			JOIN tblICItemUOM UOM ON IM.intItemUPCId = UOM.intItemUOMId
											--																			JOIN tblICItem I ON UOM.intItemId = I.intItemId
											--																			JOIN tblICCategory CATT ON I.intCategoryId = CATT.intCategoryId 
											--																			WHERE intCheckoutId = @intCheckoutId
											--																			AND CATT.intCategoryId = DT.intCategoryId)) AS NUMERIC(18, 6)
											--															           )
											--									) > 1 THEN 1
											--								ELSE -1
											--							  END
											,[intItemUOMId]				= UOM.intItemUOMId
											,[dblQtyShipped]			= CASE 
																			WHEN 
																				(
																					CAST((ISNULL(DT.dblTotalSalesAmount, 0) - ISNULL((
																																	SELECT SUM(dblTotalSales)
																																	FROM tblSTCheckoutItemMovements IM
																																	JOIN tblICItemUOM UOM ON IM.intItemUPCId = UOM.intItemUOMId
																																	JOIN tblICItem I ON UOM.intItemId = I.intItemId
																																	JOIN tblICCategory CATT ON I.intCategoryId = CATT.intCategoryId 
																																	WHERE intCheckoutId = @intCheckoutId
																																	AND CATT.intCategoryId = DT.intCategoryId
																															   ),0)
																						) AS NUMERIC(18, 6))
																				) >= 1 THEN 1
																			ELSE -1
																		  END
											,[dblDiscount]				= 0
											,[dblPrice]					= ABS(CAST((ISNULL(DT.dblTotalSalesAmount, 0) - ISNULL((
																															SELECT SUM(dblTotalSales)
																															FROM tblSTCheckoutItemMovements IM
																															JOIN tblICItemUOM UOM ON IM.intItemUPCId = UOM.intItemUOMId
																															JOIN tblICItem I ON UOM.intItemId = I.intItemId
																															JOIN tblICCategory CATT ON I.intCategoryId = CATT.intCategoryId 
																															WHERE intCheckoutId = @intCheckoutId
																															AND CATT.intCategoryId = DT.intCategoryId
																														 ), 0)
																					) AS NUMERIC(18, 6)))
											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
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
											,[dblCOGSAmount]			= 0 --IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = I.intItemId
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTCheckoutDepartmetTotals DT
								JOIN tblICItem I ON DT.intItemId = I.intItemId
								--JOIN tblICCategory CAT ON I.intCategoryId = CAT.intCategoryId
								JOIN tblICItemUOM UOM ON I.intItemId = UOM.intItemId
								JOIN tblSTCheckoutHeader CH ON DT.intCheckoutId = CH.intCheckoutId
								JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
								JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
														AND IL.intItemLocationId = IP.intItemLocationId
								JOIN tblSTStore ST ON IL.intLocationId = ST.intCompanyLocationId
													AND CH.intStoreId = ST.intStoreId
								JOIN vyuEMEntityCustomerSearch vC ON ST.intCheckoutCustomerId = vC.intEntityId
								WHERE DT.intCheckoutId = @intCheckoutId
								AND DT.dblTotalSalesAmount > 0
								AND UOM.ysnStockUnit = CAST(1 AS BIT)
					END
				END
				--ELSE 
				--	BEGIN
				--		SET @ysnUpdateCheckoutStatus = 0
				--		SET @strStatusMsg = @strStatusMsg + '<BR>' + 'No records found to Post Department Totals'
				--	END
				----------------------------------------------------------------------
				--------------------- END DEPARTMENT TOTALS --------------------------
				----------------------------------------------------------------------



				----------------------------------------------------------------------
				-------------------------- SALES TAX TOTALS --------------------------
				----------------------------------------------------------------------
				IF EXISTS(SELECT * FROM tblSTCheckoutSalesTaxTotals WHERE intCheckoutId = @intCheckoutId AND dblTotalTax > 0)
					BEGIN																																																																																																																																																																																						BEGIN
							INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
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
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= 'Invoice'
											,[strType]					= @strInvoiceType
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
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
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= UOM.intItemUOMId
											,[dblQtyOrdered]			= 0 -- 1
											,[intItemUOMId]				= UOM.intItemUOMId
											,[dblQtyShipped]			= 1
											,[dblDiscount]				= 0
											,[dblPrice]					= ISNULL(STT.dblTotalTax, 0)
											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
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
											,[dblCOGSAmount]			= 0 -- IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = I.intItemId
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTCheckoutSalesTaxTotals STT
								JOIN tblICItem I ON STT.intItemId = I.intItemId
								JOIN tblICItemUOM UOM ON I.intItemId = UOM.intItemId
								JOIN tblSTCheckoutHeader CH ON STT.intCheckoutId = CH.intCheckoutId
								JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
								JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
														AND IL.intItemLocationId = IP.intItemLocationId
								JOIN tblSTStore ST ON IL.intLocationId = ST.intCompanyLocationId
													AND CH.intStoreId = ST.intStoreId
								JOIN vyuEMEntityCustomerSearch vC ON ST.intCheckoutCustomerId = vC.intEntityId
								WHERE STT.intCheckoutId = @intCheckoutId
								AND STT.dblTotalTax > 0
								AND UOM.ysnStockUnit = CAST(1 AS BIT)
					END
				END
				--ELSE 
				--	BEGIN
				--		SET @ysnUpdateCheckoutStatus = 0
				--		SET @strStatusMsg = @strStatusMsg + '<BR>' + 'No records found to Post Sales Tax Totals'
				--	END
				----------------------------------------------------------------------
				---------------------- END SALES TAX TOTALS --------------------------
				----------------------------------------------------------------------




				----------------------------------------------------------------------
				-------------------------- PAYMENT OPTIONS --------------------------
				----------------------------------------------------------------------
				IF EXISTS(SELECT * FROM tblSTCheckoutPaymentOptions WHERE intCheckoutId = @intCheckoutId AND dblAmount > 0)
					BEGIN																																																																																																																																																																																						BEGIN
							INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
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
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= 'Invoice'
											,[strType]					= @strInvoiceType
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
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
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= UOM.intItemUOMId
											,[dblQtyOrdered]			= 0 -- 1
											,[intItemUOMId]				= UOM.intItemUOMId
											,[dblQtyShipped]			= 1
											,[dblDiscount]				= 0
											,[dblPrice]					= ISNULL(CPO.dblAmount, 0)
											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
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
											,[dblCOGSAmount]			= 0 -- IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = I.intItemId
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTCheckoutPaymentOptions CPO
								JOIN tblICItem I ON CPO.intItemId = I.intItemId
								JOIN tblICItemUOM UOM ON I.intItemId = UOM.intItemId
								JOIN tblSTCheckoutHeader CH ON CPO.intCheckoutId = CH.intCheckoutId
								JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
								JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
														AND IL.intItemLocationId = IP.intItemLocationId
								JOIN tblSTStore ST ON IL.intLocationId = ST.intCompanyLocationId
													AND CH.intStoreId = ST.intStoreId
								JOIN vyuEMEntityCustomerSearch vC ON ST.intCheckoutCustomerId = vC.intEntityId
								WHERE CPO.intCheckoutId = @intCheckoutId
								AND CPO.dblAmount > 0
								AND UOM.ysnStockUnit = CAST(1 AS BIT)
					END
				END
				--ELSE 
				--	BEGIN
				--		SET @ysnUpdateCheckoutStatus = 0
				--		SET @strStatusMsg = @strStatusMsg + '<BR>' + 'No records found to Post Payment Options'
				--	END
				----------------------------------------------------------------------
				----------------------- END PAYMENT OPTIONS --------------------------
				----------------------------------------------------------------------




				----------------------------------------------------------------------
				-------------------------- CUSTOMER CHARGES --------------------------
				----------------------------------------------------------------------
				IF EXISTS(SELECT * FROM tblSTCheckoutCustomerCharges WHERE intCheckoutId = @intCheckoutId AND dblAmount > 0 AND intProduct IS NOT NULL)
					BEGIN																																																																																																																																																																																						BEGIN
							INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
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
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= 'Invoice'
											,[strType]					= @strInvoiceType
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
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
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= CC.intProduct --UOM.intItemUOMId
											,[dblQtyOrdered]			= 0 -- -1
											,[intItemUOMId]				= CC.intProduct --UOM.intItemUOMId
											,[dblQtyShipped]			= -1
											,[dblDiscount]				= 0
											,[dblPrice]					= ISNULL(CC.dblAmount,0)
											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
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
											,[dblCOGSAmount]			= 0 --IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = I.intItemId
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTCheckoutCustomerCharges CC
								JOIN tblICItemUOM UOM ON CC.intProduct = UOM.intItemUOMId
								JOIN tblICItem I ON UOM.intItemId = I.intItemId
								JOIN tblSTCheckoutHeader CH ON CC.intCheckoutId = CH.intCheckoutId
								JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
								JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
														AND IL.intItemLocationId = IP.intItemLocationId
								JOIN tblSTStore ST ON IL.intLocationId = ST.intCompanyLocationId
													AND CH.intStoreId = ST.intStoreId
								JOIN vyuEMEntityCustomerSearch vC ON ST.intCheckoutCustomerId = vC.intEntityId
								WHERE CC.intCheckoutId = @intCheckoutId
								AND CC.dblAmount > 0
								----AND UOM.ysnStockUnit = CAST(1 AS BIT)
					END
				END
				--ELSE 
				--	BEGIN
				--		SET @ysnUpdateCheckoutStatus = 0
				--		SET @strStatusMsg = @strStatusMsg + '<BR>' + 'No records found to Post Customer Charges'
				--	END
				----------------------------------------------------------------------
				----------------------- END CUSTOMER CHARGES -------------------------
				----------------------------------------------------------------------




				----------------------------------------------------------------------
				-------------------------- CUSTOMER PAYMENTS -------------------------
				----------------------------------------------------------------------
				IF EXISTS(SELECT * FROM tblSTCheckoutCustomerPayments WHERE intCheckoutId = @intCheckoutId AND dblAmount > 0 AND intItemId IS NOT NULL)
					BEGIN																																																																																																																																																																																						BEGIN
							INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
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
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= 'Invoice'
											,[strType]					= @strInvoiceType
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
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
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= UOM.intItemUOMId
											,[dblQtyOrdered]			= 0 -- 1
											,[intItemUOMId]				= UOM.intItemUOMId
											,[dblQtyShipped]			= 1
											,[dblDiscount]				= 0
											,[dblPrice]					= ISNULL(CP.dblAmount, 0)
											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
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
											,[dblCOGSAmount]			= 0 --IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = I.intItemId
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTCheckoutCustomerPayments CP
								JOIN tblICItem I ON CP.intItemId = I.intItemId
								JOIN tblICItemUOM UOM ON I.intItemId = UOM.intItemId
								JOIN tblSTCheckoutHeader CH ON CP.intCheckoutId = CH.intCheckoutId
								JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
								JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
														AND IL.intItemLocationId = IP.intItemLocationId
								JOIN tblSTStore ST ON IL.intLocationId = ST.intCompanyLocationId
												AND CH.intStoreId = ST.intStoreId
								JOIN vyuEMEntityCustomerSearch vC ON ST.intCheckoutCustomerId = vC.intEntityId
								WHERE CP.intCheckoutId = @intCheckoutId
								AND CP.dblAmount > 0
								AND UOM.ysnStockUnit = CAST(1 AS BIT)
					END
				END
				--ELSE 
				--	BEGIN
				--		SET @ysnUpdateCheckoutStatus = 0
				--		SET @strStatusMsg = @strStatusMsg + '<BR>' + 'No records found to Post Customer Payments'
				--	END
				----------------------------------------------------------------------
				----------------------- END CUSTOMER PAYMENTS ------------------------
				----------------------------------------------------------------------




				----------------------------------------------------------------------
				--------------------------- CASH OVER SHORT --------------------------
				----------------------------------------------------------------------
				IF EXISTS(SELECT * FROM tblSTStore WHERE intStoreId = @intStoreId AND intOverShortItemId IS NOT NULL)
					BEGIN																																																																																																																																																																																						BEGIN
							INSERT INTO @EntriesForInvoice(
											 [strSourceTransaction]
											,[strTransactionType]
											,[strType]
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
											--,[ysnImportedFromOrigin]
											--,[ysnImportedAsPosted]
										)
										SELECT 
											 [strSourceTransaction]		= 'Invoice'
											,[strTransactionType]		= 'Invoice'
											,[strType]					= @strInvoiceType
											,[intSourceId]				= @intCheckoutId
											,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
											,[intInvoiceId]				= @intCurrentInvoiceId -- NULL = New
											,[intEntityCustomerId]		= @intEntityCustomerId
											,[intCompanyLocationId]		= @intCompanyLocationId
											,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
											,[intTermId]				= vC.intTermsId						--ADDED
											,[dtmDate]					= @dtmCheckoutDate --GETDATE()
											,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
											,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
											,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
											,[intEntitySalespersonId]	= vC.intSalespersonId				--ADDED
											,[intFreightTermId]			= vC.intFreightTermId				--ADDED
											,[intShipViaId]				= vC.intShipViaId					--ADDED
											,[intPaymentMethodId]		= vC.intPaymentMethodId				--ADDED
											,[strInvoiceOriginId]		= NULL -- not sure
											,[strPONumber]				= NULL -- not sure
											,[strBOLNumber]				= NULL -- not sure
											,[strComments]				= @strComments
											,[intShipToLocationId]		= vC.intShipToId					--ADDED
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
											,[ysnResetDetails]			= CASE
																			WHEN @intCurrentInvoiceId IS NOT NULL
																				THEN CAST(0 AS BIT)
																			ELSE CAST(1 AS BIT)
																	      END
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= UOM.intItemUOMId
											,[dblQtyOrdered]			= 0 -- 1
											,[intItemUOMId]				= UOM.intItemUOMId
											,[dblQtyShipped]			= 1
											,[dblDiscount]				= 0
											,[dblPrice]					= ISNULL(CH.dblCashOverShort,0)
											,[ysnRefreshPrice]			= 0
											,[strMaintenanceType]		= NULL
											,[strFrequency]				= NULL
											,[dtmMaintenanceDate]		= NULL
											,[dblMaintenanceAmount]		= NULL
											,[dblLicenseAmount]			= NULL
											,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
											,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
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
											,[dblCOGSAmount]			= 0 --IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = I.intItemId
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
											--,0
											--,1
								FROM tblSTStore ST
								JOIN tblICItem I ON ST.intOverShortItemId = I.intItemId 
								JOIN tblICItemUOM UOM ON I.intItemId = UOM.intItemId
								JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
								--						AND IL.intItemLocationId = IP.intItemLocationId
								JOIN vyuEMEntityCustomerSearch vC ON ST.intCheckoutCustomerId = vC.intEntityId
								JOIN tblSTCheckoutHeader CH ON ST.intStoreId = CH.intStoreId
								WHERE CH.intCheckoutId = @intCheckoutId
								AND UOM.ysnStockUnit = CAST(1 AS BIT)
					END
				END
				--ELSE 
				--	BEGIN
				--		SET @ysnUpdateCheckoutStatus = 0
				--		SET @strStatusMsg = @strStatusMsg + '<BR>' + 'No records found to Post Over short'
				--	END
				----------------------------------------------------------------------
				------------------------- END CASH OVER SHORT ------------------------
				----------------------------------------------------------------------






				-- START CREATE SEPARATE INVOICE for Customer Charges
				----------------------------------------------------------------------
				-------------------------- CUSTOMER CHARGES --------------------------
				----------------------------------------------------------------------
				IF EXISTS(SELECT * FROM tblSTCheckoutCustomerCharges WHERE intCheckoutId = @intCheckoutId AND dblAmount > 0 AND intProduct IS NOT NULL)
					BEGIN																																																																																																																																																																																						BEGIN
											INSERT INTO @EntriesForInvoice(
															 [strSourceTransaction]
															,[strTransactionType]
															,[strType]
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
															--,[ysnImportedFromOrigin]
															--,[ysnImportedAsPosted]
														)
														SELECT 
															 [strSourceTransaction]		= 'Invoice'
															,[strTransactionType]		= 'Invoice'
															,[strType]					= @strInvoiceType
															,[intSourceId]				= @intCheckoutId
															,[strSourceId]				= CAST(@intCheckoutId AS NVARCHAR(250))
															,[intInvoiceId]				= CC.intCustomerChargesInvoiceId --@intCurrentCustomerChragesInvoiceId -- @intCurrentInvoiceId -- NULL = New
															,[intEntityCustomerId]		= @intEntityCustomerId
															,[intCompanyLocationId]		= @intCompanyLocationId
															,[intCurrencyId]			= @intCurrencyId -- Default 3(USD)
															,[intTermId]				= NULL
															,[dtmDate]					= @dtmCheckoutDate --GETDATE()
															,[dtmDueDate]				= @dtmCheckoutDate --GETDATE()
															,[dtmShipDate]				= @dtmCheckoutDate --GETDATE()
															,[dtmCalculated]			= @dtmCheckoutDate --GETDATE()
															,[dtmPostDate]				= @dtmCheckoutDate --GETDATE()
															,[intEntitySalespersonId]	= NULL
															,[intFreightTermId]			= @intCompanyLocationId --@intEntityLocationId
															,[intShipViaId]				= NULL --@intShipViaId
															,[intPaymentMethodId]		= NULL
															,[strInvoiceOriginId]		= NULL -- not sure
															,[strPONumber]				= NULL -- not sure
															,[strBOLNumber]				= NULL -- not sure
															,[strComments]				= @strComments + CAST(CC.intCustChargeId AS NVARCHAR(100)) -- to be able to create reparate Invoices
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
															,[ysnResetDetails]			= CASE
																							WHEN @intCurrentInvoiceId IS NOT NULL
																								THEN CAST(0 AS BIT)
																							ELSE CAST(1 AS BIT)
																						  END
															,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
															,[intInvoiceDetailId]		= NULL
															,[intItemId]				= I.intItemId
															,[ysnInventory]				= 1
															,[strItemDescription]		= I.strDescription
															,[intOrderUOMId]			= CC.intProduct --UOM.intItemUOMId
															,[dblQtyOrdered]			= 0 -- -1
															,[intItemUOMId]				= CC.intProduct --UOM.intItemUOMId
															,[dblQtyShipped]			= 1 -- If separate invoice change negative to positive Qty
															,[dblDiscount]				= 0
															,[dblPrice]					= ISNULL(CC.dblAmount, 0)
															,[ysnRefreshPrice]			= 0
															,[strMaintenanceType]		= NULL
															,[strFrequency]				= NULL
															,[dtmMaintenanceDate]		= NULL
															,[dblMaintenanceAmount]		= NULL
															,[dblLicenseAmount]			= NULL
															,[intTaxGroupId]			= NULL -- Null for none Pump Total Items
															,[ysnRecomputeTax]			= 0 -- no Tax for none Pump Total Items
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
															,[dblCOGSAmount]			= 0 --IP.dblSalePrice
															,[intTempDetailIdForTaxes]  = I.intItemId
															,[intConversionAccountId]	= NULL -- not sure
															,[intCurrencyExchangeRateTypeId]	= NULL
															,[intCurrencyExchangeRateId]		= NULL
															,[dblCurrencyExchangeRate]	= 1.000000
															,[intSubCurrencyId]			= NULL
															,[dblSubCurrencyRate]		= 1.000000
															--,0
															--,1
												FROM tblSTCheckoutCustomerCharges CC
												JOIN tblICItemUOM UOM ON CC.intProduct = UOM.intItemUOMId
												JOIN tblICItem I ON UOM.intItemId = I.intItemId
												JOIN tblSTCheckoutHeader CH ON CC.intCheckoutId = CH.intCheckoutId
												JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
												JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
																		AND IL.intItemLocationId = IP.intItemLocationId
												JOIN tblSTStore ST ON IL.intLocationId = ST.intCompanyLocationId
																	AND CH.intStoreId = ST.intStoreId
												WHERE CC.intCheckoutId = @intCheckoutId
												AND CC.dblAmount > 0
												--AND UOM.ysnStockUnit = CAST(1 AS BIT)
												ORDER BY CC.intCustChargeId ASC
					END
			    END
				------------------------------------------------------------------------
				------------------------- END CUSTOMER CHARGES -------------------------
				------------------------------------------------------------------------
				-- END CREATE SEPARATE INVOICE for Customer Charges



				----------------------------------------------------------------------
				------------------------------- POST ---------------------------------
				----------------------------------------------------------------------
				DECLARE @ErrorMessage AS NVARCHAR(MAX) = ''
				DECLARE @CreatedIvoices AS NVARCHAR(MAX) = ''

				-- Filter dblPrice should not be 0 and null
				DELETE FROM @EntriesForInvoice WHERE dblPrice = 0 OR dblPrice IS NULL

				IF EXISTS(SELECT * FROM @EntriesForInvoice)
					BEGIN
						
						-- Filter None Lotted Items Only
							INSERT INTO @tblTempItems
							(
								intItemId
								, strItemNo
							)
							SELECT DISTINCT
								I.intItemId
								, I.strItemNo
							FROM @EntriesForInvoice E
							JOIN tblICItem I 
								ON E.intItemId = I.intItemId
							WHERE I.strLotTracking != 'No'

							-- Validate Items if Lotted
							IF EXISTS(SELECT * FROM @tblTempItems)
								BEGIN
									DECLARE @strLottedItem AS NVARCHAR(MAX) = ''

									SELECT @strLottedItem = @strLottedItem + temp.strItemNo + ', '
									FROM @tblTempItems temp
									SELECT @strLottedItem = LEFT(@strLottedItem, LEN(@strLottedItem)-1)

									SET @ysnUpdateCheckoutStatus = 0
									SET @strStatusMsg = 'Lotted Items (' + @strLottedItem + ') Only None Lotted Items are allowed '
									
									--GOTO With_Rollback_Exit;
								END
							ELSE
								BEGIN
									-- CLEAR
									SET @CreatedIvoices = ''

									BEGIN TRY
										-- Begin Trsaction
										BEGIN TRANSACTION

										-- POST Main Checkout Invoice
										EXEC [dbo].[uspARProcessInvoices]
													@InvoiceEntries	 = @EntriesForInvoice
													,@LineItemTaxEntries = @LineItemTaxEntries
													,@UserId			 = @intCurrentUserId
		 											,@GroupingOption	 = 11
													,@RaiseError		 = 1
													,@ErrorMessage		 = @ErrorMessage OUTPUT
													,@CreatedIvoices	 = @CreatedIvoices OUTPUT
									END TRY

									BEGIN CATCH
										SET @ErrorMessage = ERROR_MESSAGE()
										SET @strStatusMsg = 'Post Invoice error: ' + @ErrorMessage

										-- ********************************************************
										-- Having Problem on Invoice posting
										-- It still create Invoice even there's error on posting
										-- Need to call rollback after error message
										-- Rollback Transaction here
										ROLLBACK TRANSACTION
										-- ********************************************************
										
									END CATCH
								END

						IF(@ErrorMessage IS NULL OR @ErrorMessage = '')
							BEGIN
								-- Commit Transaction
								COMMIT TRANSACTION

							    -- Insert to temp table
								INSERT INTO #tmpCustomerInvoiceIdList(intInvoiceId)
								SELECT [intID] AS intInvoiceId 
								FROM [dbo].[fnGetRowsFromDelimitedValues](@CreatedIvoices) ORDER BY [intID] ASC

								-- Invoice MAIN Checkout
								SET @intCreatedInvoiceId = (SELECT TOP 1 intInvoiceId FROM #tmpCustomerInvoiceIdList ORDER BY intInvoiceId ASC)

								-- Invoice remaining will be used for Customer CHarges
								DELETE FROM #tmpCustomerInvoiceIdList WHERE intInvoiceId = @intCreatedInvoiceId

								-- CUSTOMER CHARGES
								SET @strAllCreatedInvoiceIdList = @CreatedIvoices


								-----------------------------------------------------------------------
								------------- START POST MArk Up / Down -------------------------------
								-----------------------------------------------------------------------

								-- POST
								EXEC uspSTMarkUpDownCheckoutPosting
											@intCheckoutId		= @intCheckoutId
											,@intCurrentUserId	= @intCurrentUserId
											,@ysnPost			= 1 -- POST
											,@strStatusMsg		= @strMarkUpDownPostingStatusMsg OUTPUT
											,@strBatchId		= @strBatchId OUTPUT
											,@ysnIsPosted		= @ysnIsPosted OUTPUT

								-----------------------------------------------------------------------
								------------- END POST MArk Up / Down ---------------------------------
								-----------------------------------------------------------------------


								SET @ysnUpdateCheckoutStatus = 1
								SET @strStatusMsg = 'Success'
								SET @ysnInvoiceStatus = 1

							END
						ELSE
							BEGIN
								SET @ysnUpdateCheckoutStatus = 0
								SET @strStatusMsg = 'Post Invoice error: ' + @ErrorMessage

							END
							END
				ELSE 
					BEGIN
						SET @strStatusMsg = 'No records found to Post'
					END
				----------------------------------------------------------------------
				---------------------------- END POST --------------------------------
				----------------------------------------------------------------------
			END
		ELSE IF(@ysnPost = 0)
			BEGIN
				--SET @strInvoiceIdList = CAST(@intCurrentInvoiceId AS NVARCHAR(50))

				----------------------------------------------------------------------
				----------------------------- UN-POST ---------------------------------
				----------------------------------------------------------------------
				-- Main Invoice: Main CHeckout
				IF(@strCurrentAllInvoiceIdList IS NOT NULL AND @strCurrentAllInvoiceIdList != '')
					BEGIN

						SET @ysnSuccess = 1

						BEGIN TRY
							-- Begin Trsaction
							BEGIN TRANSACTION

							EXEC [dbo].[uspARPostInvoice]
											@batchId			= NULL,
											@post				= 0, -- 0 = UnPost
											@recap				= 0,
											@param				= @strCurrentAllInvoiceIdList,
											@userId				= @intCurrentUserId,
											@beginDate			= NULL,
											@endDate			= NULL,
											@beginTransaction	= NULL,
											@endTransaction		= NULL,
											@exclude			= NULL,
											@successfulCount	= @intSuccessfullCount OUTPUT,
											@invalidCount		= @intInvalidCount OUTPUT,
											@success			= @ysnSuccess OUTPUT,
											@batchIdUsed		= @strBatchIdUsed OUTPUT,
											@transType			= N'all',
											@raiseError			= 1
						END TRY

						BEGIN CATCH
							SET @ysnUpdateCheckoutStatus = CAST(0 AS BIT)
							SET @ysnSuccess = CAST(0 AS BIT)
							SET @strStatusMsg = 'Unpost Invoice error: ' + ERROR_MESSAGE()

							-- Rollback Transaction here
							ROLLBACK TRANSACTION

						END CATCH

						-- Example OutPut params
						-- @intSuccessfullCount: 1
						-- @intInvalidCount: 0
						-- @ysnSuccess: 1
						-- @strBatchIdUsed: BATCH-722

						IF(@ysnSuccess = CAST(1 AS BIT))
							BEGIN
								-- Commit Transaction
								COMMIT TRANSACTION

								SET @ysnInvoiceStatus = 0
								-----------------------------------------------------------------------
								------------- START UNPOST MArk Up / Down -------------------------------
								-----------------------------------------------------------------------
								-- UNPOST	
								EXEC uspSTMarkUpDownCheckoutPosting
											@intCheckoutId
											,@intCurrentUserId
											,0 -- UNPOST
											,@strMarkUpDownPostingStatusMsg OUTPUT
											,@strBatchId OUTPUT
											,@ysnIsPosted OUTPUT
								-----------------------------------------------------------------------
								------------- END UNPOST MArk Up / Down ---------------------------------
								-----------------------------------------------------------------------

								SET @strStatusMsg = @strMarkUpDownPostingStatusMsg
							END
					END
				ELSE 
					BEGIN
						SET @strStatusMsg = 'There are no Invoice to Unpost'
					END
				
			END
		----------------------------------------------------------------------
		----------------------- END POST / UNPOST ----------------------------
		----------------------------------------------------------------------
		

		IF(@ysnUpdateCheckoutStatus = 1)
			BEGIN
				-- Determine Status
				IF(@strDirection = 'Post')
					BEGIN
						SET @strNewCheckoutStatus = 'Posted'
					END
				ELSE IF (@strDirection = 'UnPost')
					BEGIN
						SET @strNewCheckoutStatus = 'Manager Verified'
					END
				ELSE IF (@strDirection = 'SendToOffice')
					BEGIN
						SET @strNewCheckoutStatus = 'Manager Verified'
					END
				ELSE IF (@strDirection = 'SendBackToStore')
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

						IF (@strAllCreatedInvoiceIdList IS NOT NULL AND @strAllCreatedInvoiceIdList != '')
							BEGIN

								-- First time to Post
								-- New created invoice will be made
								UPDATE dbo.tblSTCheckoutHeader 
								SET strCheckoutStatus = @strNewCheckoutStatus
									, intInvoiceId = @intCreatedInvoiceId 
									, strAllInvoiceIdList = @strAllCreatedInvoiceIdList -- New Invoice Id
								WHERE intCheckoutId = @intCheckoutId


								IF EXISTS (SELECT * FROM #tmpCustomerInvoiceIdList)
									BEGIN
										-- Update customer charges invoices on table tblSTCheckoutCustomerCharges
										UPDATE CC
											SET intCustomerChargesInvoiceId = IX.intInvoiceId
										FROM tblSTCheckoutCustomerCharges CC
										JOIN
										(
											SELECT 
												ROW_NUMBER() OVER (ORDER BY intCustChargeId ASC) as intRowNumber
												,intCustChargeId 
											FROM tblSTCheckoutCustomerCharges C
											JOIN tblICItemUOM UOM ON C.intProduct = UOM.intItemUOMId
											JOIN tblICItem I ON UOM.intItemId = I.intItemId
											JOIN tblSTCheckoutHeader CH ON C.intCheckoutId = CH.intCheckoutId
											JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
											JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
																	AND IL.intItemLocationId = IP.intItemLocationId
											JOIN tblSTStore ST ON IL.intLocationId = ST.intCompanyLocationId
											AND CH.intStoreId = ST.intStoreId
											WHERE C.intCheckoutId = @intCheckoutId
											AND C.dblAmount > 0
											AND UOM.ysnStockUnit = CAST(1 AS BIT)

										) CCX ON CC.intCustChargeId = CCX.intCustChargeId
										JOIN
										(
											SELECT
												ROW_NUMBER() OVER (ORDER BY intInvoiceId ASC) as intRowNumber
												, intInvoiceId
											FROM #tmpCustomerInvoiceIdList

										) IX ON CCX.intRowNumber = IX.intRowNumber
									END
								
							END
					END
				ELSE IF(@ysnPost = 0) -- UNPOST
					BEGIN

						UPDATE dbo.tblSTCheckoutHeader 
						SET strCheckoutStatus = @strNewCheckoutStatus
						WHERE intCheckoutId = @intCheckoutId
					END
			END

			--DROP
			IF OBJECT_ID('tempdb..#tmpCustomerInvoiceIdList') IS NOT NULL  
				BEGIN
					DROP TABLE #tmpCustomerInvoiceIdList
				END
	END TRY

	BEGIN CATCH
		--DROP
		IF OBJECT_ID('tempdb..#tmpCustomerInvoiceIdList') IS NOT NULL  
			BEGIN
				DROP TABLE #tmpCustomerInvoiceIdList
			END

		SET @strStatusMsg = 'Script Error: ' + ERROR_MESSAGE()
	END CATCH
END