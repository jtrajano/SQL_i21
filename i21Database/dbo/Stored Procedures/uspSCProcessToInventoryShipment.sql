CREATE PROCEDURE [dbo].[uspSCProcessToInventoryShipment]
	 @intSourceTransactionId AS INT
	,@strSourceType AS NVARCHAR(100) 
	,@intUserId AS INT
	,@dblNetUnits AS DECIMAL (38,20)
	,@dblCost AS DECIMAL (9,5)
	,@intEntityId AS INT
	,@intContractId AS INT
	,@strDistributionOption AS NVARCHAR(3)
	,@intStorageScheduleId AS INT = NULL
	,@InventoryShipmentId AS INT OUTPUT
	,@intInvoiceId AS INT = NULL OUTPUT
	,@dtmClientDate DATETIME = NULL
	,@ysnSkipValidation as BIT = NULL
	,@intNewTicketId AS INT = NULL OUTPUT
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
DECLARE @intTicketId AS INT = @intSourceTransactionId
DECLARE @dblRemainingUnits AS DECIMAL (38,20)
DECLARE @dblRemainingQuantity AS DECIMAL (38,20)
DECLARE @dblRemainingUnitStorage AS DECIMAL (38,20)
DECLARE @LineItems AS ScaleTransactionTableType
DECLARE @strTransactionId NVARCHAR(40) = NULL
DECLARE @intDirectType AS INT = 3
DECLARE @intTicketItemUOMId INT
DECLARE @intOrderId INT
DECLARE @intLoadId INT
DECLARE @dblTicketFreightRate AS DECIMAL (9, 5)
DECLARE @intScaleStationId AS INT
DECLARE @intFreightItemId AS INT
DECLARE @intFreightVendorId AS INT
DECLARE @ysnDeductFreightFarmer AS BIT
DECLARE @strLotTracking AS NVARCHAR(100)
DECLARE @totalShipment AS INT
DECLARE @totalContract AS INT
DECLARE @intInventoryShipmentItemId AS INT
		,@intOwnershipType AS INT
		,@intItemId INT
		,@intPricingTypeId AS INT
		,@intShipmentOrderId AS INT
		,@successfulCount AS INT
		,@invalidCount AS INT
		,@success AS INT
		,@batchIdUsed AS NVARCHAR(100)
		,@recapId AS INT
		,@dblQtyShipped AS DECIMAL (18,6)
		,@strWhereFinalizedWeight NVARCHAR(20)
		,@strWhereFinalizedGrade NVARCHAR(20)
		,@ysnDPStorage AS BIT
		,@intContractDetailId INT
		,@ysnPriceFixation BIT = 0;
DECLARE @intTicketLoadDetailId INT
DECLARE @intTicketItemContractDetailId INT
DECLARE @dblLoopItemContractUnits NUMERIC(38,20)
DECLARE @dblPrevLoopItemContractId int
DECLARE @dblLoopItemContractId int
DECLARE @intTicketStorageScheduleTypeId INT
DECLARE @strNewTicketNumber NVARCHAR(50)
DECLARE @ysnTicketMultipleTicket BIT
DECLARE @intTicketAGWorkOrderId INT


DECLARE @loopLoadDetailId INT
DECLARE @strTicketStatus NVARCHAR(3)
DECLARE @_strShipmentNumber NVARCHAR(50)
DECLARE @strOwnedPhysicalStock NVARCHAR(20)
DECLARE @OWNERSHIP_CUSTOMER NVARCHAR(20)
DECLARE @dblAGWorkOrderReserveQuantity NUMERIC(38,20)
DECLARE @strTicketNumber NVARCHAR(50)
DECLARE @_strAuditDescription NVARCHAR(500)
dECLARE @dblTicketNetUnits NUMERIC(38,20)

SET @OWNERSHIP_CUSTOMER = 'CUSTOMER'

SELECT @intLoadId = intLoadId
	, @dblTicketFreightRate = dblFreightRate
	, @intScaleStationId = intScaleSetupId
	, @ysnDeductFreightFarmer = ysnFarmerPaysFreight
	, @strWhereFinalizedWeight = strWeightFinalized
	, @strWhereFinalizedGrade = strGradeFinalized
	, @intTicketItemUOMId = intItemUOMIdTo
	, @intItemId = intItemId
	, @intTicketLoadDetailId = intLoadDetailId
	, @intTicketItemContractDetailId = intItemContractDetailId
	,@strTicketStatus = strTicketStatus
	,@intTicketStorageScheduleTypeId = intStorageScheduleTypeId
	,@ysnTicketMultipleTicket = ysnMultipleTicket
	,@intTicketAGWorkOrderId = intAGWorkOrderId
	,@strTicketNumber = strTicketNumber
	,@dblTicketNetUnits = dblNetUnits
