﻿CREATE PROCEDURE [dbo].[uspSCDeliverySheetToInventoryReceipt]
	@LineItem ScaleManualCostingTableType READONLY,
	@intDeliverySheetId AS INT, 
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
DECLARE @intDirectType AS INT = 3
DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT
DECLARE @strReceiptType AS NVARCHAR(100)
DECLARE @ysnIsStorage AS BIT
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
		,@dblNetUnits AS DECIMAL(38,20)
		,@returnValue AS BIT
		,@requireApproval AS BIT
		,@intLocationId AS INT;

BEGIN 
	SELECT DISTINCT	@intTicketItemUOMId = UM.intItemUOMId, @intItemId = SC.intItemId
	FROM	dbo.tblICItemUOM UM	
	INNER JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
	WHERE	UM.ysnStockUnit = 1 AND SC.intDeliverySheetId = @intDeliverySheetId
END

--BEGIN 
--	SELECT	@intTicketItemUOMId = UM.intItemUOMId
--	FROM	dbo.tblICItemUOM UM	
--			JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
--	WHERE	UM.intUnitMeasureId = @intTicketUOM AND SC.intTicketId = @intDeliverySheetId
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
					IF @strDistributionOption = 'CNT'
					BEGIN
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
								SELECT	@intDeliverySheetId,
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

								IF	ISNULL(@intLoopContractId,0) != 0
								EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intDeliverySheetId, 'Delivery Sheet', @intTicketItemUOMId
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
				IF @ysnDPStorage = 1 AND ISNULL(@intLoopContractId,0) = 0
					BEGIN
					SET @strReceiptType = 'Delayed Price'
					INSERT INTO @LineItems (
					intContractDetailId,
					dblUnitsDistributed,
					dblUnitsRemaining,
					dblCost)
					EXEC dbo.uspCTUpdationFromTicketDistribution 
					@intDeliverySheetId
					,@intEntityId
					,@dblLoopContractUnits
					,@intLoopContractId
					,@intUserId
					,@ysnDPStorage
					,1

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
							EXEC dbo.uspSCDeliverySheetStorage @intDeliverySheetId, @intUserId, @dblLoopContractUnits , @intEntityId, @strDistributionOption, @intDPContractId, @intStorageScheduleId
							
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
					EXEC dbo.uspSCDeliverySheetStorage @intDeliverySheetId, @intUserId, @dblLoopContractUnits , @intEntityId, @strDistributionOption, NULL , @intStorageScheduleId
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
	EXEC dbo.uspSCAddDeliverySheetToItemReceipt @intDeliverySheetId, @intUserId, @ItemsForItemReceipt, @intEntityId, @strReceiptType, @InventoryReceiptId OUTPUT; 
END

BEGIN 
SELECT	@strTransactionId = IR.strReceiptNumber
FROM	dbo.tblICInventoryReceipt IR	        
WHERE	IR.intInventoryReceiptId = @InventoryReceiptId		
END

	SELECT @strLotTracking = strLotTracking FROM tblICItem WHERE intItemId = @intItemId
	IF @strLotTracking != 'Yes - Manual'
		BEGIN
			EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intEntityId;
			SELECT @dblNetUnits = SUM(dblQty) FROM @ItemsForItemReceipt
			EXEC dbo.uspSCProcessHoldTicket @intDeliverySheetId,@intEntityId, @dblNetUnits , @intUserId, 'I', 0, 1
			--VOUCHER intergration
			CREATE TABLE #tmpItemReceiptIds (
				[intInventoryReceiptItemId] [INT] PRIMARY KEY,
				[intOrderId] [INT],
				[intOwnershipType] [INT],
				UNIQUE ([intInventoryReceiptItemId])
			);
			INSERT INTO #tmpItemReceiptIds(intInventoryReceiptItemId,intOrderId,intOwnershipType) SELECT intInventoryReceiptItemId,intOrderId,intOwnershipType FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId = @InventoryReceiptId  AND dblUnitCost > 0

			DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
			FOR
			SELECT TOP 1 intInventoryReceiptItemId, intOrderId, intOwnershipType
			FROM #tmpItemReceiptIds WHERE intOwnershipType = 1;

			OPEN intListCursor;

			-- Initial fetch attempt
			FETCH NEXT FROM intListCursor INTO @intInventoryReceiptItemId, @intOrderId , @intOwnershipType;

			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @intPricingTypeId = intPricingTypeId FROM vyuCTContractDetailView where intContractHeaderId = @intOrderId; 
				IF ISNULL(@intInventoryReceiptItemId , 0) != 0 AND (ISNULL(@intPricingTypeId,0) <= 1 OR ISNULL(@intPricingTypeId,0) = 6) AND ISNULL(@intOwnershipType,0) = 1
				BEGIN
					EXEC dbo.uspAPCreateBillFromIR @InventoryReceiptId, @intUserId;
					SELECT @intBillId = intBillId, @dblTotal = SUM(dblTotal) FROM tblAPBillDetail WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId GROUP BY intBillId
					
					EXEC [dbo].[uspSMTransactionCheckIfRequiredApproval]
					@type = N'AccountsPayable.view.Voucher',
					@transactionEntityId = @intEntityId,
					@currentUserEntityId = @intUserId,
					@locationId = @intLocationId,
					@amount = @dblTotal,
					@requireApproval = @requireApproval OUTPUT

					IF ISNULL(@intBillId , 0) != 0 AND ISNULL(@dblTotal,0) > 0 AND ISNULL(@requireApproval , 0) = 0
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
				FETCH NEXT FROM intListCursor INTO @intInventoryReceiptItemId, @intOrderId, @intOwnershipType;
			END
		END
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