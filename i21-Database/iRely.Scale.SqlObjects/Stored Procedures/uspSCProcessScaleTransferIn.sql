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
		@ReceiptItemLotStagingTable AS ReceiptItemLotStagingTable,
		@OtherCharges AS ReceiptOtherChargesTableType, 
        @total as int,
		@intSurchargeItemId as int,
		@intFreightItemId as int,
		@intProcessingLocationId as int,
		@intItemUOMId as int,
		@intHaulerId AS INT,
		@ysnAccrue AS BIT,
		@ysnPrice AS BIT,
		@intLotType AS INT,
		@intItemId AS INT;

	SELECT TOP 1 @intProcessingLocationId = intProcessingLocationId from tblSCTicket where intTicketId = @intMatchTicketId

	SELECT @intFreightItemId = SCSetup.intFreightItemId
		, @intHaulerId = SCTicket.intHaulerId
		, @intSurchargeItemId = SCSetup.intDefaultFeeItemId
		, @intItemUOMId = SCTicket.intItemUOMIdTo
		, @intItemId = SCTicket.intItemId
	FROM tblSCScaleSetup SCSetup 
	LEFT JOIN tblSCTicket SCTicket ON SCSetup.intScaleSetupId = SCTicket.intScaleSetupId 
	WHERE SCTicket.intTicketId = @intTicketId

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
			-- Header
			strReceiptType
			,intEntityVendorId
			,intTransferorId
			,strBillOfLadding
			,intCurrencyId
			,intLocationId
			,intShipFromId
			,intShipViaId
			,intDiscountSchedule
				
			-- Detail				
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,intGrossNetUOMId
			,intCostUOMId				
			,intContractHeaderId
			,intContractDetailId
			,dtmDate				
			,dblQty
			,dblCost				
			,dblExchangeRate
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,ysnIsStorage
			,dblFreightRate
			--,dblGross
			--,dblNet
			,intSourceId
			,intSourceType	
			,strSourceScreenName
	)	
	SELECT 
			strReceiptType				= 'Transfer Order'
			,intEntityVendorId			= NULL
			,intTransferorId			= SC.intProcessingLocationId
			,strBillOfLadding			= NULL
			,intCurrencyId				= SC.intCurrencyId
			,intLocationId				= @intProcessingLocationId
			,intShipFromId				= SC.intProcessingLocationId
			,intShipViaId				= SC.intFreightCarrierId
			,intDiscountSchedule		= SC.intDiscountId

			--Detail
			,intItemId					= SC.intItemId
			,intItemLocationId			= SC.intProcessingLocationId
			,intItemUOMId				= SC.intItemUOMIdTo
			,intGrossNetUOMId			= NULL
			,intCostUOMId				= SC.intItemUOMIdTo
			,intContractHeaderId		= NULL
			,intContractDetailId		= NULL
			,dtmDate					= SC.dtmTicketDateTime
			,dblQty						= SC.dblNetUnits
			,dblCost					= SC.dblUnitPrice + SC.dblUnitBasis
			,dblExchangeRate			= 1 -- Need to check this
			,intLotId					= SC.intLotId
			,intSubLocationId			= SC.intSubLocationId
			,intStorageLocationId		= SC.intStorageLocationId
			,ysnIsStorage				= 0
			,dblFreightRate				= SC.dblFreightRate
			--,dblGross					= SC.dblGrossWeight
			--,dblNet						= SC.dblGrossWeight - SC.dblTareWeight
			,intSourceId				= SC.intTicketId
			,intSourceType		 		= 1 -- Source type for scale is 1 
			,strSourceScreenName		= 'Scale Ticket'
	FROM	tblSCTicket SC 
	WHERE	SC.intTicketId = @intTicketId AND (SC.dblNetUnits != 0 or SC.dblFreightRate != 0)

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
		,[intCostCurrencyId]  	
		,[intChargeId]
		,[intForexRateTypeId]
		,[dblForexRate]	 
		,[ysnInventoryCost] 
		,[strCostMethod] 
		,[dblRate] 
		,[intCostUOMId] 
		,[intOtherChargeEntityVendorId] 
		,[dblAmount] 
		,[intContractHeaderId]
		,[intContractDetailId] 
		,[ysnAccrue]
		,[ysnPrice]
		,[strChargesLink]
	) 
	SELECT	
		[intEntityVendorId]					= RE.intEntityVendorId
		,[strBillOfLadding]					= RE.strBillOfLadding
		,[strReceiptType]					= RE.strReceiptType
		,[intLocationId]					= RE.intLocationId
		,[intShipViaId]						= RE.intShipViaId
		,[intShipFromId]					= RE.intShipFromId
		,[intCurrencyId]  					= RE.intCurrencyId
		,[intCostCurrencyId]				= RE.intCurrencyId
		,[intChargeId]						= @intFreightItemId
		,[intForexRateTypeId]				= RE.intForexRateTypeId
		,[dblForexRate]						= RE.dblForexRate
		,[ysnInventoryCost]					= CASE WHEN ISNULL(@ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
		,[strCostMethod]					= IC.strCostMethod
		,[dblRate]							= CASE
												WHEN IC.strCostMethod = 'Amount' THEN 0
												ELSE RE.dblFreightRate
											END
		,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, RE.intItemUOMId)
		,[intOtherChargeEntityVendorId]		= CASE
												WHEN @intHaulerId = 0 THEN NULL
												WHEN @intHaulerId != 0 THEN @intHaulerId
											END
		,[dblAmount]						=  CASE
												WHEN IC.strCostMethod = 'Amount' THEN ROUND (((RE.dblQty / SC.dblNetUnits) * SC.dblFreightRate), 2)
												ELSE 0
											END
		,[intContractHeaderId]				= NULL
		,[intContractDetailId]				= NULL
		,[ysnAccrue]						= @ysnAccrue
		,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN @ysnPrice ELSE 0 END
		,[strChargesLink]					= RE.strChargesLink
		FROM @ReceiptStagingTable RE 
		LEFT JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
		LEFT JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
		LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
		WHERE RE.dblFreightRate != 0

	----Fuel Surcharge
	--UNION ALL 
	--SELECT	[intEntityVendorId]					= NULL
	--		,[strBillOfLadding]					= RE.strBillOfLadding
	--		,[strReceiptType]					= RE.strReceiptType
	--		,[intLocationId]					= RE.intLocationId
	--		,[intShipViaId]						= RE.intShipViaId
	--		,[intShipFromId]					= RE.intShipFromId
	--		,[intCurrencyId]  					= RE.intCurrencyId
	--		,[intChargeId]						= @intSurchargeItemId
	--		,[ysnInventoryCost]					= NULL
	--		,[strCostMethod]					= 'Per Unit'
	--		,[dblRate]							= RE.dblSurcharge
	--		,[intCostUOMId]						= (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId =  @intSurchargeItemId)
	--		,[intOtherChargeEntityVendorId]		= @intHaulerId
	--		,[dblAmount]						= 0
	--		,[strAllocateCostBy]				= NULL
	--		,[intContractHeaderId]				= RE.intContractHeaderId
	--		,[intContractDetailId]				= RE.intContractDetailId
	--		,[ysnAccrue]						= 1
 --   FROM	@ReceiptStagingTable RE 
	--WHERE	RE.dblSurcharge != 0 

	-- No Records to process so exit
    SELECT @total = COUNT(*) FROM @ReceiptStagingTable;
    IF (@total = 0)
	   RETURN;
	
	SELECT @intLotType = dbo.fnGetItemLotType(@intItemId)
	IF @intLotType != 0
	BEGIN 
		INSERT INTO @ReceiptItemLotStagingTable(
			[strReceiptType]
			,[intItemId]
			,[intLotId]
			,[strLotNumber]
			,[intLocationId]
			,[intShipFromId]
			,[intShipViaId]	
			,[intSubLocationId]
			,[intStorageLocationId] 
			,[intCurrencyId]
			,[intItemUnitMeasureId]
			,[dblQuantity]
			,[dblGrossWeight]
			,[dblTareWeight]
			,[dblCost]
			,[intEntityVendorId]
			,[dtmManufacturedDate]
			,[strBillOfLadding]
			,[intSourceType]
		)
		SELECT 
			[strReceiptType]		= RE.strReceiptType
			,[intItemId]			= RE.intItemId
			,[intLotId]				= RE.intLotId
			,[strLotNumber]			= SC.strLotNumber
			,[intLocationId]		= RE.intLocationId
			,[intShipFromId]		= RE.intShipFromId
			,[intShipViaId]			= RE.intShipViaId
			,[intSubLocationId]		= RE.intSubLocationId
			,[intStorageLocationId] = RE.intStorageLocationId
			,[intCurrencyId]		= RE.intCurrencyId
			,[intItemUnitMeasureId] = CASE
										WHEN IC.ysnLotWeightsRequired = 1 THEN SC.intItemUOMIdFrom
										ELSE RE.intItemUOMId
									END
			,[dblQuantity]			= RE.dblQty
			,[dblGrossWeight]		= RE.dblQty
			,[dblTareWeight]		= 0
			,[dblCost]				= RE.dblCost
			,[intEntityVendorId]	= RE.intEntityVendorId
			,[dtmManufacturedDate]	= RE.dtmDate
			,[strBillOfLadding]		= ''
			,[intSourceType]		= RE.intSourceType
			FROM @ReceiptStagingTable RE 
			INNER JOIN tblSCTicket SC ON SC.intTicketId = RE.intSourceId
			INNER JOIN tblICItem IC ON IC.intItemId = RE.intItemId
	END

    EXEC dbo.uspICAddItemReceipt 
			@ReceiptStagingTable
			,@OtherCharges
			,@intUserId
			,@ReceiptItemLotStagingTable;

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

		SELECT	TOP 1 @intEntityId = [intEntityId] 
		FROM	dbo.tblSMUserSecurity 
		WHERE	[intEntityId] = @intUserId
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