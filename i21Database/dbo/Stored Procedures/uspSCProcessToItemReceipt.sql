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
		,@thirdPartyVoucher AS VoucherDetailReceiptCharge
		,@prePayId AS Id
DECLARE @intTicketId AS INT = @intSourceTransactionId
DECLARE @dblRemainingUnits AS NUMERIC(38, 20)
DECLARE @dblRemainingQuantity AS NUMERIC(38, 20)
DECLARE @LineItems AS ScaleTransactionTableType
DECLARE @intDirectType AS INT = 3
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
		,@intCurrencyId AS INT
		,@intHaulerId INT
		,@intInventoryReceiptChargeId INT
		,@dblQtyReceived NUMERIC (38,20)
		,@dblInventoryReceiptCost NUMERIC (38,20)
		,@intTaxId INT
		,@vendorOrderNumber NVARCHAR(50)
		,@voucherDate DATETIME
		,@dblGrossUnits AS NUMERIC(38, 20)
		,@dblTicketNetUnits AS NUMERIC(38, 20)
		,@intItemId INT
		,@createVoucher AS BIT
		,@postVoucher AS BIT
		,@intLotType INT
		,@intLotId INT
		,@intContractDetailId INT
		,@shipFromEntityId INT
		,@intFarmFieldId INT;

	SELECT TOP 1 @intLoadId = ST.intLoadId
	, @dblTicketFreightRate = ST.dblFreightRate
	, @intScaleStationId = ST.intScaleSetupId
	, @ysnDeductFreightFarmer = ST.ysnFarmerPaysFreight
	, @intLocationId = ST.intProcessingLocationId
	, @dblGrossUnits = ST.dblGrossUnits
	, @dblTicketNetUnits = ST.dblNetUnits
	, @intItemId = ST.intItemId
	, @intTicketItemUOMId = ST.intItemUOMIdTo
	, @shipFromEntityId = ST.intEntityId
	, @intFarmFieldId = ST.intFarmFieldId
	FROM dbo.tblSCTicket ST WHERE
	ST.intTicketId = @intTicketId

	SELECT	@ysnDPStorage = ST.ysnDPOwnedType 
	FROM dbo.tblGRStorageType ST WHERE 
	ST.strStorageTypeCode = @strDistributionOption

