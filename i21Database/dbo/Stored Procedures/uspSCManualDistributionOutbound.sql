CREATE PROCEDURE [dbo].[uspSCManualDistributionOutbound]
	@LineItem ScaleManualCostingTableType READONLY,
	@intTicketId AS INT, 
	@intUserId AS INT,
	@intEntityId AS INT,
	@InventoryShipmentId AS INT OUTPUT ,
	@intInvoiceId AS INT OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @ItemsForItemShipment AS ItemCostingTableType
DECLARE @total AS INT
DECLARE @ErrMsg NVARCHAR(MAX)
DECLARE @strTransactionId NVARCHAR(40) = NULL
DECLARE @strDistributionOption NVARCHAR(50) = NULL

DECLARE @LineItems AS ScaleTransactionTableType
DECLARE @intDirectType AS INT = 3
DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT
DECLARE @strReceiptType AS NVARCHAR(100)
DECLARE @intOrderId AS INT
DECLARE @intLoadId AS INT
DECLARE @intScaleStationId AS INT
DECLARE @intFreightItemId AS INT
DECLARE @intFreightVendorId AS INT
DECLARE @ysnIsStorage AS BIT
DECLARE @intLoadContractId AS INT
DECLARE @dblLoadScheduledUnits AS NUMERIC(38,20)
DECLARE @strInOutFlag AS NVARCHAR(100)
DECLARE @strLotTracking AS NVARCHAR(100)
DECLARE @intItemId AS INT
DECLARE @intLoadDetailId AS INT
DECLARE @intStorageScheduleId AS INT
		,@intStorageScheduleTypeId INT
		,@intInventoryShipmentItemId AS INT
		,@intOwnershipType AS INT
		,@intPricingTypeId AS INT
		,@intShipmentOrderId AS INT
		,@successfulCount AS INT
		,@invalidCount AS INT
		,@success AS INT
		,@batchIdUsed AS INT
		,@recapId AS INT
		,@strWhereFinalizedWeight NVARCHAR(20)
		,@strWhereFinalizedGrade NVARCHAR(20)
		,@ysnCustomerStorage BIT
		,@intContractDetailId INT
		,@ysnPriceFixation BIT = 0
		,@ysnAllowInvoiceVoucher BIT = 0
		,@ysnUpdateContractWeightGrade BIT = 0;

DECLARE @intLoadContractDetailId INT  
DECLARE @intTicketContractDetailId INT  
DECLARE @dblTicketScheduleQuantity AS NUMERIC(18,6)
DECLARE @_dblTicketScheduleQuantity AS NUMERIC(18,6)
DECLARE @dblLoopAdjustedScheduleQuantity NUMERIC (38,20)  
DECLARE @strTicketDistributionOption NVARCHAR(3)
DECLARE @intTicketLoadDetailId INT  
DECLARE @_intContractDetailId INT
DECLARE @__intContractDetailId INT
DECLARE @_intContractItemUom INT


SELECT @ysnUpdateContractWeightGrade  = CASE WHEN intContractId IS NULL AND strDistributionOption = 'CNT' AND (intWeightId IS NULL AND intGradeId IS NULL ) THEN 1 ELSE 0 END FROM tblSCTicket WHERE intTicketId = @intTicketId
IF (@ysnUpdateContractWeightGrade = 1)
BEGIN
	DECLARE @intContractId int;
	SELECT TOP 1 @intContractId = intTransactionDetailId FROM @LineItem ORDER BY intId ASC
	
	UPDATE SC
	SET  SC.intWeightId = ContractDetail.intWeightId
		,SC.intGradeId = ContractDetail.intGradeId
	FROM tblSCTicket SC
	OUTER APPLY (SELECT TOP 1 CH.* FROM @LineItem LI 
								INNER JOIN tblCTContractDetail CD on CD.intContractDetailId = LI.intTransactionDetailId 
								INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				 ORDER BY intId ASC) ContractDetail
WHERE intTicketId = @intTicketId
END

SELECT @intTicketItemUOMId = intItemUOMIdTo
	, @intLoadId = intLoadId
	, @intItemId = intItemId 
	, @strWhereFinalizedWeight = strWeightFinalized
	, @strWhereFinalizedGrade = strGradeFinalized
	, @strInOutFlag = strInOutFlag
	, @intLoadId = intLoadId
	,@strTicketDistributionOption  = strDistributionOption
	, @dblTicketScheduleQuantity = ISNULL(dblScheduleQty,0)
	, @_dblTicketScheduleQuantity = ISNULL(dblScheduleQty,0)
	, @intTicketContractDetailId = intContractId
	, @intTicketLoadDetailId = intLoadDetailId
FROM vyuSCTicketScreenView where intTicketId = @intTicketId



