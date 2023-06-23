CREATE PROCEDURE [dbo].[uspTRLoadProcessToInvoice]
	 @intLoadHeaderId AS INT
	, @intUserId AS INT	
	, @ysnRecap AS BIT
	, @ysnPostOrUnPost AS BIT
	, @BatchId NVARCHAR(20) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(MAX)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @CreatedInvoices NVARCHAR(MAX)
DECLARE @UpdatedInvoices NVARCHAR(MAX)

BEGIN TRY

	DECLARE @UserEntityId INT
	SET @UserEntityId = ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE intEntityId = @intUserId), @intUserId)

	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @intFreightItemId	INT
	  , @intSurchargeItemId		INT
	  , @ysnItemizeSurcharge	BIT
	  , @HasBlend BIT = 0
	  , @strFreightItemNo NVARCHAR(300) = NULL
	  , @strSurchargeItemNo NVARCHAR(300) = NULL
	  , @ysnComboFreight BIT = 0  
	  , @intComboFreightDistId INT = NULL
	  , @ysnGrossNet BIT = 0

	SELECT @intFreightItemId = intFreightItemId, @strFreightItemNo = I.strItemNo
	FROM tblTRLoadHeader H INNER JOIN tblICItem I ON I.intItemId = H.intFreightItemId
	WHERE H.intLoadHeaderId = @intLoadHeaderId

	SELECT TOP 1 @intSurchargeItemId = intItemId, @strSurchargeItemNo = strItemNo 
	FROM vyuICGetOtherCharges WHERE intOnCostTypeId = @intFreightItemId

	 SELECT TOP 1 @ysnItemizeSurcharge = ISNULL(ysnItemizeSurcharge, 0)  
	 , @ysnComboFreight = ISNULL(ysnComboFreight, 0)  
	 , @ysnGrossNet = ISNULL(ysnAllowDifferentUnits, 0)  
	 , @intSendBolAttachmentOption = ISNULL(intSendBolAttachmentOptionId, 3)  
	 FROM tblTRCompanyPreference    

	BEGIN TRANSACTION

	SELECT DISTINCT [strSourceTransaction]		= 'Transport Load'
		,[strType] 								= CASE WHEN DD.intSiteId IS NULL THEN 'Transport Delivery' ELSE 'Tank Delivery' END
		,[intLoadDistributionHeaderId]			= DH.intLoadDistributionHeaderId
		,[intLoadDistributionDetailId]			= DD.intLoadDistributionDetailId
		,[intSourceId]							= DH.intLoadDistributionHeaderId
		,[strSourceId]							= TL.strTransaction
		,[intInvoiceId]							= DH.intInvoiceId --NULL Value will create new invoice
		,[intEntityCustomerId]					= DH.intEntityCustomerId
		,[intCompanyLocationId]					= DH.intCompanyLocationId
		,[intCurrencyId]						= NULL
		,[intTermId]                            = CASE WHEN TMS.intDeliveryTermID IS NOT NULL THEN TMS.intDeliveryTermID
                                                    WHEN EL.intTermsId IS NOT NULL THEN EL.intTermsId
                                                    WHEN TPPI.intTermId IS NOT NULL THEN TPPI.intTermId
													WHEN TPPC.intTermId IS NOT NULL THEN TPPC.intTermId
                                                    ELSE Customer.intTermsId END
		,[dtmDate]								= DH.dtmInvoiceDateTime
		,[dtmDueDate]							= NULL
		,[dtmShipDate]							= DH.dtmInvoiceDateTime
		,[intEntitySalespersonId]				= DH.intEntitySalespersonId
		,[intFreightTermId]						= EL.intFreightTermId
		,[intShipViaId]							= ISNULL(TL.intShipViaId, EL.intShipViaId) 
		,[intPaymentMethodId]					= 0
		,[strInvoiceOriginId]					= CASE WHEN (MBIL.intDeliveryHeaderId IS NOT NULL AND ISNULL(MBIL.strDeliveryNumber, '') <> '') THEN MBIL.strDeliveryNumber ELSE  TL.strTransaction END
		,[strPONumber]							= DH.strPurchaseOrder
		,[strBOLNumber]							= ISNULL(TR.strBillOfLading, DD.strBillOfLading)
		,[strComments]							= ''
		/*
		,[strComments]							= CASE WHEN TR.intLoadReceiptId IS NULL THEN (
														(CASE WHEN BlendIngredient.intSupplyPointId IS NULL AND TL.intLoadId IS NULL THEN RTRIM(ISNULL(DH.strComments, ''))
															WHEN BlendIngredient.intSupplyPointId IS NOT NULL AND TL.intLoadId IS NULL THEN 'Origin:' + RTRIM(ISNULL(BlendIngredient.strSupplyPoint, '')) + ' ' + RTRIM(ISNULL(DH.strComments, ''))
															WHEN BlendIngredient.intSupplyPointId IS NULL AND TL.intLoadId IS NOT NULL THEN 'Load #:' + RTRIM(ISNULL(LG.strExternalLoadNumber, '')) + ' ' + RTRIM(ISNULL(DH.strComments, ''))
															WHEN BlendIngredient.intSupplyPointId IS NOT NULL AND TL.intLoadId IS NOT NULL THEN 'Origin:' + RTRIM(ISNULL(BlendIngredient.strSupplyPoint, ''))  + ' Load #:' + RTRIM(ISNULL(LG.strExternalLoadNumber, '')) + ' ' + RTRIM(ISNULL(DH.strComments, ''))
														END))
													ELSE (CASE WHEN TR.intSupplyPointId IS NULL AND TL.intLoadId IS NULL THEN RTRIM(ISNULL(DH.strComments, ''))
														WHEN TR.intSupplyPointId IS NOT NULL AND TL.intLoadId IS NULL THEN 'Origin:' + RTRIM(ISNULL(ee.strSupplyPoint, '')) + ' ' + RTRIM(ISNULL(DH.strComments, ''))
														WHEN TR.intSupplyPointId IS NULL AND TL.intLoadId IS NOT NULL THEN 'Load #:' + RTRIM(ISNULL(LG.strExternalLoadNumber, '')) + ' ' + RTRIM(ISNULL(DH.strComments, ''))
														WHEN TR.intSupplyPointId IS NOT NULL AND TL.intLoadId IS NOT NULL THEN 'Origin:' + RTRIM(ISNULL(ee.strSupplyPoint, ''))  + ' Load #:' + RTRIM(ISNULL(LG.strExternalLoadNumber, '')) + ' ' + RTRIM(ISNULL(DH.strComments, ''))
													END) END
		*/
		,[strFooterComments]					= rtrim(ltrim(isnull(DH.strComments,'')))
		,[intShipToLocationId]					= DH.intShipToLocationId
		,[intBillToLocationId]					= ISNULL(Customer.intBillToId, EL.intEntityLocationId)
		,[ysnTemplate]							= 0
		,[ysnForgiven]							= 0
		,[ysnCalculated]						= 0  --0 OS
		,[ysnSplitted]							= 0
		,[intPaymentId]							= NULL
		,[intSplitId]							= NULL
		,[strActualCostId]						= CASE WHEN ISNULL(DD.strReceiptLink, '') = '' THEN BlendingIngredient.strActualCostId ELSE 
													(CASE WHEN (TR.strOrigin) = 'Terminal' AND (DH.strDestination) = 'Customer'
														THEN (TL.strTransaction)
													WHEN (TR.strOrigin) = 'Location' AND (DH.strDestination) = 'Customer' AND (TR.intCompanyLocationId) = (DH.intCompanyLocationId)
														THEN NULL
													WHEN (TR.strOrigin) = 'Location' AND (DH.strDestination) = 'Customer' AND (TR.intCompanyLocationId) != (DH.intCompanyLocationId)
														THEN (TL.strTransaction)
													WHEN (TR.strOrigin) = 'Location' AND (DH.strDestination) = 'Location'
														THEN NULL
													END) END
		,[intShipmentId]						= NULL
		,[intTransactionId]						= NULL
		,[intEntityId]							= @UserEntityId
		,[ysnResetDetails]						= 1
		,[ysnPost]								= CASE WHEN (@ysnRecap = 1) THEN NULL ELSE @ysnPostOrUnPost END
		,[intInvoiceDetailId]					= NULL
		,[intItemId]							= DD.intItemId
		,[ysnInventory]							= [dbo].[fnIsStockTrackingItem](DD.intItemId)
		,[strItemDescription]					= Item.strItemDescription
		,[intOrderUOMId]						= Item.intIssueUOMId
		,[intItemUOMId]							= Item.intIssueUOMId
		,[dblQtyOrdered]						= CASE WHEN @ysnGrossNet = 1 THEN 
															CASE WHEN EL.strSaleUnits = 'Gross' THEN DD.dblDistributionGrossSalesUnits 
																WHEN EL.strSaleUnits = 'Net' THEN DD.dblDistributionNetSalesUnits
																WHEN TR.strGrossOrNet = 'Net' THEN DD.dblDistributionNetSalesUnits
																WHEN TR.strGrossOrNet = 'Gross' THEN DD.dblDistributionGrossSalesUnits 
																ELSE DD.dblUnits END
														ELSE DD.dblUnits END
		,[dblQtyShipped]						= CASE WHEN @ysnGrossNet = 1 THEN 
															CASE WHEN EL.strSaleUnits = 'Gross' THEN DD.dblDistributionGrossSalesUnits 
																WHEN EL.strSaleUnits = 'Net' THEN DD.dblDistributionNetSalesUnits
																WHEN TR.strGrossOrNet = 'Net' THEN DD.dblDistributionNetSalesUnits
																WHEN TR.strGrossOrNet = 'Gross' THEN DD.dblDistributionGrossSalesUnits 
																ELSE DD.dblUnits END
														ELSE DD.dblUnits END
		,[dblDiscount]							= 0
		,[dblPrice]								--= DD.dblPrice
												= CASE WHEN DD.ysnFreightInPrice = 0 THEN DD.dblPrice
														WHEN DD.ysnFreightInPrice = 1 AND @ysnItemizeSurcharge = 0 AND ISNULL(DD.dblDistSurcharge,0) != 0 THEN DD.dblPrice + ISNULL(DD.dblFreightRate,0) + (ISNULL(DD.dblFreightRate,0) * (DD.dblDistSurcharge / 100))
														WHEN DD.ysnFreightInPrice = 1 THEN DD.dblPrice + ISNULL(DD.dblFreightRate,0)
												END
		,[ysnRefreshPrice]						= 0
		,[strMaintenanceType]					= ''
		,[strFrequency]							= ''
		,[dtmMaintenanceDate]					= NULL
		,[dblMaintenanceAmount]					= NULL
		,[dblLicenseAmount]						= NULL
		,[intTaxGroupId]						= DD.intTaxGroupId
		,[ysnRecomputeTax]						= CASE WHEN ISNULL(DD.intTaxGroupId, '') <> '' THEN 1
														ELSE 0 END
		,[intSCInvoiceId]						= NULL
		,[strSCInvoiceNumber]					= ''
		,[intInventoryShipmentItemId]			= NULL
		,[strShipmentNumber]					= ''
		,[intSalesOrderDetailId]				= NULL
		,[strSalesOrderNumber]					= ''
		,[intContractHeaderId]					= (SELECT TOP 1 intContractHeaderId FROM vyuCTContractDetailView CT WHERE CT.intContractDetailId = DD.intContractDetailId) 
		,[intContractDetailId]					= DD.intContractDetailId
		,[intShipmentPurchaseSalesContractId]	= NULL
		,[intTicketId]							= NULL
		,[intTicketHoursWorkedId]				= NULL
		,[intSiteId]							= DD.intSiteId
		,[strBillingBy]							= ''
		,[dblPercentFull]						= CASE WHEN DD.intSiteId IS NULL THEN NULL ELSE DD.dblPercentFull END
		,[dblNewMeterReading]					= NULL
		,[dblPreviousMeterReading]				= NULL
		,[dblConversionFactor]					= NULL
		,[intPerformerId]						= NULL
		,[ysnLeaseBilling]						= NULL
		,[ysnVirtualMeterReading]				= NULL
		,[ysnClearDetailTaxes]					= 1
		,[intTempDetailIdForTaxes]				= NULL
		,[dblSurcharge]							= DD.dblDistSurcharge
		,DD.dblFreightRate
		,DD.ysnFreightInPrice
		,intTruckDriverId = CASE WHEN TL.intDriverId IS NULL THEN NULL ELSE TL.intDriverId END
		,intTruckDriverReferenceId = SC.intTruckDriverReferenceId
		,ysnImpactInventory = CASE WHEN ISNULL(CustomerFreight.ysnFreightOnly, 0) = 1 THEN 0 ELSE 1 END
		,strBOLNumberDetail  = DD.strBillOfLading
		,ysnBlended = CASE WHEN BlendingIngredient.intLoadDistributionDetailId IS NOT NULL AND BlendingIngredient.intItemId IS NOT NULL THEN 1 ELSE 0 END
		,dblMinimumUnits						= DD.dblMinimumUnits
		,dblComboFreightRate					= DD.dblComboFreightRate
		,ysnComboFreight						= DD.ysnComboFreight
		,dblComboMinimumUnits					= DD.dblComboMinimumUnits
		,dblComboSurcharge						= DD.dblComboSurcharge
		,intInventoryReceiptId					= TR.intInventoryReceiptId
		,intDispatchId							= DD.intTMOId
		,[intCompanyLocationSubLocationId]		= TR.intBulkStorageLocationId
		,ysnUseOriginIdAsInvoiceNumber			= CASE WHEN (MBIL.intDeliveryHeaderId IS NOT NULL AND ISNULL(MBIL.strDeliveryNumber, '') <> '') THEN 1 ELSE  0 END
	INTO #tmpSourceTable
	FROM tblTRLoadHeader TL
	LEFT JOIN tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = TL.intLoadHeaderId
	LEFT JOIN tblARCustomer Customer ON Customer.intEntityId = DH.intEntityCustomerId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = DH.intShipToLocationId
	LEFT JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
	LEFT JOIN vyuICGetItemLocation Item ON Item.intItemId = DD.intItemId AND Item.intLocationId = DH.intCompanyLocationId
	LEFT JOIN tblLGLoad LG ON LG.intLoadId = TL.intLoadId
	LEFT JOIN vyuICGetItemStock IC ON IC.intItemId = DD.intItemId AND IC.intLocationId = DH.intCompanyLocationId
	LEFT JOIN tblSCTruckDriverReference SC ON SC.intTruckDriverReferenceId = TL.intTruckDriverReferenceId
	LEFT JOIN vyuTRGetLoadReceipt TR ON TR.intLoadHeaderId = TL.intLoadHeaderId AND TR.strReceiptLine IN (
		SELECT Item 
		FROM dbo.fnTRSplit(DD.strReceiptLink,','))
		LEFT JOIN ( 
				SELECT DISTINCT intLoadDistributionDetailId
					, STUFF(( SELECT DISTINCT ', ' + CD.strSupplyPoint
								FROM dbo.vyuTRLinkedReceipts CD
								WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
									AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
								FOR XML PATH('')), 1, 2, '') strSupplyPoint
				FROM vyuTRLinkedReceipts CH) ee 
			ON ee.intLoadDistributionDetailId = DD.intLoadDistributionDetailId
	LEFT JOIN (
		SELECT DistItem.intLoadDistributionDetailId
			, HeaderDistItem.intLoadDistributionHeaderId
			, intItemId = BlendIngredient.intIngredientItemId
			, dblQty = BlendIngredient.dblQuantity
			, HeaderDistItem.intCompanyLocationId
			, HeaderDistItem.dtmInvoiceDateTime
			, strActualCostId = (CASE WHEN Receipt.strOrigin = 'Terminal' AND HeaderDistItem.strDestination = 'Customer'
										THEN LoadHeader.strTransaction
									WHEN Receipt.strOrigin = 'Location' AND HeaderDistItem.strDestination = 'Customer' AND Receipt.intCompanyLocationId = HeaderDistItem.intCompanyLocationId
										THEN NULL
									WHEN Receipt.strOrigin = 'Location' AND HeaderDistItem.strDestination = 'Customer' AND Receipt.intCompanyLocationId != HeaderDistItem.intCompanyLocationId
										THEN LoadHeader.strTransaction
									WHEN Receipt.strOrigin = 'Location' AND HeaderDistItem.strDestination = 'Location'
										THEN NULL
									END)
			, Receipt.strBillOfLading
			, Receipt.intSupplyPointId
			, Receipt.strSupplyPoint
			, Receipt.strZipCode
		FROM tblTRLoadDistributionDetail DistItem
		LEFT JOIN tblTRLoadDistributionHeader HeaderDistItem ON HeaderDistItem.intLoadDistributionHeaderId = DistItem.intLoadDistributionHeaderId
		LEFT JOIN tblTRLoadHeader LoadHeader ON LoadHeader.intLoadHeaderId = HeaderDistItem.intLoadHeaderId
		LEFT JOIN vyuTRGetLoadBlendIngredient BlendIngredient ON BlendIngredient.intLoadDistributionDetailId = DistItem.intLoadDistributionDetailId
		LEFT JOIN vyuTRGetLoadReceipt Receipt ON Receipt.intLoadHeaderId = LoadHeader.intLoadHeaderId AND Receipt.intItemId = BlendIngredient.intIngredientItemId
		WHERE ISNULL(DistItem.strReceiptLink, '') = ''
		--AND ISNULL(BlendIngredient.strType, '') != 'Other Charge'
	) BlendingIngredient ON BlendingIngredient.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId AND ISNULL(DD.strReceiptLink, '') = '' AND BlendingIngredient.intLoadDistributionDetailId = DD.intLoadDistributionDetailId
	LEFT JOIN tblARCustomerFreightXRef CustomerFreight ON CustomerFreight.intEntityCustomerId = DH.intEntityCustomerId
			AND CustomerFreight.intEntityLocationId = DH.intShipToLocationId
			AND CustomerFreight.intCategoryId = Item.intCategoryId
			AND CustomerFreight.strZipCode = ISNULL(TR.strZipCode, BlendingIngredient.strZipCode)
	LEFT JOIN tblTMSite TMS ON TMS.intSiteID = DD.intSiteId
	
	LEFT JOIN tblSMTermPullPoint TPPI ON TPPI.strPullPoint = CASE WHEN TR.strOrigin = 'Location' THEN 'Company Location' ELSE TR.strOrigin END
    AND TPPI.intCategoryId = IC.intCategoryId AND TPPI.intItemId = DD.intItemId
	
	LEFT JOIN tblSMTermPullPoint TPPC ON TPPC.strPullPoint = CASE WHEN TR.strOrigin = 'Location' THEN 'Company Location' ELSE TR.strOrigin END
    AND TPPC.intCategoryId = IC.intCategoryId

	LEFT JOIN tblMBILDeliveryHeader MBIL ON DH.intDeliveryHeaderId = MBIL.intDeliveryHeaderId
	WHERE TL.intLoadHeaderId = @intLoadHeaderId
		AND DH.strDestination = 'Customer'
		-- AND (TL.intMobileLoadHeaderId IS NULL
		-- 	OR (TL.intMobileLoadHeaderId IS NOT NULL AND DH.ysnMobileInvoice = 0)
		-- )

	-- Concatenate PO Number, BOL Number, and Comments in cases there are different values and they are not used as a grouping option
	DECLARE @concatPONumber NVARCHAR(MAX) = ''
		, @concatBOLNumber NVARCHAR(MAX) = ''
		, @concatComment NVARCHAR(MAX) = ''
		, @currentId INT
		, @QueryString NVARCHAR(MAX)
		, @EntityCustomerId INT
		, @SourceId INT
		, @CompanyLocationId INT
		, @Date DATETIME
		, @TermId INT
		, @ShipViaId INT
		, @EntitySalespersonId INT
		, @Comments NVARCHAR(200) = ''
		, @PONumber NVARCHAR(200) = ''
		, @BOLNumber NVARCHAR(200) = ''
		, @concatActualCost NVARCHAR(MAX) = ''
		, @ActualCost NVARCHAR(200) = ''
		, @DistributionDetailKey INT


	-- Update multiple comment concatenation.
	SELECT DISTINCT intEntityCustomerId, intSourceId, intCompanyLocationId, dtmDate, intTermId, intShipViaId, intEntitySalespersonId, strComments, strFooterComments
	INTO #tmpComment
	FROM #tmpSourceTable
	WHERE ISNULL(strComments, '') <> ''
	ORDER BY intEntityCustomerId, intSourceId, intCompanyLocationId, dtmDate, intTermId, intShipViaId, intEntitySalespersonId

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpComment)
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1
				FROM #tmpComment
				WHERE intEntityCustomerId = @EntityCustomerId
					AND intSourceId = @SourceId
					AND intCompanyLocationId = @CompanyLocationId
					AND dtmDate = @Date
					AND intTermId = @TermId
					AND intShipViaId = @ShipViaId
					AND intEntitySalespersonId = @EntitySalespersonId
		)
		BEGIN
			SET @concatComment = ''
		END

		SELECT TOP 1 @EntityCustomerId = intEntityCustomerId
			, @SourceId = intSourceId
			, @CompanyLocationId = intCompanyLocationId
			, @Date = dtmDate
			, @TermId = intTermId
			, @ShipViaId = intShipViaId
			, @EntitySalespersonId = intEntitySalespersonId
			, @Comments = strComments
		FROM #tmpComment

		IF (LEN(@concatComment) > 0)
		BEGIN
			SET @concatComment += ', '
		END
		SET @concatComment += @Comments

		UPDATE #tmpSourceTable
			SET strComments = @concatComment
		WHERE intEntityCustomerId = @EntityCustomerId
			AND intSourceId = @SourceId
			AND intCompanyLocationId = @CompanyLocationId
			AND dtmDate = @Date
			AND intTermId = @TermId
			AND intShipViaId = @ShipViaId
			AND intEntitySalespersonId = @EntitySalespersonId

		DELETE FROM #tmpComment
		WHERE intEntityCustomerId = @EntityCustomerId
			AND intSourceId = @SourceId
			AND intCompanyLocationId = @CompanyLocationId
			AND dtmDate = @Date
			AND intTermId = @TermId
			AND intShipViaId = @ShipViaId
			AND intEntitySalespersonId = @EntitySalespersonId
			AND strComments = @Comments
	END	
	DROP TABLE #tmpComment

	-- Update multiple BOL Number concatenation.
	SELECT DISTINCT intEntityCustomerId, intSourceId, intCompanyLocationId, dtmDate, intTermId, intShipViaId, intEntitySalespersonId, strBOLNumber
	INTO #tmpBOL
	FROM #tmpSourceTable
	WHERE ISNULL(strBOLNumber, '') <> ''
	ORDER BY intEntityCustomerId, intSourceId, intCompanyLocationId, dtmDate, intTermId, intShipViaId, intEntitySalespersonId

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpBOL)
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1
				FROM #tmpBOL
				WHERE intEntityCustomerId = @EntityCustomerId
					AND intSourceId = @SourceId
					AND intCompanyLocationId = @CompanyLocationId
					AND dtmDate = @Date
					AND intTermId = @TermId
					AND intShipViaId = @ShipViaId
					AND intEntitySalespersonId = @EntitySalespersonId
		)
		BEGIN
			SET @concatBOLNumber = ''
		END

		SELECT TOP 1 @EntityCustomerId = intEntityCustomerId
			, @SourceId = intSourceId
			, @CompanyLocationId = intCompanyLocationId
			, @Date = dtmDate
			, @TermId = intTermId
			, @ShipViaId = intShipViaId
			, @EntitySalespersonId = intEntitySalespersonId
			, @BOLNumber = strBOLNumber
		FROM #tmpBOL

		IF (LEN(@concatBOLNumber) > 0)
		BEGIN
			SET @concatBOLNumber += ', '
		END
		SET @concatBOLNumber += @BOLNumber

		UPDATE #tmpSourceTable
			SET strBOLNumber = @concatBOLNumber
		WHERE intEntityCustomerId = @EntityCustomerId
			AND intSourceId = @SourceId
			AND intCompanyLocationId = @CompanyLocationId
			AND dtmDate = @Date
			AND intTermId = @TermId
			AND intShipViaId = @ShipViaId
			AND intEntitySalespersonId = @EntitySalespersonId

		DELETE FROM #tmpBOL
		WHERE intEntityCustomerId = @EntityCustomerId
			AND intSourceId = @SourceId
			AND intCompanyLocationId = @CompanyLocationId
			AND dtmDate = @Date
			AND intTermId = @TermId
			AND intShipViaId = @ShipViaId
			AND intEntitySalespersonId = @EntitySalespersonId
			AND strBOLNumber = @BOLNumber
	END	
	DROP TABLE #tmpBOL

	-- Update multiple PO Number concatenation.
	SELECT DISTINCT intEntityCustomerId, intSourceId, intCompanyLocationId, dtmDate, intTermId, intShipViaId, intEntitySalespersonId, strPONumber
	INTO #tmpPO
	FROM #tmpSourceTable
	WHERE ISNULL(strPONumber, '') <> ''
	ORDER BY intEntityCustomerId, intSourceId, intCompanyLocationId, dtmDate, intTermId, intShipViaId, intEntitySalespersonId
	
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpPO)
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1
				FROM #tmpPO
				WHERE intEntityCustomerId = @EntityCustomerId
					AND intSourceId = @SourceId
					AND intCompanyLocationId = @CompanyLocationId
					AND dtmDate = @Date
					AND intTermId = @TermId
					AND intShipViaId = @ShipViaId
					AND intEntitySalespersonId = @EntitySalespersonId
		)
		BEGIN
			SET @concatPONumber = ''
		END

		SELECT TOP 1 @EntityCustomerId = intEntityCustomerId
			, @SourceId = intSourceId
			, @CompanyLocationId = intCompanyLocationId
			, @Date = dtmDate
			, @TermId = intTermId
			, @ShipViaId = intShipViaId
			, @EntitySalespersonId = intEntitySalespersonId
			, @PONumber = strPONumber
		FROM #tmpPO

		IF (LEN(@concatPONumber) > 0)
		BEGIN
			SET @concatPONumber += ', '
		END
		SET @concatPONumber += @PONumber

		UPDATE #tmpSourceTable
			SET strPONumber = @concatPONumber
		WHERE intEntityCustomerId = @EntityCustomerId
			AND intSourceId = @SourceId
			AND intCompanyLocationId = @CompanyLocationId
			AND dtmDate = @Date
			AND intTermId = @TermId
			AND intShipViaId = @ShipViaId
			AND intEntitySalespersonId = @EntitySalespersonId

		DELETE FROM #tmpPO
		WHERE intEntityCustomerId = @EntityCustomerId
			AND intSourceId = @SourceId
			AND intCompanyLocationId = @CompanyLocationId
			AND dtmDate = @Date
			AND intTermId = @TermId
			AND intShipViaId = @ShipViaId
			AND intEntitySalespersonId = @EntitySalespersonId
			AND strPONumber = @PONumber
	END	
	DROP TABLE #tmpPO

	-- Update multiple Actual Cost concatenation.
	SELECT DISTINCT intLoadDistributionDetailId, strActualCostId
	INTO #tmpActualCost
	FROM #tmpSourceTable
	WHERE ISNULL(strActualCostId, '') <> ''
	ORDER BY intLoadDistributionDetailId, strActualCostId
	
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpActualCost)
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1
				FROM #tmpActualCost
				WHERE intLoadDistributionDetailId = @DistributionDetailKey
		)
		BEGIN
			SET @concatActualCost = ''
		END

		SELECT TOP 1 @DistributionDetailKey = intLoadDistributionDetailId
			, @ActualCost = strActualCostId
		FROM #tmpActualCost

		IF (LEN(@concatActualCost) > 0)
		BEGIN
			SET @concatActualCost += ', '
		END
		SET @concatActualCost += @ActualCost

		UPDATE #tmpSourceTable
			SET strActualCostId = @concatActualCost
		WHERE intLoadDistributionDetailId = @DistributionDetailKey

		DELETE FROM #tmpActualCost
		WHERE intLoadDistributionDetailId = @DistributionDetailKey
			AND strActualCostId = @ActualCost
	END	
	DROP TABLE #tmpActualCost

	--Auto Blend
	SELECT DistItem.intLoadDistributionDetailId
		, DistItem.intItemId
		, Recipe.intRecipeId
		, dblQty = dblUnits
		, Recipe.intItemUOMId
		, HeaderDistItem.intCompanyLocationId
		, HeaderDistItem.dtmInvoiceDateTime
	INTO #tmpBlendDistributionItems
	FROM tblTRLoadDistributionDetail DistItem
	LEFT JOIN tblTRLoadDistributionHeader HeaderDistItem ON HeaderDistItem.intLoadDistributionHeaderId = DistItem.intLoadDistributionHeaderId
	LEFT JOIN tblTRLoadHeader LoadHeader ON LoadHeader.intLoadHeaderId = HeaderDistItem.intLoadHeaderId
	LEFT JOIN tblMFRecipe Recipe ON Recipe.intItemId = DistItem.intItemId AND Recipe.intLocationId = HeaderDistItem.intCompanyLocationId
	LEFT JOIN tblMFRecipeItem RecipeItem ON RecipeItem.intRecipeId = Recipe.intRecipeId
	LEFT JOIN tblTRLoadReceipt Receipt ON Receipt.intLoadHeaderId = LoadHeader.intLoadHeaderId AND Receipt.intItemId = RecipeItem.intItemId
	WHERE HeaderDistItem.intLoadHeaderId = @intLoadHeaderId
		AND ysnActive = 1
		AND ISNULL(DistItem.strReceiptLink, '') = ''
	GROUP BY DistItem.intLoadDistributionDetailId
		, DistItem.intItemId
		, Recipe.intRecipeId
		, dblUnits
		, Recipe.intItemUOMId
		, HeaderDistItem.intCompanyLocationId
		, HeaderDistItem.dtmInvoiceDateTime

	IF EXISTS(SELECT TOP 1 1 FROM #tmpBlendDistributionItems) AND @ysnRecap = 0
	BEGIN
		DECLARE @DistributionItemId INT
			, @RecipeId INT
			, @ItemId INT
			, @ItemUOMId INT
			, @LocationId INT
			, @Qty NUMERIC(18, 6)
			, @QtyBlended NUMERIC(18, 6)
			, @dtmInvoiceDateTime DATETIME 

		SET @HasBlend = 1

		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpBlendDistributionItems)
		BEGIN
			SELECT TOP 1 @DistributionItemId = intLoadDistributionDetailId
				, @RecipeId = intRecipeId
				, @ItemId = intItemId
				, @ItemUOMId = intItemUOMId
				, @LocationId = intCompanyLocationId
				, @Qty = dblQty
				, @dtmInvoiceDateTime = dtmInvoiceDateTime
			FROM #tmpBlendDistributionItems

			IF (@ysnPostOrUnPost = 1)
			BEGIN
				EXEC uspMFAutoBlend
					@intSalesOrderDetailId = NULL
					, @intInvoiceDetailId = NULL
					, @intLoadDistributionDetailId = @DistributionItemId
					, @intItemId = @ItemId
					, @dblQtyToProduce = @Qty
					, @intItemUOMId = @ItemUOMId
					, @intLocationId = @LocationId
					, @intSubLocationId = NULL
					, @intStorageLocationId = NULL
					, @intUserId = @intUserId
					, @dblMaxQtyToProduce = @QtyBlended OUTPUT
					, @dtmDate = @dtmInvoiceDateTime
				
				IF (@Qty <> @QtyBlended)
				BEGIN
					RAISERROR('Cannot blend all distribution items', 16, 1)
				END
			END

			DELETE FROM #tmpBlendDistributionItems WHERE intLoadDistributionDetailId = @DistributionItemId
		END
	END
	
	DROP TABLE #tmpBlendDistributionItems

	--VALIDATE FREIGHT AND SURCHARGE ITEM
	DECLARE @intLocationId		INT
	  , @intFreightItemUOMId	INT
	  , @intSurchargeItemUOMId	INT

	SELECT TOP 1 @intLocationId = intCompanyLocationId FROM @EntriesForInvoice 

	IF ISNULL(@intFreightItemId, 0) > 0
	BEGIN		
		SELECT TOP 1 @intFreightItemUOMId = intIssueUOMId FROM tblICItemLocation WHERE intItemId = @intFreightItemId AND intLocationId = @intLocationId

		IF ISNULL(@intFreightItemUOMId, 0) = 0
		BEGIN
			SELECT TOP 1 @intFreightItemUOMId = intItemUOMId FROM tblICItemUOM WHERE intItemId = @intFreightItemId ORDER BY ysnStockUnit DESC
		END
		IF ISNULL(@intFreightItemUOMId, 0) = 0 AND EXISTS(SELECT TOP 1 1 FROM #tmpSourceTable WHERE ISNULL(dblFreightRate, 0.000000) > 0.000000)
		BEGIN
			RAISERROR('Freight Item doesn''t have default Sales UOM and stock UOM.', 11, 1) 
			RETURN 0
		END
			
		-- CHECK FREIGHT ITEM LOCATION
		IF ((SELECT COUNT(*) FROM #tmpSourceTable T 
			LEFT JOIN tblICItemLocation IL ON IL.intLocationId = T.intCompanyLocationId
			AND T.dblFreightRate > 0 
			AND IL.intItemLocationId IS NULL
			AND IL.intItemId = @intFreightItemId) < 1 AND (SELECT COUNT(*) FROM #tmpSourceTable) > 0)
		BEGIN
			DECLARE @strFreightError NVARCHAR(500) = NULL
			SET @strFreightError = 'Incorrect Freight Item setup: Company Location is not properly set in Item ' + @strFreightItemNo + '. Please go to Item > Setup > Location.'
			RAISERROR(@strFreightError, 16, 1)
		END
	END

	IF (@ysnItemizeSurcharge = 1 AND ISNULL(@intSurchargeItemId, 0) > 0)
	BEGIN
		SELECT TOP 1 @intSurchargeItemUOMId = intIssueUOMId FROM tblICItemLocation WHERE intItemId = @intSurchargeItemId AND intLocationId = @intLocationId

		IF ISNULL(@intSurchargeItemUOMId, 0) = 0
		BEGIN
			SELECT TOP 1 @intSurchargeItemUOMId = intItemUOMId FROM tblICItemUOM WHERE intItemId = @intSurchargeItemId ORDER BY ysnStockUnit DESC
		END
		IF ISNULL(@intSurchargeItemUOMId, 0) = 0 AND EXISTS(SELECT TOP 1 1 FROM #tmpSourceTable WHERE ISNULL(dblSurcharge, 0.000000) > 0.000000)
		BEGIN
			RAISERROR('Surcharge doesn''t have default Sales UOM and stock UOM.', 11, 1) 
			RETURN 0
		END

		-- CHECK SURCHARGE ITEM LOCATION
		IF ((SELECT COUNT(*) FROM #tmpSourceTable T 
			LEFT JOIN tblICItemLocation IL ON IL.intLocationId = T.intCompanyLocationId
			AND T.dblSurcharge > 0 
			AND IL.intItemLocationId IS NULL
			AND IL.intItemId = @intSurchargeItemId) < 1 AND (SELECT COUNT(*) FROM #tmpSourceTable) > 0)
		BEGIN
			DECLARE @strSurchargeError NVARCHAR(500) = NULL
			SET @strSurchargeError = 'Incorrect Surcharge Item setup: Company Location is not properly set in Item ' + @strSurchargeItemNo + '. Please go to Item > Setup > Location.'
			RAISERROR(@strSurchargeError, 16, 1)
		END
	END

	SELECT ROW_NUMBER() OVER(ORDER BY intLoadDistributionHeaderId, intLoadDistributionDetailId DESC) AS intId, * 
	INTO #tmpSourceTableFinal
	FROM (
		SELECT DISTINCT TOP 100 PERCENT *
		FROM #tmpSourceTable
	) Invoices

	--Freight Items

	-- Sum for Combo Freight Only
	DECLARE @dblSumQtyShipped DECIMAL(18,6) = 0,
		@dblSumQtyOrdered DECIMAL(18,6) = 0
	SELECT @dblSumQtyOrdered = SUM(ISNULL(dblQtyOrdered, 0)), @dblSumQtyShipped = SUM(ISNULL(dblQtyShipped, 0)) FROM #tmpSourceTableFinal
	WHERE (ISNULL(dblComboFreightRate, 0) != 0 AND ysnFreightInPrice != 1 AND ysnComboFreight = 1)

	INSERT INTO #tmpSourceTableFinal(
		[intId]
		,[strType] 
		,[strSourceTransaction]
		,[intLoadDistributionDetailId]
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
		,[intEntitySalespersonId]
		,[intFreightTermId]
		,[intShipViaId]
		,[intPaymentMethodId]
		,[strInvoiceOriginId]
		,[strPONumber]
		,[strBOLNumber]
		,[strComments]
		,[strFooterComments]
		,[intShipToLocationId]
		,[intBillToLocationId]
		,[ysnTemplate]
		,[ysnForgiven]
		,[ysnCalculated]
		,[ysnSplitted]
		,[intPaymentId]
		,[intSplitId]
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
		,[intItemUOMId]
		,[dblQtyOrdered]
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
		,[ysnClearDetailTaxes]					
		,[intTempDetailIdForTaxes]
		,[ysnImpactInventory]
		,[strBOLNumberDetail]
		,[ysnBlended]
		,[ysnComboFreight]
		,[dblComboFreightRate]
		,[intInventoryReceiptId]
		,[ysnUseOriginIdAsInvoiceNumber]
	)
	SELECT
		0 AS intId
		,[strType] 								= IE.strType
		,[strSourceTransaction]					= IE.strSourceTransaction
		,[intLoadDistributionDetailId]			= IE.intLoadDistributionDetailId
		,[intSourceId]							= IE.intSourceId
		,[strSourceId]							= IE.strSourceId
		,[intInvoiceId]							= IE.intInvoiceId --NULL Value will create new invoice
		,[intEntityCustomerId]					= IE.intEntityCustomerId
		,[intCompanyLocationId]					= IE.intCompanyLocationId
		,[intCurrencyId]						= IE.intCurrencyId
		,[intTermId]							= IE.intTermId
		,[dtmDate]								= IE.dtmDate
		,[dtmDueDate]							= IE.dtmDueDate
		,[dtmShipDate]							= IE.dtmShipDate
		,[intEntitySalespersonId]				= IE.intEntitySalespersonId
		,[intFreightTermId]						= IE.intFreightTermId
		,[intShipViaId]							= IE.intShipViaId
		,[intPaymentMethodId]					= IE.intPaymentMethodId
		,[strInvoiceOriginId]					= IE.strInvoiceOriginId
		,[strPONumber]							= IE.strPONumber
		,[strBOLNumber]							= IE.strBOLNumber
		,[strComments]							= IE.strComments
		,[strFooterComments]					= IE.strFooterComments
		,[intShipToLocationId]					= IE.intShipToLocationId
		,[intBillToLocationId]					= IE.intBillToLocationId
		,[ysnTemplate]							= IE.ysnTemplate
		,[ysnForgiven]							= IE.ysnForgiven
		,[ysnCalculated]						= IE.ysnCalculated
		,[ysnSplitted]							= IE.ysnSplitted
		,[intPaymentId]							= IE.intPaymentId
		,[intSplitId]							= IE.intSplitId
		,[strActualCostId]						= IE.strActualCostId
		,[intShipmentId]						= IE.intShipmentId
		,[intTransactionId]						= IE.intTransactionId
		,[intEntityId]							= IE.intEntityCustomerId
		,[ysnResetDetails]						= IE.ysnResetDetails
		,[ysnPost]								= IE.ysnPost
		,[intInvoiceDetailId]					= IE.intInvoiceDetailId
		,[intItemId]							= @intFreightItemId
		,[ysnInventory]							= [dbo].[fnIsStockTrackingItem](@intFreightItemId)
		,[strItemDescription]					= Item.strDescription
		,[intOrderUOMId]						= @intFreightItemUOMId
		,[intItemUOMId]							= @intFreightItemUOMId
		,[dblQtyOrdered]						= IE.dblQtyOrdered
		,[dblQtyShipped]						= CASE WHEN IE.dblQtyShipped <= IE.dblMinimumUnits THEN IE.dblMinimumUnits ELSE IE.dblQtyShipped END
		,[dblDiscount]							= 0
		,[dblPrice]								= CASE WHEN ISNULL(IE.dblSurcharge,0) != 0 AND @ysnItemizeSurcharge = 0 
													THEN ISNULL(IE.[dblFreightRate],0) + (ISNULL(IE.[dblFreightRate],0) * (IE.dblSurcharge / 100))
													WHEN ISNULL(IE.dblSurcharge,0) = 0 OR @ysnItemizeSurcharge = 1 
													THEN ISNULL(IE.[dblFreightRate],0) END
		,[ysnRefreshPrice]						= 0
		,[strMaintenanceType]					= IE.strMaintenanceType
		,[strFrequency]							= IE.strFrequency
		,[dtmMaintenanceDate]					= IE.dtmMaintenanceDate
		,[dblMaintenanceAmount]					= IE.dblMaintenanceAmount
		,[dblLicenseAmount]						= IE.dblLicenseAmount
		,[intTaxGroupId]						= NULL
		,[ysnRecomputeTax]						= 0
		,[intSCInvoiceId]						= IE.intSCInvoiceId
		,[strSCInvoiceNumber]					= IE.strSCInvoiceNumber
		,[intInventoryShipmentItemId]			= IE.intInventoryShipmentItemId
		,[strShipmentNumber]					= IE.strShipmentNumber
		,[intSalesOrderDetailId]				= IE.intSalesOrderDetailId
		,[strSalesOrderNumber]					= IE.strSalesOrderNumber
		,[intContractHeaderId]					= NULL
		,[intContractDetailId]					= NULL
		,[intShipmentPurchaseSalesContractId]	= NULL
		,[intTicketId]							= NULL
		,[intTicketHoursWorkedId]				= NULL
		,[intSiteId]							= NULL
		,[strBillingBy]							= IE.strBillingBy
		,[dblPercentFull]						= NULL--IE.dblPercentFull
		,[dblNewMeterReading]					= NULL
		,[dblPreviousMeterReading]				= NULL
		,[dblConversionFactor]					= IE.dblConversionFactor
		,[intPerformerId]						= IE.intPerformerId
		,[ysnLeaseBilling]						= IE.ysnLeaseBilling
		,[ysnVirtualMeterReading]				= IE.ysnVirtualMeterReading
		,[ysnClearDetailTaxes]					= IE.ysnClearDetailTaxes
		,[intTempDetailIdForTaxes]				= IE.intTempDetailIdForTaxes
		,[ysnImpactInventory]					= IE.ysnImpactInventory
		,[strBOLNumberDetail]					= IE.strBOLNumberDetail
		,[ysnBlended]							= IE.ysnBlended
		,[ysnComboFreight]						= IE.ysnComboFreight
		,[dblComboFreightRate]					= IE.dblComboFreightRate
		,[intInventoryReceiptId]				= IE.intInventoryReceiptId
		,[ysnUseOriginIdAsInvoiceNumber]        = IE.ysnUseOriginIdAsInvoiceNumber
	FROM #tmpSourceTableFinal IE
	INNER JOIN tblICItem Item ON Item.intItemId = @intFreightItemId
	WHERE (ISNULL(IE.dblFreightRate, 0) != 0 AND IE.ysnFreightInPrice != 1) AND ysnComboFreight = 0
	UNION ALL
	SELECT DISTINCT
		0 AS intId
		,[strType] 								= IE.strType
		,[strSourceTransaction]					= IE.strSourceTransaction
		,[intLoadDistributionDetailId]			= CASE WHEN @ysnComboFreight = 1 THEN NULL ELSE IE.intLoadDistributionDetailId END
		,[intSourceId]							= IE.intSourceId
		,[strSourceId]							= IE.strSourceId
		,[intInvoiceId]							= IE.intInvoiceId --NULL Value will create new invoice
		,[intEntityCustomerId]					= IE.intEntityCustomerId
		,[intCompanyLocationId]					= IE.intCompanyLocationId
		,[intCurrencyId]						= IE.intCurrencyId
		,[intTermId]							= IE.intTermId
		,[dtmDate]								= IE.dtmDate
		,[dtmDueDate]							= IE.dtmDueDate
		,[dtmShipDate]							= IE.dtmShipDate
		,[intEntitySalespersonId]				= IE.intEntitySalespersonId
		,[intFreightTermId]						= IE.intFreightTermId
		,[intShipViaId]							= IE.intShipViaId
		,[intPaymentMethodId]					= IE.intPaymentMethodId
		,[strInvoiceOriginId]					= IE.strInvoiceOriginId
		,[strPONumber]							= IE.strPONumber
		,[strBOLNumber]							= IE.strBOLNumber
		,[strComments]							= IE.strComments
		,[strFooterComments]					= IE.strFooterComments
		,[intShipToLocationId]					= IE.intShipToLocationId
		,[intBillToLocationId]					= IE.intBillToLocationId
		,[ysnTemplate]							= IE.ysnTemplate
		,[ysnForgiven]							= IE.ysnForgiven
		,[ysnCalculated]						= IE.ysnCalculated
		,[ysnSplitted]							= IE.ysnSplitted
		,[intPaymentId]							= IE.intPaymentId
		,[intSplitId]							= IE.intSplitId
		,[strActualCostId]						= IE.strActualCostId
		,[intShipmentId]						= IE.intShipmentId
		,[intTransactionId]						= IE.intTransactionId
		,[intEntityId]							= IE.intEntityCustomerId
		,[ysnResetDetails]						= IE.ysnResetDetails
		,[ysnPost]								= IE.ysnPost
		,[intInvoiceDetailId]					= IE.intInvoiceDetailId
		,[intItemId]							= @intFreightItemId
		,[ysnInventory]							= [dbo].[fnIsStockTrackingItem](@intFreightItemId)
		,[strItemDescription]					= Item.strDescription
		,[intOrderUOMId]						= @intFreightItemUOMId
		,[intItemUOMId]							= @intFreightItemUOMId
		,[dblQtyOrdered]						= @dblSumQtyOrdered
		,[dblQtyShipped]						= CASE WHEN @dblSumQtyShipped <= IE.dblComboMinimumUnits AND ysnComboFreight = 1 THEN IE.dblComboMinimumUnits ELSE @dblSumQtyShipped END
		,[dblDiscount]							= 0
		,[dblPrice]								= CASE WHEN ISNULL(IE.dblSurcharge,0) != 0 AND @ysnItemizeSurcharge = 0 
													THEN ISNULL(IE.[dblComboFreightRate],0) + (ISNULL(IE.[dblComboFreightRate],0) * (IE.dblSurcharge / 100))
													WHEN ISNULL(IE.dblSurcharge,0) = 0 OR @ysnItemizeSurcharge = 1 
													THEN ISNULL(IE.[dblComboFreightRate],0) END
		,[ysnRefreshPrice]						= 0
		,[strMaintenanceType]					= IE.strMaintenanceType
		,[strFrequency]							= IE.strFrequency
		,[dtmMaintenanceDate]					= IE.dtmMaintenanceDate
		,[dblMaintenanceAmount]					= IE.dblMaintenanceAmount
		,[dblLicenseAmount]						= IE.dblLicenseAmount
		,[intTaxGroupId]						= NULL
		,[ysnRecomputeTax]						= 0
		,[intSCInvoiceId]						= IE.intSCInvoiceId
		,[strSCInvoiceNumber]					= IE.strSCInvoiceNumber
		,[intInventoryShipmentItemId]			= IE.intInventoryShipmentItemId
		,[strShipmentNumber]					= IE.strShipmentNumber
		,[intSalesOrderDetailId]				= IE.intSalesOrderDetailId
		,[strSalesOrderNumber]					= IE.strSalesOrderNumber
		,[intContractHeaderId]					= NULL
		,[intContractDetailId]					= NULL
		,[intShipmentPurchaseSalesContractId]	= NULL
		,[intTicketId]							= NULL
		,[intTicketHoursWorkedId]				= NULL
		,[intSiteId]							= NULL
		,[strBillingBy]							= IE.strBillingBy
		,[dblPercentFull]						= NULL --IE.dblPercentFull
		,[dblNewMeterReading]					= NULL
		,[dblPreviousMeterReading]				= NULL
		,[dblConversionFactor]					= IE.dblConversionFactor
		,[intPerformerId]						= IE.intPerformerId
		,[ysnLeaseBilling]						= IE.ysnLeaseBilling
		,[ysnVirtualMeterReading]				= IE.ysnVirtualMeterReading
		,[ysnClearDetailTaxes]					= IE.ysnClearDetailTaxes
		,[intTempDetailIdForTaxes]				= IE.intTempDetailIdForTaxes
		,[ysnImpactInventory]					= 0
		,[strBOLNumberDetail]					= IE.strBOLNumberDetail
		,[ysnBlended]							= IE.ysnBlended
		,[ysnComboFreight]						= IE.ysnComboFreight
		,[dblComboFreightRate]					= IE.dblComboFreightRate
		,[intInventoryReceiptId]				= IE.intInventoryReceiptId
		,[ysnUseOriginIdAsInvoiceNumber]        = IE.ysnUseOriginIdAsInvoiceNumber
	FROM #tmpSourceTableFinal IE
	INNER JOIN tblICItem Item ON Item.intItemId = @intFreightItemId
	WHERE (ISNULL(IE.dblComboFreightRate, 0) != 0 AND IE.ysnFreightInPrice != 1 AND ysnComboFreight = 1)

	-- -- FOR COMBO SPLIT THE QTY BASE ON THE NUMBERS OF FREIGHT
	-- UPDATE TF SET TF.dblQtyShipped = ROUND(TF.dblQtyShipped / ComboCounts.Counts, 2)
	-- FROM #tmpSourceTableFinal TF
	-- FULL OUTER JOIN (SELECT intId,COUNT(*) Counts
	-- 	FROM #tmpSourceTableFinal
	-- 	WHERE intId = 0 AND ysnComboFreight = 1
	-- 	GROUP BY intId) AS ComboCounts ON ComboCounts.intId = TF.intId 
	-- WHERE TF.intId = 0 AND TF.ysnComboFreight = 1

	-- FOR COMBO FREIGHT, ONLY PASS THE FREIGHT OF THE ITEM THAT THE COMBO FREIGHT RATE WAS BASED ON  
	IF (@ysnComboFreight = 1)  
	BEGIN  
	 --  DELETE IE   
	 --  FROM   #tmpSourceTableFinal IE   
		--INNER JOIN tblICItem IT ON IE.intItemId = IT.intItemId  
	 --  WHERE IT.strType != 'Inventory'   
		--AND IE.intId = 0   
		--AND IE.intLoadDistributionDetailId != (SELECT TOP 1 intLoadDistributionDetailId   
		--	FROM #tmpSourceTableFinal   
		--	WHERE dblFreightRate = dblComboFreightRate AND intId != 0)  
		SELECT @intComboFreightDistId = (SELECT TOP 1 intLoadDistributionDetailId FROM #tmpSourceTableFinal WHERE dblFreightRate = dblComboFreightRate AND intId != 0)
	
		UPDATE IE 
			SET IE.intLoadDistributionDetailId = @intComboFreightDistId
		FROM   #tmpSourceTableFinal IE   
			INNER JOIN tblICItem IT ON IE.intItemId = IT.intItemId  
		WHERE IT.strType != 'Inventory'   
			AND IE.intId = 0   
	END  

	INSERT INTO @EntriesForInvoice(
		 [strSourceTransaction]
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
		,[intEntitySalespersonId]
		,[intFreightTermId]
		,[intShipViaId]
		,[intPaymentMethodId]
		,[strInvoiceOriginId]
		,[strPONumber]
		,[strBOLNumber]
		,[strComments]
		,[strFooterComments]
		,[intShipToLocationId]
		,[intBillToLocationId]
		,[ysnTemplate]
		,[ysnForgiven]
		,[ysnCalculated]
		,[ysnSplitted]
		,[intPaymentId]
		,[intSplitId]
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
		,[intItemUOMId]
		,[dblQtyOrdered]
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
		,[ysnClearDetailTaxes]					
		,[intTempDetailIdForTaxes]
		,[intLoadDistributionHeaderId]
		,[intLoadDistributionDetailId]
		,[intTruckDriverId]
		,[intTruckDriverReferenceId]
		,[ysnImpactInventory]
		,[strBOLNumberDetail]
		,[ysnBlended]
		,[intDispatchId]
		,[intCompanyLocationSubLocationId]
		,[ysnUseOriginIdAsInvoiceNumber]
	)
	SELECT
		 [strSourceTransaction]					= TR.strSourceTransaction
		,[strType]								= TR.strType
		,[intSourceId]							= TR.intSourceId
		,[strSourceId]							= TR.strSourceId
		,[intInvoiceId]							= TR.intInvoiceId
		,[intEntityCustomerId]					= TR.intEntityCustomerId
		,[intCompanyLocationId]					= TR.intCompanyLocationId
		,[intCurrencyId]						= TR.intCurrencyId
		,[intTermId]							= TR.intTermId
		,[dtmDate]								= CAST(TR.dtmDate AS DATE) 
		,[dtmDueDate]							= TR.dtmDueDate
		,[dtmShipDate]							= TR.dtmShipDate
		,[intEntitySalespersonId]				= TR.intEntitySalespersonId
		,[intFreightTermId]						= TR.intFreightTermId
		,[intShipViaId]							= TR.intShipViaId
		,[intPaymentMethodId]					= TR.intPaymentMethodId
		,[strInvoiceOriginId]					= TR.strInvoiceOriginId
		,[strPONumber]							= TR.strPONumber
		,[strBOLNumber]							= TR.strBOLNumber
		,[strComments]							= TR.strComments
		,[strFooterComments]					= TR.strFooterComments
		,[intShipToLocationId]					= TR.intShipToLocationId
		,[intBillToLocationId]					= TR.intBillToLocationId
		,[ysnTemplate]							= TR.ysnTemplate
		,[ysnForgiven]							= TR.ysnForgiven
		,[ysnCalculated]						= TR.ysnCalculated
		,[ysnSplitted]							= TR.ysnSplitted
		,[intPaymentId]							= TR.intPaymentId
		,[intSplitId]							= TR.intSplitId
		,[strActualCostId]						= TR.strActualCostId
		,[intShipmentId]						= TR.intShipmentId
		,[intTransactionId]						= TR.intTransactionId
		,[intEntityId]							= TR.intEntityId
		,[ysnResetDetails]						= TR.ysnResetDetails
		,[ysnPost]								= TR.ysnPost
		,[intInvoiceDetailId]					= TR.intInvoiceDetailId
		,[intItemId]							= TR.intItemId
		,[ysnInventory]							= TR.ysnInventory
		,[strItemDescription]					= TR.strItemDescription
		,[intOrderUOMId]						= TR.intOrderUOMId
		,[intItemUOMId]							= TR.intItemUOMId
		,[dblQtyOrdered]						= TR.dblQtyOrdered
		,[dblQtyShipped]						= CASE WHEN intId = 0 THEN TR.dblQtyShipped ELSE TR.dblQtyOrdered END
		,[dblDiscount]							= TR.dblDiscount
		,[dblPrice]								= TR.dblPrice
		,[ysnRefreshPrice]						= TR.ysnRefreshPrice
		,[strMaintenanceType]					= TR.strMaintenanceType
		,[strFrequency]							= TR.strFrequency
		,[dtmMaintenanceDate]					= TR.dtmMaintenanceDate
		,[dblMaintenanceAmount]					= TR.dblMaintenanceAmount
		,[dblLicenseAmount]						= TR.dblLicenseAmount
		,[intTaxGroupId]						= TR.intTaxGroupId
		,[ysnRecomputeTax]						= TR.ysnRecomputeTax
		,[intSCInvoiceId]						= TR.intSCInvoiceId
		,[strSCInvoiceNumber]					= TR.strSCInvoiceNumber
		,[intInventoryShipmentItemId]			= TR.intInventoryShipmentItemId
		,[strShipmentNumber]					= TR.strShipmentNumber
		,[intSalesOrderDetailId]				= TR.intSalesOrderDetailId
		,[strSalesOrderNumber]					= TR.strSalesOrderNumber
		,[intContractHeaderId]					= TR.intContractHeaderId
		,[intContractDetailId]					= TR.intContractDetailId
		,[intShipmentPurchaseSalesContractId]	= TR.intShipmentPurchaseSalesContractId
		,[intTicketId]							= TR.intTicketId
		,[intTicketHoursWorkedId]				= TR.intTicketHoursWorkedId
		,[intSiteId]							= TR.intSiteId
		,[strBillingBy]							= TR.strBillingBy
		,[dblPercentFull]						= TR.dblPercentFull
		,[dblNewMeterReading]					= TR.dblNewMeterReading
		,[dblPreviousMeterReading]				= TR.dblPreviousMeterReading
		,[dblConversionFactor]					= TR.dblConversionFactor
		,[intPerformerId]						= TR.intPerformerId
		,[ysnLeaseBilling]						= TR.ysnLeaseBilling
		,[ysnVirtualMeterReading]				= TR.ysnVirtualMeterReading
		,[ysnClearDetailTaxes]					= TR.ysnClearDetailTaxes
		,[intTempDetailIdForTaxes]				= TR.intTempDetailIdForTaxes
		,[intLoadDistributionHeaderId]			= TR.intLoadDistributionHeaderId
		,[intLoadDistributionDetailId]			= TR.intLoadDistributionDetailId
		,intTruckDriverId						= TR.intTruckDriverId
		,intTruckDriverReferenceId				= TR.intTruckDriverReferenceId
		,ysnImpactInventory                     = ISNULL(TR.ysnImpactInventory, 0)
		,strBOLNumberDetail						= TR.strBOLNumberDetail
		,ysnBlended								= TR.ysnBlended
		,intDispatchId							= TR.intDispatchId
		,intCompanyLocationSubLocationId		= TR.intCompanyLocationSubLocationId
		,ysnUseOriginIdAsInvoiceNumber			= TR.ysnUseOriginIdAsInvoiceNumber
	FROM #tmpSourceTableFinal TR
	ORDER BY TR.intLoadDistributionDetailId, intId DESC



	-- GET SURCHARGE SUM FOR COMBO FREIGHT CALCULATION
	DECLARE @dblFreightQtySurchargeTotal DECIMAL(18,6) = 0

	SELECT @dblFreightQtySurchargeTotal = SUM(IE.dblFreightQty)
	FROM #tmpSourceTableFinal IE 
		INNER JOIN tblICItem Item ON Item.intItemId = @intSurchargeItemId
	WHERE (ISNULL(IE.dblComboFreightRate, 0) != 0 
		AND IE.ysnComboFreight = 1 
		AND IE.intId > 0 
		AND ISNULL(IE.dblSurcharge, 0) != 0)



	DECLARE @FreightSurchargeEntries AS InvoiceIntegrationStagingTable

	--Surcharge Item
	IF @ysnItemizeSurcharge = 1 AND ISNULL(@intSurchargeItemId, 0) > 0
	BEGIN
		INSERT INTO @FreightSurchargeEntries
			([strSourceTransaction]
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
			,[intEntitySalespersonId]
			,[intFreightTermId]
			,[intShipViaId]
			,[intPaymentMethodId]
			,[strInvoiceOriginId]
			,[strPONumber]
			,[strBOLNumber]
			,[strComments]
			,[strFooterComments]
			,[intShipToLocationId]
			,[intBillToLocationId]
			,[ysnTemplate]
			,[ysnForgiven]
			,[ysnCalculated]
			,[ysnSplitted]
			,[intPaymentId]
			,[intSplitId]
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
			,[intItemUOMId]
			,[dblQtyOrdered]
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
			,[ysnClearDetailTaxes]					
			,[intTempDetailIdForTaxes]
			,[strBOLNumberDetail]
			,[ysnBlended]
			,[intLoadDistributionDetailId])
		SELECT
			[strSourceTransaction]					= IE.strSourceTransaction
			,[intSourceId]							= IE.intSourceId
			,[strSourceId]							= IE.strSourceId
			,[intInvoiceId]							= IE.intInvoiceId --NULL Value will create new invoice
			,[intEntityCustomerId]					= IE.intEntityCustomerId
			,[intCompanyLocationId]					= IE.intCompanyLocationId
			,[intCurrencyId]						= IE.intCurrencyId
			,[intTermId]							= IE.intTermId
			,[dtmDate]								= CAST(IE.dtmDate AS DATE) 
			,[dtmDueDate]							= IE.dtmDueDate
			,[dtmShipDate]							= IE.dtmShipDate
			,[intEntitySalespersonId]				= IE.intEntitySalespersonId
			,[intFreightTermId]						= IE.intFreightTermId
			,[intShipViaId]							= IE.intShipViaId
			,[intPaymentMethodId]					= IE.intPaymentMethodId
			,[strInvoiceOriginId]					= IE.strInvoiceOriginId
			,[strPONumber]							= IE.strPONumber
			,[strBOLNumber]							= IE.strBOLNumber
			,[strComments]							= IE.strComments
			,[strFooterComments]					= IE.strFooterComments
			,[intShipToLocationId]					= IE.intShipToLocationId
			,[intBillToLocationId]					= IE.intBillToLocationId
			,[ysnTemplate]							= IE.ysnTemplate
			,[ysnForgiven]							= IE.ysnForgiven
			,[ysnCalculated]						= IE.ysnCalculated
			,[ysnSplitted]							= IE.ysnSplitted
			,[intPaymentId]							= IE.intPaymentId
			,[intSplitId]							= IE.intSplitId
			,[strActualCostId]						= IE.strActualCostId
			,[intShipmentId]						= IE.intShipmentId
			,[intTransactionId]						= IE.intTransactionId
			,[intEntityId]							= IE.intEntityCustomerId
			,[ysnResetDetails]						= IE.ysnResetDetails
			,[ysnPost]								= IE.ysnPost
			,[intInvoiceDetailId]					= IE.intInvoiceDetailId
			,[intItemId]							= @intSurchargeItemId
			,[ysnInventory]							= [dbo].[fnIsStockTrackingItem](@intSurchargeItemId)
			,[strItemDescription]					= Item.strDescription
			,[intOrderUOMId]						= @intSurchargeItemUOMId
			,[intItemUOMId]							= @intSurchargeItemUOMId
			,[dblQtyOrdered]						= CASE WHEN IE.dblQtyShipped <= IE.dblMinimumUnits THEN ISNULL(IE.dblMinimumUnits, 0.000000) * ISNULL(IE.[dblFreightRate], 0.000000) ELSE ISNULL(IE.dblQtyShipped, 0.000000) * ISNULL(IE.[dblFreightRate], 0.000000) END
			,[dblQtyShipped]						= CASE WHEN IE.dblQtyShipped <= IE.dblMinimumUnits THEN ISNULL(IE.dblMinimumUnits, 0.000000) * ISNULL(IE.[dblFreightRate], 0.000000) ELSE ISNULL(IE.dblQtyShipped, 0.000000) * ISNULL(IE.[dblFreightRate], 0.000000) END
			,[dblDiscount]							= 0
			,[dblPrice]								= ISNULL(IE.dblSurcharge, 0.000000) / 100
			,[ysnRefreshPrice]						= 0
			,[strMaintenanceType]					= IE.strMaintenanceType
			,[strFrequency]							= IE.strFrequency
			,[dtmMaintenanceDate]					= IE.dtmMaintenanceDate
			,[dblMaintenanceAmount]					= IE.dblMaintenanceAmount
			,[dblLicenseAmount]						= IE.dblLicenseAmount
			,[intTaxGroupId]						= NULL
			,[ysnRecomputeTax]						= 0
			,[intSCInvoiceId]						= IE.intSCInvoiceId
			,[strSCInvoiceNumber]					= IE.strSCInvoiceNumber
			,[intInventoryShipmentItemId]			= IE.intInventoryShipmentItemId
			,[strShipmentNumber]					= IE.strShipmentNumber
			,[intSalesOrderDetailId]				= IE.intSalesOrderDetailId
			,[strSalesOrderNumber]					= IE.strSalesOrderNumber
			,[intContractHeaderId]					= NULL
			,[intContractDetailId]					= NULL
			,[intShipmentPurchaseSalesContractId]	= NULL
			,[intTicketId]							= NULL
			,[intTicketHoursWorkedId]				= NULL
			,[intSiteId]							= NULL
			,[strBillingBy]							= IE.strBillingBy
			,[dblPercentFull]						= NULL --IE.dblPercentFull
			,[dblNewMeterReading]					= NULL
			,[dblPreviousMeterReading]				= NULL
			,[dblConversionFactor]					= IE.dblConversionFactor
			,[intPerformerId]						= IE.intPerformerId
			,[ysnLeaseBilling]						= IE.ysnLeaseBilling
			,[ysnVirtualMeterReading]				= IE.ysnVirtualMeterReading
			,[ysnClearDetailTaxes]					= IE.ysnClearDetailTaxes
			,[intTempDetailIdForTaxes]				= IE.intTempDetailIdForTaxes
			,[strBOLNumberDetail]					= IE.strBOLNumberDetail 
			,[ysnBlended]							= IE.ysnBlended
			,[intLoadDistributionDetailId]   = CASE WHEN @ysnComboFreight = 1 THEN NULL ELSE IE.intLoadDistributionDetailId END
		FROM #tmpSourceTableFinal IE
		INNER JOIN tblICItem Item ON Item.intItemId = @intSurchargeItemId
		WHERE (ISNULL(IE.dblFreightRate, 0) != 0 AND IE.ysnComboFreight = 0 AND IE.intId > 0 AND ISNULL(IE.dblSurcharge, 0) != 0)
		UNION ALL
		SELECT DISTINCT
			[strSourceTransaction]					= IE.strSourceTransaction
			,[intSourceId]							= IE.intSourceId
			,[strSourceId]							= IE.strSourceId
			,[intInvoiceId]							= IE.intInvoiceId --NULL Value will create new invoice
			,[intEntityCustomerId]					= IE.intEntityCustomerId
			,[intCompanyLocationId]					= IE.intCompanyLocationId
			,[intCurrencyId]						= IE.intCurrencyId
			,[intTermId]							= IE.intTermId
			,[dtmDate]								= CAST(IE.dtmDate AS DATE) 
			,[dtmDueDate]							= IE.dtmDueDate
			,[dtmShipDate]							= IE.dtmShipDate
			,[intEntitySalespersonId]				= IE.intEntitySalespersonId
			,[intFreightTermId]						= IE.intFreightTermId
			,[intShipViaId]							= IE.intShipViaId
			,[intPaymentMethodId]					= IE.intPaymentMethodId
			,[strInvoiceOriginId]					= IE.strInvoiceOriginId
			,[strPONumber]							= IE.strPONumber
			,[strBOLNumber]							= IE.strBOLNumber
			,[strComments]							= IE.strComments
			,[strFooterComments]					= IE.strFooterComments
			,[intShipToLocationId]					= IE.intShipToLocationId
			,[intBillToLocationId]					= IE.intBillToLocationId
			,[ysnTemplate]							= IE.ysnTemplate
			,[ysnForgiven]							= IE.ysnForgiven
			,[ysnCalculated]						= IE.ysnCalculated
			,[ysnSplitted]							= IE.ysnSplitted
			,[intPaymentId]							= IE.intPaymentId
			,[intSplitId]							= IE.intSplitId
			,[strActualCostId]						= IE.strActualCostId
			,[intShipmentId]						= IE.intShipmentId
			,[intTransactionId]						= IE.intTransactionId
			,[intEntityId]							= IE.intEntityCustomerId
			,[ysnResetDetails]						= IE.ysnResetDetails
			,[ysnPost]								= IE.ysnPost
			,[intInvoiceDetailId]					= IE.intInvoiceDetailId
			,[intItemId]							= @intSurchargeItemId
			,[ysnInventory]							= [dbo].[fnIsStockTrackingItem](@intSurchargeItemId)
			,[strItemDescription]					= Item.strDescription
			,[intOrderUOMId]						= @intSurchargeItemUOMId
			,[intItemUOMId]							= @intSurchargeItemUOMId
			,[dblQtyOrdered]						= CASE WHEN IE.ysnComboFreight = 1 THEN CASE WHEN @dblFreightQtySurchargeTotal <= IE.dblComboMinimumUnits THEN ISNULL(IE.dblComboMinimumUnits, 0.000000) * ISNULL(IE.[dblComboFreightRate], 0.000000) ELSE ISNULL(@dblFreightQtySurchargeTotal, 0.000000) * ISNULL(IE.[dblComboFreightRate], 0.000000) END
													  ELSE CASE WHEN IE.dblFreightQty <= IE.dblComboMinimumUnits THEN ISNULL(IE.dblComboMinimumUnits, 0.000000) * ISNULL(IE.[dblComboFreightRate], 0.000000) ELSE ISNULL(IE.dblFreightQty, 0.000000) * ISNULL(IE.[dblComboFreightRate], 0.000000) END
													  END
			,[dblQtyShipped]						= CASE WHEN IE.ysnComboFreight = 1 THEN CASE WHEN @dblFreightQtySurchargeTotal <= IE.dblComboMinimumUnits THEN ISNULL(IE.dblComboMinimumUnits, 0.000000) * ISNULL(IE.[dblComboFreightRate], 0.000000) ELSE ISNULL(@dblFreightQtySurchargeTotal, 0.000000) * ISNULL(IE.[dblComboFreightRate], 0.000000) END
													  ELSE CASE WHEN IE.dblFreightQty <= IE.dblComboMinimumUnits THEN ISNULL(IE.dblComboMinimumUnits, 0.000000) * ISNULL(IE.[dblComboFreightRate], 0.000000) ELSE ISNULL(IE.dblFreightQty, 0.000000) * ISNULL(IE.[dblComboFreightRate], 0.000000) END
													  END
			,[dblDiscount]							= 0
			,[dblPrice]								= ISNULL(IE.dblComboSurcharge, 0.000000) / 100
			,[ysnRefreshPrice]						= 0
			,[strMaintenanceType]					= IE.strMaintenanceType
			,[strFrequency]							= IE.strFrequency
			,[dtmMaintenanceDate]					= IE.dtmMaintenanceDate
			,[dblMaintenanceAmount]					= IE.dblMaintenanceAmount
			,[dblLicenseAmount]						= IE.dblLicenseAmount
			,[intTaxGroupId]						= NULL
			,[ysnRecomputeTax]						= 0
			,[intSCInvoiceId]						= IE.intSCInvoiceId
			,[strSCInvoiceNumber]					= IE.strSCInvoiceNumber
			,[intInventoryShipmentItemId]			= IE.intInventoryShipmentItemId
			,[strShipmentNumber]					= IE.strShipmentNumber
			,[intSalesOrderDetailId]				= IE.intSalesOrderDetailId
			,[strSalesOrderNumber]					= IE.strSalesOrderNumber
			,[intContractHeaderId]					= NULL
			,[intContractDetailId]					= NULL
			,[intShipmentPurchaseSalesContractId]	= NULL
			,[intTicketId]							= NULL
			,[intTicketHoursWorkedId]				= NULL
			,[intSiteId]							= IE.intSiteId
			,[strBillingBy]							= IE.strBillingBy
			,[dblPercentFull]						= IE.dblPercentFull
			,[dblNewMeterReading]					= NULL
			,[dblPreviousMeterReading]				= NULL
			,[dblConversionFactor]					= IE.dblConversionFactor
			,[intPerformerId]						= IE.intPerformerId
			,[ysnLeaseBilling]						= IE.ysnLeaseBilling
			,[ysnVirtualMeterReading]				= IE.ysnVirtualMeterReading
			,[ysnClearDetailTaxes]					= IE.ysnClearDetailTaxes
			,[intTempDetailIdForTaxes]				= IE.intTempDetailIdForTaxes
			,[strBOLNumberDetail]					= IE.strBOLNumberDetail 
			,[ysnBlended]							= IE.ysnBlended
			,[intLoadDistributionDetailId]   = CASE WHEN @ysnComboFreight = 1 THEN NULL ELSE IE.intLoadDistributionDetailId END    
		FROM #tmpSourceTableFinal IE
		INNER JOIN tblICItem Item ON Item.intItemId = @intSurchargeItemId
		WHERE (ISNULL(IE.dblComboFreightRate, 0) != 0 AND IE.ysnComboFreight = 1 AND IE.intId > 0 AND ISNULL(IE.dblSurcharge, 0) != 0)
	END

	IF (@ysnComboFreight = 1)
	BEGIN
	UPDATE IE   
		SET IE.intLoadDistributionDetailId = @intComboFreightDistId
	FROM   @FreightSurchargeEntries IE   
		INNER JOIN tblICItem IT ON IE.intItemId = IT.intItemId  
	END

	--Group and Summarize Freight and Surcharge Entries before adding to Invoice Entries
	INSERT INTO @EntriesForInvoice (
		[strSourceTransaction]
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
		,[intEntitySalespersonId]
		,[intFreightTermId]
		,[intShipViaId]
		,[intPaymentMethodId]
		,[strInvoiceOriginId]
		,[strPONumber]
		,[strBOLNumber]
		,[strComments]
		,[strFooterComments]
		,[intShipToLocationId]
		,[intBillToLocationId]
		,[ysnTemplate]
		,[ysnForgiven]
		,[ysnCalculated]
		,[ysnSplitted]
		,[intPaymentId]
		,[intSplitId]
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
		,[intItemUOMId]
		,[dblQtyOrdered]
		,[dblQtyShipped]
		,[dblDiscount]
		,[dblPrice]
		,[ysnRefreshPrice]
		,[strMaintenanceType]
		,[strFrequency]
		,[dtmMaintenanceDate]
		,[dblMaintenanceAmount]
		,[dblLicenseAmount]
		,[ysnRecomputeTax]
		,[intSCInvoiceId]
		,[strSCInvoiceNumber]
		,[intInventoryShipmentItemId]
		,[strShipmentNumber]
		,[intSalesOrderDetailId]
		,[strSalesOrderNumber]
		,[intSiteId]
		,[strBillingBy]
		,[dblPercentFull]
		,[dblConversionFactor]
		,[intPerformerId]
		,[ysnLeaseBilling]
		,[ysnVirtualMeterReading]
		,[ysnClearDetailTaxes]
		,[intTempDetailIdForTaxes]
		,[intLoadDistributionHeaderId]
		,[ysnImpactInventory]
		,[strBOLNumberDetail]
		,[intLoadDistributionDetailId]
	)
	SELECT 
		[strSourceTransaction]					= IE.strSourceTransaction
		,[intSourceId]							= MIN(IE.intSourceId)
		,[strSourceId]							= IE.strSourceId
		,[intInvoiceId]							= IE.intInvoiceId
		,[intEntityCustomerId]					= IE.intEntityCustomerId
		,[intCompanyLocationId]					= IE.intCompanyLocationId
		,[intCurrencyId]						= IE.intCurrencyId
		,[intTermId]							= IE.intTermId
		,[dtmDate]								= IE.dtmDate
		,[dtmDueDate]							= IE.dtmDueDate
		,[dtmShipDate]							= IE.dtmShipDate
		,[intEntitySalespersonId]				= IE.intEntitySalespersonId
		,[intFreightTermId]						= IE.intFreightTermId
		,[intShipViaId]							= IE.intShipViaId
		,[intPaymentMethodId]					= IE.intPaymentMethodId
		,[strInvoiceOriginId]					= IE.strInvoiceOriginId
		,[strPONumber]							= IE.strPONumber
		,[strBOLNumber]							= IE.strBOLNumber
		,[strComments]							= IE.strComments
		,[strFooterComments]					= IE.strFooterComments
		,[intShipToLocationId]					= IE.intShipToLocationId
		,[intBillToLocationId]					= IE.intBillToLocationId
		,[ysnTemplate]							= IE.ysnTemplate
		,[ysnForgiven]							= IE.ysnForgiven
		,[ysnCalculated]						= IE.ysnCalculated
		,[ysnSplitted]							= IE.ysnSplitted
		,[intPaymentId]							= IE.intPaymentId
		,[intSplitId]							= IE.intSplitId
		,[strActualCostId]						= IE.strActualCostId
		,[intShipmentId]						= IE.intShipmentId
		,[intTransactionId]						= IE.intTransactionId
		,[intEntityId]							= IE.intEntityCustomerId
		,[ysnResetDetails]						= IE.ysnResetDetails
		,[ysnPost]								= IE.ysnPost
		,[intInvoiceDetailId]					= IE.intInvoiceDetailId
		,[intItemId]							= IE.intItemId
		,[ysnInventory]							= IE.ysnInventory
		,[strItemDescription]					= IE.strItemDescription
		,[intOrderUOMId]						= IE.intOrderUOMId
		,[intItemUOMId]							= IE.intItemUOMId
		,[dblQtyOrdered]						= SUM(IE.dblQtyOrdered)
		,[dblQtyShipped]						= SUM(IE.dblQtyShipped)
		,[dblDiscount]							= SUM(IE.dblDiscount)
		,[dblPrice]								= dblPrice
		,[ysnRefreshPrice]						= IE.ysnRefreshPrice
		,[strMaintenanceType]					= IE.strMaintenanceType
		,[strFrequency]							= IE.strFrequency
		,[dtmMaintenanceDate]					= IE.dtmMaintenanceDate
		,[dblMaintenanceAmount]					= IE.dblMaintenanceAmount
		,[dblLicenseAmount]						= IE.dblLicenseAmount
		,[ysnRecomputeTax]						= IE.ysnRecomputeTax
		,[intSCInvoiceId]						= IE.intSCInvoiceId
		,[strSCInvoiceNumber]					= IE.strSCInvoiceNumber
		,[intInventoryShipmentItemId]			= IE.intInventoryShipmentItemId
		,[strShipmentNumber]					= IE.strShipmentNumber
		,[intSalesOrderDetailId]				= IE.intSalesOrderDetailId
		,[strSalesOrderNumber]					= IE.strSalesOrderNumber
		,[intSiteId]							= IE.intSiteId
		,[strBillingBy]							= IE.strBillingBy
		,[dblPercentFull]						= IE.dblPercentFull
		,[dblConversionFactor]					= IE.dblConversionFactor
		,[intPerformerId]						= IE.intPerformerId
		,[ysnLeaseBilling]						= IE.ysnLeaseBilling
		,[ysnVirtualMeterReading]				= IE.ysnVirtualMeterReading
		,[ysnClearDetailTaxes]					= IE.ysnClearDetailTaxes
		,[intTempDetailIdForTaxes]				= IE.intTempDetailIdForTaxes
		,[intLoadDistributionHeaderId]			= IE.intLoadDistributionHeaderId
		,[ysnImpactInventory]                   = ISNULL(IE.ysnImpactInventory,0)
		,[strBOLNumberDetail]					= IE.strBOLNumberDetail
		,[intLoadDistributionDetailId]			= IE.intLoadDistributionDetailId
	FROM @FreightSurchargeEntries IE
	GROUP BY [strSourceTransaction]
		,[strSourceId]
		,[intInvoiceId]
		,[intEntityCustomerId]
		,[intCompanyLocationId]
		,[intCurrencyId]
		,[intTermId]
		,[dtmDate]
		,[dtmDueDate]
		,[dtmShipDate]
		,[intEntitySalespersonId]
		,[intFreightTermId]
		,[intShipViaId]
		,[intPaymentMethodId]
		,[strInvoiceOriginId]
		,[strPONumber]
		,[strBOLNumber]
		,[strComments]
		,[strFooterComments]
		,[intShipToLocationId]
		,[intBillToLocationId]
		,[ysnTemplate]
		,[ysnForgiven]
		,[ysnCalculated]
		,[ysnSplitted]
		,[intPaymentId]
		,[intSplitId]
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
		,[intItemUOMId]
		,[dblPrice]
		,[ysnRefreshPrice]
		,[strMaintenanceType]
		,[strFrequency]
		,[dtmMaintenanceDate]
		,[dblMaintenanceAmount]
		,[dblLicenseAmount]
		,[ysnRecomputeTax]
		,[intSCInvoiceId]
		,[strSCInvoiceNumber]
		,[intInventoryShipmentItemId]
		,[strShipmentNumber]
		,[intSalesOrderDetailId]
		,[strSalesOrderNumber]
		,[intSiteId]
		,[strBillingBy]
		,[dblPercentFull]
		,[dblConversionFactor]
		,[intPerformerId]
		,[ysnLeaseBilling]
		,[ysnVirtualMeterReading]
		,[ysnClearDetailTaxes]
		,[intTempDetailIdForTaxes]
		,[intLoadDistributionHeaderId]
		,[ysnImpactInventory]
		,[strBOLNumberDetail]
		,[intLoadDistributionDetailId]

	DECLARE @TaxDetails AS LineItemTaxDetailStagingTable

	-- Removes duplicate Freight Item when combo freight is on
	IF (@ysnComboFreight = 1)  
	BEGIN  
		DECLARE @intTopFreight INT
		SELECT TOP 1 @intTopFreight = intId FROM @EntriesForInvoice WHERE intLoadDistributionDetailId = @intComboFreightDistId AND intItemId = @intFreightItemId
		DELETE FROM @EntriesForInvoice WHERE intId IN (SELECT intId FROM @EntriesForInvoice WHERE intLoadDistributionDetailId = @intComboFreightDistId AND intItemId = @intFreightItemId AND intId != @intTopFreight)  
	END 

	-- CHECK IF INTERNAL CARRIER
	IF EXISTS(SELECT TOP 1 1 FROM @EntriesForInvoice E
	LEFT JOIN tblSMShipVia S ON S.intEntityId = E.intShipViaId
	WHERE E.intLoadDistributionHeaderId IS NOT NULL AND S.strFreightBilledBy = 'Internal Carrier')
	BEGIN
		DECLARE @dblTotalFreightCharge NUMERIC(18,6) = NULL
		DECLARE @dblTotalSurcharge NUMERIC(18,6) = NULL
		
		SELECT @dblTotalFreightCharge = SUM(RC.dblAmount) FROM #tmpSourceTableFinal STF 
		INNER JOIN tblICInventoryReceiptCharge RC ON RC.intInventoryReceiptId = STF.intInventoryReceiptId
		INNER JOIN tblICItem II ON RC.intChargeId = II.intItemId
		WHERE STF.intId != 0 AND II.strCostType = 'Freight'

		SELECT @dblTotalSurcharge = SUM(RC.dblAmount) FROM #tmpSourceTableFinal STF 
		INNER JOIN tblICInventoryReceiptCharge RC ON RC.intInventoryReceiptId = STF.intInventoryReceiptId
		INNER JOIN tblICItem II ON RC.intChargeId = II.intItemId
		WHERE STF.intId != 0 AND II.strCostType = 'Other Charges'

		UPDATE E SET E.intFreightCompanySegment = S.intCompanySegmentId
		, E.intFreightLocationSegment = S.intProfitCenterId
		, E.dblFreightCharge = @dblTotalFreightCharge
		, E.dblSurcharge = @dblTotalSurcharge
		FROM @EntriesForInvoice E
		LEFT JOIN tblSMShipVia S ON S.intEntityId = E.intShipViaId
		WHERE E.intId = (
			SELECT TOP 1 intId FROM @EntriesForInvoice EI
			LEFT JOIN tblSMShipVia SI ON SI.intEntityId = EI.intShipViaId
			WHERE EI.intLoadDistributionHeaderId IS NOT NULL AND SI.strFreightBilledBy = 'Internal Carrier'
		)
	END

	EXEC [dbo].[uspARProcessInvoices]
			 @InvoiceEntries	= @EntriesForInvoice
			,@LineItemTaxEntries= @TaxDetails
			,@UserId			= @intUserId
			,@GroupingOption	= 8
			,@RaiseError		= 1
			,@ErrorMessage		= @ErrorMessage OUTPUT
			,@CreatedIvoices	= @CreatedInvoices OUTPUT
			,@UpdatedIvoices	= @UpdatedInvoices OUTPUT
			,@RollBackAllTransaction = 1

	-- Unpost Blending Transaction
	IF (ISNULL(@ysnPostOrUnPost, 0) = 0 AND @HasBlend = 1)
	BEGIN
		SELECT DISTINCT DistItem.intLoadDistributionDetailId
		INTO #tmpBlendItems
		FROM vyuTRGetLoadBlendIngredient DistItem
		LEFT JOIN tblTRLoadDistributionHeader HeaderDistItem ON HeaderDistItem.intLoadDistributionHeaderId = DistItem.intLoadDistributionHeaderId
		WHERE HeaderDistItem.intLoadHeaderId = @intLoadHeaderId

		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpBlendItems)
		BEGIN
		
			SELECT TOP 1 @DistributionItemId = intLoadDistributionDetailId FROM #tmpBlendItems

			EXEC uspMFReverseAutoBlend
			@intSalesOrderDetailId = NULL
			, @intInvoiceDetailId = NULL
			, @intLoadDistributionDetailId = @DistributionItemId
			, @intUserId = @intUserId	

			DELETE FROM #tmpBlendItems WHERE intLoadDistributionDetailId = @DistributionItemId
			
		END
			
		DROP TABLE #tmpBlendItems
	END

	IF (@ErrorMessage IS NULL)
	BEGIN
		COMMIT TRANSACTION
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END

	DECLARE @strReceiptLink NVARCHAR(100),
		@strBOL NVARCHAR(50),
		@InvoiceId INT

	IF (@CreatedInvoices IS NOT NULL AND @ErrorMessage IS NULL)
	BEGIN
		
		SELECT Item INTO #tmpCreated FROM [fnSplitStringWithTrim](@CreatedInvoices,',')
		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpCreated)
		BEGIN
			SELECT TOP 1 @InvoiceId = CAST(Item AS INT) FROM #tmpCreated

			UPDATE tblTRLoadDistributionHeader 
			SET intInvoiceId = @InvoiceId
			WHERE intLoadHeaderId = @intLoadHeaderId
				AND strDestination = 'Customer'
				AND intLoadDistributionHeaderId = (
					SELECT intLoadDistributionHeaderId FROM tblARInvoice
					WHERE intInvoiceId = @InvoiceId
				)

			IF (@ysnRecap != 1)
			BEGIN
			UPDATE tblTRLoadHeader 
			SET ysnPosted = @ysnPostOrUnPost
			WHERE intLoadHeaderId = @intLoadHeaderId
			END

			DELETE FROM #tmpCreated WHERE CAST(Item AS INT) = @InvoiceId
		END
	END

	IF (@UpdatedInvoices IS NOT NULL AND @ErrorMessage IS NULL)
	BEGIN
		SELECT Item INTO #tmpUpdated FROM [fnSplitStringWithTrim](@UpdatedInvoices,',')
		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUpdated)
		BEGIN
			SELECT TOP 1 @InvoiceId = CAST(Item AS INT) FROM #tmpUpdated

			IF (@ysnRecap != 1)
			BEGIN
			UPDATE tblTRLoadHeader 
			SET ysnPosted = @ysnPostOrUnPost
			WHERE intLoadHeaderId = @intLoadHeaderId
			END

			DELETE FROM #tmpUpdated WHERE CAST(Item AS INT) = @InvoiceId
		END
	END

	IF(@ErrorMessage IS NULL)
	BEGIN
			-- COPY THE ATTACHMENT FROM TR TO INVOICE
		IF ((SELECT COUNT(intEntityCustomerId) FROM tblTRLoadDistributionHeader DH 
			WHERE DH.intLoadHeaderId = @intLoadHeaderId AND DH.strDestination = 'Customer') = 1)
		BEGIN
			DECLARE @intTransportAttachmentId INT = NULL,
				@intAttachmentInvoiceId INT = NULL

			DECLARE @CursorAttachmentTran AS CURSOR
			SET @CursorAttachmentTran = CURSOR FAST_FORWARD FOR
				SELECT TA.intAttachmentId, I.intInvoiceId
			FROM tblTRLoadDistributionHeader DH INNER JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = DH.intLoadHeaderId 
			INNER JOIN tblSMAttachment TA ON TA.strRecordNo = LH.intLoadHeaderId
			LEFT JOIN tblARInvoice I ON I.intInvoiceId = DH.intInvoiceId
			LEFT JOIN tblSMAttachment IA ON IA.strRecordNo = DH.intInvoiceId AND IA.strScreen = 'AccountsReceivable.view.Invoice' AND IA.strName = TA.strName
			WHERE LH.intLoadHeaderId = @intLoadHeaderId
			AND DH.intInvoiceId IS NOT NULL
			AND TA.strScreen = 'Transports.view.TransportLoads'
			AND IA.strName IS NULL
			AND DH.strDestination = 'Customer'

			OPEN @CursorAttachmentTran
			FETCH NEXT FROM @CursorAttachmentTran INTO @intTransportAttachmentId, @intAttachmentInvoiceId
			WHILE @@FETCH_STATUS = 0
			BEGIN
				DECLARE @strAttachmentErrorMessage NVARCHAR(MAX) = NULL
			
				EXEC dbo.uspSMCopyAttachments @srcNamespace = 'Transports.view.TransportLoads'
					, @srcRecordId =  @intLoadHeaderId
					, @destNamespace = 'AccountsReceivable.view.Invoice'
					, @destRecordId = @intAttachmentInvoiceId
					, @ErrorMessage = @strAttachmentErrorMessage OUTPUT
					, @srcIntAttachmentId = @intTransportAttachmentId
				
				FETCH NEXT FROM @CursorAttachmentTran INTO @intTransportAttachmentId, @intAttachmentInvoiceId
			END
			CLOSE @CursorAttachmentTran  
			DEALLOCATE @CursorAttachmentTran
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
