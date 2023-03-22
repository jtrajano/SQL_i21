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
SET ANSI_WARNINGS ON

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
DECLARE @_dblQtyToCompare NUMERIC (38,20)  
DECLARE @_intLoadItemUOM INT
dECLARE @intTicketLoadDetailId INT
DECLARE @_intContractItemUom  INT
DECLARE @_dblContractScheduledQty NUMERIC (38,20)  

DECLARE @_dblContractScheduled NUMERIC(38,20)
DECLARE @_dblContractAvailable NUMERIC(38,20)
DECLARE @_dblCurrentContractAvailable NUMERIC(38,20)
DECLARE @_dblCurrentContractSchedule NUMERIC(38,20)

DECLARE @REFERENCE_ONLY BIT

DECLARE @_tmpContractSchedule TABLE(
	intContractDetailId INT
	,dblScheduleQty NUMERIC (38,20)
	,dblAvailable NUMERIC (38,20)
)

SELECT	
	@intTicketItemUOMId = SC.intItemUOMIdTo
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
	, @intTicketLoadDetailId = SC.intLoadDetailId
	
	, @REFERENCE_ONLY = CASE WHEN SC.intStorageScheduleTypeId = -9 THEN 1 ELSE 0 END
FROM dbo.tblSCTicket SC 
WHERE SC.intTicketId = @intTicketId 


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


SELECT 
	*
INTO #tmpManualDistributionLineItem
FROM @LineItem
WHERE strDistributionOption = @strTicketDistributionOption

INSERT INTO #tmpManualDistributionLineItem
SELECT 
	*
FROM @LineItem
WHERE strDistributionOption <> @strTicketDistributionOption


--GEt the current scheduled Qty of Contracts used
IF OBJECT_ID (N'tempdb.dbo.#tmpContractSchedule') IS NOT NULL
		DROP TABLE #tmpContractSchedule


INSERT INTO @_tmpContractSchedule(
	dblScheduleQty
	,dblAvailable
	,intContractDetailId
)
SELECT 
	dblScheduleQty
	,dblAvailable = ISNULL(dblBalance,0) - ISNULL(dblScheduleQty,0)
	,intContractDetailId
FROM tblCTContractDetail
WHERE intContractDetailId IN (
	SELECT DISTINCT intTransactionDetailId 
	FROM @LineItem
	WHERE intTransactionDetailId IS NOT NULL
)


if @strTicketDistributionOption = 'CNT' and not exists ( select top 1 1 
															from #tmpManualDistributionLineItem
																where strDistributionOption = @strTicketDistributionOption 
																	and intTransactionDetailId = @intTicketContractDetailId)
begin

	exec uspSCCheckContractStatus  @intContractDetailId = @intTicketContractDetailId

end



DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT intTransactionDetailId, dblQty, ysnIsStorage, intId, strDistributionOption , intStorageScheduleId, intStorageScheduleTypeId, intLoadDetailId
FROM #tmpManualDistributionLineItem;

