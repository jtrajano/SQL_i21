CREATE PROCEDURE [dbo].[uspSCProcessToItemReceipt]
	 @intSourceTransactionId AS INT
	,@strSourceType AS NVARCHAR(100) 
	,@intUserId AS INT
	,@dblNetUnits AS DECIMAL (38,20)
	,@dblCost AS DECIMAL (9,5)
	,@intEntityId AS INT
	,@intContractId AS INT
	,@strDistributionOption AS NVARCHAR(3)
	,@intStorageScheduleId AS INT = NULL
	,@InventoryReceiptId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

-- Constant variables for the source type
DECLARE @SourceType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
DECLARE @SourceType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
DECLARE @SourceType_Direct AS NVARCHAR(100) = 'Direct'
DECLARE @strTransactionId NVARCHAR(40) = NULL
DECLARE @strDummyDistributionOption AS NVARCHAR(3) = NULL

DECLARE @ItemsForItemReceipt AS ItemCostingTableType
		,@voucherItems AS VoucherDetailReceipt 
		,@voucherOtherCharges AS VoucherDetailReceiptCharge
DECLARE @intTicketId AS INT = @intSourceTransactionId
DECLARE @dblRemainingUnits AS NUMERIC(38, 20)
DECLARE @dblRemainingQuantity AS NUMERIC(38, 20)
DECLARE @LineItems AS ScaleTransactionTableType
DECLARE @intDirectType AS INT = 3
DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT
DECLARE @strReceiptType AS NVARCHAR(100)
DECLARE @intLoadId INT
DECLARE @dblTicketFreightRate AS DECIMAL (9, 5)
DECLARE @intScaleStationId AS INT
DECLARE @intFreightItemId AS INT
DECLARE @intFreightVendorId AS INT
DECLARE @ysnDeductFreightFarmer AS BIT
DECLARE @intLoadContractId AS INT
DECLARE @dblLoadScheduledUnits AS NUMERIC(12,4)
DECLARE @total AS INT
DECLARE @ysnDPStorage AS BIT
DECLARE @strLotTracking AS NVARCHAR(100)
DECLARE @intInventoryReceiptItemId AS INT
		,@intOrderId INT
		,@intOwnershipType INT
		,@intPricingTypeId INT
		,@intBillId AS INT
		,@successfulCount AS INT
		,@invalidCount AS INT
		,@success AS INT
		,@batchIdUsed AS INT
		,@recapId AS INT
		,@dblTotal AS DECIMAL(18,6)
		,@returnValue AS BIT
		,@requireApproval AS BIT
		,@intLocationId AS INT
		,@intShipTo AS INT
		,@intShipFrom AS INT
		,@intCurrencyId AS INT;

BEGIN
    SELECT TOP 1 @intLoadId = ST.intLoadId, @dblTicketFreightRate = ST.dblFreightRate, @intScaleStationId = ST.intScaleSetupId,
	@ysnDeductFreightFarmer = ST.ysnFarmerPaysFreight, @intLocationId = ST.intProcessingLocationId
	FROM dbo.tblSCTicket ST WHERE
	ST.intTicketId = @intTicketId
END

BEGIN
	SELECT	@ysnDPStorage = ST.ysnDPOwnedType 
	FROM dbo.tblGRStorageType ST WHERE 
	ST.strStorageTypeCode = @strDistributionOption
END

DECLARE @ErrMsg              NVARCHAR(MAX),
        @dblBalance          NUMERIC(38, 20),                    
        @intItemId           INT,
        @dblNewBalance       NUMERIC(38, 20),
        @strInOutFlag        NVARCHAR(4),
        @dblQuantity         NUMERIC(38, 20),
        @strAdjustmentNo     NVARCHAR(50)

