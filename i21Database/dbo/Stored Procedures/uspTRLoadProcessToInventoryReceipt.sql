CREATE PROCEDURE [dbo].[uspTRLoadProcessToInventoryReceipt]
	 @intLoadHeaderId AS INT
	,@intUserId AS INT	
	,@ysnRecap AS BIT
	,@ysnPostOrUnPost AS BIT
	,@BatchId NVARCHAR(20) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @InventoryReceiptId AS INT; 
DECLARE @ErrMsg                    NVARCHAR(MAX);

DECLARE @ReceiptStagingTable AS ReceiptStagingTable,
		@OtherCharges AS ReceiptOtherChargesTableType, 
        @total as int,
		@defaultCurrency int,
		@intSurchargeItemId as int,
		@intFreightItemId as int,
		@SurchargeUOMId as int,
		@FreightUOMId as int,
		@FreightCostAllocationMethod AS INT

SELECT	TOP 1 @defaultCurrency = CP.intDefaultCurrencyId		
											FROM	dbo.tblSMCompanyPreference CP
											WHERE	CP.intCompanyPreferenceId = 1 

IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
BEGIN 
	CREATE TABLE #tmpAddItemReceiptResult (
		intSourceId INT
		,intInventoryReceiptId INT
	)
END 
BEGIN TRY
if @ysnPostOrUnPost = 0 and @ysnRecap = 0
BEGIN
     INSERT  INTO #tmpAddItemReceiptResult
     SELECT TR.intLoadReceiptId,TR.intInventoryReceiptId FROM	tblTRLoadHeader TL JOIN tblTRLoadReceipt TR 
     				ON TR.intLoadHeaderId = TL.intLoadHeaderId			
     			LEFT JOIN vyuCTContractDetailView CT 
     				ON CT.intContractDetailId = TR.intContractDetailId
     			LEFT JOIN tblTRSupplyPoint SP 
     				ON SP.intSupplyPointId = TR.intSupplyPointId
				LEFT JOIN vyuICGetItemStock IC
			    ON IC.intItemId = TR.intItemId and IC.intLocationId = TR.intCompanyLocationId	
     	WHERE	TL.intLoadHeaderId = @intLoadHeaderId 
     			AND TR.strOrigin = 'Terminal'
				AND IC.strType != 'Non-Inventory'
     			AND (TR.dblUnitCost != 0 or TR.dblFreightRate != 0 or TR.dblPurSurcharge != 0);
	SELECT @total = COUNT(*) FROM #tmpAddItemReceiptResult;
    IF (@total = 0)
	   BEGIN
	     RETURN;
	   END
	ELSE
	    BEGIN
        	GOTO _PostOrUnPost;
		END

