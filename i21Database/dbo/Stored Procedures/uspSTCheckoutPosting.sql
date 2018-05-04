﻿CREATE PROCEDURE [dbo].[uspSTCheckoutPosting]
@intCurrentUserId INT,
@intCheckoutId INT,
@strDirection NVARCHAR(50),
@strStatusMsg NVARCHAR(1000) OUTPUT,
@strNewCheckoutStatus NVARCHAR(100) OUTPUT,
@ysnInvoiceStatus BIT OUTPUT
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
		SET @strNewCheckoutStatus = ''


		DECLARE @ysnUpdateCheckoutStatus BIT = 1

		DECLARE @intEntityCustomerId INT
		DECLARE @intCompanyLocationId INT
		DECLARE @intTaxGroupId INT
		DECLARE @strComments NVARCHAR(MAX) = 'Store Checkout' -- All comments should be same to create a single Invoice
		DECLARE @strInvoiceType AS NVARCHAR(50) = 'Store Checkout'

		SELECT @intCompanyLocationId = intCompanyLocationId
			   , @intEntityCustomerId = intCheckoutCustomerId
			   , @intTaxGroupId = intTaxGroupId
		FROM tblSTStore 
		WHERE intStoreId = (
				SELECT intStoreId FROM tblSTCheckoutHeader
				WHERE intCheckoutId = @intCheckoutId
		)

		DECLARE @intCurrencyId INT = (SELECT intDefaultCurrencyId FROM tblSMCompanyPreference)
		DECLARE @intShipViaId INT = (SELECT TOP 1 1 intShipViaId FROM tblEMEntityLocation WHERE intEntityId = @intEntityCustomerId AND intShipViaId IS NOT NULL)
		DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
		DECLARE @ysnPost BIT = NULL
		-- DECLARE @CheckoutCurrentStatus NVARCHAR(50) = ''
		DECLARE @intCurrentInvoiceId INT = (SELECT intInvoiceId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId)
		DECLARE @intCreatedInvoiceId INT = NULL

		-- FOR UNPOST
		DECLARE @strInvoiceId NVARCHAR(50) = ''
		DECLARE @ysnInvoiceIsPosted BIT = NULL
		DECLARE @intSuccessfullCount INT
		DECLARE @intInvalidCount INT
		DECLARE @ysnSuccess BIT
		DECLARE @strBatchIdUsed NVARCHAR(40)
		DECLARE @ysnError BIT = 1


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

						--IF(@ysnCurrentInvoiceStatus = 1)
						--	BEGIN
						--		SET @CheckoutCurrentStatus = 'Posted'
						--	END
						--ELSE IF(@ysnCurrentInvoiceStatus = 0)
						--	BEGIN
						--		SET @CheckoutCurrentStatus = 'Manager Verified'
						--	END
					END
			END
		ELSE
			BEGIN
				SET @ysnInvoiceStatus = 0 -- Set to false

				--SELECT @CheckoutCurrentStatus = strCheckoutStatus
				--FROM tblSTCheckoutHeader
				--WHERE intCheckoutId = @intCheckoutId
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
					BEGIN																																																																																																																																																																																									BEGIN
						INSERT INTO @EntriesForInvoice(
						--INSERT INTO CopierDB.dbo.InvoiceIntegrationStagingTable(
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
										,[strComments]				= @strComments
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
										,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
										,[intInvoiceDetailId]		= NULL
										,[intItemId]				= I.intItemId
										,[ysnInventory]				= 1
										,[strItemDescription]		= I.strDescription
										,[intOrderUOMId]			= UOM.intItemUOMId
										,[dblQtyOrdered]			= CPT.dblQuantity --(Select dblQuantity From tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
										,[intItemUOMId]				= UOM.intItemUOMId
										,[dblQtyShipped]			= CPT.dblQuantity --(Select dblQuantity From tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
										,[dblDiscount]				= 0

										-- Should remove tax to calculate Net Price --CPT.dblPrice
										-- ,[dblPrice]				    = CPT.dblPrice --(Select dblPrice From tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
										,[dblPrice]					= CPT.dblPrice - CAST((SELECT SUM(dblAdjustedTax) 
																						  FROM [dbo].[fnGetItemTaxComputationForCustomer]
																						  (
																								I.intItemId
																								, ST.intCheckoutCustomerId
																								, GETDATE()
																								, CPT.dblPrice
																								, 1
																								, ST.intTaxGroupId
																								, ST.intCompanyLocationId
																								, EL.intEntityLocationId
																								, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
																						  )) AS DECIMAL(18,6))

										,[ysnRefreshPrice]			= 0
										,[strMaintenanceType]		= NULL
										,[strFrequency]				= NULL
										,[dtmMaintenanceDate]		= NULL
										,[dblMaintenanceAmount]		= NULL
										,[dblLicenseAmount]			= NULL
										,[intTaxGroupId]			= @intTaxGroupId
										,[ysnRecomputeTax]			= 1 -- Should recompute tax only for Pump Total Items
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
										,[intSubCurrencyId]			= @intCurrencyId
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
							JOIN dbo.tblEMEntityLocation EL ON ST.intCheckoutCustomerId = EL.intEntityId
							WHERE CPT.intCheckoutId = @intCheckoutId
							AND CPT.dblAmount > 0
							AND UOM.ysnStockUnit = CAST(1 AS BIT)

					END
				END
				ELSE
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = @strStatusMsg + '<BR>' + 'No records found to Post Pump Totals'
					END
				----------------------------------------------------------------------
				------------------------- END PUMP TOTALS ----------------------------
				----------------------------------------------------------------------


				----------------------------------------------------------------------
				---------------------------- ITEM MOVEMENTS --------------------------
				----------------------------------------------------------------------
				IF EXISTS(SELECT * FROM tblSTCheckoutItemMovements WHERE intCheckoutId = @intCheckoutId AND dblTotalSales > 0)
					BEGIN																																																																																																																																																																																						BEGIN
							INSERT INTO @EntriesForInvoice(
							--INSERT INTO CopierDB.dbo.InvoiceIntegrationStagingTable(
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
											,[strComments]				= @strComments
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
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= UOM.intItemUOMId
											,[dblQtyOrdered]			= IM.intQtySold
											,[intItemUOMId]				= UOM.intItemUOMId
											,[dblQtyShipped]			= IM.intQtySold
											,[dblDiscount]				= 0
											,[dblPrice]					= IM.dblTotalSales / IM.intQtySold --IM.dblCurrentPrice
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
											,[dblCOGSAmount]			= IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = I.intItemId
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
								FROM tblSTCheckoutItemMovements IM
								JOIN tblICItemUOM UOM ON IM.intItemUPCId = UOM.intItemUOMId
								JOIN tblSTCheckoutHeader CH ON IM.intCheckoutId = CH.intCheckoutId
								JOIN tblICItem I ON UOM.intItemId = I.intItemId
								JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
								JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
														AND IL.intItemLocationId = IP.intItemLocationId
								JOIN tblSTStore ST ON IL.intLocationId = ST.intCompanyLocationId
													AND CH.intStoreId = ST.intStoreId
								WHERE IM.intCheckoutId = @intCheckoutId
								AND IM.dblTotalSales > 0
								AND UOM.ysnStockUnit = CAST(1 AS BIT)
					END
				END
				ELSE 
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = @strStatusMsg + '<BR>' + 'No records found to Post Item Movements'
					END
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
											,[strComments]				= @strComments
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
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= UOM.intItemUOMId
											,[dblQtyOrdered]			= CASE 
																			WHEN 
																				(
																					CAST((DT.dblTotalSalesAmount - (
																														SELECT SUM(dblTotalSales)
																														FROM tblSTCheckoutItemMovements IM
																														JOIN tblICItemUOM UOM ON IM.intItemUPCId = UOM.intItemUOMId
																														JOIN tblICItem I ON UOM.intItemId = I.intItemId
																														JOIN tblICCategory CATT ON I.intCategoryId = CATT.intCategoryId 
																														WHERE intCheckoutId = @intCheckoutId
																														AND CATT.intCategoryId = DT.intCategoryId)) AS NUMERIC(18, 6)
																										           )
																				) > 1 THEN 1
																			ELSE -1
																		  END
											,[intItemUOMId]				= UOM.intItemUOMId
											,[dblQtyShipped]			= CASE 
																			WHEN 
																				(
																					CAST((DT.dblTotalSalesAmount - (
																														SELECT SUM(dblTotalSales)
																														FROM tblSTCheckoutItemMovements IM
																														JOIN tblICItemUOM UOM ON IM.intItemUPCId = UOM.intItemUOMId
																														JOIN tblICItem I ON UOM.intItemId = I.intItemId
																														JOIN tblICCategory CATT ON I.intCategoryId = CATT.intCategoryId 
																														WHERE intCheckoutId = @intCheckoutId
																														AND CATT.intCategoryId = DT.intCategoryId)) AS NUMERIC(18, 6)
																										           )
																				) > 1 THEN 1
																			ELSE -1
																		  END
											,[dblDiscount]				= 0
											,[dblPrice]					= CAST((DT.dblTotalSalesAmount - (
																											SELECT SUM(dblTotalSales)
																											FROM tblSTCheckoutItemMovements IM
																											JOIN tblICItemUOM UOM ON IM.intItemUPCId = UOM.intItemUOMId
																											JOIN tblICItem I ON UOM.intItemId = I.intItemId
																											JOIN tblICCategory CATT ON I.intCategoryId = CATT.intCategoryId 
																											WHERE intCheckoutId = @intCheckoutId
																											AND CATT.intCategoryId = DT.intCategoryId)) AS NUMERIC(18, 6)
																										 )
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
											,[dblCOGSAmount]			= IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = I.intItemId
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
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
								WHERE DT.intCheckoutId = @intCheckoutId
								AND DT.dblTotalSalesAmount > 0
								AND UOM.ysnStockUnit = CAST(1 AS BIT)
					END
				END
				ELSE 
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = @strStatusMsg + '<BR>' + 'No records found to Post Department Totals'
					END
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
											,[strComments]				= @strComments
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
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= UOM.intItemUOMId
											,[dblQtyOrdered]			= 1
											,[intItemUOMId]				= UOM.intItemUOMId
											,[dblQtyShipped]			= 1
											,[dblDiscount]				= 0
											,[dblPrice]					= STT.dblTotalTax
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
											,[dblCOGSAmount]			= IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = I.intItemId
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
								FROM tblSTCheckoutSalesTaxTotals STT
								JOIN tblICItem I ON STT.intItemId = I.intItemId
								JOIN tblICItemUOM UOM ON I.intItemId = UOM.intItemId
								JOIN tblSTCheckoutHeader CH ON STT.intCheckoutId = CH.intCheckoutId
								JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
								JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
														AND IL.intItemLocationId = IP.intItemLocationId
								JOIN tblSTStore ST ON IL.intLocationId = ST.intCompanyLocationId
													AND CH.intStoreId = ST.intStoreId
								WHERE STT.intCheckoutId = @intCheckoutId
								AND STT.dblTotalTax > 0
								AND UOM.ysnStockUnit = CAST(1 AS BIT)
					END
				END
				ELSE 
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = @strStatusMsg + '<BR>' + 'No records found to Post Department Totals'
					END
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
											,[strComments]				= @strComments
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
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= UOM.intItemUOMId
											,[dblQtyOrdered]			= 1
											,[intItemUOMId]				= UOM.intItemUOMId
											,[dblQtyShipped]			= 1
											,[dblDiscount]				= 0
											,[dblPrice]					= CPO.dblAmount
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
											,[dblCOGSAmount]			= IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = I.intItemId
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
								FROM tblSTCheckoutPaymentOptions CPO
								JOIN tblICItem I ON CPO.intItemId = I.intItemId
								JOIN tblICItemUOM UOM ON I.intItemId = UOM.intItemId
								JOIN tblSTCheckoutHeader CH ON CPO.intCheckoutId = CH.intCheckoutId
								JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
								JOIN tblICItemPricing IP ON I.intItemId = IP.intItemId
														AND IL.intItemLocationId = IP.intItemLocationId
								JOIN tblSTStore ST ON IL.intLocationId = ST.intCompanyLocationId
													AND CH.intStoreId = ST.intStoreId
								WHERE CPO.intCheckoutId = @intCheckoutId
								AND CPO.dblAmount > 0
								AND UOM.ysnStockUnit = CAST(1 AS BIT)
					END
				END
				ELSE 
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = @strStatusMsg + '<BR>' + 'No records found to Post Department Totals'
					END
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
											,[strComments]				= @strComments
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
											,[ysnPost]					= 1 -- 1 = 'Post', 2 = 'UnPost'
											,[intInvoiceDetailId]		= NULL
											,[intItemId]				= I.intItemId
											,[ysnInventory]				= 1
											,[strItemDescription]		= I.strDescription
											,[intOrderUOMId]			= UOM.intItemUOMId
											,[dblQtyOrdered]			= -1
											,[intItemUOMId]				= UOM.intItemUOMId
											,[dblQtyShipped]			= -1
											,[dblDiscount]				= 0
											,[dblPrice]					= CC.dblAmount
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
											,[dblCOGSAmount]			= IP.dblSalePrice
											,[intTempDetailIdForTaxes]  = I.intItemId
											,[intConversionAccountId]	= NULL -- not sure
											,[intCurrencyExchangeRateTypeId]	= NULL
											,[intCurrencyExchangeRateId]		= NULL
											,[dblCurrencyExchangeRate]	= 1.000000
											,[intSubCurrencyId]			= NULL
											,[dblSubCurrencyRate]		= 1.000000
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
								AND UOM.ysnStockUnit = CAST(1 AS BIT)
					END
				END
				ELSE 
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = @strStatusMsg + '<BR>' + 'No records found to Post Customer Charges'
					END
				----------------------------------------------------------------------
				----------------------- END CUSTOMER CHARGES -------------------------
				----------------------------------------------------------------------




				----------------------------------------------------------------------
				------------------------------- POST ---------------------------------
				----------------------------------------------------------------------
				DECLARE @ErrorMessage AS NVARCHAR(MAX) = ''
				DECLARE @CreatedIvoices AS NVARCHAR(MAX) = ''

				-- SELECT * FROM @EntriesForInvoice

				BEGIN TRY
					EXEC [dbo].[uspARProcessInvoices]
								@InvoiceEntries	 = @EntriesForInvoice
								--,@LineItemTaxEntries = NULL
								,@UserId			 = @intCurrentUserId
		 						,@GroupingOption	 = 11
								,@RaiseError		 = 1
								,@ErrorMessage		 = @ErrorMessage OUTPUT
								,@CreatedIvoices	 = @CreatedIvoices OUTPUT
				END TRY

				BEGIN CATCH
					SET @ErrorMessage = ERROR_MESSAGE()
				END CATCH



				IF(@ErrorMessage IS NULL OR @ErrorMessage = '')
					BEGIN
						SET @intCreatedInvoiceId = CAST(@CreatedIvoices AS INT)
						SET @ysnUpdateCheckoutStatus = 1
						SET @strStatusMsg = 'Success'
						SET @ysnInvoiceStatus = 1
					END
				ELSE
					BEGIN
						SET @ysnUpdateCheckoutStatus = 0
						SET @strStatusMsg = @strStatusMsg + '<BR>' + @ErrorMessage
					END
				----------------------------------------------------------------------
				---------------------------- END POST --------------------------------
				----------------------------------------------------------------------
			END
		ELSE IF(@ysnPost = 0)
			BEGIN
				SET @strInvoiceId = CAST(@intCurrentInvoiceId AS NVARCHAR(50))

				----------------------------------------------------------------------
				----------------------------- UN-POST ---------------------------------
				----------------------------------------------------------------------
				BEGIN TRY
						EXEC [dbo].[uspARPostInvoice]
								@batchId			= NULL,
								@post				= 0, -- 0 = UnPost
								@recap				= 0,
								@param				= @strInvoiceId,
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

						SET @ysnSuccess = 1
				END TRY

				BEGIN CATCH
					SET @ysnUpdateCheckoutStatus = 0
					SET @ysnSuccess = 0
					SET @strStatusMsg = ERROR_MESSAGE()
				END CATCH

				-- Example OutPut params
				-- @intSuccessfullCount: 1
				-- @intInvalidCount: 0
				-- @ysnSuccess: 1
				-- @strBatchIdUsed: BATCH-722

				IF(@ysnSuccess = 1)
					BEGIN
						SET @ysnInvoiceStatus = 0
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
		SET @strStatusMsg = 'Script Error: ' + ERROR_MESSAGE()
	END CATCH
END