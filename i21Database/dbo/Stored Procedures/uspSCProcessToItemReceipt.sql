CREATE PROCEDURE [dbo].[uspSCProcessToItemReceipt]
	 @intSourceTransactionId AS INT
	,@intUserId AS INT
	,@dblNetUnits AS DECIMAL (38,20)
	,@dblCost AS DECIMAL (38, 20)
	,@intEntityId AS INT
	,@intContractId AS INT
	,@strDistributionOption AS NVARCHAR(3)
	,@intStorageScheduleId AS INT = NULL
	,@InventoryReceiptId AS INT OUTPUT
	,@intBillId AS INT OUTPUT
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
		,@voucherPayable as VoucherPayable
		,@voucherTaxDetail as VoucherDetailTax
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
DECLARE @total AS INT
DECLARE @ysnDPStorage AS BIT
DECLARE @strLotTracking AS NVARCHAR(100)
DECLARE @intIRContractPricingType AS INT
DECLARE @intInventoryReceiptItemId AS INT
		,@intOrderId INT
		,@intOwnershipType INT
		,@intPricingTypeId INT
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
		IF @strDistributionOption = 'LOD' AND @intLoadId IS NULL
		BEGIN
			RAISERROR('Unable to find load details. Try Again.', 11, 1);
			GOTO _Exit
		END

		IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
		BEGIN
			INSERT INTO @LineItems (
			intContractDetailId,
			dblUnitsDistributed,
			dblUnitsRemaining,
			dblCost,
			intCurrencyId)
			EXEC dbo.uspCTUpdationFromTicketDistribution 
			 @intTicketId
			,@intEntityId
			,@dblNetUnits
			,@intContractId
			,@intUserId
			,0
		IF @strDistributionOption = 'CNT'
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
		ELSE IF @strDistributionOption = 'LOD'
		BEGIN
			DECLARE @intLoadContractId INT;
			DECLARE @dblLoadContractUnits NUMERIC(38,20);
			DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
			FOR
			SELECT intContractDetailId, dblUnitsDistributed
			FROM @LineItems;

			OPEN intListCursor;

			-- Initial fetch attempt
			FETCH NEXT FROM intListCursor INTO @intLoadContractId, @dblLoadContractUnits;

			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF ISNULL(@intLoadContractId,0) != 0
				BEGIN
					SELECT @intContractDetailId = intContractDetailId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId
					IF @intContractDetailId != @intContractId
					BEGIN
						EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoadContractId, @dblLoadContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
						EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoadContractId, @dblLoadContractUnits, @intEntityId;
					END
				END
				-- Attempt to fetch next row from cursor
				FETCH NEXT FROM intListCursor INTO @intLoadContractId, @dblLoadContractUnits;
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
					,intStorageScheduleTypeId
					,ysnAllowVoucher
				)
				EXEC dbo.uspSCGetScaleItemForItemReceipt 
					 @intTicketId
					,@intUserId
					,@dblRemainingUnits
					,0
					,@intEntityId
					,@intContractId
					,'SPT'
					,@LineItems
			END
		END
		
		UPDATE @LineItems set intTicketId = @intTicketId
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
			,intStorageScheduleTypeId
			,ysnAllowVoucher
		)
		EXEC dbo.uspSCGetScaleItemForItemReceipt 
			@intTicketId
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
					,intStorageScheduleTypeId
					,ysnAllowVoucher
				)
				EXEC dbo.uspSCGetScaleItemForItemReceipt 
					 @intTicketId
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
					dblCost,
					intCurrencyId)
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
								,intStorageLocationId
								,ysnIsStorage
								,strSourceTransactionId 
								,ysnAllowVoucher 
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
							,ysnAllowVoucher
					)
					EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblNetUnits , @intEntityId, @strDistributionOption, NULL, @intStorageScheduleId
				END
		END
	END

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

	EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intUserId;
		
	UPDATE	SC
	SET		SC.intLotId = ICLot.intLotId, SC.strLotNumber = ICLot.strLotNumber
	FROM	dbo.tblSCTicket SC 
	INNER JOIN tblICInventoryReceiptItem IRI ON SC.intTicketId = IRI.intSourceId
	INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND intSourceType = 1
	INNER JOIN tblICInventoryReceiptItemLot ICLot ON ICLot.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
	WHERE SC.intTicketId = @intTicketId

	SELECT @intContractDetailId = MIN(ri.intLineNo)
			,@intIRContractPricingType = MIN(CD.intPricingTypeId)
	FROM tblICInventoryReceipt r 
	JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
	LEFT JOIN tblCTContractDetail CD 
		ON ri.intContractDetailId = CD.intContractDetailId
	WHERE ri.intInventoryReceiptId = @InventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
 
	WHILE ISNULL(@intContractDetailId,0) > 0 AND @intIRContractPricingType = 2
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId)
		BEGIN
			EXEC uspCTCreateVoucherInvoiceForPartialPricing @intContractDetailId, @intUserId, 0, @InventoryReceiptId
		END

		SELECT @intContractDetailId = MIN(ri.intLineNo)
				,@intIRContractPricingType = MIN(CD.intPricingTypeId)
		FROM tblICInventoryReceipt r 
		JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
		LEFT JOIN tblCTContractDetail CD 
			ON ri.intContractDetailId = CD.intContractDetailId
		WHERE ri.intInventoryReceiptId = @InventoryReceiptId AND r.strReceiptType = 'Purchase Contract' AND ri.intLineNo > @intContractDetailId

		select @intBillId = intBillId from tblAPBillDetail where intInventoryReceiptItemId in (
			select ri.intInventoryReceiptItemId
			FROM tblICInventoryReceipt r 
				JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId					
					WHERE ri.intInventoryReceiptId = @InventoryReceiptId 
		) and intInventoryReceiptChargeId is null
		
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

	SELECT @total = COUNT(1)
			FROM	tblICInventoryReceiptItem ri
			WHERE	ri.intInventoryReceiptId = @InventoryReceiptId
					AND ri.intOwnershipType = 1
					AND ISNULL(ri.ysnAllowVoucher,1) = 1

	DECLARE @ysnHasBasisContract INT = 0
		SELECT @ysnHasBasisContract = CASE WHEN COUNT(DISTINCT intPricingTypeId) > 0 THEN 1 ELSE 0 END FROM tblICInventoryReceiptItem IRI
		INNER JOIN tblCTContractDetail CT
			ON CT.intContractDetailId = IRI.intContractDetailId
		WHERE intInventoryReceiptId = @InventoryReceiptId and CT.intPricingTypeId = 2
		GROUP BY intInventoryReceiptId
		IF(@ysnHasBasisContract = 1)
		BEGIN
				SELECT @intContractDetailId = MIN(ri.intLineNo)
				FROM tblICInventoryReceipt r 
				JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
				WHERE ri.intInventoryReceiptId = @InventoryReceiptId AND r.strReceiptType = 'Purchase Contract' 
			
				WHILE ISNULL(@intContractDetailId,0) > 0
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId)
					BEGIN
						EXEC uspCTCreateVoucherInvoiceForPartialPricing @intContractDetailId, @intUserId, 0, @InventoryReceiptId
					END
					SELECT @intContractDetailId = MIN(ri.intLineNo)
					FROM tblICInventoryReceipt r 
					JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId					
					WHERE ri.intInventoryReceiptId = @InventoryReceiptId AND r.strReceiptType = 'Purchase Contract' AND ri.intLineNo > @intContractDetailId
					
					
					select @intBillId = intBillId from tblAPBillDetail where intInventoryReceiptItemId in (
						select ri.intInventoryReceiptItemId
						FROM tblICInventoryReceipt r 
							JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId					
								WHERE ri.intInventoryReceiptId = @InventoryReceiptId 
					) and intInventoryReceiptChargeId is null
				END
		END

	SELECT @createVoucher = ysnCreateVoucher, @postVoucher = ysnPostVoucher FROM tblAPVendor WHERE intEntityId = @intEntityId
	IF ISNULL(@createVoucher, 0) = 1 OR ISNULL(@postVoucher, 0) = 1
	BEGIN
		--EXEC [dbo].[uspSCProcessTicketPayables] @intTicketId = @intTicketId, @intInventoryReceiptId = @InventoryReceiptId, @intUserId = @intUserId,@ysnAdd = 1, @strErrorMessage = @ErrorMessage OUT, @intBillId = @intBillId OUT
		IF(@InventoryReceiptId IS NOT NULL and @total > 0 and @ysnHasBasisContract = 0)
		BEGIN
			EXEC dbo.uspICProcessToBill @intReceiptId = @InventoryReceiptId, @intUserId = @intUserId, @intBillId = @intBillId OUT
		END
		IF ISNULL(@intBillId , 0) != 0 AND ISNULL(@postVoucher, 0) = 1
		BEGIN

			--Add contract prepayment to voucher
			BEGIN
				IF OBJECT_ID (N'tempdb.dbo.#tmpContractPrepay') IS NOT NULL
					DROP TABLE #tmpContractPrepay

				CREATE TABLE #tmpContractPrepay (
					[intPrepayId] INT
				);
				DECLARE @Ids as Id
			
				INSERT INTO @Ids(intId)
				SELECT CT.intContractHeaderId 
				FROM tblICInventoryReceiptItem A 
				INNER JOIN tblCTContractDetail CT 
					ON CT.intContractDetailId = A.intContractDetailId
				WHERE A.dblUnitCost > 0
					AND A.intInventoryReceiptId = @InventoryReceiptId
				GROUP BY CT.intContractHeaderId 
				
				

				INSERT INTO #tmpContractPrepay(
					[intPrepayId]
				) 
				SELECT intTransactionId FROM dbo.fnSCGetPrepaidIds(@Ids)
			
				SELECT @total = COUNT(intPrepayId) FROM #tmpContractPrepay where intPrepayId > 0;
				IF (@total > 0)
				BEGIN
					INSERT INTO @prePayId(
						[intId]
					)
					SELECT [intId] = intPrepayId
					FROM #tmpContractPrepay where intPrepayId > 0
				
					IF EXISTS(SELECT 1 FROM tblAPBill WHERE ISNULL(ysnPosted,0)=0 AND intBillId = @intBillId)
					BEGIN
						EXEC uspAPApplyPrepaid @intBillId, @prePayId
					END       
					update tblAPBillDetail set intScaleTicketId = @intTicketId WHERE intBillId = @intBillId
				END
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

		EXEC dbo.uspSMAuditLog 
			@keyValue			= @intTicketId				-- Primary Key Value of the Ticket. 
			,@screenName		= 'Grain.view.Scale'		-- Screen Namespace
			,@entityId			= @intUserId				-- Entity Id.
			,@actionType		= 'Updated'					-- Action Type
			,@changeDescription	= 'Inventory Receipt'		-- Description
			,@fromValue			= ''						-- Old Value
			,@toValue			= @strTransactionId			-- New Value
			,@details			= '';
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