END

	SELECT strReceiptType			= CASE WHEN min(TR.intContractDetailId) IS NULL THEN 'Direct'
											WHEN min(TR.intContractDetailId) IS NOT NULL THEN 'Purchase Contract' END
		,intEntityVendorId			= min(TR.intTerminalId)
		,intShipFromId				= min(SP.intEntityLocationId)
		,intLocationId				= min(TR.intCompanyLocationId)
		,intItemId					= min(TR.intItemId)
		,intItemLocationId			= min(TR.intCompanyLocationId)
		,intItemUOMId				= CASE WHEN min(TR.intContractDetailId) is NULL THEN min(IC.intStockUOMId)
											WHEN min(TR.intContractDetailId) is NOT NULL THEN min(CT.intItemUOMId) END -- Need to add the Gallons UOM from Company Preference
		,strBillOfLadding			= min(TR.strBillOfLading)
		,intContractHeaderId		= min(CT.intContractHeaderId)
		,intContractDetailId		= min(TR.intContractDetailId)
		,dtmDate					= min(TL.dtmLoadDateTime)
		,intShipViaId				= min(TL.intShipViaId)
		,dblQty						= CASE WHEN min(SP.strGrossOrNet) = 'Gross' THEN min(TR.dblGross)
											WHEN min(SP.strGrossOrNet) = 'Net' THEN min(TR.dblNet) END
		,dblCost					= min(TR.dblUnitCost)
		,intCurrencyId				= @defaultCurrency
		,dblExchangeRate			= 1 -- Need to check this
		,intLotId					= NULL --No LOTS from transport
		,intSubLocationId			= NULL -- No Sub Location from transport
		,intStorageLocationId		= NULL -- No Storage Location from transport
		,ysnIsStorage				= 0 -- No Storage from transports
		,dblFreightRate				= min(TR.dblFreightRate)
		,intSourceId				= min(TR.intLoadReceiptId)
		,intSourceType		 		= 3 -- Source type for transports is 3 
		,dblGross					= min(TR.dblGross)
		,dblNet						= min(TR.dblNet)
		,intInventoryReceiptId		= min(TR.intInventoryReceiptId)
		,dblSurcharge				= min(TR.dblPurSurcharge)
		,ysnFreightInPrice			= CAST(MIN(CAST(TR.ysnFreightInPrice AS INT)) AS BIT)
		,strActualCostId			= ISNULL(min(TLD.strTransaction), min(BID.strTransaction))
		,intTaxGroupId				= min(TR.intTaxGroupId)
		,strVendorRefNo				= min(TR.strBillOfLading)
		,strSourceId				= min(TL.strTransaction)
		,strSourceScreenName		= 'Transport Loads'
		,intPaymentOn				= 1 -- Compute on Qty to Receive
		,strChargesLink				= MIN(TR.strReceiptLine)
		,strDestinationType			= ISNULL(MIN(TLD.strDestination), MIN(BID.strDestination))
		,strFreightBilledBy			= MIN(ShipVia.strFreightBilledBy)
	INTO #tmpReceipts
	FROM tblTRLoadHeader TL
	LEFT JOIN tblTRLoadReceipt TR ON TR.intLoadHeaderId = TL.intLoadHeaderId			
	LEFT JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = TR.intContractDetailId
	LEFT JOIN tblTRSupplyPoint SP ON SP.intSupplyPointId = TR.intSupplyPointId
	LEFT JOIN vyuICGetItemStock IC ON IC.intItemId = TR.intItemId and IC.intLocationId = TR.intCompanyLocationId
	LEFT JOIN tblSMShipVia ShipVia ON ShipVia.intEntityId = TL.intShipViaId
	LEFT JOIN vyuTRGetLoadReceiptToDistribution TLD on TLD.intLoadHeaderId = TR.intLoadHeaderId AND TLD.intLoadReceiptId = TR.intLoadReceiptId AND TLD.intItemId = TR.intItemId
	LEFT JOIN vyuTRGetLoadReceiptToBlendIngredient BID ON BID.intLoadHeaderId = TR.intLoadHeaderId and BID.intLoadReceiptId = TR.intLoadReceiptId and BID.intItemId = TR.intItemId
	WHERE	TL.intLoadHeaderId = @intLoadHeaderId
			AND TR.strOrigin = 'Terminal'
			AND IC.strType != 'Non-Inventory'
			AND (TR.dblUnitCost != 0 or TR.dblFreightRate != 0 or TR.dblPurSurcharge != 0)
    group by TR.intLoadReceiptId
	ORDER BY intEntityVendorId
		,strBillOfLadding
		,strReceiptType
		,intLocationId
		,intShipViaId
		,intShipFromId
		,intSourceType
		,intTaxGroupId

	-- Insert Entries to Stagging table that needs to processed to Transport Load
	INSERT into @ReceiptStagingTable(
			strReceiptType
			,intEntityVendorId
			,intShipFromId
			,intLocationId
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,strBillOfLadding
			,intContractHeaderId
			,intContractDetailId
			,dtmDate
			,intShipViaId
			,dblQty
			,dblCost
			,intCurrencyId
			,dblExchangeRate
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,ysnIsStorage
			,dblFreightRate
			,intSourceId	
			,intSourceType		 	
			,dblGross
			,dblNet
			,intInventoryReceiptId
			,dblSurcharge
			,ysnFreightInPrice
			,strActualCostId
			,intTaxGroupId
			,strVendorRefNo
			,strSourceId
			,strSourceScreenName
			,intPaymentOn
			,strChargesLink
	)	
	SELECT strReceiptType		= strReceiptType
		,intEntityVendorId		= intEntityVendorId
		,intShipFromId			= intShipFromId
		,intLocationId			= intLocationId
		,intItemId				= intItemId
		,intItemLocationId		= intItemLocationId
		,intItemUOMId			= intItemUOMId
		,strBillOfLadding		= strBillOfLadding
		,intContractHeaderId	= intContractHeaderId
		,intContractDetailId	= intContractDetailId
		,dtmDate				= dtmDate
		,intShipViaId			= intShipViaId
		,dblQty					= dblQty
		,dblCost				= dblCost
		,intCurrencyId			= intCurrencyId
		,dblExchangeRate		= dblExchangeRate
		,intLotId				= intLotId
		,intSubLocationId		= intSubLocationId
		,intStorageLocationId	= intStorageLocationId
		,ysnIsStorage			= ysnIsStorage
		,dblFreightRate			= dblFreightRate
		,intSourceId			= intSourceId
		,intSourceType		 	= intSourceType
		,dblGross				= dblGross
		,dblNet					= dblNet
		,intInventoryReceiptId	= intInventoryReceiptId
		,dblSurcharge			= dblSurcharge
		,ysnFreightInPrice		= ysnFreightInPrice
		,strActualCostId		= strActualCostId
		,intTaxGroupId			= intTaxGroupId
		,strVendorRefNo			= strVendorRefNo
		,strSourceId			= strSourceId
		,strSourceScreenName	= strSourceScreenName
		,intPaymentOn			= intPaymentOn
		,strChargesLink			= strChargesLink
	FROM #tmpReceipts

	SELECT TOP 1 @intFreightItemId = intItemForFreightId FROM tblTRCompanyPreference
	SELECT TOP 1 @intSurchargeItemId = intItemId FROM vyuICGetOtherCharges WHERE intOnCostTypeId = @intFreightItemId

	SELECT TOP 1 @FreightUOMId = intCostUOMId FROM tblICItem WHERE intItemId = @intFreightItemId
	IF (@FreightUOMId IS NULL)
		SELECT TOP 1 @FreightUOMId = intItemUOMId FROM tblICItemUOM WHERE intItemId = @intFreightItemId AND ysnStockUnit = 1
	
	SELECT TOP 1 @SurchargeUOMId = intCostUOMId FROM tblICItem WHERE intItemId = @intSurchargeItemId
	IF (@SurchargeUOMId IS NULL)
		SELECT TOP 1 @SurchargeUOMId = intItemUOMId FROM tblICItemUOM WHERE intItemId = @intSurchargeItemId AND ysnStockUnit = 1

	-- Get Freight Cost Allocation Method from Company Preferences
	SELECT TOP 1 @FreightCostAllocationMethod = intFreightCostAllocationMethod FROM tblTRCompanyPreference

	--Fuel Freight
	INSERT INTO @OtherCharges
	(
			[intEntityVendorId] 
			,[strBillOfLadding] 
			,[strReceiptType] 
			,[intLocationId] 
			,[intShipViaId] 
			,[intShipFromId] 
			,[intCurrencyId]  	
			,[intChargeId] 
			,[ysnInventoryCost] 
			,[strCostMethod] 
			,[dblRate] 
			,[intCostUOMId] 
			,[intOtherChargeEntityVendorId] 
			,[dblAmount] 
			,[strAllocateCostBy] 
			,[intContractHeaderId]
			,[intContractDetailId] 
			,[ysnAccrue]
			,[strChargesLink]
	) 
   SELECT	[intEntityVendorId]				= RE.intEntityVendorId
			,[strBillOfLadding]				= RE.strBillOfLadding
			,[strReceiptType]				= RE.strReceiptType
			,[intLocationId]				= RE.intLocationId
			,[intShipViaId]					= RE.intShipViaId
			,[intShipFromId]				= RE.intShipFromId
			,[intCurrencyId]  				= RE.intCurrencyId
			,[intChargeId]					= @intFreightItemId
			,[ysnInventoryCost]				= (CASE WHEN @FreightCostAllocationMethod = 2 THEN CAST (1 AS BIT)
													WHEN @FreightCostAllocationMethod = 3 THEN CAST (0 AS BIT)
													ELSE (CASE WHEN RE.strDestinationType = 'Location' THEN CAST(1 AS BIT)
																ELSE CAST(0 AS BIT) END) END)
			,[strCostMethod]				= 'Per Unit'
			,[dblRate]						= RE.dblFreightRate
			,[intCostUOMId]					= @FreightUOMId
			,[intOtherChargeEntityVendorId]	= CASE	WHEN RE.strFreightBilledBy = 'Vendor' THEN RE.intEntityVendorId
													WHEN RE.strFreightBilledBy = 'Internal' THEN NULL
													WHEN RE.strFreightBilledBy = 'Other' THEN RE.intShipViaId
													ELSE NULL END
			,[dblAmount]					= 0
			,[strAllocateCostBy]			= 'Unit'
			,[intContractHeaderId]			= RE.intContractHeaderId
			,[intContractDetailId]			= RE.intContractDetailId
			,[ysnAccrue]					= CASE WHEN RE.strFreightBilledBy = 'Vendor' THEN 1
													WHEN RE.strFreightBilledBy = 'Internal' THEN 0
													WHEN RE.strFreightBilledBy = 'Other' THEN 1
													ELSE 0 END
			,strChargesLink					= RE.strChargesLink
    FROM	#tmpReceipts RE 
	WHERE	RE.dblFreightRate != 0

	--Fuel Surcharge
	UNION ALL 
	SELECT	[intEntityVendorId]				= RE.intEntityVendorId
			,[strBillOfLadding]				= RE.strBillOfLadding
			,[strReceiptType]				= RE.strReceiptType
			,[intLocationId]				= RE.intLocationId
			,[intShipViaId]					= RE.intShipViaId
			,[intShipFromId]				= RE.intShipFromId
			,[intCurrencyId]  				= RE.intCurrencyId
			,[intChargeId]					= @intSurchargeItemId
			,[ysnInventoryCost]				= (CASE WHEN @FreightCostAllocationMethod = 2 THEN CAST (1 AS BIT)
													WHEN @FreightCostAllocationMethod = 3 THEN CAST (0 AS BIT)
													ELSE (CASE WHEN RE.strDestinationType = 'Location' THEN CAST(1 AS BIT)
																ELSE CAST(0 AS BIT) END) END)
			,[strCostMethod]				= 'Percentage'
			,[dblRate]						= RE.dblSurcharge
			,[intCostUOMId]					= @SurchargeUOMId
			,[intOtherChargeEntityVendorId]	= CASE WHEN RE.strFreightBilledBy = 'Vendor' THEN RE.intEntityVendorId
													WHEN RE.strFreightBilledBy = 'Internal' THEN NULL
													WHEN RE.strFreightBilledBy = 'Other' THEN RE.intShipViaId
													ELSE NULL END
			,[dblAmount]					= 0
			,[strAllocateCostBy]			= 'Unit'
			,[intContractHeaderId]			= RE.intContractHeaderId
			,[intContractDetailId]			= RE.intContractDetailId
			,[ysnAccrue]					= CASE WHEN RE.strFreightBilledBy = 'Vendor' THEN 1
													WHEN RE.strFreightBilledBy = 'Internal' THEN 0
													WHEN RE.strFreightBilledBy = 'Other' THEN 1
													ELSE 0 END

			,strChargesLink					= RE.strChargesLink
    FROM	#tmpReceipts RE 
	WHERE	RE.dblSurcharge != 0 

	DROP TABLE #tmpReceipts

	-- No Records to process so exit
    SELECT @total = COUNT(*) FROM @ReceiptStagingTable;
    IF (@total = 0)
	   RETURN;

	EXEC dbo.uspICAddItemReceipt 
			@ReceiptStagingTable
			,@OtherCharges
			,@intUserId;

	-- Update the Inventory Receipt Key to the Transaction Table
	UPDATE	TR
	SET		intInventoryReceiptId = addResult.intInventoryReceiptId
	FROM	dbo.tblTRLoadReceipt TR INNER JOIN #tmpAddItemReceiptResult addResult
				ON TR.intLoadReceiptId = addResult.intSourceId

_PostOrUnPost:
	-- Post the Inventory Receipts                                            
	DECLARE @ReceiptId INT
			,@intEntityId INT
			,@strTransactionId NVARCHAR(50);

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpAddItemReceiptResult) 
	BEGIN

		SELECT TOP 1 
				@ReceiptId = intInventoryReceiptId  
		FROM	#tmpAddItemReceiptResult 
  
		-- Post the Inventory Receipt that was created
		SELECT	@strTransactionId = strReceiptNumber 
		FROM	tblICInventoryReceipt 
		WHERE	intInventoryReceiptId = @ReceiptId

		SELECT	TOP 1 @intEntityId = intEntityId 
		FROM	tblSMUserSecurity 
		WHERE	intEntityId = @intUserId
		if @ysnRecap = 0
		BEGIN
		  EXEC dbo.uspICPostInventoryReceipt @ysnPostOrUnPost, 0, @strTransactionId, @intEntityId;			
		END
		

		DELETE	FROM #tmpAddItemReceiptResult 
		WHERE	intInventoryReceiptId = @ReceiptId
	END;

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