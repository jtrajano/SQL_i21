CREATE PROCEDURE [dbo].[uspSCProcessScaleTransferIn]
	@intTicketId AS INT
	,@intMatchTicketId AS INT
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

	SELECT  @intFreightItemId = SCSetup.intFreightItemId
		, @intHaulerId = SCTicket.intHaulerId
		, @intSurchargeItemId = SCSetup.intDefaultFeeItemId
		, @intItemUOMId = SCTicket.intItemUOMIdTo
		, @intItemId = SCTicket.intItemId
	FROM tblSCScaleSetup SCSetup 
	LEFT JOIN tblSCTicket SCTicket ON SCSetup.intScaleSetupId = SCTicket.intScaleSetupId 
	WHERE SCTicket.intTicketId = @intTicketId

	SELECT @intLotType = dbo.fnGetItemLotType(@intItemId)

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
			,dblGross
			,dblNet
			,intSourceId
			,intTicketId
			,intInventoryTransferId
			,intInventoryTransferDetailId
			,intSourceType	
			,strSourceScreenName
			,intSort
			,intShipFromEntityId
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
			,intGrossNetUOMId			= CASE
											WHEN IC.ysnLotWeightsRequired = 1 AND @intLotType != 0 THEN SC.intItemUOMIdFrom
											ELSE SC.intItemUOMIdTo
										END
			,intCostUOMId				= SC.intItemUOMIdTo
			,intContractHeaderId		= NULL
			,intContractDetailId		= NULL
			,dtmDate					= SC.dtmTicketDateTime
			,dblQty						= abs(ICTran.dblQty) --case when abs(ICTran.dblQty) < SC.dblNetUnits then abs(ICTran.dblQty) else SC.dblNetUnits end  --- SCMatch.dblNetUnits --
			,dblCost					= ICTran.dblCost + ( (case when abs(ICTran.dblQty) > SC.dblNetUnits then 1 else -1 end)
																*
																((ICTran.dblCost) * abs(((SC.dblNetUnits - SCMatch.dblNetUnits)/SC.dblNetUnits))) 
											)
											--ICTran.dblCost
			,dblExchangeRate			= 1 -- Need to check this
			,intLotId					= SC.intLotId
			,intSubLocationId			= SC.intSubLocationId
			,intStorageLocationId		= SC.intStorageLocationId
			,ysnIsStorage				= 0
			,dblFreightRate				= SC.dblFreightRate
			,dblGross					=  CASE
											WHEN IC.ysnLotWeightsRequired = 1 AND @intLotType != 0 THEN (SCMatch.dblGrossWeight - SCMatch.dblTareWeight)
											ELSE SCMatch.dblGrossUnits
										END
			,dblNet						= CASE
											WHEN IC.ysnLotWeightsRequired = 1 AND @intLotType != 0 THEN dbo.fnCalculateQtyBetweenUOM(SCMatch.intItemUOMIdTo, SCMatch.intItemUOMIdFrom, SCMatch.dblNetUnits)
											ELSE SCMatch.dblNetUnits 
										END
			,intSourceId                    = SC.intTicketId
            ,intTicketId                    = SC.intTicketId
            ,intInventoryTransferId         = ICTD.intInventoryTransferId
            ,intInventoryTransferDetailId   = ICTD.intInventoryTransferDetailId
            ,intSourceType                  = 1 -- Source type for scale is 1 
            ,strSourceScreenName            = 'Scale Ticket'
			,intSort						= RANK() OVER( ORDER BY ICTran.dblQty ASC)--RANK() OVER (ORDER BY ICTran.dblQty)
			,intShipFromEntityId			= SC.intEntityId
	FROM	tblSCTicket SC 
	INNER JOIN tblICItem IC ON IC.intItemId = SC.intItemId
	INNER JOIN tblICCommodity ICC ON ICC.intCommodityId = IC.intCommodityId
	INNER JOIN tblSCTicket SCMatch ON SCMatch.intTicketId = SC.intMatchTicketId
	LEFT JOIN tblICInventoryTransferDetail ICTD ON ICTD.intInventoryTransferId = SCMatch.intInventoryTransferId
	LEFT JOIN tblICInventoryTransaction ICTran ON ICTran.intTransactionId = ICTD.intInventoryTransferId AND ICTran.intTransactionDetailId = ICTD.intInventoryTransferDetailId 
	WHERE SC.intTicketId = @intTicketId AND (SC.dblNetUnits != 0 or SC.dblFreightRate != 0) AND ICTran.dblQty >= SC.dblNetUnits AND ICTran.intTransactionTypeId = 13
	--FROM	tblSCTicket SC 
	--INNER JOIN tblICItem IC ON IC.intItemId = SC.intItemId
	--INNER JOIN tblSCTicket SCMatch ON SCMatch.intTicketId = SC.intMatchTicketId
	--LEFT JOIN tblICInventoryTransferDetail ICTD ON ICTD.intInventoryTransferId = SCMatch.intInventoryTransferId
	--LEFT JOIN tblICInventoryTransaction ICTran ON ICTran.intTransactionId = ICTD.intInventoryTransferId AND ICTran.intTransactionDetailId = ICTD.intInventoryTransferDetailId 
	--WHERE SC.intTicketId = @intTicketId AND (SC.dblNetUnits != 0 or SC.dblFreightRate != 0) AND ICTran.dblQty >= SC.dblNetUnits AND ICTran.intTransactionTypeId = 13


	/*
	IF((SELECT TOP 1 intAdjustInventoryTransfer FROM tblICItem ICI 
		INNER JOIN tblICCommodity ICC ON ICC.intCommodityId = ICI.intCommodityId
		INNER JOIN tblSCTicket SC ON SC.intItemId = ICI.intItemId WHERE intTicketId = @intTicketId) = 1)
	BEGIN
		-- Validate if multiple cost bucket
			DECLARE @_qtyToAdjust AS DECIMAL(18,6)
			SELECT @_qtyToAdjust = T.dblNetUnits - MT.dblNetUnits
			FROM tblSCTicket T 
			INNER JOIN tblSCTicket MT ON T.intMatchTicketId = MT.intTicketId
			INNER JOIN tblICItem ICI
				ON ICI.intItemId = T.intItemId
			INNER JOIN tblICCommodity ICC
				ON ICC.intCommodityId = ICI.intCommodityId
			WHERE T.intTicketId = @intTicketId and ICC.intAdjustInventoryTransfer = 1;

			--1.) Check if Line new quantity is less than the transaction line quantity (for multiple cost bucket)
			IF(@_qtyToAdjust < 0 and (SELECT COUNT(1) FROM @ReceiptStagingTable) > 1)
			BEGIN 
				DECLARE @_remainingQty AS DECIMAL(18,6)
				DECLARE @_dblQty AS DECIMAL(18,6)
				DECLARE @_intId INT
				DECLARE a CURSOR FOR
				SELECT dblQty,intId FROM @ReceiptStagingTable ORDER BY intId DESC
				OPEN a
				FETCH NEXT FROM a
				INTO @_dblQty,@_intId

				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF(@_qtyToAdjust < 0 AND ((@_qtyToAdjust) * -1 ) > @_dblQty)
						BEGIN
							SET @_qtyToAdjust = @_qtyToAdjust + @_dblQty
							DELETE FROM @ReceiptStagingTable WHERE intId = @_intId
						END
				FETCH NEXT FROM a
				INTO @_dblQty,@_intId
				END
				CLOSE a;
				DEALLOCATE a;
			END;


			WITH CTE as
			(SELECT TOP 1 * FROM @ReceiptStagingTable ORDER BY intId DESC)
			UPDATE CTE
			SET dblQty = CASE WHEN @_qtyToAdjust < 0 THEN dblQty - (@_qtyToAdjust *-1) ELSE dblQty + @_qtyToAdjust END;			
	END

	*/
	declare @dblUnitDifference numeric(38, 20)
	select @dblUnitDifference = sum(dblNetUnits) from (
		SELECT SC.dblNetUnits FROM tblSCTicket SC where SC.intTicketId = @intTicketId
		union all
		SELECT -SC.dblNetUnits FROM tblSCTicket SC where SC.intTicketId = @intMatchTicketId
	) a

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
		,[intChargeId]						= SCS.intFreightItemId
		,[intForexRateTypeId]				= RE.intForexRateTypeId
		,[dblForexRate]						= RE.dblForexRate
		,[ysnInventoryCost]					= CASE WHEN ISNULL(@ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
		,[strCostMethod]					= IC.strCostMethod
		,[dblRate]							= CASE
												WHEN IC.strCostMethod = 'Amount' THEN 0
												ELSE RE.dblFreightRate
											END
		,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(SCS.intFreightItemId, RE.intItemUOMId)
		,[intOtherChargeEntityVendorId]		= SC.intHaulerId
		,[dblAmount]						=  CASE
												WHEN IC.strCostMethod = 'Amount' THEN ROUND (((RE.dblQty / SC.dblNetUnits) * SC.dblFreightRate), 2)
												ELSE 0
											END
		,[intContractHeaderId]				= NULL
		,[intContractDetailId]				= NULL
		,[ysnAccrue]						= CASE WHEN ISNULL(SC.intHaulerId , 0) > 0 THEN 1 ELSE 0 END
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
			,[strLotNumber]			= CASE
										WHEN SC.strLotNumber = '' THEN NULL
										ELSE SC.strLotNumber
									END
			,[intLocationId]		= RE.intLocationId
			,[intShipFromId]		= RE.intShipFromId
			,[intShipViaId]			= RE.intShipViaId
			,[intSubLocationId]		= RE.intSubLocationId
			,[intStorageLocationId] = RE.intStorageLocationId
			,[intCurrencyId]		= RE.intCurrencyId
			,[intItemUnitMeasureId] = RE.intItemUOMId
			,[dblQuantity]			= RE.dblQty
			,[dblGrossWeight]		= RE.dblGross
			,[dblTareWeight]		= (RE.dblGross - RE.dblNet)
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

		EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intUserId;			

		UPDATE	SC
		SET		SC.intLotId = ICLot.intLotId, SC.strLotNumber = ICLot.strLotNumber
		FROM	dbo.tblSCTicket SC 
		INNER JOIN tblICInventoryReceiptItem IRI ON SC.intTicketId = IRI.intSourceId
		INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND intSourceType = 1
		INNER JOIN tblICInventoryReceiptItemLot ICLot ON ICLot.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
		WHERE SC.intTicketId = @intTicketId	

		
		if @dblUnitDifference <> 0
		begin
			declare @intItemIdDifference		int
				,@dtmDateDifference datetime
				,@intLocationIdDifference int
				,@intSubLocationIdDifference int
				,@intStorageLocationIdDifference int
				,@strLotNumberDifference NVARCHAR(50)	
				,@intOwnershipTypeDifference int
				,@intItemUOMIdDifference int
				,@intInventoryAdjustmentIdDifference int
				,@strTicketNumberIn nvarchar(40)
				,@strTicketNumberOut nvarchar(40)
			select 
				@intItemIdDifference = intItemId,				
				@dtmDateDifference = dtmTicketDateTime,
				@intLocationIdDifference = intProcessingLocationId,
				@intSubLocationIdDifference = intSubLocationId,
				@intStorageLocationIdDifference = intStorageLocationId,
				@strLotNumberDifference = 'e',
				@intOwnershipTypeDifference = 1,
				@intItemUOMIdDifference = intItemUOMIdTo,
				@strTicketNumberOut	= strTicketNumber
				from tblSCTicket where intTicketId = @intMatchTicketId

			select @strTicketNumberIn = strTicketNumber from tblSCTicket where intTicketId = @intTicketId
			declare @message nvarchar(200)
			set @message = 'Inventory adjustment for Transfer Out-' +  @strTicketNumberOut + ' and Transfer In-' + @strTicketNumberIn 
			EXEC [dbo].[uspICInventoryAdjustment_CreatePostQtyChange]
				@intItemIdDifference
				,@dtmDateDifference
				,@intLocationIdDifference
				,@intSubLocationIdDifference
				,@intStorageLocationIdDifference
				,@intStorageLocationIdDifference
				,@intOwnershipTypeDifference
				,@dblUnitDifference 
				,0
				,@intItemUOMId
				,@ReceiptId
				,52
				,@intUserId
				,@intInventoryAdjustmentIdDifference OUTPUT
				,@message;


				update tblSCTicket set intInventoryAdjustmentId = @intInventoryAdjustmentIdDifference where intTicketId = @intTicketId 
				
		end
		

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