BEGIN TRY
		IF @strDistributionOption = 'LOD'
		BEGIN
			IF @intLoadId IS NULL
			BEGIN 
				RAISERROR('Unable to find load details. Try Again.', 11, 1);
				GOTO _Exit
			END
			ELSE
			BEGIN
				SELECT @intLoadContractId = LGLD.intPContractDetailId, @dblLoadScheduledUnits = LGLD.dblQuantity FROM tblLGLoad LGL
				INNER JOIN tblLGLoadDetail LGLD
				ON LGL.intLoadId = LGLD.intLoadId 
				WHERE LGL.intLoadId = @intLoadId
			END
			IF @intLoadContractId IS NULL
			BEGIN 
				RAISERROR('Unable to find load contract details. Try Again.', 11, 1);
				GOTO _Exit
			END
			BEGIN
			SET @dblLoadScheduledUnits = @dblLoadScheduledUnits * -1;
				EXEC uspCTUpdateScheduleQuantity @intLoadContractId, @dblLoadScheduledUnits, @intUserId, @intTicketId, 'Scale'
			END
			BEGIN
				INSERT INTO [dbo].[tblSCTicketCost]
						   ([intTicketId]
						   ,[intConcurrencyId]
						   ,[intItemId]
						   ,[intEntityVendorId]
						   ,[strCostMethod]
						   ,[dblRate]
						   ,[intItemUOMId]
						   ,[ysnAccrue]
						   ,[ysnMTM]
						   ,[ysnPrice])
				SELECT	@intTicketId,
						1, 
						LD.intItemId,
						LD.intVendorId,
						LD.strCostMethod,
						LD.dblRate,
						LD.intItemUOMId,
						LD.ysnAccrue,
						LD.ysnMTM,
						LD.ysnPrice
				FROM	tblLGLoadCost LD WHERE LD.intLoadId = @intLoadId
			END
		END
		IF @strDistributionOption = 'CNT'
		BEGIN
		INSERT INTO [dbo].[tblSCTicketCost]
				   ([intTicketId]
				   ,[intConcurrencyId]
				   ,[intItemId]
				   ,[intEntityVendorId]
				   ,[strCostMethod]
				   ,[dblRate]
				   ,[intItemUOMId]
				   ,[ysnAccrue]
				   ,[ysnMTM]
				   ,[ysnPrice])
		SELECT	@intTicketId,
				1, 
				CC.intItemId,
				CC.intVendorId,
				CC.strCostMethod,
				CC.dblRate,
				CC.intItemUOMId,
				CC.ysnAccrue,
				CC.ysnMTM,
				CC.ysnPrice
		FROM	tblCTContractCost CC WHERE CC.intContractDetailId = @intContractId
		END
		IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
		BEGIN
			SET @strReceiptType = 'Purchase Contract'
		END
		--ELSE IF @ysnDPStorage = 1
  --      BEGIN
  --          SET @strReceiptType = 'Delayed Price'
  --      END
		ELSE
		BEGIN
			SET @strReceiptType = 'Direct'
		END
		BEGIN 
			SELECT	@intTicketUOM = UOM.intUnitMeasureId, @intItemId = SC.intItemId
			FROM	dbo.tblSCTicket SC	        
					--JOIN dbo.tblICCommodityUnitMeasure UOM On SC.intCommodityId  = UOM.intCommodityId
					JOIN dbo.tblICItemUOM UOM ON SC.intItemId = UOM.intItemId
			WHERE	SC.intTicketId = @intTicketId AND UOM.ysnStockUnit = 1		
		END

		BEGIN 
			SELECT	@intTicketItemUOMId = UM.intItemUOMId, @intLoadId = SC.intLoadId
				FROM	dbo.tblICItemUOM UM	
				  JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
			WHERE	UM.ysnStockUnit = 1 AND SC.intTicketId = @intTicketId
		END

	IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
		BEGIN
			INSERT INTO @LineItems (
			intContractDetailId,
			dblUnitsDistributed,
			dblUnitsRemaining,
			dblCost)
			EXEC dbo.uspCTUpdationFromTicketDistribution 
			 @intTicketId
			,@intEntityId
			,@dblNetUnits
			,@intContractId
			,@intUserId
			,0
			IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
			BEGIN
				DECLARE @intLoopContractId INT;
				DECLARE @dblLoopContractUnits NUMERIC(38,20);
				DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
				FOR
				SELECT intContractDetailId, dblUnitsDistributed
				FROM @LineItems;

				OPEN intListCursor;

				-- Initial fetch attempt
				FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits;

				WHILE @@FETCH_STATUS = 0
				BEGIN
				   -- Here we do some kind of action that requires us to 
				   -- process the table variable row-by-row. This example simply
				   -- uses a PRINT statement as that action (not a very good
				   -- example).
				   IF ISNULL(@intLoopContractId,0) != 0
				   EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
				   EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoopContractId, @dblLoopContractUnits, @intEntityId;
				   -- Attempt to fetch next row from cursor
				   FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits;
				END;

				CLOSE intListCursor;
				DEALLOCATE intListCursor;
			END
		SELECT TOP 1 @dblRemainingUnits = LI.dblUnitsRemaining FROM @LineItems LI
		IF(@dblRemainingUnits IS NULL)
		BEGIN
		SET @dblRemainingUnits = @dblNetUnits
		END
		IF(@dblRemainingUnits > 0)
		BEGIN
			INSERT INTO @ItemsForItemReceipt (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,intTransactionDetailId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId -- ???? I don't see usage for this in the PO to Inventory receipt conversion.
				,ysnIsStorage
				,strSourceTransactionId  
			)
			EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblRemainingUnits , @intEntityId, @strDistributionOption, NULL
			SELECT TOP 1 @dblRemainingQuantity = dblQty FROM @ItemsForItemReceipt
			IF(@dblRemainingUnits > ISNULL(@dblRemainingQuantity,0))
				BEGIN
					INSERT INTO @ItemsForItemReceipt (
					intItemId
					,intItemLocationId
					,intItemUOMId
					,dtmDate
					,dblQty
					,dblUOMQty
					,dblCost
					,dblSalesPrice
					,intCurrencyId
					,dblExchangeRate
					,intTransactionId
					,intTransactionDetailId
					,strTransactionId
					,intTransactionTypeId
					,intLotId
					,intSubLocationId
					,intStorageLocationId -- ???? I don't see usage for this in the PO to Inventory receipt conversion.
					,ysnIsStorage 
					,strSourceTransactionId 
				)
				EXEC dbo.uspSCGetScaleItemForItemReceipt 
					 @intTicketId
					,@strSourceType
					,@intUserId
					,@dblRemainingUnits
					,@dblCost
					,@intEntityId
					,@intContractId
					,'SPT'
					,@LineItems
				END
			--IF (@dblRemainingUnits = @dblNetUnits)
			--RETURN
		END
			UPDATE @LineItems set intTicketId = @intTicketId
			--DELETE FROM @ItemsForItemReceipt
			-- Get the items to process
			INSERT INTO @ItemsForItemReceipt (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,intTransactionDetailId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId -- ???? I don't see usage for this in the PO to Inventory receipt conversion.
				,ysnIsStorage
				,strSourceTransactionId  
			)
			EXEC dbo.uspSCGetScaleItemForItemReceipt 
				 @intTicketId
				,@strSourceType
				,@intUserId
				,@dblNetUnits
				,@dblCost
				,@intEntityId
				,@intContractId
				,@strDistributionOption
				,@LineItems

		-- Validate the items to receive 
		EXEC dbo.uspICValidateProcessToItemReceipt @ItemsForItemReceipt; 

		SELECT @total = COUNT(*) FROM @ItemsForItemReceipt;
		IF (@total = 0)
			RETURN;
		END
	ELSE
	BEGIN
		IF @strDistributionOption = 'SPT'
		BEGIN
			UPDATE @LineItems set intTicketId = @intTicketId
				--DELETE FROM @ItemsForItemReceipt
				-- Get the items to process
				INSERT INTO @ItemsForItemReceipt (
					intItemId
					,intItemLocationId
					,intItemUOMId
					,dtmDate
					,dblQty
					,dblUOMQty
					,dblCost
					,dblSalesPrice
					,intCurrencyId
					,dblExchangeRate
					,intTransactionId
					,intTransactionDetailId
					,strTransactionId
					,intTransactionTypeId
					,intLotId
					,intSubLocationId
					,intStorageLocationId -- ???? I don't see usage for this in the PO to Inventory receipt conversion.
					,ysnIsStorage
					,strSourceTransactionId 
				)
				EXEC dbo.uspSCGetScaleItemForItemReceipt 
					 @intTicketId
					,@strSourceType
					,@intUserId
					,@dblNetUnits
					,@dblCost
					,@intEntityId
					,@intContractId
					,@strDistributionOption
					,@LineItems

			-- Validate the items to receive 
			EXEC dbo.uspICValidateProcessToItemReceipt @ItemsForItemReceipt;
		END
		ELSE
		BEGIN
			IF @ysnDPStorage = 1
				BEGIN
					SET @strReceiptType = 'Delayed Price';
					INSERT INTO @LineItems (
					intContractDetailId,
					dblUnitsDistributed,
					dblUnitsRemaining,
					dblCost)
					EXEC dbo.uspCTUpdationFromTicketDistribution 
					@intTicketId
					,@intEntityId
					,@dblNetUnits
					,@intContractId
					,@intUserId
					,@ysnDPStorage

					DECLARE @intDPContractId INT;
					DECLARE @dblDPContractUnits NUMERIC(38,20);
					DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
					FOR
					SELECT intContractDetailId, dblUnitsDistributed
					FROM @LineItems;

					OPEN intListCursor;

					-- Initial fetch attempt
					FETCH NEXT FROM intListCursor INTO @intDPContractId, @dblDPContractUnits;

					WHILE @@FETCH_STATUS = 0
					BEGIN
						-- Here we do some kind of action that requires us to 
						-- process the table variable row-by-row. This example simply
						-- uses a PRINT statement as that action (not a very good
						-- example).
						IF	ISNULL(@intDPContractId,0) != 0
							INSERT INTO @ItemsForItemReceipt (
							intItemId
							,intItemLocationId
							,intItemUOMId
							,dtmDate
							,dblQty
							,dblUOMQty
							,dblCost
							,dblSalesPrice
							,intCurrencyId
							,dblExchangeRate
							,intTransactionId
							,intTransactionDetailId
							,strTransactionId
							,intTransactionTypeId
							,intLotId
							,intSubLocationId
							,intStorageLocationId -- ???? I don't see usage for this in the PO to Inventory receipt conversion.
							,ysnIsStorage
							,strSourceTransactionId  
							)
							EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblNetUnits , @intEntityId, @strDistributionOption, @intDPContractId, @intStorageScheduleId
							EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intDPContractId, @dblNetUnits, @intEntityId, @ysnDPStorage;

						-- Attempt to fetch next row from cursor
						FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits;
					END;

					CLOSE intListCursor;
					DEALLOCATE intListCursor;
				END
			ELSE
				BEGIN
					INSERT INTO @ItemsForItemReceipt (
							intItemId
							,intItemLocationId
							,intItemUOMId
							,dtmDate
							,dblQty
							,dblUOMQty
							,dblCost
							,dblSalesPrice
							,intCurrencyId
							,dblExchangeRate
							,intTransactionId
							,intTransactionDetailId
							,strTransactionId
							,intTransactionTypeId
							,intLotId
							,intSubLocationId
							,intStorageLocationId -- ???? I don't see usage for this in the PO to Inventory receipt conversion.
							,ysnIsStorage
							,strSourceTransactionId 
					)
					EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblNetUnits , @intEntityId, @strDistributionOption, NULL, @intStorageScheduleId
				END
		END
	END

	-- Add the items to the item receipt 
	--IF @strSourceType = @SourceType_Direct
	BEGIN 
		EXEC dbo.uspSCAddScaleTicketToItemReceipt @intTicketId, @intUserId, @ItemsForItemReceipt, @intEntityId, @strReceiptType, @InventoryReceiptId OUTPUT; 
	END

	SELECT	@strTransactionId = IR.strReceiptNumber
			,@intShipFrom = IR.intShipFromId
			,@intShipTo = IR.intLocationId
			,@intCurrencyId = IR.intCurrencyId
	FROM	dbo.tblICInventoryReceipt IR	        
	WHERE	IR.intInventoryReceiptId = @InventoryReceiptId		

	EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intEntityId;
		
	UPDATE	SC
	SET		SC.intLotId = ICLot.intLotId
	FROM	dbo.tblSCTicket SC 
	INNER JOIN tblICInventoryReceiptItem IRI ON SC.intTicketId = IRI.intSourceId
	INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND intSourceType = 1
	INNER JOIN tblICInventoryReceiptItemLot ICLot ON ICLot.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId

	BEGIN
		-- Assemble the voucher items 
		BEGIN 
			INSERT INTO @voucherItems (
					[intInventoryReceiptType]
					,[intInventoryReceiptItemId]
					,[dblQtyReceived]
					,[dblCost]
					,[intTaxGroupId]
			)
			SELECT 
					[intInventoryReceiptType] = 
					CASE 
						WHEN r.strReceiptType = 'Direct' THEN 1
						WHEN r.strReceiptType = 'Purchase Contract' THEN 2
						WHEN r.strReceiptType = 'Purchase Order' THEN 3
						WHEN r.strReceiptType = 'Transfer Order' THEN 4
						WHEN r.strReceiptType = 'Inventory Return' THEN 4
						ELSE NULL 
					END 
					,[intInventoryReceiptItemId] = ri.intInventoryReceiptItemId
					,[dblQtyReceived] = ri.dblOpenReceive - ri.dblBillQty
					,[dblCost] = ri.dblUnitCost
					,[intTaxGroupId] = ri.intTaxGroupId
			FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
						ON r.intInventoryReceiptId = ri.intInventoryReceiptId
					LEFT JOIN tblCTContractHeader CT ON CT.intContractHeaderId = ri.intOrderId AND (CT.intPricingTypeId <= 1 OR CT.intPricingTypeId = 6)
			WHERE	r.ysnPosted = 1
					AND r.intInventoryReceiptId = @InventoryReceiptId
					AND ri.intOwnershipType = 1		
		END 

		-- Assemble the Other Charges
		BEGIN
			INSERT INTO @voucherOtherCharges (
					[intInventoryReceiptChargeId]
					,[dblQtyReceived]
					,[dblCost]
					,[intTaxGroupId]
			)
			SELECT	
					[intInventoryReceiptChargeId] = rc.intInventoryReceiptChargeId
					,[dblQtyReceived] = 
						CASE 
							WHEN rc.ysnPrice = 1 THEN 
								rc.dblQuantity - ISNULL(-rc.dblQuantityPriced, 0) 
							ELSE 
								rc.dblQuantity - ISNULL(rc.dblQuantityBilled, 0) 
						END 
					,[dblCost] = 
						CASE 
							WHEN rc.strCostMethod = 'Per Unit' THEN rc.dblRate
							ELSE rc.dblAmount
						END 
					,[intTaxGroupId] = rc.intTaxGroupId
			FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc
						ON r.intInventoryReceiptId = rc.intInventoryReceiptId
			WHERE	r.ysnPosted = 1
					AND r.intInventoryReceiptId = @InventoryReceiptId
					AND 
					(
						(
							rc.ysnPrice = 1
							AND ISNULL(-rc.dblAmountPriced, 0) < rc.dblAmount
						)
						OR (
							rc.ysnAccrue = 1 
							AND r.intEntityVendorId = ISNULL(rc.intEntityVendorId, r.intEntityVendorId) 
							AND ISNULL(rc.dblAmountBilled, 0) < rc.dblAmount
						)
					)
		END 

		EXEC [dbo].[uspAPCreateBillData]
				@userId = @intUserId
				,@vendorId = @intEntityId
				,@type = 1
				,@voucherDetailReceipt = @voucherItems
				,@voucherDetailReceiptCharge = @voucherOtherCharges
				,@shipTo = @intShipTo
				,@shipFrom = @intShipFrom
				,@currencyId = @intCurrencyId
				,@billId = @intBillId OUTPUT

		IF ISNULL(@intBillId , 0) != 0
		BEGIN
			EXEC [dbo].[uspSMTransactionCheckIfRequiredApproval]
			@type = N'AccountsPayable.view.Voucher',
			@transactionEntityId = @intEntityId,
			@currentUserEntityId = @intUserId,
			@locationId = @intLocationId,
			@amount = @dblTotal,
			@requireApproval = @requireApproval OUTPUT

			SELECT @dblTotal = SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = @intBillId

			IF ISNULL(@dblTotal,0) > 0 AND ISNULL(@requireApproval , 0) = 0
			BEGIN
				EXEC [dbo].[uspAPPostBill]
				@post = 1
				,@recap = 0
				,@isBatch = 0
				,@param = @intBillId
				,@userId = @intUserId
				,@success = @success OUTPUT
			END
		END
	END

	----VOUCHER intergration
	--CREATE TABLE #tmpItemReceiptIds (
	--	[intInventoryReceiptItemId] [INT] PRIMARY KEY,
	--	[intOrderId] [INT],
	--	[intOwnershipType] [INT],
	--	UNIQUE ([intInventoryReceiptItemId])
	--);
	--INSERT INTO #tmpItemReceiptIds(intInventoryReceiptItemId,intOrderId,intOwnershipType) SELECT intInventoryReceiptItemId,intOrderId,intOwnershipType FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId = @InventoryReceiptId AND dblUnitCost > 0

	--DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
	--FOR
	--SELECT TOP 1 intInventoryReceiptItemId, intOrderId, intOwnershipType
	--FROM #tmpItemReceiptIds WHERE intOwnershipType = 1;

	--OPEN intListCursor;

	---- Initial fetch attempt
	--FETCH NEXT FROM intListCursor INTO @intInventoryReceiptItemId, @intOrderId , @intOwnershipType;

	--WHILE @@FETCH_STATUS = 0
	--BEGIN
	--	SELECT @intPricingTypeId = intPricingTypeId FROM vyuCTContractDetailView where intContractHeaderId = @intOrderId; 
	--	IF ISNULL(@intInventoryReceiptItemId , 0) != 0 AND (ISNULL(@intPricingTypeId,0) <= 1 OR ISNULL(@intPricingTypeId,0) = 6) AND ISNULL(@intOwnershipType,0) = 1
	--	BEGIN
			
		
	--		EXEC [dbo].[uspAPCreateBillData]
	--			@userId = @intUserId
	--			,@vendorId = @intEntityId
	--			,@type = 1
	--			,@voucherDetailReceipt = @voucherItems
	--			,@voucherDetailReceiptCharge = @voucherOtherCharges
	--			,@shipTo = @intShipTo
	--			,@shipFrom = @intShipFrom
	--			,@currencyId = @intCurrencyId
	--			,@billId = @intBillId OUTPUT

	--		--EXEC dbo.uspAPCreateBillFromIR @InventoryReceiptId, @intEntityId;
	--		--SELECT @intBillId = intBillId, @dblTotal = SUM(dblTotal) FROM tblAPBillDetail WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId GROUP BY intBillId

	--		EXEC [dbo].[uspSMTransactionCheckIfRequiredApproval]
	--		@type = N'AccountsPayable.view.Voucher',
	--		@transactionEntityId = @intEntityId,
	--		@currentUserEntityId = @intUserId,
	--		@locationId = @intLocationId,
	--		@amount = @dblTotal,
	--		@requireApproval = @requireApproval OUTPUT

	--		IF ISNULL(@intBillId , 0) != 0 AND ISNULL(@dblTotal,0) > 0 AND ISNULL(@requireApproval , 0) = 0
	--		BEGIN
	--			EXEC [dbo].[uspAPPostBill]
	--			@post = 1
	--			,@recap = 0
	--			,@isBatch = 0
	--			,@param = @intBillId
	--			,@userId = @intUserId
	--			,@success = @success OUTPUT
	--		END
	--	END
	--	FETCH NEXT FROM intListCursor INTO @intInventoryReceiptItemId, @intOrderId, @intOwnershipType;
	--END

_Exit:

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