CREATE PROCEDURE [dbo].[uspSCManualDistribution]
	@LineItem ScaleManualCostingTableType READONLY,
	@intTicketId AS INT, 
	@intUserId AS INT,
	@intEntityId AS INT,
	@InventoryReceiptId AS INT OUTPUT,
	@intBillId AS INT OUTPUT
	,@ysnSkipValidation as BIT = NULL
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
		,@prePayId AS Id
		,@voucherPayable as VoucherPayable
		,@voucherTaxDetail as VoucherDetailTax
DECLARE @intTicketItemUOMId INT
DECLARE @strReceiptType AS NVARCHAR(100)
DECLARE @intLoadId INT
DECLARE @ysnIsStorage AS BIT
DECLARE @intLoadContractId AS INT
DECLARE @dblLoadScheduledUnits AS NUMERIC(38, 20)
DECLARE @strInOutFlag AS NVARCHAR(100)
DECLARE @strLotTracking AS NVARCHAR(100)
DECLARE @intItemId AS INT
DECLARE @intLoadDetailId AS INT
DECLARE @intStorageScheduleId AS INT
		,@intStorageScheduleTypeId INT
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
		,@dblNetUnits AS NUMERIC(38, 20)
		,@createVoucher AS BIT
		,@postVoucher AS BIT
		,@intLotType INT
		,@intLotId INT
		,@intContractDetailId INT
		,@shipFromEntityId INT
		,@intFarmFieldId INT
		,@ysnCustomerStorage BIT;
DECLARE @dblLoadScheduleQty NUMERIC (38,20)  
DECLARE @intLoadItemUOMId INT  
DECLARE @intLoadContractDetailId INT  
DECLARE @intTicketContractDetailId INT  
DECLARE @dblTicketScheduleQuantity AS NUMERIC(18,6)
DECLARE @dblLoopAdjustedScheduleQuantity NUMERIC (38,20)  
DECLARE @strTicketDistributionOption NVARCHAR(3)
DECLARE @ysnTicketHasSpecialDiscount BIT
DECLARE @ysnTicketSpecialGradePosted BIT
DECLARE @ysnLoadContract BIT
DECLARE @_dblQuantityPerLoad NUMERIC(18,6)
DECLARE @strTicketStatus NVARCHAR(5)
DECLARE @_strReceiptNumber NVARCHAR(50)

SELECT	
	@intTicketItemUOMId = UOM.intItemUOMId
	, @intLoadId = SC.intLoadId
	, @intItemId = SC.intItemId
	, @dblGrossUnits = SC.dblGrossUnits
	, @dblNetUnits = SC.dblNetUnits
	, @shipFromEntityId = SC.intEntityId
	, @intFarmFieldId = SC.intFarmFieldId
	, @intTicketContractDetailId = SC.intContractId
	, @dblTicketScheduleQuantity = ISNULL(SC.dblScheduleQty,0)
	, @strTicketDistributionOption = SC.strDistributionOption
	, @ysnTicketHasSpecialDiscount = SC.ysnHasSpecialDiscount
	, @ysnTicketSpecialGradePosted = SC.ysnSpecialGradePosted
	, @strTicketStatus = SC.strTicketStatus
FROM dbo.tblSCTicket SC JOIN dbo.tblICItemUOM UOM ON SC.intItemId = UOM.intItemId
WHERE SC.intTicketId = @intTicketId AND UOM.ysnStockUnit = 1		

BEGIN TRY
DECLARE @intId INT;
DECLARE @ysnDPStorage AS BIT;
DECLARE @intLoopContractId INT;
DECLARE @dblLoopContractUnits NUMERIC(38, 20);

--Validation
BEGIN

	IF @strTicketStatus = 'C' OR  @strTicketStatus = 'V'
	BEGIN
		RAISERROR('Cannot distribute closed ticket.', 11, 1);
	END

	---Check existing IS and Invoice
	if isnull(@ysnSkipValidation, 0) = 0
	begin
		SELECT TOP 1 
			@_strReceiptNumber = ISNULL(B.strReceiptNumber,'')
		FROM tblICInventoryReceiptItem A
		INNER JOIN tblICInventoryReceipt B
			ON A.intInventoryReceiptId = B.intInventoryReceiptId
		WHERE B.intSourceType = 1
			AND A.intSourceId = @intTicketId

		IF ISNULL(@_strReceiptNumber,'') <> ''
		BEGIN
			SET @ErrMsg  = 'Cannot distribute ticket. Ticket already have a receipt ' + @_strReceiptNumber + '.'
			RAISERROR(@ErrMsg, 11, 1);
		END
	end