BEGIN TRY
DECLARE @intId INT;
DECLARE @ysnDPStorage AS BIT;
DECLARE @intLoopContractId INT;
DECLARE @dblLoopContractUnits NUMERIC(38,20);
DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT intTransactionDetailId, dblQty, ysnIsStorage, intId, strDistributionOption , intStorageScheduleId, intStorageScheduleTypeId, ysnAllowVoucher, intLoadDetailId
FROM @LineItem;

OPEN intListCursor;

		-- Initial fetch attempt
		FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits, @ysnIsStorage, @intId, @strDistributionOption, @intStorageScheduleId, @intStorageScheduleTypeId, @ysnAllowInvoiceVoucher, @intLoadDetailId;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF ISNULL(@intStorageScheduleTypeId,0) > 0
				SELECT	@ysnDPStorage = ST.ysnDPOwnedType, @ysnCustomerStorage = ysnCustomerStorage FROM dbo.tblGRStorageType ST WHERE ST.intStorageScheduleTypeId = @intStorageScheduleTypeId

			
			SELECT TOP 1
				@_intContractItemUom = intItemUOMId
			FROM tblCTContractDetail
			WHERE intContractDetailId = @intContractDetailId

			SET @dblTicketScheduleQuantity = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId,@_intContractItemUom,@_dblTicketScheduleQuantity)

			IF @ysnIsStorage = 0 AND ISNULL(@intStorageScheduleTypeId, 0) <= 0
				BEGIN
					IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
					BEGIN
						-- IF ISNULL(@intLoopContractId,0) != 0 AND @strDistributionOption = 'CNT'
						-- EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
						-- EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoopContractId, @dblLoopContractUnits, @intEntityId;

						-- IF(@strDistributionOption = 'LOD' AND @intLoadDetailId > 0)
						-- BEGIN
						-- 	EXEC dbo.uspSCUpdateTicketLoadUsed @intTicketId, @intLoadDetailId, @dblLoopContractUnits, @intEntityId;	
						-- END

						IF(@strDistributionOption = 'LOD' AND @intLoadDetailId > 0)  
						BEGIN  
							--get contract Detail Id of the load detail  
							SELECT @intLoadContractDetailId = intPContractDetailId FROM tblLGLoadDetail WHERE intLoadDetailId = @intLoadDetailId  
							
							IF(@intLoopContractId = @intLoadContractDetailId)  
							BEGIN   

								EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoopContractId, @dblLoopContractUnits, @intEntityId;  
							END  

							
					
							EXEC dbo.uspSCUpdateTicketLoadUsed @intTicketId, @intLoadDetailId, @dblLoopContractUnits, @intEntityId;   

							IF(@intLoadDetailId = @intTicketLoadDetailId)
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

							-- do not schedule if the contract is the same as the ticket contract since this is already scheduled upon saving the ticket
							IF ISNULL(@intLoopContractId,0) <> 0 AND @strTicketDistributionOption = 'CNT' AND @intTicketContractDetailId = @intLoopContractId  
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
							ELSE
							BEGIN
								EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId  
							END

							EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoopContractId, @dblLoopContractUnits, @intEntityId;  
						END 


						INSERT INTO @ItemsForItemShipment (
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
								,ysnAllowVoucher   
							FROM @LineItem
							where intId = @intId
					END
					ELSE
						BEGIN
						INSERT INTO @ItemsForItemShipment (
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
								,ysnAllowVoucher 
							FROM @LineItem
							where intId = @intId
					END
					EXEC dbo.uspICValidateProcessToItemReceipt @ItemsForItemShipment; 
				END
			IF @ysnIsStorage = 1 OR ISNULL(@ysnCustomerStorage, 0) = 1
			BEGIN
				IF @ysnDPStorage = 1
					BEGIN
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

					SET @dblLoopContractUnits = @dblLoopContractUnits * -1
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
							INSERT INTO @ItemsForItemShipment (
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
							EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblLoopContractUnits , @intEntityId, @strDistributionOption, @intDPContractId
							EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intDPContractId, @dblDPContractUnits, @intEntityId, @ysnIsStorage;
						-- Attempt to fetch next row from cursor
						FETCH NEXT FROM intListCursorDP INTO @intLoopContractId, @dblDPContractUnits;
					END;

					CLOSE intListCursorDP;
					DEALLOCATE intListCursorDP;
				END
				ELSE
					BEGIN
					SET @dblLoopContractUnits = @dblLoopContractUnits * -1
					INSERT INTO @ItemsForItemShipment (
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
						,intStorageScheduleTypeId
						,ysnAllowVoucher
					)
					EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblLoopContractUnits , @intEntityId, @strDistributionOption, NULL , @intStorageScheduleId
					END
			END		   
			-- Attempt to fetch next row from cursor
			FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits, @ysnIsStorage, @intId, @strDistributionOption, @intStorageScheduleId, @intStorageScheduleTypeId,@ysnAllowInvoiceVoucher, @intLoadDetailId;
		END;

CLOSE intListCursor;
DEALLOCATE intListCursor;

SELECT @total = COUNT(*) FROM @ItemsForItemShipment;
IF (@total = 0)
	RETURN;

SELECT TOP 1 @strDistributionOption = strSourceTransactionId FROM @ItemsForItemShipment WHERE (strSourceTransactionId = 'LOD' OR strSourceTransactionId = 'CNT');
IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
BEGIN
 	SET @intOrderId = 1
END
ELSE
BEGIN
 	SET @intOrderId = 4
END

	EXEC dbo.uspSCAddScaleTicketToItemShipment @intTicketId ,@intUserId ,@ItemsForItemShipment ,@intEntityId ,@intOrderId ,@InventoryShipmentId OUTPUT;

	SELECT	@strTransactionId = ship.strShipmentNumber
	FROM	dbo.tblICInventoryShipment ship	        
	WHERE	ship.intInventoryShipmentId = @InventoryShipmentId		

	EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @intUserId;

	SELECT 
		@intContractDetailId = MIN(si.intLineNo)
    FROM tblICInventoryShipment s 
    JOIN tblICInventoryShipmentItem si 
		ON si.intInventoryShipmentId = s.intInventoryShipmentId
    WHERE si.intInventoryShipmentId = @InventoryShipmentId AND s.intOrderType = 1

	SET @_intContractDetailId = @intContractDetailId
	SET @__intContractDetailId = @intContractDetailId
 
 
	--INVOICE intergration
	/*
	SELECT @intPricingTypeId = CTD.intPricingTypeId FROM tblICInventoryShipmentItem ISI 
	LEFT JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = ISI.intLineNo
	WHERE intInventoryShipmentId = @InventoryShipmentId

	IF ISNULL(@InventoryShipmentId, 0) != 0 AND (ISNULL(@intPricingTypeId,0) <= 1 OR ISNULL(@intPricingTypeId,0) = 6) AND ISNULL(@strWhereFinalizedWeight, 'Origin') = 'Origin' AND ISNULL(@strWhereFinalizedGrade, 'Origin') = 'Origin' AND @ysnPriceFixation = 0
		BEGIN
			EXEC @intInvoiceId = dbo.uspARCreateInvoiceFromShipment @InventoryShipmentId, @intUserId, NULL, 0, 1;
			IF @intInvoiceId = 0
				SET @intInvoiceId = NULL
		END
	ELSE
		IF (@intPricingTypeId = 2)
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId)
				EXEC uspCTCreateVoucherInvoiceForPartialPricing @intContractDetailId, @intUserId
		END
			SELECT @intInvoiceId = id.intInvoiceId
			FROM tblICInventoryShipment s 
			JOIN tblICInventoryShipmentItem si ON si.intInventoryShipmentId = s.intInventoryShipmentId
			join tblARInvoiceDetail id on id.intInventoryShipmentItemId = si.intInventoryShipmentItemId
			WHERE si.intInventoryShipmentId = @InventoryShipmentId AND s.intOrderType = 1
	*/

	IF ISNULL(@InventoryShipmentId, 0) != 0 AND EXISTS(SELECT TOP 1 1 FROM tblICInventoryShipmentItem WHERE ysnAllowInvoice = 1 AND intInventoryShipmentId = @InventoryShipmentId)
	BEGIN
		EXEC @intInvoiceId = dbo.uspARCreateInvoiceFromShipment @InventoryShipmentId, @intUserId, NULL, 0, 1;
	END

	WHILE ISNULL(@_intContractDetailId,0) > 0
	BEGIN

		IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = @_intContractDetailId)
		BEGIN
			EXEC uspCTCreateVoucherInvoiceForPartialPricing @_intContractDetailId, @intUserId
		END


		SET @_intContractDetailId = NULL

		SELECT 
			@_intContractDetailId = MIN(si.intLineNo)
		FROM tblICInventoryShipment s 
		JOIN tblICInventoryShipmentItem si ON si.intInventoryShipmentId = s.intInventoryShipmentId
		WHERE si.intInventoryShipmentId = @InventoryShipmentId AND s.intOrderType = 1
			AND ISNULL(intLineNo,0) > @__intContractDetailId

		SET @__intContractDetailId = @_intContractDetailId
	END

	EXEC dbo.uspSMAuditLog 
		@keyValue			= @intTicketId				-- Primary Key Value of the Ticket. 
		,@screenName		= 'Grain.view.Scale'		-- Screen Namespace
		,@entityId			= @intUserId				-- Entity Id.
		,@actionType		= 'Updated'					-- Action Type
		,@changeDescription	= 'Inventory Shipment'		-- Description
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