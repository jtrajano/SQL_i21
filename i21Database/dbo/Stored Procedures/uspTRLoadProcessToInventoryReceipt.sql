CREATE PROCEDURE [dbo].[uspTRLoadProcessToInventoryReceipt]
	 @intLoadHeaderId AS INT
	,@intUserId AS INT	
	,@ysnRecap AS BIT
	,@ysnPostOrUnPost AS BIT
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
		@intSurchargeItemId as int,
		@intFreightItemId as int;

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
     	WHERE	TL.intLoadHeaderId = @intLoadHeaderId 
     			AND TR.strOrigin = 'Terminal'
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
	)	
	SELECT 
			strReceiptType				=	CASE	WHEN TR.intContractDetailId IS NULL THEN 'Direct'
													WHEN TR.intContractDetailId IS NOT NULL THEN 'Purchase Contract'
											END
			,intEntityVendorId			= TR.intTerminalId
			,intShipFromId				= SP.intEntityLocationId
			,intLocationId				= TR.intCompanyLocationId
			,intItemId					= TR.intItemId
			,intItemLocationId			= TR.intCompanyLocationId
			,intItemUOMId				=	CASE	
												WHEN TR.intContractDetailId is NULL  
													THEN (SELECT	TOP 1 
															IU.intItemUOMId											
															FROM dbo.tblICItemUOM IU 
															WHERE	IU.intItemId = TR.intItemId and IU.ysnStockUnit = 1)
												WHEN TR.intContractDetailId is NOT NULL 
													THEN	(select top 1 intItemUOMId from vyuCTContractDetailView CT where CT.intContractDetailId = TR.intContractDetailId)
											END-- Need to add the Gallons UOM from Company Preference	   
			,strBillOfLadding			= TR.strBillOfLading
			,intContractHeaderId		= CT.intContractHeaderId
			,intContractDetailId		= TR.intContractDetailId
			,dtmDate					= TL.dtmLoadDateTime
			,intShipViaId				= TL.intShipViaId
			,dblQty						=	CASE	WHEN SP.strGrossOrNet = 'Gross' THEN TR.dblGross
													WHEN SP.strGrossOrNet = 'Net' THEN TR.dblNet
											END
			,dblCost					= TR.dblUnitCost
			,intCurrencyId				= (
											SELECT	TOP 1 
													CP.intDefaultCurrencyId		
											FROM	dbo.tblSMCompanyPreference CP
											WHERE	CP.intCompanyPreferenceId = 1 												
										) -- USD default from company Preference 
			,dblExchangeRate			= 1 -- Need to check this
			,intLotId					= NULL --No LOTS from transport
			,intSubLocationId			= NULL -- No Sub Location from transport
			,intStorageLocationId		= NULL -- No Storage Location from transport
			,ysnIsStorage				= 0 -- No Storage from transports
			,dblFreightRate				= TR.dblFreightRate
			,intSourceId				= TR.intLoadReceiptId
			,intSourceType		 		= 3 -- Source type for transports is 3 
			,dblGross					= TR.dblGross
			,dblNet						= TR.dblNet
			,intInventoryReceiptId		= TR.intInventoryReceiptId
			,dblSurcharge				= TR.dblPurSurcharge
			,ysnFreightInPrice			= TR.ysnFreightInPrice
			,strActualCostId			= (
											SELECT top 1	strTransaction 
											FROM	tblTRLoadHeader TT JOIN tblTRLoadReceipt RR 
														ON TT.intLoadHeaderId = RR.intLoadHeaderId
													JOIN tblTRLoadDistributionHeader HH on HH.intLoadHeaderId = TT.intLoadHeaderId 
													JOIN tblTRLoadDistributionDetail HD on HD.intLoadDistributionHeaderId = HH.intLoadDistributionHeaderId 
											WHERE	RR.strOrigin = 'Terminal' 
													AND HH.strDestination = 'Customer' 
													AND RR.intLoadReceiptId = TR.intLoadReceiptId 
													
										)
			,intTaxGroupId				= TR.intTaxGroupId
			,strVendorRefNo				= TR.strBillOfLading
			,strSourceId				= TL.strTransaction
			,strSourceScreenName		= 'Transport Loads'
	FROM	tblTRLoadHeader TL JOIN tblTRLoadReceipt TR 
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

   SELECT TOP 1 @intFreightItemId = intItemForFreightId FROM tblTRCompanyPreference
   SELECT TOP 1 @intSurchargeItemId = intItemId FROM vyuICGetOtherCharges WHERE intOnCostTypeId = @intFreightItemId

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
	) 
   SELECT	[intEntityVendorId]					= RE.intEntityVendorId
			,[strBillOfLadding]					= RE.strBillOfLadding
			,[strReceiptType]					= RE.strReceiptType
			,[intLocationId]					= RE.intLocationId
			,[intShipViaId]						= RE.intShipViaId
			,[intShipFromId]					= RE.intShipFromId
			,[intCurrencyId]  					= RE.intCurrencyId
			,[intChargeId]						= @intFreightItemId
			,[ysnInventoryCost]					= CASE	WHEN (select top 1 strTransaction from tblTRLoadHeader TT
					                                                 join tblTRLoadReceipt RR on TT.intLoadHeaderId = RR.intLoadHeaderId
					                                                 JOIN tblTRLoadDistributionHeader HH on HH.intLoadHeaderId = TT.intLoadHeaderId 
													                 JOIN tblTRLoadDistributionDetail HD on HD.intLoadDistributionHeaderId = HH.intLoadDistributionHeaderId 
					                                                 where RR.strOrigin = 'Terminal' 
					                                                 	and HH.strDestination = 'Customer' 
					                                                 	and RR.intLoadReceiptId = RE.intSourceId
                                                                        ) = Null THEN 1
 										                                                       
												    	WHEN (select top 1 strTransaction from tblTRLoadHeader TT
					                                                 join tblTRLoadReceipt RR on TT.intLoadHeaderId = RR.intLoadHeaderId
					                                                 JOIN tblTRLoadDistributionHeader HH on HH.intLoadHeaderId = TT.intLoadHeaderId 
													                 JOIN tblTRLoadDistributionDetail HD on HD.intLoadDistributionHeaderId = HH.intLoadDistributionHeaderId 
					                                                 where RR.strOrigin = 'Terminal' 
					                                                 	and HH.strDestination = 'Customer' 
					                                                 	and RR.intLoadReceiptId = RE.intSourceId
                                                                        ) != Null THEN 0
														                                   
												END
			,[strCostMethod]					= 'Per Unit'
			,[dblRate]							= RE.dblFreightRate
			,[intCostUOMId]						= (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId =  @intFreightItemId)
			,[intOtherChargeEntityVendorId]		= CASE	WHEN (select top 1 strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
															RE.intEntityVendorId
														WHEN (select top 1 strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
															NULL
														WHEN (select top 1 strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
															RE.intShipViaId
												END
			,[dblAmount]						= 0
			,[strAllocateCostBy]				=  CASE	WHEN (select top 1 strTransaction from tblTRLoadHeader TT
					                                                 join tblTRLoadReceipt RR on TT.intLoadHeaderId = RR.intLoadHeaderId
					                                                 JOIN tblTRLoadDistributionHeader HH on HH.intLoadHeaderId = TT.intLoadHeaderId 
													                 JOIN tblTRLoadDistributionDetail HD on HD.intLoadDistributionHeaderId = HH.intLoadDistributionHeaderId 
					                                                 where RR.strOrigin = 'Terminal' 
					                                                 	and HH.strDestination = 'Customer' 
					                                                 	and RR.intLoadReceiptId = RE.intSourceId
                                                                        ) = Null THEN 'Unit'
												    	WHEN (select top 1 strTransaction from tblTRLoadHeader TT
					                                                 join tblTRLoadReceipt RR on TT.intLoadHeaderId = RR.intLoadHeaderId
					                                                 JOIN tblTRLoadDistributionHeader HH on HH.intLoadHeaderId = TT.intLoadHeaderId 
													                 JOIN tblTRLoadDistributionDetail HD on HD.intLoadDistributionHeaderId = HH.intLoadDistributionHeaderId 
					                                                 where RR.strOrigin = 'Terminal' 
					                                                 	and HH.strDestination = 'Customer' 
					                                                 	and RR.intLoadReceiptId = RE.intSourceId
                                                                        ) != Null THEN Null
														                                   
											    	END
			,[intContractHeaderId]				= RE.intContractHeaderId
			,[intContractDetailId]				= RE.intContractDetailId
			,[ysnAccrue]						= CASE	WHEN (select top 1 strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
															1
														WHEN (select top 1 strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
															0
														WHEN (select top 1 strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
															1
												END
    FROM	@ReceiptStagingTable RE 
	WHERE	RE.dblFreightRate != 0 

	--Fuel Surcharge
	UNION ALL 
	SELECT	[intEntityVendorId]					= RE.intEntityVendorId
			,[strBillOfLadding]					= RE.strBillOfLadding
			,[strReceiptType]					= RE.strReceiptType
			,[intLocationId]					= RE.intLocationId
			,[intShipViaId]						= RE.intShipViaId
			,[intShipFromId]					= RE.intShipFromId
			,[intCurrencyId]  					= RE.intCurrencyId
			,[intChargeId]						= @intSurchargeItemId
			,[ysnInventoryCost]					= CASE WHEN (select top 1 strTransaction from tblTRLoadHeader TT
					                                                 join tblTRLoadReceipt RR on TT.intLoadHeaderId = RR.intLoadHeaderId
					                                                 JOIN tblTRLoadDistributionHeader HH on HH.intLoadHeaderId = TT.intLoadHeaderId 
													                 JOIN tblTRLoadDistributionDetail HD on HD.intLoadDistributionHeaderId = HH.intLoadDistributionHeaderId 
					                                                 where RR.strOrigin = 'Terminal' 
					                                                 	and HH.strDestination = 'Customer' 
					                                                 	and RR.intLoadReceiptId = RE.intSourceId
                                                                         ) = Null THEN 1
												    	WHEN (select top 1 strTransaction from tblTRLoadHeader TT
					                                                 join tblTRLoadReceipt RR on TT.intLoadHeaderId = RR.intLoadHeaderId
					                                                 JOIN tblTRLoadDistributionHeader HH on HH.intLoadHeaderId = TT.intLoadHeaderId 
													                 JOIN tblTRLoadDistributionDetail HD on HD.intLoadDistributionHeaderId = HH.intLoadDistributionHeaderId 
					                                                 where RR.strOrigin = 'Terminal' 
					                                                 	and HH.strDestination = 'Customer' 
					                                                 	and RR.intLoadReceiptId = RE.intSourceId
                                                                        ) != Null THEN 0
												END
			,[strCostMethod]					= 'Percentage'
			,[dblRate]							= RE.dblSurcharge
			,[intCostUOMId]						= (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId =  @intSurchargeItemId)
			,[intOtherChargeEntityVendorId]		= CASE	WHEN (SELECT top 1 strFreightBilledBy FROM tblSMShipVia SM WHERE SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
															RE.intEntityVendorId
														WHEN (SELECT top 1 strFreightBilledBy FROM tblSMShipVia SM WHERE SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
															NULL
														WHEN (SELECT top 1 strFreightBilledBy FROM tblSMShipVia SM WHERE SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
															RE.intShipViaId
												END
			,[dblAmount]						= 0
			,[strAllocateCostBy]				= CASE	WHEN (select top 1 strTransaction from tblTRLoadHeader TT
					                                                 join tblTRLoadReceipt RR on TT.intLoadHeaderId = RR.intLoadHeaderId
					                                                 JOIN tblTRLoadDistributionHeader HH on HH.intLoadHeaderId = TT.intLoadHeaderId 
													                 JOIN tblTRLoadDistributionDetail HD on HD.intLoadDistributionHeaderId = HH.intLoadDistributionHeaderId 
					                                                 where RR.strOrigin = 'Terminal' 
					                                                 	and HH.strDestination = 'Customer' 
					                                                 	and RR.intLoadReceiptId = RE.intSourceId
                                                                        ) = Null THEN 'Unit'
												    	WHEN (select top 1 strTransaction from tblTRLoadHeader TT
					                                                 join tblTRLoadReceipt RR on TT.intLoadHeaderId = RR.intLoadHeaderId
					                                                 JOIN tblTRLoadDistributionHeader HH on HH.intLoadHeaderId = TT.intLoadHeaderId 
													                 JOIN tblTRLoadDistributionDetail HD on HD.intLoadDistributionHeaderId = HH.intLoadDistributionHeaderId 
					                                                 where RR.strOrigin = 'Terminal' 
					                                                 	and HH.strDestination = 'Customer' 
					                                                 	and RR.intLoadReceiptId = RE.intSourceId
                                                                        ) != Null THEN Null
														                                   
											    	END
			,[intContractHeaderId]				= RE.intContractHeaderId
			,[intContractDetailId]				= RE.intContractDetailId
			,[ysnAccrue]						= CASE	WHEN (select top 1 strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
															1
														WHEN (select top 1 strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
															0
														WHEN (select top 1 strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
															1
												END
    FROM	@ReceiptStagingTable RE 
	WHERE	RE.dblSurcharge != 0 

	-- No Records to process so exit
    SELECT @total = COUNT(*) FROM @ReceiptStagingTable;
    IF (@total = 0)
	   RETURN;

	-- Create the temp table if it does not exists. 
	--IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
	--BEGIN 
	--	CREATE TABLE #tmpAddItemReceiptResult (
	--		intSourceId INT
	--		,intInventoryReceiptId INT
	--	)
	--END 

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

		SELECT	TOP 1 @intEntityId = [intEntityUserSecurityId] 
		FROM	dbo.tblSMUserSecurity 
		WHERE	[intEntityUserSecurityId] = @intUserId
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