FROM vyuSCTicketScreenView where intTicketId = @intTicketId

SELECT	@ysnDPStorage = ST.ysnDPOwnedType
	,@strOwnedPhysicalStock = UPPER(strOwnedPhysicalStock)
FROM dbo.tblGRStorageType ST WHERE 
ST.strStorageTypeCode = @strDistributionOption

DECLARE @ErrMsg              NVARCHAR(MAX),
        @dblBalance          NUMERIC(12,4),                    
        @dblNewBalance       NUMERIC(12,4),
        @strInOutFlag        NVARCHAR(4),
        @dblQuantity         NUMERIC(12,4),
        @strAdjustmentNo     NVARCHAR(50);
BEGIN TRY
		IF @strDistributionOption = 'LOD' AND  @intLoadId IS NULL
		BEGIN
			RAISERROR('Unable to find load details. Try Again.', 11, 1);
			GOTO _Exit
		END

		IF @strTicketStatus = 'C' OR  @strTicketStatus = 'V'
		BEGIN
			RAISERROR('Cannot distribute closed ticket.', 11, 1);
			GOTO _Exit
		END

		---Check existing IS and Invoice
		if isnull(@ysnSkipValidation, 0) = 0
		begin
			SELECT TOP 1 
				@_strShipmentNumber = ISNULL(B.strShipmentNumber,'')
			FROM tblICInventoryShipmentItem A
			INNER JOIN tblICInventoryShipment B
				ON A.intInventoryShipmentId = B.intInventoryShipmentId
			LEFT JOIN tblARInvoiceDetail C
				ON A.intInventoryShipmentItemId = ISNULL(C.intInventoryShipmentItemId,0)
			LEFT JOIN tblARInvoice D
				ON ISNULL(D.intInvoiceId,0) = ISNULL(C.intInvoiceId,0)
			LEFT JOIN tblARInvoiceDetail E
				ON ISNULL(C.intInvoiceDetailId,0) = ISNULL(E.intOriginalInvoiceDetailId,0)
			WHERE B.intSourceType = 1
				AND A.intSourceId = @intTicketId
				AND D.strTransactionType = 'Invoice'
				AND E.intInvoiceDetailId IS NULL

			IF ISNULL(@_strShipmentNumber,'') <> ''
			BEGIN
				SET @ErrMsg  = 'Cannot distribute ticket. Ticket already have a shipment ' + @_strShipmentNumber + '.'
				RAISERROR(@ErrMsg, 11, 1);
				GOTO _Exit
			END
		end
		
		

 		SET @intOrderId = CASE WHEN @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD' THEN 1 ELSE 4 END

		IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
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
				,@dblNetUnits
				,@intContractId
				,@intUserId
				,0
				,0
				,1
				,@strDistributionOption
				,@intTicketLoadDetailId
			-- IF @strDistributionOption = 'CNT'
			-- BEGIN
				DECLARE @intLoopContractId INT;
				DECLARE @dblLoopContractUnits NUMERIC(38,20);
				DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
				FOR
				SELECT intContractDetailId, dblUnitsDistributed,intLoadDetailId
				FROM @LineItems;

				OPEN intListCursor;

				-- Initial fetch attempt
				FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits,@loopLoadDetailId;

				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF ISNULL(@intLoopContractId,0) != 0
					BEGIN
						--    EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
						EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoopContractId, @dblLoopContractUnits, @intEntityId;
					END

					IF ISNULL(@loopLoadDetailId,0) != 0 AND @strDistributionOption = 'LOD'
					BEGIN
						EXEC dbo.uspSCUpdateTicketLoadUsed @intTicketId,@loopLoadDetailId, @dblLoopContractUnits, @intEntityId;
					END

				   -- Attempt to fetch next row from cursor
				   FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits,@loopLoadDetailId;
				END;

				CLOSE intListCursor;
				DEALLOCATE intListCursor;
			-- END
			-- ELSE IF @strDistributionOption = 'LOD'
			-- BEGIN
			-- 	DECLARE @intLoadContractId INT;
			-- 	DECLARE @dblLoadContractUnits NUMERIC(38,20);
			-- 	DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
			-- 	FOR
			-- 	SELECT intContractDetailId, dblUnitsDistributed
			-- 	FROM @LineItems;

			-- 	OPEN intListCursor;

			-- 	-- Initial fetch attempt
			-- 	FETCH NEXT FROM intListCursor INTO @intLoadContractId, @dblLoadContractUnits;

			-- 	WHILE @@FETCH_STATUS = 0
			-- 	BEGIN
			-- 		IF ISNULL(@intLoadContractId,0) != 0
			-- 		BEGIN
			-- 			SELECT @intContractDetailId = intContractDetailId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId
			-- 			IF @intContractDetailId != @intContractId
			-- 			BEGIN
			-- 				EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoadContractId, @dblLoadContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
			-- 				EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoadContractId, @dblLoadContractUnits, @intEntityId;
			-- 				EXEC dbo.uspSCUpdateTicketLoadUsed @intTicketId, @intLoadId, @dblLoopContractUnits, @intEntityId;	
			-- 			END
			-- 		END
			-- 	   -- Attempt to fetch next row from cursor
			-- 	   FETCH NEXT FROM intListCursor INTO @intLoadContractId, @dblLoadContractUnits;
			-- 	END;
			-- 	CLOSE intListCursor;
			-- 	DEALLOCATE intListCursor;
			-- END

			SELECT TOP 1 @dblRemainingUnits = LI.dblUnitsRemaining FROM @LineItems LI
			IF(@dblRemainingUnits IS NULL)
			BEGIN
				SET @dblRemainingUnits = @dblNetUnits
			END
			IF(@dblRemainingUnits > 0)
			BEGIN
				SET @dblRemainingUnitStorage = (@dblRemainingUnits *-1);
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
						,intStorageLocationId
						,ysnIsStorage
						,strSourceTransactionId 
						,intStorageScheduleTypeId
						,ysnAllowVoucher
					)
					EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblRemainingUnitStorage , @intEntityId, @strDistributionOption, NULL

					SELECT TOP 1 @dblQtyShipped = dblQty FROM @ItemsForItemShipment IIS
					SET @dblRemainingUnits = (@dblRemainingUnits - CASE WHEN ISNULL(@dblQtyShipped,0) = 0 THEN 0 ELSE (@dblRemainingUnitStorage * -1) END)
					IF(@dblRemainingUnits > 0)
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
								,ysnAllowVoucher
							)
							EXEC dbo.uspSCGetScaleItemForItemShipment
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
			END
				UPDATE @LineItems set intTicketId = @intTicketId
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
					,ysnAllowVoucher
				)
				EXEC dbo.uspSCGetScaleItemForItemShipment
					@intTicketId
					,@strSourceType
					,@intUserId
					,@dblRemainingUnits
					,@dblCost
					,@intEntityId
					,@intContractId
					,@strDistributionOption
					,@LineItems

			-- Validate the items to shipment
			EXEC dbo.uspICValidateProcessToInventoryShipment @ItemsForItemShipment;

			SELECT @totalShipment = COUNT(*) FROM @ItemsForItemShipment;
			IF (@totalShipment = 0)
				RETURN;
		END
		ELSE
		BEGIN
			IF @strDistributionOption = 'ICN'
			BEGIN
				INSERT INTO @LineItems (
				intTicketId,
				intContractDetailId,
				dblUnitsDistributed,
				dblUnitsRemaining,
				dblCost,
				intCurrencyId)
				EXEC dbo.uspSCGetItemContractsAndAllocate
				 @intTicketId
				,@intEntityId
				,@dblNetUnits
				,@intTicketItemContractDetailId
				,@intUserId


				SET @intLoopContractId = NULL

				SELECT TOP 1
					@dblPrevLoopItemContractId = intContractDetailId
					,@dblLoopItemContractId = intContractDetailId
					,@dblLoopItemContractUnits = dblUnitsDistributed
				FROM @LineItems ORDER BY intContractDetailId ASC

				WHILE ISNULL(@dblLoopItemContractId,0) > 0
				BEGIN
					EXEC dbo.uspSCUpdateTicketItemContractUsed @intTicketId, @dblLoopItemContractId, @dblLoopItemContractUnits, @intEntityId;

					SET @dblLoopItemContractId = NULL
					SELECT TOP 1
						@dblPrevLoopItemContractId = intContractDetailId
						,@dblLoopItemContractId = intContractDetailId
						,@dblLoopItemContractUnits = dblUnitsDistributed
					FROM @LineItems
					WHERE intContractDetailId > @dblPrevLoopItemContractId
					ORDER BY intContractDetailId ASC
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
					,ysnAllowVoucher
				)
				EXEC dbo.uspSCGetScaleItemForItemShipment
				@intTicketId
				,@strSourceType
				,@intUserId
				,@dblRemainingUnits
				,@dblCost
				,@intEntityId
				,@intContractId
				,@strDistributionOption
				,@LineItems
			END
			ELSE
			BEGIN
				IF @strDistributionOption = 'SPT'
				BEGIN
					UPDATE @LineItems set intTicketId = @intTicketId
						--DELETE FROM @ItemsForItemReceipt
						-- Get the items to process
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
							,ysnAllowVoucher
						)
						EXEC dbo.uspSCGetScaleItemForItemShipment
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
					EXEC dbo.uspICValidateProcessToInventoryShipment @ItemsForItemShipment;
				END
				ELSE
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
						,@dblNetUnits
						,@intContractId
						,@intUserId
						,@ysnDPStorage
						SET @dblNetUnits = @dblNetUnits * -1;
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
									,intStorageScheduleTypeId
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
					IF(@dblRemainingUnits IS NULL)
						SET @dblRemainingUnits = (@dblNetUnits * -1)

					IF(@intTicketStorageScheduleTypeId  <> -9)
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
							,intStorageScheduleTypeId
							,ysnAllowVoucher
						)
						EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblRemainingUnits , @intEntityId, @strDistributionOption, NULL, @intStorageScheduleId
						SELECT TOP 1 @dblRemainingUnitStorage = dblQty FROM @ItemsForItemShipment IIS

						IF @strOwnedPhysicalStock = @OWNERSHIP_CUSTOMER AND ABS(@dblRemainingUnits) > 0 
							and  @dblNetUnits > ISNULL(@dblRemainingUnitStorage, 0)
						BEGIN
							SET @ErrMsg  = 'Cannot distribute ticket. Not enough storage unit.'
							RAISERROR(@ErrMsg, 11, 1);	
						END

						SET @dblRemainingUnits = (@dblRemainingUnits + ISNULL(@dblRemainingUnitStorage, 0)) * -1
						IF (@dblRemainingUnits > 0)
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
								,@dblRemainingUnits
								,NULL
								,@intUserId
								,0
							BEGIN
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
								IF	ISNULL(@intLoopContractId,0) != 0
								EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
								EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoopContractId, @dblLoopContractUnits, @intEntityId;
								SET @dblRemainingUnits -=@dblLoopContractUnits;
								-- Attempt to fetch next row from cursor
								FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits;
								END;

								CLOSE intListCursor;
								DEALLOCATE intListCursor;
							END
							SELECT @totalContract = COUNT(intContractDetailId) FROM @LineItems
							IF(@totalContract > 0)
							BEGIN
								UPDATE @LineItems set intTicketId = @intTicketId
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
									,ysnAllowVoucher
								)
								EXEC dbo.uspSCGetScaleItemForItemShipment
									@intTicketId
									,@strSourceType
									,@intUserId
									,@dblRemainingUnits
									,0
									,@intEntityId
									,NULL
									,'CNT'
									,@LineItems
							END
							IF(@dblRemainingUnits > 0)
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
									,ysnAllowVoucher
								)
								EXEC dbo.uspSCGetScaleItemForItemShipment
									@intTicketId
									,@strSourceType
									,@intUserId
									,@dblRemainingUnits
									,0
									,@intEntityId
									,NULL
									,'SPT'
									,@LineItems
							END
							SET @dblRemainingUnits = 0
						END
					END
					---- AG Work Order
					ELSE
					BEGIN
						SET @dblRemainingUnits = @dblNetUnits
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
							,ysnAllowVoucher
						)
						EXEC dbo.uspSCGetScaleItemForItemShipment
							@intTicketId
							,@strSourceType
							,@intUserId
							,@dblRemainingUnits
							,@dblCost
							,@intEntityId
							,NULL
							,'AWO'
							,@LineItems

						----------Remove the reservation from WorkOrder for the Item in ticket

						EXEC [uspSCUpdateAGWorkOrderItemReservation] @intTicketAGWorkOrderId, @intTicketId,@intItemId, 1

					END
				END
			END
		END

	SELECT @strWhereFinalizedWeight = strWeightFinalized
		 , @strWhereFinalizedGrade = strGradeFinalized
	FROM vyuSCTicketScreenView where intTicketId = @intTicketId

	EXEC dbo.uspSCAddScaleTicketToItemShipment @intTicketId ,@intUserId ,@ItemsForItemShipment ,@intEntityId ,@intOrderId ,@InventoryShipmentId OUTPUT;

	SELECT	@strTransactionId = ship.strShipmentNumber
	FROM	dbo.tblICInventoryShipment ship	        
	WHERE	ship.intInventoryShipmentId = @InventoryShipmentId		
	
	EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @intUserId;

	IF(@intTicketStorageScheduleTypeId <> -9)
	BEGIN
		EXEC uspSCProcessShipmentToInvoice 
			@intTicketId = @intTicketId
			,@intInventoryShipmentId = @InventoryShipmentId
			,@intUserId = @intUserId
			,@intInvoiceId = @intInvoiceId OUTPUT 
			,@dtmClientDate = @dtmClientDate
			
		SELECT @intInvoiceId = id.intInvoiceId
		FROM tblICInventoryShipment s 
		JOIN tblICInventoryShipmentItem si ON si.intInventoryShipmentId = s.intInventoryShipmentId
		join tblARInvoiceDetail id on id.intInventoryShipmentItemId = si.intInventoryShipmentItemId
		WHERE si.intInventoryShipmentId = @InventoryShipmentId AND s.intOrderType = 1
	END

	-- WORK ORDER
	ELSE
	BEGIN
		--Create New Ticket 
		IF(@ysnTicketMultipleTicket  = 1 AND ISNULL(@InventoryShipmentId,0) > 0)
		BEGIN
			EXEC uspSMGetStartingNumber 79, @strNewTicketNumber output
			--tblSCTicket
			INSERT INTO [dbo].[tblSCTicket]
				([strTicketStatus]
				,[strTicketNumber]
				,[strOriginalTicketNumber]
				,[intScaleSetupId]
				,[intTicketPoolId]
				,[intTicketLocationId]
				,[intTicketType]
				,[strInOutFlag]
				,[dtmTicketDateTime]
				,[dtmTicketTransferDateTime]
				,[dtmTicketVoidDateTime]
				,[dtmTransactionDateTime]
				,[intProcessingLocationId]
				,[intTransferLocationId]
				,[strScaleOperatorUser]
				,[intEntityScaleOperatorId]
				,[strTruckName]
				,[strDriverName]
				,[ysnDriverOff]
				,[ysnSplitWeightTicket]
				,[ysnGrossManual]
				,[ysnGross1Manual]
				,[ysnGross2Manual]
				,[dblGrossWeight]
				,[dblGrossWeight1]
				,[dblGrossWeight2]
				,[dblGrossWeightOriginal]
				,[dblGrossWeightSplit1]
				,[dblGrossWeightSplit2]
				,[dtmGrossDateTime]
				,[dtmGrossDateTime1]
				,[dtmGrossDateTime2]
				,[intGrossUserId]
				,[ysnTareManual]
				,[ysnTare1Manual]
				,[ysnTare2Manual]
				,[dblTareWeight]
				,[dblTareWeight1]
				,[dblTareWeight2]
				,[dblTareWeightOriginal]
				,[dblTareWeightSplit1]
				,[dblTareWeightSplit2]
				,[dtmTareDateTime]
				,[dtmTareDateTime1]
				,[dtmTareDateTime2]
				,[intTareUserId]
				,[dblGrossUnits]
				,[dblShrink]
				,[dblNetUnits]
				,[strItemUOM]
				,[intCustomerId]
				,[intSplitId]
				,[strDistributionOption]
				,[intDiscountSchedule]
				,[strDiscountLocation]
				,[dtmDeferDate]
				,[dblUnitPrice]
				,[dblUnitBasis]
				,[dblTicketFees]
				,[intCurrencyId]
				,[dblCurrencyRate]
				,[strTicketComment]
				,[strCustomerReference]
				,[ysnTicketPrinted]
				,[ysnPlantTicketPrinted]
				,[ysnGradingTagPrinted]
				,[intHaulerId]
				,[intFreightCarrierId]
				,[dblFreightRate]
				,[dblFreightAdjustment]
				,[intFreightCurrencyId]
				,[dblFreightCurrencyRate]
				,[strFreightCContractNumber]
				,[ysnFarmerPaysFreight]
				,[ysnCusVenPaysFees]
				,[strLoadNumber]
				,[intLoadLocationId]
				,[intAxleCount]
				,[intAxleCount1]
				,[intAxleCount2]
				,[strPitNumber]
				,[intGradingFactor]
				,[strVarietyType]
				,[strFarmNumber]
				,[strFieldNumber]
				,[strDiscountComment]
				,[intCommodityId]
				,[intDiscountId]
				,[intDiscountLocationId]
				,[intItemId]
				,[intEntityId]
				,[intLoadId]
				,[intMatchTicketId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[intSubLocationToId]
				,[intStorageLocationToId]
				,[intFarmFieldId]
				,[intDistributionMethod]
				,[intSplitInvoiceOption]
				,[intDriverEntityId]
				,[intStorageScheduleId]
				,[intConcurrencyId]
				,[dblNetWeightDestination]
				,[ysnHasGeneratedTicketNumber]
				,[intInventoryTransferId]
				,[intInventoryReceiptId]
				,[intInventoryShipmentId]
				,[intInventoryAdjustmentId]
				,[dblScheduleQty]
				,[dblConvertedUOMQty]
				,[dblContractCostConvertedUOM]
				,[intItemUOMIdFrom]
				,[intItemUOMIdTo]
				,[intTicketTypeId]
				,[intStorageScheduleTypeId]
				,[strFreightSettlement]
				,[strCostMethod]
				,[intGradeId]
				,[intWeightId]
				,[intDeliverySheetId]
				,[intCommodityAttributeId]
				,[strElevatorReceiptNumber]
				,[ysnRailCar]
				,[ysnDeliverySheetPost]
				,[intLotId]
				,[strLotNumber]
				,[intSalesOrderId]
				,[intTicketLVStagingId]
				,[intBillId]
				,[intInvoiceId]
				,[intCompanyId]
				,[intEntityContactId]
				,[strPlateNumber]
				,[blbPlateNumber]
				,[ysnDestinationWeightGradePost]
				,[strSourceType]
				,[ysnHasSpecialDiscount]
				,intAGWorkOrderId
				)
			SELECT 
				[strTicketStatus] = 'O'
				,[strTicketNumber] = @strNewTicketNumber
				,[strOriginalTicketNumber] = @strNewTicketNumber
				,[intScaleSetupId]
				,[intTicketPoolId]
				,[intTicketLocationId]
				,[intTicketType]
				,[strInOutFlag]
				,[dtmTicketDateTime] = GETDATE()
				,[dtmTicketTransferDateTime]
				,[dtmTicketVoidDateTime]
				,[dtmTransactionDateTime] = GETDATE()
				,[intProcessingLocationId]
				,[intTransferLocationId]
				,[strScaleOperatorUser]
				,[intEntityScaleOperatorId]
				,[strTruckName]
				,[strDriverName]
				,[ysnDriverOff]
				,[ysnSplitWeightTicket]
				,[ysnGrossManual] 
				,[ysnGross1Manual]
				,[ysnGross2Manual]
				,[dblGrossWeight]
				,[dblGrossWeight1]
				,[dblGrossWeight2]
				,[dblGrossWeightOriginal]
				,[dblGrossWeightSplit1]
				,[dblGrossWeightSplit2]
				,[dtmGrossDateTime]
				,[dtmGrossDateTime1]
				,[dtmGrossDateTime2]
				,[intGrossUserId]
				,[ysnTareManual]
				,[ysnTare1Manual]
				,[ysnTare2Manual]
				,[dblTareWeight]
				,[dblTareWeight1]
				,[dblTareWeight2]
				,[dblTareWeightOriginal]
				,[dblTareWeightSplit1]
				,[dblTareWeightSplit2]
				,[dtmTareDateTime]
				,[dtmTareDateTime1]
				,[dtmTareDateTime2]
				,[intTareUserId]
				,[dblGrossUnits]
				,[dblShrink] = 0
				,[dblNetUnits]
				,[strItemUOM]
				,[intCustomerId]
				,[intSplitId]
				,[strDistributionOption]
				,[intDiscountSchedule]
				,[strDiscountLocation]
				,[dtmDeferDate]
				,[dblUnitPrice]
				,[dblUnitBasis]
				,[dblTicketFees]
				,[intCurrencyId]
				,[dblCurrencyRate]
				,[strTicketComment]
				,[strCustomerReference]
				,[ysnTicketPrinted]
				,[ysnPlantTicketPrinted]
				,[ysnGradingTagPrinted]
				,[intHaulerId]
				,[intFreightCarrierId]
				,[dblFreightRate]
				,[dblFreightAdjustment]
				,[intFreightCurrencyId]
				,[dblFreightCurrencyRate]
				,[strFreightCContractNumber]
				,[ysnFarmerPaysFreight]
				,[ysnCusVenPaysFees]
				,[strLoadNumber]
				,[intLoadLocationId]
				,[intAxleCount]
				,[intAxleCount1]
				,[intAxleCount2]
				,[strPitNumber]  = ''
				,[intGradingFactor]
				,[strVarietyType]
				,[strFarmNumber]
				,[strFieldNumber]
				,[strDiscountComment]
				,[intCommodityId]
				,[intDiscountId]
				,[intDiscountLocationId]
				,[intItemId]
				,[intEntityId] 
				,[intLoadId]
				,[intMatchTicketId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[intSubLocationToId]
				,[intStorageLocationToId]
				,[intFarmFieldId]
				,[intDistributionMethod]
				,[intSplitInvoiceOption]
				,[intDriverEntityId]
				,[intStorageScheduleId]
				,[intConcurrencyId]
				,[dblNetWeightDestination]
				,[ysnHasGeneratedTicketNumber] = 0
				,[intInventoryTransferId]
				,[intInventoryReceiptId]
				,[intInventoryShipmentId]
				,[intInventoryAdjustmentId]
				,[dblScheduleQty]
				,[dblConvertedUOMQty]
				,[dblContractCostConvertedUOM]
				,[intItemUOMIdFrom]
				,[intItemUOMIdTo]
				,[intTicketTypeId]
				,[intStorageScheduleTypeId]
				,[strFreightSettlement]
				,[strCostMethod]
				,[intGradeId]
				,[intWeightId]
				,[intDeliverySheetId]
				,[intCommodityAttributeId]
				,[strElevatorReceiptNumber]
				,[ysnRailCar]
				,[ysnDeliverySheetPost]
				,[intLotId]
				,[strLotNumber]
				,[intSalesOrderId]
				,[intTicketLVStagingId]
				,[intBillId]
				,[intInvoiceId]
				,[intCompanyId]
				,[intEntityContactId]
				,[strPlateNumber]
				,[blbPlateNumber]
				,[ysnDestinationWeightGradePost]
				,[strSourceType]
				,[ysnHasSpecialDiscount]
				,intAGWorkOrderId
			FROM tblSCTicket
			WHERE intTicketId = @intTicketId

			SET @intNewTicketId = SCOPE_IDENTITY()
		END
		
		--Update Work order Shipped Quantity for the Ticket Item
		IF(ISNULL(@InventoryShipmentId,0) > 0)
		BEGIN
			SELECT TOP 1
				@dblAGWorkOrderReserveQuantity = ISNULL(dblQtyShipped,0) + @dblTicketNetUnits
			FROM tblAGWorkOrderDetail
			WHERE intWorkOrderId = @intTicketAGWorkOrderId
				AND intItemId = @intItemId

			IF(ISNULL(@dblAGWorkOrderReserveQuantity,0) > 0)
			BEGIN
				SET @dblAGWorkOrderReserveQuantity = (SELECT ROUND(@dblAGWorkOrderReserveQuantity,6))
				SET @_strAuditDescription = 'Distribution of Ticket - ' +  @strTicketNumber
				EXEC uspAGUpdateWOShippedQty @intTicketAGWorkOrderId, @intItemId, @dblAGWorkOrderReserveQuantity, @intUserId, @_strAuditDescription 
			END
		END
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
GO