DECLARE @ErrMsg              NVARCHAR(MAX),
        @dblBalance          NUMERIC(38, 20),                    
        @dblNewBalance       NUMERIC(38, 20),
        @strInOutFlag        NVARCHAR(4),
        @dblQuantity         NUMERIC(38, 20),
        @strAdjustmentNo     NVARCHAR(50);

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
				INNER JOIN tblLGLoadDetail LGLD ON LGL.intLoadId = LGLD.intLoadId 
				WHERE LGL.intLoadId = @intLoadId
			END
			IF @intLoadContractId IS NULL
			BEGIN 
				RAISERROR('Unable to find load contract details. Try Again.', 11, 1);
				GOTO _Exit
			END
			BEGIN
				SET @dblLoadScheduledUnits = @dblLoadScheduledUnits * -1;
				EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoadContractId, @dblLoadScheduledUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
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
		ELSE
		BEGIN
			SET @strReceiptType = 'Direct'
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
			,@vendorOrderNumber = IR.strVendorRefNo
			,@intCurrencyId = IR.intCurrencyId
	FROM	dbo.tblICInventoryReceipt IR	        
	WHERE	IR.intInventoryReceiptId = @InventoryReceiptId		

	EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intEntityId;
		
	UPDATE	SC
	SET		SC.intLotId = ICLot.intLotId, SC.strLotNumber = ICLot.strLotNumber
	FROM	dbo.tblSCTicket SC 
	INNER JOIN tblICInventoryReceiptItem IRI ON SC.intTicketId = IRI.intSourceId
	INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND intSourceType = 1
	INNER JOIN tblICInventoryReceiptItemLot ICLot ON ICLot.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
	WHERE SC.intTicketId = @intTicketId

	SELECT @intContractDetailId = MIN(ri.intLineNo)
	FROM tblICInventoryReceipt r 
	JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
	WHERE ri.intInventoryReceiptId = @InventoryReceiptId AND r.strReceiptType = 'Purchase Contract' 
 
	WHILE ISNULL(@intContractDetailId,0) > 0
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId)
		BEGIN
		EXEC uspCTCreateVoucherInvoiceForPartialPricing @intContractDetailId, @intUserId
		END
		SELECT @intContractDetailId = MIN(ri.intLineNo)
		FROM tblICInventoryReceipt r 
		JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
		WHERE ri.intInventoryReceiptId = @InventoryReceiptId AND r.strReceiptType = 'Purchase Contract' AND ri.intLineNo > @intContractDetailId
	END

	SELECT @intLotType = dbo.fnGetItemLotType(@intItemId)
    IF @intLotType != 0
    BEGIN
        DECLARE @QualityPropertyValueTable AS QualityPropertyValueTable;
        INSERT INTO @QualityPropertyValueTable(
            strPropertyName
            ,strPropertyValue
            ,strComment
        )
        SELECT 
            strPropertyName = IC.strShortName
            ,strPropertyValue = QM.dblGradeReading
            ,strComment = QM.strShrinkWhat 
        FROM tblQMTicketDiscount QM 
        INNER JOIN tblGRDiscountScheduleCode GR ON GR.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
        INNER JOIN tblICItem IC ON IC.intItemId = GR.intItemId
        WHERE QM.intTicketId = @intTicketId AND QM.strSourceType = 'Scale'

        DECLARE lotCursor CURSOR LOCAL FAST_FORWARD
        FOR
        SELECT ICLot.intLotId FROM dbo.tblSCTicket SC 
        INNER JOIN tblICInventoryReceiptItem IRI ON SC.intTicketId = IRI.intSourceId
        INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND intSourceType = 1
        INNER JOIN tblICInventoryReceiptItemLot ICLot ON ICLot.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
        WHERE SC.intTicketId = @intTicketId

        OPEN lotCursor;

        -- Initial fetch attempt
        FETCH NEXT FROM lotCursor INTO @intLotId

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF    ISNULL(@intLotId,0) != 0
            EXEC dbo.uspQMSampleCreateForScaleTicket @intItemId,'Inbound Scale Sample', @intLotId, @intUserId, @QualityPropertyValueTable
            FETCH NEXT FROM lotCursor INTO @intLotId;
        END

        CLOSE lotCursor;
        DEALLOCATE lotCursor;
    END


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
		LEFT JOIN tblCTPriceFixation CTP ON CTP.intContractDetailId = CT.intContractDetailId
		WHERE ri.intInventoryReceiptId = @InventoryReceiptId AND ri.intOwnershipType = 1 AND CTP.intPriceFixationId IS NULL
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
							WHEN rc.strCostMethod = 'Amount' THEN  rc.dblAmount
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
		SET @intShipFrom = COALESCE(@intFarmFieldId, @intShipFrom);
		EXEC [dbo].[uspAPCreateBillData]
				@userId = @intUserId
				,@vendorId = @intEntityId
				,@type = 1
				,@voucherDetailReceipt = @voucherItems
				,@voucherDetailReceiptCharge = @voucherOtherCharges
				,@shipTo = @intLocationId
				,@shipFrom = @intShipFrom
				,@shipFromEntityId = @shipFromEntityId
				,@vendorOrderNumber = @vendorOrderNumber
				,@voucherDate = @voucherDate
				,@currencyId = @intCurrencyId
				,@billId = @intBillId OUTPUT
		END

		IF ISNULL(@intBillId , 0) != 0 AND ISNULL(@postVoucher, 0) = 1
		BEGIN
			IF OBJECT_ID (N'tempdb.dbo.#tmpContractPrepay') IS NOT NULL
				DROP TABLE #tmpContractPrepay

			CREATE TABLE #tmpContractPrepay (
				[intPrepayId] INT
			);
			INSERT INTO #tmpContractPrepay(
				[intPrepayId]
			) 
			SELECT ISNULL(dbo.fnCTGetPrepaidIds(CT.intContractHeaderId),0)
			FROM #tmpReceiptItem tmp 
			INNER JOIN tblCTContractDetail CT ON CT.intContractDetailId = tmp.intContractDetailId
			GROUP BY CT.intContractHeaderId
		
			SELECT @total = COUNT(intPrepayId) FROM #tmpContractPrepay where intPrepayId > 0;
			IF (@total > 0)
			BEGIN
				INSERT INTO @prePayId(
					[intId]
				)
				SELECT [intId] = intPrepayId
				FROM #tmpContractPrepay where intPrepayId > 0
			
				EXEC uspAPApplyPrepaid @intBillId, @prePayId
				update tblAPBillDetail set intScaleTicketId = @intTicketId WHERE intBillId = @intBillId
			END

			SELECT @dblTotal = SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = @intBillId

			EXEC [dbo].[uspSMTransactionCheckIfRequiredApproval]
			@type = N'AccountsPayable.view.Voucher',
			@transactionEntityId = @intEntityId,
			@currentUserEntityId = @intUserId,
			@locationId = @intLocationId,
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