OPEN intListCursor;

		-- Initial fetch attempt
		FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits, @ysnIsStorage, @intId, @strDistributionOption, @intStorageScheduleId, @intStorageScheduleTypeId, @intLoadDetailId;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @ysnDPStorage = NULL
			
			IF ISNULL(@intStorageScheduleTypeId,0) > 0
				SELECT	@ysnDPStorage = ST.ysnDPOwnedType, @ysnCustomerStorage = ysnCustomerStorage FROM dbo.tblGRStorageType ST WHERE ST.intStorageScheduleTypeId = @intStorageScheduleTypeId

			IF @ysnIsStorage = 0 AND ISNULL(@ysnDPStorage,0) = 0 AND (@strDistributionOption IN ('SPT','CNT','LOD'))
				BEGIN
					IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'  
					BEGIN  
						---Get the Initital/original Contract Schedule
						IF NOT EXISTS(SELECT TOP 1 1 FROM  @_tmpContractSchedule WHERE intContractDetailId = @intLoopContractId)
						BEGIN
							INSERT INTO @_tmpContractSchedule(
								dblScheduleQty
								,dblAvailable
								,intContractDetailId
							)
							SELECT 
								dblScheduleQty
								,dblAvailable = ISNULL(dblBalance,0) - ISNULL(dblScheduleQty,0)
								,intContractDetailId
							FROM tblCTContractDetail
							WHERE intContractDetailId = @intLoopContractId
						END

						IF(@strDistributionOption = 'LOD' AND @intLoadDetailId > 0)  
						BEGIN  
							--get contract Detail Id and quantity of the load detail  
							SELECT TOP 1 
								@intLoadContractDetailId = intPContractDetailId 
								,@_dblQuantityPerLoad = dblQuantity
							FROM tblLGLoadDetail 
							WHERE intLoadDetailId = @intLoadDetailId 

							if @intLoadContractDetailId > 0
							begin
								exec uspSCCheckContractStatus  @intContractDetailId = @intLoadContractDetailId
							end

							SET @ysnLoadContract = 0
							SELECT TOP 1 
								@ysnLoadContract = ISNULL(ysnLoad,0)
								,@_intContractItemUom = B.intItemUOMId
								,@_dblContractScheduledQty = B.dblScheduleQty
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
								SET @_dblContractScheduled = 0
								SELECT TOP 1 
									@_dblContractScheduled = dblScheduleQty
									,@_dblContractAvailable = dblAvailable
								FROM @_tmpContractSchedule
								WHERE intContractDetailId = @intLoopContractId


								SET @_dblCurrentContractSchedule = 0
								SET @_dblCurrentContractAvailable = 0
								SELECT TOP 1
									@_dblCurrentContractAvailable =  ISNULL(dblBalance,0) - ISNULL(dblScheduleQty,0)
									,@_dblCurrentContractSchedule = dblScheduleQty
								FROM tblCTContractDetail
								WHERE intContractDetailId = @intLoopContractId



								SELECT TOP 1 
									@_intLoadItemUOM = intItemUOMId
								FROM tblLGLoadDetail WITH(NOLOCK)
								WHERE intLoadDetailId = @intLoadDetailId

								-- SET @_dblContractScheduledQty = dbo.fnCalculateQtyBetweenUOM(@_intContractItemUom,@intTicketItemUOMId,@_dblContractScheduledQty)

								SET @_dblCurrentContractAvailable = dbo.fnCalculateQtyBetweenUOM(@_intContractItemUom,@intTicketItemUOMId,@_dblCurrentContractAvailable)
								SET @_dblCurrentContractSchedule = dbo.fnCalculateQtyBetweenUOM(@_intContractItemUom,@intTicketItemUOMId,@_dblCurrentContractSchedule)
								SET @_dblContractScheduled  = dbo.fnCalculateQtyBetweenUOM(@_intContractItemUom,@intTicketItemUOMId,@_dblContractScheduled)
								
								SET @_dblQtyToCompare = dbo.fnCalculateQtyBetweenUOM(@_intLoadItemUOM,@intTicketItemUOMId,@_dblQuantityPerLoad)	
								
								-- IF (@_dblContractScheduledQty <  @_dblQtyToCompare)
								-- BEGIN
								-- 	SET @dblLoopAdjustedScheduleQuantity = @dblLoopContractUnits - @_dblContractScheduledQty
								-- END
								-- ELSE
								-- BEGIN
									
								-- 	SET @dblLoopAdjustedScheduleQuantity = @dblLoopContractUnits - @_dblQtyToCompare
								-- END

								SET @dblLoopAdjustedScheduleQuantity = @dblLoopContractUnits - @_dblQtyToCompare

								
								IF(@dblLoopAdjustedScheduleQuantity < 0)
								BEGIN
									IF(@_dblContractScheduled <= @dblLoopContractUnits)
									BEGIN
										SET @dblLoopAdjustedScheduleQuantity = @dblLoopContractUnits - @_dblContractScheduled
										
										IF(@dblLoopAdjustedScheduleQuantity >  @_dblCurrentContractAvailable)
										BEGIN
											SET @dblLoopAdjustedScheduleQuantity = @_dblCurrentContractAvailable
										END
									END
								END
								ELSE
								BEGIN
									IF(@_dblCurrentContractAvailable < @dblLoopAdjustedScheduleQuantity)
									BEGIN
										SET @dblLoopAdjustedScheduleQuantity = @_dblCurrentContractAvailable
									END
								END

								IF(@dblLoopAdjustedScheduleQuantity <> 0)
								BEGIN
									EXEC	uspCTUpdateScheduleQuantityUsingUOM 
									@intContractDetailId	=	@intLoopContractId,
									@dblQuantityToUpdate	=	@dblLoopAdjustedScheduleQuantity,
									@intUserId				=	@intUserId,
									@intExternalId			=	@intTicketId,
									@strScreenName			=	'Auto - Scale'
									,@intSourceItemUOMId	=	@intTicketItemUOMId
								END
								
							END

						END  
						ELSE  
						BEGIN
							
							exec uspSCCheckContractStatus  @intContractDetailId = @intLoopContractId

							
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
										EXEC uspCTUpdateScheduleQuantityUsingUOM 
											@intContractDetailId	=	@intLoopContractId
											,@dblQuantityToUpdate	=	@dblLoopAdjustedScheduleQuantity
											,@intUserId				=	@intUserId
											,@intExternalId			=   @intTicketId
											,@strScreenName			=	'Auto - Scale'
											,@intSourceItemUOMId	=	@intTicketItemUOMId
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
								,intSourceTransactionId -- Will be used for the loadDetailid
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
								,intSourceTransactionId = @intLoadDetailId
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
	PRINT 'INVENTORY RECEIPT CREATED : ' + ISNULL(LTRIM(@InventoryReceiptId), '-NO IR CREATED')
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
	
		IF(@ysnTicketHasSpecialDiscount <> 1 OR (@ysnTicketSpecialGradePosted = 1 AND @ysnTicketHasSpecialDiscount = 1))
		BEGIN
			EXEC uspSCProcessReceiptToVoucher @intTicketId, @InventoryReceiptId	,@intUserId, @intBillId OUTPUT
		END


		/*
			this will add load shipment item detail
		*/
		IF @REFERENCE_ONLY = 1
		BEGIN
			DECLARE @CURRENT_RECEIPT_ITEM_ID INT
			DECLARE @CURRENT_RECEIPT_CONTRACT_DETAIL_ID INT
			DECLARE @CURRENT_RECEIPT_QUANTITY NUMERIC(18, 6)
			DECLARE @CURRENT_RECEIPT_ITEM_UOM_ID INT
			DECLARE @CURRENT_LOAD_DETAIL_ID INT

			SELECT @CURRENT_RECEIPT_ITEM_ID = MIN(intInventoryReceiptItemId) 
			FROM tblICInventoryReceiptItem 
			WHERE intInventoryReceiptId = @InventoryReceiptId

			
			EXEC [uspSCTicketClearLoadDetail] @TICKET_ID = @intTicketId, @USER_ID = @intUserId, @DELETE_ALL = 0
			
			WHILE @CURRENT_RECEIPT_ITEM_ID IS NOT NULL
			BEGIN
				
				SELECT 
					@CURRENT_RECEIPT_CONTRACT_DETAIL_ID = intContractDetailId
					, @CURRENT_RECEIPT_QUANTITY = dblReceived
					, @CURRENT_RECEIPT_ITEM_UOM_ID = intWeightUOMId
				FROM tblICInventoryReceiptItem
				WHERE intInventoryReceiptItemId = @CURRENT_RECEIPT_ITEM_ID

				EXEC uspLGGenerateLoadDetail
					 @intLoadId = @intLoadId
					 , @intContractDetailId = @CURRENT_RECEIPT_CONTRACT_DETAIL_ID
					 , @dblQty = @CURRENT_RECEIPT_QUANTITY
					 , @intItemUOMId = @CURRENT_RECEIPT_ITEM_UOM_ID
					 , @intEntityUserId = @intUserId
					 , @intInventoryReceiptItemId = @CURRENT_RECEIPT_ITEM_ID
					 , @intLoadDetailId = @CURRENT_LOAD_DETAIL_ID OUTPUT 
				
				SELECT 
					@CURRENT_RECEIPT_ITEM_ID = MIN(intInventoryReceiptItemId) 
				FROM tblICInventoryReceiptItem 
				WHERE intInventoryReceiptId = @InventoryReceiptId
					AND intInventoryReceiptItemId > @CURRENT_RECEIPT_ITEM_ID


			END


			UPDATE tblLGLoad SET intShipmentStatus = 4 WHERE intLoadId = @intLoadId

			
		END 


		--EXEC uspSCModifyTicketDiscountItemInfo @intTicketId
		
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