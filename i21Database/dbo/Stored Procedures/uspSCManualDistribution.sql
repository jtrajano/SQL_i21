CREATE PROCEDURE [dbo].[uspSCManualDistribution]
	@LineItem ScaleManualCostingTableType READONLY,
	@intTicketId AS INT, 
	@intUserId AS INT,
	@intEntityId AS INT,
	@InventoryReceiptId AS INT OUTPUT 
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @ItemsForItemReceipt AS ItemCostingTableType
DECLARE @total AS INT
DECLARE @ErrMsg NVARCHAR(MAX)
DECLARE @strTransactionId NVARCHAR(40) = NULL
DECLARE @strDistributionOption NVARCHAR(50) = NULL

DECLARE @dblRemainingUnits AS NUMERIC(38, 20)
DECLARE @LineItems AS ScaleTransactionTableType
		,@voucherItems AS VoucherDetailReceipt 
		,@voucherOtherCharges AS VoucherDetailReceiptCharge
DECLARE @intDirectType AS INT = 3
DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT
DECLARE @strReceiptType AS NVARCHAR(100)
DECLARE @intLoadId INT
DECLARE @dblTicketFreightRate AS DECIMAL (9, 6)
DECLARE @intScaleStationId AS INT
DECLARE @intFreightItemId AS INT
DECLARE @intFreightVendorId AS INT
DECLARE @ysnIsStorage AS BIT
DECLARE @intLoadContractId AS INT
DECLARE @dblLoadScheduledUnits AS NUMERIC(38, 20)
DECLARE @strInOutFlag AS NVARCHAR(100)
DECLARE @strLotTracking AS NVARCHAR(100)
DECLARE @intItemId AS INT
DECLARE @intStorageScheduleId AS INT
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
	SELECT	@intTicketUOM = UOM.intUnitMeasureId, @intItemId = SC.intItemId
	FROM	dbo.tblSCTicket SC	        
			JOIN dbo.tblICItemUOM UOM ON SC.intItemId = UOM.intItemId
	WHERE	SC.intTicketId = @intTicketId AND UOM.ysnStockUnit = 1		
END

BEGIN 
	SELECT	@intTicketItemUOMId = UM.intItemUOMId, @intLoadId = SC.intLoadId
		FROM	dbo.tblICItemUOM UM	
	      JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
	WHERE	UM.ysnStockUnit = 1 AND SC.intTicketId = @intTicketId
END

--BEGIN 
--	SELECT	@intTicketItemUOMId = UM.intItemUOMId
--	FROM	dbo.tblICItemUOM UM	
--			JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
--	WHERE	UM.intUnitMeasureId = @intTicketUOM AND SC.intTicketId = @intTicketId
--END

BEGIN TRY
DECLARE @intId INT;
DECLARE @ysnDPStorage AS BIT;
DECLARE @intLoopContractId INT;
DECLARE @dblLoopContractUnits NUMERIC(38, 20);
DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT intTransactionDetailId, dblQty, ysnIsStorage, intId, strDistributionOption , intStorageScheduleId
FROM @LineItem;

OPEN intListCursor;

		-- Initial fetch attempt
		FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits, @ysnIsStorage, @intId, @strDistributionOption, @intStorageScheduleId;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Here we do some kind of action that requires us to 
			-- process the table variable row-by-row. This example simply
			-- uses a PRINT statement as that action (not a very good
			-- example).

			BEGIN
				SELECT	@ysnDPStorage = ST.ysnDPOwnedType 
				FROM dbo.tblGRStorageType ST WHERE 
				ST.strStorageTypeCode = @strDistributionOption
			END

			IF @ysnIsStorage = 0
				BEGIN
					IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
					BEGIN
						IF @strDistributionOption = 'LOD'
							BEGIN 
								SELECT @intLoadId = intLoadId, @strInOutFlag = strInOutFlag FROM tblSCTicket WHERE intTicketId = @intTicketId;
							END
							BEGIN
								IF @strInOutFlag = 'I'
									SELECT @intLoadContractId = LGL.intPContractDetailId, @dblLoadScheduledUnits = LGL.dblQuantity FROM vyuLGLoadDetailView LGL WHERE LGL.intLoadId = @intLoadId
								ELSE
									SELECT @intLoadContractId = LGL.intSContractDetailId, @dblLoadScheduledUnits = LGL.dblQuantity FROM vyuLGLoadDetailView LGL WHERE LGL.intLoadId = @intLoadId
							END
							IF @intLoadContractId IS NOT NULL
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
									FROM	tblCTContractCost CC WHERE CC.intContractDetailId = @intLoopContractId
								END
							IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
							BEGIN
								IF	ISNULL(@intLoopContractId,0) != 0
								EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
								EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoopContractId, @dblLoopContractUnits, @intEntityId;
							END
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
							)SELECT 
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
								,intStorageLocationId
								,ysnIsStorage
								,strDistributionOption 
							FROM @LineItem
							where intId = @intId
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
							)SELECT 
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
								,intStorageLocationId
								,ysnIsStorage
								,strDistributionOption 
							FROM @LineItem
							where intId = @intId
					END
					EXEC dbo.uspICValidateProcessToItemReceipt @ItemsForItemReceipt; 
				END
			IF @ysnIsStorage = 1
			BEGIN
				IF @ysnDPStorage = 1
					BEGIN
					SET @strReceiptType = 'Delayed Price'
					INSERT INTO @LineItems (
					intContractDetailId,
					dblUnitsDistributed,
					dblUnitsRemaining,
					dblCost)
					EXEC dbo.uspCTUpdationFromTicketDistribution 
					@intTicketId
					,@intEntityId
					,@dblLoopContractUnits
					,@intLoopContractId
					,@intUserId
					,@ysnDPStorage

					DECLARE @intDPContractId INT;
					DECLARE @dblDPContractUnits NUMERIC(12,4);
					DECLARE intListCursorDP CURSOR LOCAL FAST_FORWARD
					FOR
					SELECT intContractDetailId, dblUnitsDistributed
					FROM @LineItems;

					OPEN intListCursorDP;

					-- Initial fetch attempt
					FETCH NEXT FROM intListCursorDP INTO @intDPContractId, @dblDPContractUnits;

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
							EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblLoopContractUnits , @intEntityId, @strDistributionOption, @intDPContractId, @intStorageScheduleId
							EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intDPContractId, @dblLoopContractUnits, @intEntityId, @ysnIsStorage;
						-- Attempt to fetch next row from cursor
						FETCH NEXT FROM intListCursorDP INTO @intLoopContractId, @dblDPContractUnits;
					END;

					CLOSE intListCursorDP;
					DEALLOCATE intListCursorDP;
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
					EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblLoopContractUnits , @intEntityId, @strDistributionOption, NULL , @intStorageScheduleId
					END
			END		   
			-- Attempt to fetch next row from cursor
			FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits, @ysnIsStorage, @intId, @strDistributionOption, @intStorageScheduleId;
		END;

