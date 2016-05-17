CREATE PROCEDURE [dbo].[uspSCProcessScaleTransferIn]
	@intTicketId AS INT
	,@intMatchTicketId AS INT
	,@strInOutIndicator AS NVARCHAR(1)
	,@intUserId AS INT
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
			--,intTaxGroupId
			,strVendorRefNo
			,strSourceId
			,strSourceScreenName
	)	
	SELECT 
			strReceiptType				=	CASE	WHEN SC.intContractId IS NULL THEN 'Direct'
													WHEN SC.intContractId IS NOT NULL THEN 'Purchase Contract'
											END
			,intEntityVendorId			= @intUserId
			,intShipFromId				= (SELECT SS.intLocationId from tblSCTicket as ST JOIN tblSCScaleSetup as SS
											ON ST.intScaleSetupId = SS.intScaleSetupId
											WHERE ST.intMatchTicketId = @intMatchTicketId)
			,intLocationId				= (select top 1 intLocationId from tblSCScaleSetup where intScaleSetupId = SC.intScaleSetupId)
			,intItemId					= SC.intItemId
			,intItemLocationId			= (select top 1 intLocationId from tblSCScaleSetup where intScaleSetupId = SC.intScaleSetupId)
			,intItemUOMId				=	CASE	
												WHEN SC.intContractId is NULL  
													THEN (SELECT TOP 1 
															IU.intItemUOMId											
															FROM dbo.tblICItemUOM IU 
															WHERE	IU.intItemId = SC.intItemId and IU.ysnStockUnit = 1)
												WHEN SC.intContractId is NOT NULL 
													THEN	(select intItemUOMId from vyuCTContractDetailView CT where CT.intContractDetailId = SC.intContractId)
											END-- Need to add the Gallons UOM from Company Preference	   
			,strBillOfLadding			= NULL
			,intContractHeaderId		= (select top 1 intContractHeaderId from tblCTContractDetail where intContractDetailId = SC.intContractId)
			,intContractDetailId		= SC.intContractId
			,dtmDate					= SC.dtmTicketDateTime
			,intShipViaId				= SC.intFreightCarrierId
			,dblQty						= SC.dblNetUnits
			,dblCost					= SC.dblUnitPrice
			,intCurrencyId				= (
											SELECT	TOP 1 
													CP.intDefaultCurrencyId		
											FROM	dbo.tblSMCompanyPreference CP
											WHERE	CP.intCompanyPreferenceId = 1 												
										) -- USD default from company Preference 
			,dblExchangeRate			= 1 -- Need to check this
			,intLotId					= NULL --No LOTS from scale
			,intSubLocationId			= SC.intSubLocationId
			,intStorageLocationId		= SC.intStorageLocationId
			,ysnIsStorage				= 0
			,dblFreightRate				= SC.dblFreightRate
			,intSourceId				= SC.intTicketId
			,intSourceType		 		= 1 -- Source type for scale is 1 
			,dblGross					= SC.dblGrossUnits
			,dblNet						= SC.dblNetUnits
			,intInventoryReceiptId		= SC.intInventoryReceiptId
			,dblSurcharge				= 0
			,ysnFreightInPrice			= NULL
			,strActualCostId			= NULL
			--,intTaxGroupId				= NULL
			,strVendorRefNo				= NULL
			,strSourceId				= SC.intTicketId
			,strSourceScreenName		= 'Scale Ticket'
	FROM	tblSCTicket SC
	WHERE	SC.intTicketId = @intTicketId 
			AND (SC.dblNetUnits != 0 or SC.dblFreightRate != 0);

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
			,[ysnInventoryCost]					= 0
			,[strCostMethod]					= 'Per Unit'
			,[dblRate]							= RE.dblFreightRate
			,[intCostUOMId]						= (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId =  @intFreightItemId)
			,[intOtherChargeEntityVendorId]		= CASE	WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
															RE.intEntityVendorId
														WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
															NULL
														WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
															RE.intShipViaId
												END
			,[dblAmount]						= 0
			,[strAllocateCostBy]				=  NULL
			,[intContractHeaderId]				= RE.intContractHeaderId
			,[intContractDetailId]				= RE.intContractDetailId
			,[ysnAccrue]						= CASE	WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
															1
														WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
															0
														WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
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
			,[ysnInventoryCost]					= NULL
			,[strCostMethod]					= 'Percentage'
			,[dblRate]							= RE.dblSurcharge
			,[intCostUOMId]						= (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId =  @intSurchargeItemId)
			,[intOtherChargeEntityVendorId]		= CASE	WHEN (SELECT strFreightBilledBy FROM tblSMShipVia SM WHERE SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
															RE.intEntityVendorId
														WHEN (SELECT strFreightBilledBy FROM tblSMShipVia SM WHERE SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
															NULL
														WHEN (SELECT strFreightBilledBy FROM tblSMShipVia SM WHERE SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
															RE.intShipViaId
												END
			,[dblAmount]						= 0
			,[strAllocateCostBy]				= NULL
			,[intContractHeaderId]				= RE.intContractHeaderId
			,[intContractDetailId]				= RE.intContractDetailId
			,[ysnAccrue]						= CASE	WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
															1
														WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
															0
														WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
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
	UPDATE	SC
	SET		SC.intInventoryReceiptId = addResult.intInventoryReceiptId
	FROM	dbo.tblSCTicket SC INNER JOIN #tmpAddItemReceiptResult addResult
				ON SC.intTicketId = addResult.intSourceId

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
		BEGIN
		  EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intEntityId;			
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