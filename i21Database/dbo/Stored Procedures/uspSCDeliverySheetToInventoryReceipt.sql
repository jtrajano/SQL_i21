CREATE PROCEDURE [dbo].[uspSCDeliverySheetToInventoryReceipt]
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
		,@voucherItems AS VoucherDetailReceipt 
		,@voucherOtherCharges AS VoucherDetailReceiptCharge
		,@thirdPartyVoucher AS VoucherDetailReceiptCharge
DECLARE @intDirectType AS INT = 3
DECLARE @intTicketItemUOMId INT
DECLARE @strReceiptType AS NVARCHAR(100)
DECLARE @ysnIsStorage AS BIT
DECLARE @strLotTracking AS NVARCHAR(100)
DECLARE @intItemId AS INT
DECLARE @intStorageScheduleId AS INT
		,@intStorageScheduleTypeId INT
		,@intInventoryReceiptItemId AS INT
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
		,@intShipTo AS INT
		,@intShipFrom AS INT
		,@intCurrencyId AS INT
		,@intHaulerId INT
		,@intInventoryReceiptChargeId INT
		,@dblQtyReceived NUMERIC (38,20)
		,@dblInventoryReceiptCost NUMERIC (38,20)
		,@intTaxId INT
		,@vendorOrderNumber NVARCHAR(50)
		,@voucherDate DATETIME
		,@createVoucher AS BIT
		,@postVoucher AS BIT
		,@shipFromEntityId INT;

BEGIN 
	SELECT @intTicketItemUOMId = UM.intItemUOMId
	, @intItemId = SCD.intItemId 
	, @shipFromEntityId = SCD.intEntityId 
	FROM tblSCDeliverySheet SCD 
	INNER JOIN dbo.tblICItemUOM UM	ON UM.intItemId = SCD.intItemId AND UM.ysnStockUnit = 1
	WHERE SCD.intDeliverySheetId = @intDeliverySheetId
END

BEGIN TRY
DECLARE @intId INT;
DECLARE @ysnDPStorage AS BIT;
DECLARE @intLoopContractId INT;
DECLARE @dblLoopContractUnits NUMERIC(38, 20);
DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT intTransactionDetailId, dblQty, ysnIsStorage, intId, strDistributionOption , intStorageScheduleId, intStorageScheduleTypeId
FROM @LineItem;

OPEN intListCursor;

		-- Initial fetch attempt
		FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits, @ysnIsStorage, @intId, @strDistributionOption, @intStorageScheduleId, @intStorageScheduleTypeId;

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
			FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits, @ysnIsStorage, @intId, @strDistributionOption, @intStorageScheduleId, @intStorageScheduleTypeId;
		END;

CLOSE intListCursor;
DEALLOCATE intListCursor;

SELECT @total = COUNT(*) FROM @ItemsForItemReceipt;
IF (@total = 0)
	RETURN;
BEGIN 
	EXEC dbo.uspSCAddDeliverySheetToItemReceipt @intDeliverySheetId, @intUserId, @ItemsForItemReceipt, @intEntityId, @strReceiptType, @InventoryReceiptId OUTPUT; 