END

DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT intTransactionDetailId, dblQty, ysnIsStorage, intId, strDistributionOption , intStorageScheduleId, intStorageScheduleTypeId, intLoadDetailId
FROM @LineItem;

OPEN intListCursor;

		-- Initial fetch attempt
		FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits, @ysnIsStorage, @intId, @strDistributionOption, @intStorageScheduleId, @intStorageScheduleTypeId, @intLoadDetailId;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF ISNULL(@intStorageScheduleTypeId,0) > 0
				SELECT	@ysnDPStorage = ST.ysnDPOwnedType, @ysnCustomerStorage = ysnCustomerStorage FROM dbo.tblGRStorageType ST WHERE ST.intStorageScheduleTypeId = @intStorageScheduleTypeId

			IF @ysnIsStorage = 0 AND ISNULL(@ysnDPStorage,0) = 0 AND (@strDistributionOption IN ('SPT','CNT','LOD'))
				BEGIN
					IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'  
					BEGIN  
						IF(@strDistributionOption = 'LOD' AND @intLoadDetailId > 0)  
						BEGIN  
							--get contract Detail Id and quantity of the load detail  
							SELECT TOP 1 
								@intLoadContractDetailId = intPContractDetailId 
								,@_dblQuantityPerLoad = dblQuantity
							FROM tblLGLoadDetail 
							WHERE intLoadDetailId = @intLoadDetailId 

							SET @ysnLoadContract = 0
							SELECT TOP 1 @ysnLoadContract = ISNULL(ysnLoad,0)
							FROM tblCTContractHeader A
							INNER JOIN tblCTContractDetail B
								ON A.intContractHeaderId = B.intContractHeaderId
							WHERE B.intContractDetailId = @intLoadContractDetailId 
							
							IF(@intLoopContractId = @intLoadContractDetailId)  
							BEGIN   

								EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoopContractId, @dblLoopContractUnits, @intEntityId;  
							END  
							
					
							EXEC dbo.uspSCUpdateTicketLoadUsed @intTicketId, @intLoadDetailId, @dblLoopContractUnits, @intEntityId;   

							-- Adjust the contract Scheduled quantity based on the difference between the quantity/load and the units allocated
							IF(@ysnLoadContract = 0)
							BEGIN
								
								SET @dblLoopAdjustedScheduleQuantity = @dblLoopContractUnits - @_dblQuantityPerLoad 
								IF(@dblLoopAdjustedScheduleQuantity <> 0)
								BEGIN
									EXEC	uspCTUpdateScheduleQuantity 
									@intContractDetailId	=	@intLoopContractId,
									@dblQuantityToUpdate	=	@dblLoopAdjustedScheduleQuantity,
									@intUserId				=	@intUserId,
									@intExternalId			=	@intTicketId,
									@strScreenName			=	'Auto - Scale'
								END
								
							END

						END  
						ELSE  
						BEGIN  
							SET @ysnLoadContract = 0
							SELECT TOP 1 @ysnLoadContract = ISNULL(ysnLoad,0)
							FROM tblCTContractHeader A
							INNER JOIN tblCTContractDetail B
								ON A.intContractHeaderId = B.intContractHeaderId
							WHERE B.intContractDetailId = @intLoopContractId

							-- do not schedule if the contract is the same as the ticket contract since this is already scheduled upon saving the ticket
							IF ISNULL(@intLoopContractId,0) <> 0 AND @strTicketDistributionOption = 'CNT' AND @intTicketContractDetailId = @intLoopContractId  
							BEGIN  
								-- EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Auto - Scale', @intTicketItemUOMId  

								
								IF(@ysnLoadContract = 0)
								BEGIN
									IF(@dblLoopContractUnits > @dblTicketScheduleQuantity )
									BEGIN
										SET @dblLoopAdjustedScheduleQuantity = @dblLoopContractUnits - @dblTicketScheduleQuantity
									END
									ELSE
									BEGIN
										SET @dblLoopAdjustedScheduleQuantity = (@dblTicketScheduleQuantity - @dblLoopContractUnits) * -1
									END
									

									IF @dblLoopAdjustedScheduleQuantity <> 0
									BEGIN
										EXEC	uspCTUpdateScheduleQuantity 
										@intContractDetailId	=	@intLoopContractId,
										@dblQuantityToUpdate	=	@dblLoopAdjustedScheduleQuantity,
										@intUserId				=	@intUserId,
										@intExternalId			=	@intTicketId,
										@strScreenName			=	'Auto - Scale'
									END
								END
								
							END 
							ELSE
							BEGIN
								IF (@ysnLoadContract = 0)
								BEGIN
									EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Auto - Scale', @intTicketItemUOMId  
								END
								ELSE
								BEGIN
									EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, 1, @intUserId, @intTicketId, 'Auto - Scale', @intTicketItemUOMId  
								END
							END 

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
								,intStorageScheduleTypeId
								,ysnAllowVoucher
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
								,intStorageScheduleTypeId = @intStorageScheduleTypeId
								,ysnAllowVoucher
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
								,intStorageScheduleTypeId 
								,ysnAllowVoucher  
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
								,intStorageScheduleTypeId = @intStorageScheduleTypeId
								,ysnAllowVoucher
							FROM @LineItem
							where intId = @intId
					END
					EXEC dbo.uspICValidateProcessToItemReceipt @ItemsForItemReceipt; 
				END
			IF @ysnIsStorage = 1 OR ISNULL(@ysnCustomerStorage, 0) = 1
			BEGIN
				IF @ysnDPStorage = 1
					BEGIN
					SET @strReceiptType = 'Delayed Price'
					INSERT INTO @LineItems (
					intContractDetailId,
					dblUnitsDistributed,
					dblUnitsRemaining,
					dblCost,
					intCurrencyId,
					intLoadDetailId)
					EXEC dbo.uspSCGetContractsAndAllocate 
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
								,intStorageScheduleTypeId
								,ysnAllowVoucher  
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
						,intStorageScheduleTypeId
						,ysnAllowVoucher
					)
					EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblLoopContractUnits , @intEntityId, @strDistributionOption, NULL , @intStorageScheduleId
					END
			END		   
			-- Attempt to fetch next row from cursor
			FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits, @ysnIsStorage, @intId, @strDistributionOption, @intStorageScheduleId, @intStorageScheduleTypeId,@intLoadDetailId;
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
		, @intLocationId = IR.intLocationId
		, @intShipFrom = IR.intShipFromId
		, @vendorOrderNumber = IR.strVendorRefNo 
		, @voucherDate = IR.dtmReceiptDate
		, @intCurrencyId = IR.intCurrencyId
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

	--SELECT @intContractDetailId = MIN(ri.intLineNo)
	--FROM tblICInventoryReceipt r 
	--JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
	--WHERE ri.intInventoryReceiptId = @InventoryReceiptId AND r.strReceiptType = 'Purchase Contract' 
 
	--WHILE ISNULL(@intContractDetailId,0) > 0
	--BEGIN
	--	IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId)
	--	BEGIN
	--		EXEC uspCTCreateVoucherInvoiceForPartialPricing @intContractDetailId, @intUserId
	--	END
	--	SELECT @intContractDetailId = MIN(ri.intLineNo)
	--	FROM tblICInventoryReceipt r 
	--	JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
	--	WHERE ri.intInventoryReceiptId = @InventoryReceiptId AND r.strReceiptType = 'Purchase Contract' AND ri.intLineNo > @intContractDetailId
	--END
	
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
			IF	ISNULL(@intLotId,0) != 0
			EXEC dbo.uspQMSampleCreateForScaleTicket @intItemId,'Inbound Scale Sample', @intLotId, @intUserId, @QualityPropertyValueTable
			FETCH NEXT FROM lotCursor INTO @intLotId;
		END

		CLOSE lotCursor;
		DEALLOCATE lotCursor;
	END
	
	/*
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
		INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId AND ri.dblUnitCost > 0
		LEFT JOIN tblCTContractDetail CT ON CT.intContractDetailId = ri.intLineNo
		LEFT JOIN tblCTPriceFixation CTP ON CTP.intContractDetailId = CT.intContractDetailId
		WHERE ri.intInventoryReceiptId = @InventoryReceiptId AND ri.intOwnershipType = 1 
		AND CTP.intPriceFixationId IS NULL AND ri.ysnAllowVoucher = 1
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
			INSERT INTO @voucherPayable(
				[intTransactionType],
				[intItemId],
				[strMiscDescription],
				[intInventoryReceiptItemId],
				[dblQuantityToBill],
				[dblOrderQty],
				[dblExchangeRate],
				[intCurrencyExchangeRateTypeId],
				[ysnSubCurrency],
				[intAccountId],
				[dblCost],
				[dblOldCost],
				[dblNetWeight],
				[dblNetShippedWeight],
				[dblWeightLoss],
				[dblFranchiseWeight],
				[intContractDetailId],
				[intContractHeaderId],
				[intQtyToBillUOMId],
				[intCostUOMId],
				[intWeightUOMId],
				[intLineNo],
				[dblWeightUnitQty],
				[dblCostUnitQty],
				[dblQtyToBillUnitQty],
				[intCurrencyId],
				[intStorageLocationId],
				[int1099Form],
				[int1099Category],
				[intLoadShipmentDetailId],
				[strBillOfLading],
				[intScaleTicketId],
				[intLocationId],			
				[intShipFromId],
				[intShipToId],
				[intInventoryReceiptChargeId],
				[intPurchaseDetailId],
				[intPurchaseTaxGroupId],
				[dblTax],
				[intEntityVendorId],
				[strVendorOrderNumber],
				[intLoadShipmentId]
			)
			EXEC [dbo].[uspSCGenerateVoucherDetails] @voucherItems,@voucherOtherCharges

			IF EXISTS(SELECT NULL FROM @voucherPayable)
				BEGIN
					INSERT INTO @voucherTaxDetail(
					[intVoucherPayableId]
					,[intTaxGroupId]				
					,[intTaxCodeId]				
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[intAccountId]				
					,[dblTax]					
					,[dblAdjustedTax]			
					,[ysnTaxAdjusted]			
					,[ysnSeparateOnBill]			
					,[ysnCheckOffTax]		
					,[ysnTaxExempt]	
					,[ysnTaxOnly]
					)
					SELECT	[intVoucherPayableId]
							,[intTaxGroupId]				
							,[intTaxCodeId]				
							,[intTaxClassId]				
							,[strTaxableByOtherTaxes]	
							,[strCalculationMethod]		
							,[dblRate]					
							,[intAccountId]				
							,[dblTax]					
							,[dblAdjustedTax]			
							,[ysnTaxAdjusted]			
							,[ysnSeparateOnBill]			
							,[ysnCheckOffTax]		
							,[ysnTaxExempt]	
							,[ysnTaxOnly]
					FROM dbo.fnICGeneratePayablesTaxes(@voucherPayable)
					BEGIN 
						EXEC [dbo].[uspAPCreateVoucher] @voucherPayables = @voucherPayable,@voucherPayableTax = @voucherTaxDetail, @userId = @intUserId,@throwError = 1, @error = @ErrorMessage, @createdVouchersId = @intBillId OUTPUT
					END
				END

		END
		

		SELECT @total = COUNT(1)
		FROM	tblICInventoryReceiptItem ri
		WHERE	ri.intInventoryReceiptId = @InventoryReceiptId
				AND ri.intOwnershipType = 1
				AND ISNULL(ri.ysnAllowVoucher,1) = 1

		DECLARE @ysnHasBasisContract INT = 0;
		DECLARE @ysnHasUnpriced BIT = 1;
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
						EXEC uspCTCreateVoucherInvoiceForPartialPricing @intContractDetailId, @intUserId
						SET @ysnHasUnpriced = 0;
					END
					SELECT @intContractDetailId = MIN(ri.intLineNo)
					FROM tblICInventoryReceipt r 
					JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
					WHERE ri.intInventoryReceiptId = @InventoryReceiptId AND r.strReceiptType = 'Purchase Contract' AND ri.intLineNo > @intContractDetailId
				END
		END

		IF(@InventoryReceiptId IS NOT NULL AND @total > 0 AND @ysnHasBasisContract = 0 OR (@ysnHasUnpriced = 1 AND @ysnHasBasisContract <> 0))
		BEGIN
			EXEC dbo.uspICProcessToBill @intReceiptId = @InventoryReceiptId, @intUserId = @intUserId, @intBillId = @intBillId OUT
		END

		IF ISNULL(@intBillId , 0) != 0 AND ISNULL(@postVoucher, 0) = 1
		BEGIN
			IF OBJECT_ID (N'tempdb.dbo.#tmpContractPrepay') IS NOT NULL
				DROP TABLE #tmpContractPrepay

			CREATE TABLE #tmpContractPrepay (
				[intPrepayId] INT
			);

			DECLARE @Ids as Id
			
			INSERT INTO @Ids(intId)
			SELECT CT.intContractHeaderId FROM #tmpReceiptItem tmp 
			INNER JOIN tblCTContractDetail CT ON CT.intContractDetailId = tmp.intContractDetailId
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
		*/

		IF(@ysnTicketHasSpecialDiscount <> 1 OR (@ysnTicketSpecialGradePosted = 1 AND @ysnTicketHasSpecialDiscount = 1))
		BEGIN
			EXEC uspSCProcessReceiptToVoucher @intTicketId, @InventoryReceiptId	,@intUserId, @intBillId OUTPUT
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
