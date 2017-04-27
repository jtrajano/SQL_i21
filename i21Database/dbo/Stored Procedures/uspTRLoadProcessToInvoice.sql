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

	SELECT TOP 1
		   @intFreightItemId	= intItemForFreightId
		 , @intSurchargeItemId	= intSurchargeItemId
		 , @ysnItemizeSurcharge = ISNULL(ysnItemizeSurcharge, 0)
	FROM tblTRCompanyPreference

	BEGIN TRANSACTION

	SELECT
		ROW_NUMBER() OVER(ORDER BY DH.intLoadDistributionHeaderId, DD.intLoadDistributionDetailId DESC) AS intId
		,[strSourceTransaction]					= 'Transport Load'
		,[intLoadDistributionHeaderId]			= DH.intLoadDistributionHeaderId
		,[intLoadDistributionDetailId]			= DD.intLoadDistributionDetailId
		,[intSourceId]							= DH.intLoadDistributionHeaderId
		,[strSourceId]							= TL.strTransaction
		,[intInvoiceId]							= DH.intInvoiceId --NULL Value will create new invoice
		,[intEntityCustomerId]					= DH.intEntityCustomerId
		,[intCompanyLocationId]					= DH.intCompanyLocationId
		,[intCurrencyId]						= NULL
		,[intTermId]							= EL.intTermsId
		,[dtmDate]								= DH.dtmInvoiceDateTime
		,[dtmDueDate]							= NULL
		,[dtmShipDate]							= DH.dtmInvoiceDateTime
		,[intEntitySalespersonId]				= DH.intEntitySalespersonId
		,[intFreightTermId]						= NULL 
		,[intShipViaId]							= ISNULL(TL.intShipViaId, EL.intShipViaId) 
		,[intPaymentMethodId]					= 0
		,[strInvoiceOriginId]					= ''
		,[strPONumber]							= DH.strPurchaseOrder
		,[strBOLNumber]							= TR.strBillOfLading
		,[strDeliverPickup]						= 'Deliver'
		,[strComments]							= (CASE WHEN TR.intSupplyPointId IS NULL AND TL.intLoadId IS NULL THEN RTRIM(ISNULL(DH.strComments, ''))
														WHEN TR.intSupplyPointId IS NOT NULL AND TL.intLoadId IS NULL THEN 'Origin:' + RTRIM(ISNULL(ee.strSupplyPoint, '')) + ' ' + RTRIM(ISNULL(DH.strComments, ''))
														WHEN TR.intSupplyPointId IS NULL AND TL.intLoadId IS NOT NULL THEN 'Load #:' + RTRIM(ISNULL(LG.strExternalLoadNumber, '')) + ' ' + RTRIM(ISNULL(DH.strComments, ''))
														WHEN TR.intSupplyPointId IS NOT NULL AND TL.intLoadId IS NOT NULL THEN 'Origin:' + RTRIM(ISNULL(ee.strSupplyPoint, ''))  + ' Load #:' + RTRIM(ISNULL(LG.strExternalLoadNumber, '')) + ' ' + RTRIM(ISNULL(DH.strComments, ''))
													END)
		,[intShipToLocationId]					= DH.intShipToLocationId
		,[intBillToLocationId]					= ISNULL(Customer.intBillToId, EL.intEntityLocationId)
		,[ysnTemplate]							= 0
		,[ysnForgiven]							= 0
		,[ysnCalculated]						= 0  --0 OS
		,[ysnSplitted]							= 0
		,[intPaymentId]							= NULL
		,[intSplitId]							= NULL
		,[strActualCostId]						= (CASE WHEN (TR.strOrigin) = 'Terminal' AND (DH.strDestination) = 'Customer'
														THEN (TL.strTransaction)
													WHEN (TR.strOrigin) = 'Location' AND (DH.strDestination) = 'Customer' AND (TR.intCompanyLocationId) = (DH.intCompanyLocationId)
														THEN NULL
													WHEN (TR.strOrigin) = 'Location' AND (DH.strDestination) = 'Customer' AND (TR.intCompanyLocationId) != (DH.intCompanyLocationId)
														THEN (TL.strTransaction)
													WHEN (TR.strOrigin) = 'Location' AND (DH.strDestination) = 'Location'
														THEN NULL
													END)
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
		,[dblQtyOrdered]						= DD.dblUnits
		,[dblQtyShipped]						= DD.dblUnits
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
		,[intSiteId]							= NULL
		,[strBillingBy]							= ''
		,[dblPercentFull]						= NULL
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
	INTO #tmpSourceTable
	FROM tblTRLoadHeader TL
			LEFT JOIN tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = TL.intLoadHeaderId
			LEFT JOIN tblARCustomer Customer ON Customer.intEntityId = DH.intEntityCustomerId
			LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = DH.intShipToLocationId
			LEFT JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
			LEFT JOIN vyuICGetItemLocation Item ON Item.intItemId = DD.intItemId AND Item.intLocationId = DH.intCompanyLocationId
			LEFT JOIN tblLGLoad LG ON LG.intLoadId = TL.intLoadId
			LEFT JOIN vyuICGetItemStock IC ON IC.intItemId = DD.intItemId AND IC.intLocationId = DH.intCompanyLocationId
			LEFT JOIN tblTRLoadReceipt TR ON TR.intLoadHeaderId = TL.intLoadHeaderId AND TR.strReceiptLine IN (
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
		WHERE TL.intLoadHeaderId = @intLoadHeaderId
			AND DH.strDestination = 'Customer'

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

	-- Update multiple comment concatenation.
	SELECT DISTINCT intEntityCustomerId, intSourceId, intCompanyLocationId, dtmDate, intTermId, intShipViaId, intEntitySalespersonId, strComments
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

	--Auto Blend
	SELECT DistItem.intLoadDistributionDetailId
		, DistItem.intItemId
		, intRecipeId
		, dblQty = dblUnits
		, Recipe.intItemUOMId
		, HeaderDistItem.intCompanyLocationId
	INTO #tmpBlendDistributionItems
	FROM tblTRLoadDistributionDetail DistItem
	LEFT JOIN tblMFRecipe Recipe ON Recipe.intItemId = DistItem.intItemId
	LEFT JOIN tblTRLoadDistributionHeader HeaderDistItem ON HeaderDistItem.intLoadDistributionHeaderId = DistItem.intLoadDistributionHeaderId
	WHERE HeaderDistItem.intLoadHeaderId = @intLoadHeaderId
		AND ysnActive = 1

	IF EXISTS(SELECT TOP 1 1 FROM #tmpBlendDistributionItems) AND @ysnRecap = 0
	BEGIN
		DECLARE @DistributionItemId INT
			, @RecipeId INT
			, @ItemId INT
			, @ItemUOMId INT
			, @LocationId INT
			, @Qty NUMERIC(18, 6)
			, @QtyBlended NUMERIC(18, 6)

		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpBlendDistributionItems)
		BEGIN
			SELECT TOP 1 @DistributionItemId = intLoadDistributionDetailId
				, @RecipeId = intRecipeId
				, @ItemId = intItemId
				, @ItemUOMId = intItemUOMId
				, @LocationId = intCompanyLocationId
				, @Qty = dblQty
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
				
				IF (@Qty <> @QtyBlended)
				BEGIN
					RAISERROR('Cannot blend all distribution items', 16, 1)
				END
			END
			ELSE
			BEGIN
				EXEC uspMFReverseAutoBlend
					@intSalesOrderDetailId = NULL
					, @intInvoiceDetailId = NULL
					, @intLoadDistributionDetailId = @DistributionItemId
					, @intUserId = @intUserId
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
	END
	
	--Freight Items
	INSERT INTO #tmpSourceTable(
		[intId] 
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
		,[strDeliverPickup]
		,[strComments]
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
	)
	SELECT 
		0 AS intId
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
		,[strDeliverPickup]						= IE.strDeliverPickup
		,[strComments]							= IE.strComments
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
		,[dblQtyShipped]						= IE.dblQtyShipped
		,[dblDiscount]							= 0
		,[dblPrice]								= CASE WHEN ISNULL(IE.dblSurcharge,0) != 0 AND @ysnItemizeSurcharge = 0 THEN ISNULL(IE.[dblFreightRate],0) + (ISNULL(IE.[dblFreightRate],0) * (IE.dblSurcharge / 100))
													WHEN ISNULL(IE.dblSurcharge,0) = 0 OR @ysnItemizeSurcharge = 1  THEN ISNULL(IE.[dblFreightRate],0) END 
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
	FROM #tmpSourceTable IE
	INNER JOIN tblICItem Item ON Item.intItemId = @intFreightItemId
	WHERE ISNULL(IE.dblFreightRate, 0) != 0 AND IE.ysnFreightInPrice != 1

	INSERT INTO @EntriesForInvoice(
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
		,[strDeliverPickup]
		,[strComments]
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
	)
	SELECT
		 [strSourceTransaction]					= TR.strSourceTransaction
		,[intSourceId]							= TR.intSourceId
		,[strSourceId]							= TR.strSourceId
		,[intInvoiceId]							= TR.intInvoiceId
		,[intEntityCustomerId]					= TR.intEntityCustomerId
		,[intCompanyLocationId]					= TR.intCompanyLocationId
		,[intCurrencyId]						= TR.intCurrencyId
		,[intTermId]							= TR.intTermId
		,[dtmDate]								= TR.dtmDate
		,[dtmDueDate]							= TR.dtmDueDate
		,[dtmShipDate]							= TR.dtmShipDate
		,[intEntitySalespersonId]				= TR.intEntitySalespersonId
		,[intFreightTermId]						= TR.intFreightTermId
		,[intShipViaId]							= TR.intShipViaId
		,[intPaymentMethodId]					= TR.intPaymentMethodId
		,[strInvoiceOriginId]					= TR.strInvoiceOriginId
		,[strPONumber]							= TR.strPONumber
		,[strBOLNumber]							= TR.strBOLNumber
		,[strDeliverPickup]						= TR.strDeliverPickup
		,[strComments]							= TR.strComments
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
		,[dblQtyShipped]						= TR.dblQtyShipped
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
	FROM #tmpSourceTable TR
	ORDER BY TR.intLoadDistributionDetailId, intId DESC

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
			,[strDeliverPickup]
			,[strComments]
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
			,[intTempDetailIdForTaxes])
		SELECT 
			[strSourceTransaction]					= IE.strSourceTransaction
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
			,[strDeliverPickup]						= IE.strDeliverPickup
			,[strComments]							= IE.strComments
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
			,[dblQtyOrdered]						= ISNULL(IE.dblQtyShipped, 0.000000) * ISNULL(IE.[dblFreightRate], 0.000000)
			,[dblQtyShipped]						= ISNULL(IE.dblQtyShipped, 0.000000) * ISNULL(IE.[dblFreightRate], 0.000000)
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
		FROM #tmpSourceTable IE
		INNER JOIN tblICItem Item ON Item.intItemId = @intSurchargeItemId
		WHERE ISNULL(IE.dblFreightRate, 0) != 0
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
		,[strDeliverPickup]
		,[strComments]
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
		,[strDeliverPickup]						= IE.strDeliverPickup
		,[strComments]							= IE.strComments
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
		,[dblPrice]								= MIN(dblPrice)
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
		,[strDeliverPickup]
		,[strComments]
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

	EXEC [dbo].[uspARProcessInvoices]
			 @InvoiceEntries	= @EntriesForInvoice
			,@UserId			= @intUserId
			,@GroupingOption	= 8
			,@RaiseError		= 1
			,@ErrorMessage		= @ErrorMessage OUTPUT
			,@CreatedIvoices	= @CreatedInvoices OUTPUT
			,@UpdatedIvoices	= @UpdatedInvoices OUTPUT

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

			UPDATE tblTRLoadHeader 
			SET ysnPosted = @ysnPostOrUnPost
			WHERE intLoadHeaderId = @intLoadHeaderId

			DELETE FROM #tmpCreated WHERE CAST(Item AS INT) = @InvoiceId
		END
	END

	IF (@UpdatedInvoices IS NOT NULL AND @ErrorMessage IS NULL)
	BEGIN
		SELECT Item INTO #tmpUpdated FROM [fnSplitStringWithTrim](@UpdatedInvoices,',')
		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUpdated)
		BEGIN
			SELECT TOP 1 @InvoiceId = CAST(Item AS INT) FROM #tmpUpdated

			UPDATE tblTRLoadHeader 
			SET ysnPosted = @ysnPostOrUnPost
			WHERE intLoadHeaderId = @intLoadHeaderId

			DELETE FROM #tmpUpdated WHERE CAST(Item AS INT) = @InvoiceId
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