END

	SELECT	@strTransactionId = IR.strReceiptNumber
			,@intShipFrom = IR.intShipFromId
			,@intShipTo = IR.intLocationId
			,@intCurrencyId = IR.intCurrencyId
			,@vendorOrderNumber = IR.strVendorRefNo
			,@voucherDate = IR.dtmReceiptDate
	FROM	dbo.tblICInventoryReceipt IR	        
	WHERE	IR.intInventoryReceiptId = @InventoryReceiptId		

	EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intUserId;
	SELECT @dblNetUnits = SUM(dblQty) FROM @ItemsForItemReceipt
	EXEC dbo.uspSCProcessHoldTicket @intDeliverySheetId,@intEntityId, @dblNetUnits , @intUserId, 'I', 0, 1

	-- VOUCHER INTEGRATION
	SELECT @createVoucher = ysnCreateVoucher, @postVoucher = ysnPostVoucher FROM tblAPVendor WHERE intEntityId = @intEntityId
	IF ISNULL(@createVoucher, 0) = 1 OR ISNULL(@postVoucher, 0) = 1
	BEGIN
		IF OBJECT_ID (N'tempdb.dbo.#tmpReceiptItem') IS NOT NULL
			DROP TABLE #tmpReceiptItem
		CREATE TABLE #tmpReceiptItem (
			[intInventoryReceiptItemId] INT PRIMARY KEY
			,[intInventoryReceiptId] INT
			,[intEntityVendorId] INT
			,[intContractDetailId] INT
			,[intPricingTypeId] INT
			,[ysnPosted] BIT
			,[strChargesLink] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
			,[dblQtyReceived] NUMERIC(38,20)
			,[dblCost] NUMERIC(38,20)
			,[intOwnershipType] INT
			UNIQUE ([intInventoryReceiptItemId])
		);
		INSERT INTO #tmpReceiptItem(
			[intInventoryReceiptItemId]
			,[intInventoryReceiptId]
			,[intEntityVendorId]
			,[intContractDetailId]
			,[intPricingTypeId]
			,[ysnPosted]
			,[strChargesLink]
			,[dblQtyReceived]
			,[dblCost]
			,[intOwnershipType]
		)
		SELECT 
			ri.intInventoryReceiptItemId
			,ri.intInventoryReceiptId
			,r.intEntityVendorId
			,CT.intContractDetailId 
			,ISNULL(CT.intPricingTypeId,0)
			,r.ysnPosted 
			,ri.strChargesLink
			,ri.dblOpenReceive - ri.dblBillQty
			,ri.dblUnitCost
			,ri.intOwnershipType
		FROM tblICInventoryReceipt r 
		INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
		LEFT JOIN tblCTContractDetail CT ON CT.intContractDetailId = ri.intLineNo
		WHERE ri.intInventoryReceiptId = @InventoryReceiptId AND ri.intOwnershipType = 1
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
						WHEN ri.intOrderId > 0 THEN 2
						ELSE 1
					END 
					,[intInventoryReceiptItemId] = ri.intInventoryReceiptItemId
					,[dblQtyReceived] = ri.dblOpenReceive - ri.dblBillQty
					,[dblCost] = ri.dblUnitCost
					,[intTaxGroupId] = ri.intTaxGroupId
			FROM	tblICInventoryReceiptItem ri
					INNER JOIN #tmpReceiptItem tmp ON tmp.intInventoryReceiptItemId = ri.intInventoryReceiptItemId AND tmp.intPricingTypeId IN (0,1,6)
			WHERE	ri.intInventoryReceiptId = @InventoryReceiptId
					AND tmp.intOwnershipType = 1		
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
					,[dblQtyReceived] = rc.dblQuantity - ISNULL(-rc.dblQuantityPriced, 0)
					,[dblCost] = 
						CASE 
							WHEN rc.strCostMethod = 'Amount' THEN rc.dblAmount
							ELSE rc.dblRate
						END 
					,[intTaxGroupId] = rc.intTaxGroupId
			FROM	#tmpReceiptItem tmp 
					INNER JOIN tblICInventoryReceiptCharge rc ON rc.intInventoryReceiptId = tmp.intInventoryReceiptId AND rc.strChargesLink = tmp.strChargesLink AND tmp.intPricingTypeId IN (0,1,6)
			WHERE	tmp.ysnPosted = 1
					AND tmp.intInventoryReceiptId = @InventoryReceiptId
					AND tmp.intOwnershipType = 1
					AND 
					(
						(
							rc.ysnPrice = 1
							AND ISNULL(-rc.dblAmountPriced, 0) < rc.dblAmount
						)
						OR (
							rc.ysnAccrue = 1 
							AND tmp.intEntityVendorId = rc.intEntityVendorId 
							AND ISNULL(rc.dblAmountBilled, 0) < rc.dblAmount
						)
					)
		END 

		SELECT @total = COUNT(*) FROM @voucherItems;
		IF (@total > 0)
		BEGIN
		EXEC [dbo].[uspAPCreateBillData]
				@userId = @intUserId
				,@vendorId = @intEntityId
				,@type = 1
				,@voucherDetailReceipt = @voucherItems
				,@voucherDetailReceiptCharge = @voucherOtherCharges
				,@shipTo = @intShipTo
				,@shipFrom = @intShipFrom
				,@shipFromEntityId = @shipFromEntityId
				,@vendorOrderNumber = @vendorOrderNumber
				,@voucherDate = @voucherDate
				,@currencyId = @intCurrencyId
				,@billId = @intBillId OUTPUT
		END

		IF ISNULL(@intBillId , 0) != 0 AND ISNULL(@postVoucher, 0) = 1
		BEGIN
			SELECT @dblTotal = SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = @intBillId

			EXEC [dbo].[uspSMTransactionCheckIfRequiredApproval]
			@type = N'AccountsPayable.view.Voucher',
			@transactionEntityId = @intEntityId,
			@currentUserEntityId = @intUserId,
			@locationId = @intShipTo,
			@amount = @dblTotal,
			@requireApproval = @requireApproval OUTPUT

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