CLOSE intListCursor;
DEALLOCATE intListCursor;

SELECT @total = COUNT(*) FROM @ItemsForItemReceipt;
IF (@total = 0)
	RETURN;
BEGIN 
	EXEC dbo.uspSCAddScaleTicketToItemReceipt @intTicketId, @intUserId, @ItemsForItemReceipt, @intEntityId, @strReceiptType, @InventoryReceiptId OUTPUT; 
END

	SELECT	@strTransactionId = IR.strReceiptNumber
	FROM	dbo.tblICInventoryReceipt IR	        
	WHERE	IR.intInventoryReceiptId = @InventoryReceiptId
	
	EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intEntityId;

	UPDATE	SC
	SET		SC.intLotId = ICLot.intLotId
	FROM	dbo.tblSCTicket SC 
	INNER JOIN tblICInventoryReceiptItem IRI ON SC.intTicketId = IRI.intSourceId
	INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND intSourceType = 1
	INNER JOIN tblICInventoryReceiptItemLot ICLot ON ICLot.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId

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
		
	----VOUCHER intergration
	--CREATE TABLE #tmpItemReceiptIds (
	--	[intInventoryReceiptItemId] [INT] PRIMARY KEY,
	--	[intOrderId] [INT],
	--	[intOwnershipType] [INT],
	--	UNIQUE ([intInventoryReceiptItemId])
	--);
	--INSERT INTO #tmpItemReceiptIds(intInventoryReceiptItemId,intOrderId,intOwnershipType) SELECT intInventoryReceiptItemId,intOrderId,intOwnershipType FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId = @InventoryReceiptId  AND dblUnitCost > 0

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
	--		EXEC dbo.uspAPCreateBillFromIR @InventoryReceiptId, @intUserId;
	--		IF OBJECT_ID (N'tempdb.dbo.#tmpVoucherDetail') IS NOT NULL
 --               DROP TABLE #tmpVoucherDetail
	--		CREATE TABLE #tmpVoucherDetail (
	--			[intBillId] [INT] PRIMARY KEY,
	--			[dblTotal] DECIMAL(18,6),
	--			UNIQUE ([intBillId])
	--		);
	--		INSERT INTO #tmpVoucherDetail(intBillId, dblTotal) SELECT DISTINCT(intBillId), SUM(dblTotal) FROM tblAPBillDetail WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId GROUP BY intBillId
					
	--		DECLARE voucherCursor CURSOR LOCAL FAST_FORWARD
	--		FOR
	--		SELECT intBillId,dblTotal FROM #tmpVoucherDetail

	--		OPEN voucherCursor;

	--		FETCH NEXT FROM voucherCursor INTO @intBillId, @dblTotal;

	--		WHILE @@FETCH_STATUS = 0
	--		BEGIN
	--			EXEC [dbo].[uspSMTransactionCheckIfRequiredApproval]
	--				@type = N'AccountsPayable.view.Voucher',
	--				@transactionEntityId = @intEntityId,
	--				@currentUserEntityId = @intUserId,
	--				@locationId = @intLocationId,
	--				@amount = @dblTotal,
	--				@requireApproval = @requireApproval OUTPUT

	--				IF ISNULL(@intBillId , 0) != 0 AND ISNULL(@dblTotal,0) > 0 AND ISNULL(@requireApproval , 0) = 0
	--				BEGIN
	--					EXEC [dbo].[uspAPPostBill]
	--					@post = 1
	--					,@recap = 0
	--					,@isBatch = 0
	--					,@param = @intBillId
	--					,@userId = @intUserId
	--					,@success = @success OUTPUT
	--				END
	--			FETCH NEXT FROM voucherCursor INTO @intBillId, @dblTotal;
	--		END
			
	--		CLOSE voucherCursor  
	--		DEALLOCATE voucherCursor 

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