CREATE PROCEDURE [dbo].[uspTRLoadProcessToInventoryReceipt]
	 @intLoadHeaderId AS INT
	,@intUserId AS INT	
	,@ysnRecap AS BIT
	,@ysnPostOrUnPost AS BIT
	,@BatchId NVARCHAR(20) = NULL
	,@ysnIRViewOnly AS BIT = 0    
	,@strReceiptLink NVARCHAR(20) = NULL    
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
				LEFT JOIN tblICInventoryReceipt IR ON TR.intInventoryReceiptId = IR.intInventoryReceiptId
     	WHERE	TL.intLoadHeaderId = @intLoadHeaderId 
     			AND TR.strOrigin = 'Terminal'
				AND IC.strType != 'Non-Inventory'
     			AND (TR.dblUnitCost != 0 or TR.dblFreightRate != 0 or TR.dblPurSurcharge != 0)
				AND TR.intInventoryReceiptId IS NOT NULL
				AND IR.ysnPosted = 1;
				
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

	-- List all Distributions along with Customer Freight 
	SELECT DISTINCT strReceiptLine = LR.strReceiptLine
		,dblUnitCost = ISNULL(LR.dblUnitCost, 0) 
		,dblFreightRate =  ISNULL(LR.dblFreightRate, 0) 
		,dblPurSurcharge = ISNULL(LR.dblPurSurcharge, 0)
		,ysnFreightOnly = ISNULL(CF.ysnFreightOnly, 0)
		,intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
	INTO #tmpList
	FROM tblTRLoadDistributionDetail DD
	JOIN tblTRLoadDistributionHeader DH ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
	JOIN tblICItem I ON I.intItemId = DD.intItemId
	JOIN tblTRLoadReceipt LR ON LR.strReceiptLine = DD.strReceiptLink AND LR.intLoadHeaderId = DH.intLoadHeaderId
	JOIN vyuTRSupplyPointView SP ON SP.intSupplyPointId = LR.intSupplyPointId
	JOIN vyuTRCustomerFreightList CF ON CF.intCustomerId = DH.intEntityCustomerId
										AND CF.inCustomerLocationId = DH.intShipToLocationId
										AND CF.intCategoryId = I.intCategoryId
										AND CF.strZipCode = SP.strZipCode

	
	--WHERE ISNULL(CF.ysnFreightOnly, 0) = 1
		--AND (ISNULL(LR.dblUnitCost, 0) != 0 OR ISNULL(LR.dblFreightRate, 0) != 0 OR ISNULL(LR.dblPurSurcharge, 0) != 0)
		WHERE (LR.strReceiptLine = @strReceiptLink OR @strReceiptLink IS NULL)
		AND DH.intLoadHeaderId = @intLoadHeaderId

	DECLARE @ysnCompanyOwnedInternalCarrier BIT = 0
	SELECT @ysnCompanyOwnedInternalCarrier = ISNULL(ysnCompanyOwnedCarrier, 0) FROM tblSMShipVia
	WHERE intEntityId = (SELECT intShipViaId = ISNULL(intShipViaId, 0) FROM tblTRLoadHeader WHERE intLoadHeaderId = @intLoadHeaderId)
	AND strFreightBilledBy = 'Internal Carrier'
	
	
	----@ysnPostOrUnPost
	DECLARE	@FreightOnlyids AS NVARCHAR(MAX)
	--SELECT	@FreightOnlyids = STUFF((SELECT DISTINCT ', ' + RTRIM(LTRIM(strReceiptLine))
	--						FROM #tmpList --WHERE dblUnitCost != 0 OR dblFreightRate != 0 OR dblPurSurcharge!= 0
	--						FOR XML PATH('')), 1, 2, '')

		
	--VALIDATE/disalllow if Freight there is Freight only and no amount in  fields
	--but ALLOW/Skip validation error if there is at least one that is NON-Freight Only 


		SELECT * INTO #receipts FROM #tmpList
			
		IF(@ysnIRViewOnly = 1 AND @strReceiptLink IS NOT NULL)
			BEGIN
					IF EXISTS(	SELECT TOP 1 1 FROM #tmpList WHERE ysnFreightOnly = 1 )  AND NOT EXISTS(SELECT TOP 1 1 FROM #tmpList WHERE ysnFreightOnly = 0)
					BEGIN
						SET @ErrMsg = 'Inventory Receipt is not available for Receipt (' + @strReceiptLink + ') that was distributed as Freight Only.'
						RAISERROR(@ErrMsg, 16, 1)
					END
			END
					
		ELSE
			BEGIN
				--LOOP thru each Recipt then check each distribution per Receipt link
				DECLARE @RLink NVARCHAR(50)
				WHILE EXISTS (SELECT TOP 1 1 FROM #receipts) 
					BEGIN
					SELECT TOP 1  @RLink = strReceiptLine FROM #receipts 


					IF EXISTS(	SELECT TOP 1 1 FROM #receipts WHERE ysnFreightOnly = 1 AND strReceiptLine = @RLink AND dblUnitCost != 0 OR dblFreightRate != 0 OR dblPurSurcharge!= 0)  
					   AND NOT EXISTS(SELECT TOP 1 1 FROM #receipts WHERE ysnFreightOnly = 0 AND strReceiptLine = @RLink )
						BEGIN
								IF(ISNULL(@ysnCompanyOwnedInternalCarrier,0) = 0)
								BEGIN
									SET @ErrMsg = 'Receipt (' + @RLink + ') that was distributed as Freight Only should not have any cost, freight, or surcharge.'
									RAISERROR(@ErrMsg, 16, 1)
								END
						END
					ELSE
						BEGIN
							IF(ISNULL(@ysnCompanyOwnedInternalCarrier,0) = 0 AND NOT EXISTS(SELECT TOP 1 1 FROM #receipts WHERE ysnFreightOnly = 1 AND strReceiptLine = @RLink AND dblUnitCost != 0 OR dblFreightRate != 0 OR dblPurSurcharge!= 0))
									BEGIN
										SET @ErrMsg = 'Receipt (' + @RLink + ') that was distributed as Freight Only should not have any cost, freight, or surcharge.'
										RAISERROR(@ErrMsg, 16, 1)
									END
						END
					--RAISERROR(@ErrMsg, 16, 1)

					DELETE	FROM #receipts WHERE	strReceiptLine = @RLink 
					END
			END
			
			IF EXISTS(SELECT TOP 1 1 FROM #tmpList WHERE ysnFreightOnly = 1 AND ISNULL(@ysnCompanyOwnedInternalCarrier,0) = 1 ) 
			BEGIN
				RETURN
			END


	DROP TABLE #tmpList
	-- End of Freight Only Validation

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
		,intSubLocationId			= MIN(TMSite.intCompanyLocationSubLocationId) -- No Storage Location from transport unless COmpany Consumption Site
		,intStorageLocationId		= NULL -- No Sub Location from transport
		,ysnIsStorage				= 0 -- No Storage from transports
		,dblFreightRate				= min(TR.dblFreightRate)
		,intSourceId				= min(TR.intLoadReceiptId)
		,intSourceType		 		= 3 -- Source type for transports is 3 
		,dblGross					= min(TR.dblGross)
		,dblNet						= min(TR.dblNet)
		,intInventoryReceiptId		= min(TR.intInventoryReceiptId)
		,dblSurcharge				= min(TR.dblPurSurcharge)
		,ysnFreightInPrice			= CAST(MIN(CAST(TR.ysnFreightInPrice AS INT)) AS BIT)
		,strActualCostId			= ISNULL(min(TL.strTransaction), min(BID.strTransaction))
		,intTaxGroupId				= min(TR.intTaxGroupId)
		,strVendorRefNo				= min(TR.strBillOfLading)
		,strSourceId				= min(TL.strTransaction)
		,strSourceScreenName		= 'Transport Loads'
		,intPaymentOn				= 1 -- Compute on Qty to Receive
		,strChargesLink				= MIN(TR.strReceiptLine)
		,strDestinationType			= ISNULL(MIN(DH.strDestination), MIN(BID.strDestination))
		,strFreightBilledBy			= MIN(ShipVia.strFreightBilledBy)
		,dblMinimumUnits			= MIN(TR.dblMinimumUnits)
		,dblComboFreightRate		= MIN(TR.dblComboFreightRate)
		,ysnComboFreight			= CAST(MIN(CAST(TR.ysnComboFreight AS INT)) AS BIT)
		,dblComboMinimumUnits		= MIN(TR.dblComboMinimumUnits)
		,dblComboSurcharge			= MIN(TR.dblComboSurcharge)
	INTO #tmpReceipts
	FROM tblTRLoadHeader TL
	LEFT JOIN tblTRLoadReceipt TR ON TR.intLoadHeaderId = TL.intLoadHeaderId			
	LEFT JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = TR.intContractDetailId
	LEFT JOIN tblTRSupplyPoint SP ON SP.intSupplyPointId = TR.intSupplyPointId
	LEFT JOIN vyuICGetItemStock IC ON IC.intItemId = TR.intItemId and IC.intLocationId = TR.intCompanyLocationId
	LEFT JOIN tblSMShipVia ShipVia ON ShipVia.intEntityId = TL.intShipViaId
	LEFT JOIN tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = TR.intLoadHeaderId
	LEFT JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId AND DD.strReceiptLink = TR.strReceiptLine
	LEFT JOIN vyuTRGetLoadReceiptToBlendIngredient BID ON BID.intLoadHeaderId = TR.intLoadHeaderId and BID.intLoadReceiptId = TR.intLoadReceiptId and BID.intItemId = TR.intItemId
	LEFT JOIN vyuTMGetSite TMSite ON TMSite.intSiteID = DD.intSiteId AND ISNULL(TMSite.ysnCompanySite, 0) = 1
	WHERE	TL.intLoadHeaderId = @intLoadHeaderId --333333
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
	
	---- Insert Entries to Stagging table that needs to processed to Transport Load
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
		,intTaxGroupId			= CASE WHEN intTaxGroupId IS NULL AND dblCost = 0 THEN -1 ELSE intTaxGroupId END
		,strVendorRefNo			= strVendorRefNo
		,strSourceId			= strSourceId
		,strSourceScreenName	= strSourceScreenName
		,intPaymentOn			= intPaymentOn
		,strChargesLink			= strChargesLink
	FROM #tmpReceipts

	--SELECT TOP 1 @intFreightItemId = intItemForFreightId FROM tblTRCompanyPreference
	SELECT TOP 1 @intFreightItemId = intFreightItemId FROM tblTRLoadHeader WHERE intLoadHeaderId = @intLoadHeaderId 
	SELECT TOP 1 @intSurchargeItemId = intItemId FROM vyuICGetOtherCharges WHERE intOnCostTypeId = @intFreightItemId


	-- GET COST METHOD - FREIGHT
	DECLARE @strCostMethodFreight NVARCHAR(30) = NULL
	SELECT @strCostMethodFreight = strCostMethod FROM tblICItem WHERE intItemId = @intFreightItemId
	IF(ISNULL(@strCostMethodFreight,'') = '')
	BEGIN
		RAISERROR('Cost Method for Freight item cannot be null', 16 ,1)
	END

	-- GET COST METHOD - FREIGHT
	DECLARE @strCostMethodSurcharge NVARCHAR(30) = NULL
	SELECT @strCostMethodSurcharge = strCostMethod FROM tblICItem WHERE intItemId = @intSurchargeItemId
	IF(ISNULL(@strCostMethodSurcharge,'') = '' AND @intSurchargeItemId IS NOT NULL)
	BEGIN
		RAISERROR('Cost Method for Surcharge item cannot be null', 16 ,1)
	END

	SELECT TOP 1 @FreightUOMId = intCostUOMId FROM tblICItem WHERE intItemId = @intFreightItemId
	IF (@FreightUOMId IS NULL)
		SELECT TOP 1 @FreightUOMId = intItemUOMId FROM tblICItemUOM WHERE intItemId = @intFreightItemId AND ysnStockUnit = 1
	

	SELECT @SurchargeUOMId = dbo.fnGetMatchingItemUOMId(@intSurchargeItemId, @FreightUOMId)

	-- SELECT TOP 1 @SurchargeUOMId = intCostUOMId FROM tblICItem WHERE intItemId = @intSurchargeItemId
	-- IF (@SurchargeUOMId IS NULL)
	-- 	SELECT TOP 1 @SurchargeUOMId = intItemUOMId FROM tblICItemUOM WHERE intItemId = @intSurchargeItemId AND ysnStockUnit = 1

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
			,[dblQuantity]
	) 	
	SELECT	DISTINCT [intEntityVendorId]	= RE.intEntityVendorId
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
			,[strCostMethod]				= CASE  WHEN dblQty <= dblComboMinimumUnits AND ysnComboFreight = 1 THEN 'Custom Unit' WHEN dblQty <= dblMinimumUnits AND ysnComboFreight = 0 THEN 'Custom Unit' ELSE @strCostMethodFreight END
			,[dblRate]						= CASE WHEN ysnComboFreight = 1 AND RE.dblComboFreightRate > 0 THEN RE.dblComboFreightRate ELSE RE.dblFreightRate END
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
			,strChargesLink					= CASE WHEN ysnComboFreight = 1 THEN NULL ELSE RE.strChargesLink END
			,[dblQuantity]					= CASE WHEN dblQty <= dblComboMinimumUnits AND ysnComboFreight = 1 THEN dblComboMinimumUnits WHEN dblQty <= dblMinimumUnits AND ysnComboFreight = 0 THEN dblMinimumUnits ELSE dblQty END
	FROM	#tmpReceipts RE 
	WHERE RE.dblFreightRate != 0  OR (RE.dblComboFreightRate != 0  AND ysnComboFreight = 1)
	--Fuel Surcharge
	UNION ALL 
	SELECT DISTINCT	[intEntityVendorId]			= RE.intEntityVendorId
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
				,[strCostMethod]				= @strCostMethodSurcharge
				,[dblRate]						= CASE WHEN ysnComboFreight = 1 AND RE.dblComboSurcharge > 0 THEN RE.dblComboSurcharge ELSE RE.dblSurcharge END
				,[intCostUOMId]					= @SurchargeUOMId
				,[intOtherChargeEntityVendorId]	= CASE WHEN RE.strFreightBilledBy = 'Vendor' THEN RE.intEntityVendorId
														WHEN RE.strFreightBilledBy = 'Internal' THEN NULL
														WHEN RE.strFreightBilledBy = 'Other' THEN RE.intShipViaId
														ELSE NULL END
				,[dblAmount]					= 0
				,[strAllocateCostBy]			= CASE WHEN RE.dblCost = 0 THEN 'Unit' ELSE 'Cost' END
				,[intContractHeaderId]			= RE.intContractHeaderId
				,[intContractDetailId]			= RE.intContractDetailId
				,[ysnAccrue]					= CASE WHEN RE.strFreightBilledBy = 'Vendor' THEN 1
														WHEN RE.strFreightBilledBy = 'Internal' THEN 0
														WHEN RE.strFreightBilledBy = 'Other' THEN 1
														ELSE 0 END

				,strChargesLink					= CASE WHEN ysnComboFreight = 1 THEN NULL ELSE RE.strChargesLink END
				,dblQuantity					= NULL
	FROM	#tmpReceipts RE 
	WHERE (RE.dblSurcharge != 0  AND ISNULL(ysnComboFreight, 0) = 0) OR (RE.dblComboSurcharge != 0  AND ysnComboFreight = 1)

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