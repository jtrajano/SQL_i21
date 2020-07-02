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
		,@intInvoiceId AS INT
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

SELECT @intLoadId = intLoadId
	, @dblTicketFreightRate = dblFreightRate
	, @intScaleStationId = intScaleSetupId
	, @ysnDeductFreightFarmer = ysnFarmerPaysFreight
	, @strWhereFinalizedWeight = strWeightFinalized
	, @strWhereFinalizedGrade = strGradeFinalized
	, @intTicketItemUOMId = intItemUOMIdTo
	, @intItemId = intItemId
FROM vyuSCTicketScreenView where intTicketId = @intTicketId

SELECT	@ysnDPStorage = ST.ysnDPOwnedType 
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

 		SET @intOrderId = CASE WHEN @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD' THEN 1 ELSE 4 END

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
				   IF ISNULL(@intLoopContractId,0) != 0
				   BEGIN
					   EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
					   EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoopContractId, @dblLoopContractUnits, @intEntityId;
				   END
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
					,intStorageScheduleTypeId 
					,ysnAllowInvoiceVoucher
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
							,ysnAllowInvoiceVoucher
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
				,ysnAllowInvoiceVoucher
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
					,ysnAllowInvoiceVoucher 
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
					intCurrencyId)
					EXEC dbo.uspCTUpdationFromTicketDistribution 
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
								,intStorageScheduleTypeId 
								,ysnAllowInvoiceVoucher
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
					,ysnAllowInvoiceVoucher
				)
				EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblRemainingUnits , @intEntityId, @strDistributionOption, NULL, @intStorageScheduleId
				SELECT TOP 1 @dblRemainingUnitStorage = dblQty FROM @ItemsForItemShipment IIS
				SET @dblRemainingUnits = (@dblRemainingUnits + ISNULL(@dblRemainingUnitStorage, 0)) * -1
				IF (@dblRemainingUnits > 0)
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
						   EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoopContractId, @dblLoopContractUnits, @intEntityId, 1;
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
							,ysnAllowInvoiceVoucher
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
							,ysnAllowInvoiceVoucher
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


	SELECT @strWhereFinalizedWeight = strWeightFinalized
		 , @strWhereFinalizedGrade = strGradeFinalized
	FROM vyuSCTicketScreenView where intTicketId = @intTicketId

	EXEC dbo.uspSCAddScaleTicketToItemShipment @intTicketId ,@intUserId ,@ItemsForItemShipment ,@intEntityId ,@intOrderId ,@InventoryShipmentId OUTPUT;

	SELECT	@strTransactionId = ship.strShipmentNumber
	FROM	dbo.tblICInventoryShipment ship	        
	WHERE	ship.intInventoryShipmentId = @InventoryShipmentId		
	
	EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @intUserId;

	SELECT @intContractDetailId = MIN(si.intLineNo)
    FROM tblICInventoryShipment s 
    JOIN tblICInventoryShipmentItem si ON si.intInventoryShipmentId = s.intInventoryShipmentId
    WHERE si.intInventoryShipmentId = @InventoryShipmentId AND s.intOrderType = 1
 
    WHILE ISNULL(@intContractDetailId,0) > 0
    BEGIN
        IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId)
        BEGIN
			SET @ysnPriceFixation = 1;
            EXEC uspCTCreateVoucherInvoiceForPartialPricing @intContractDetailId, @intUserId
        END
        SELECT @intContractDetailId = MIN(si.intLineNo)
        FROM tblICInventoryShipment s 
        JOIN tblICInventoryShipmentItem si ON si.intInventoryShipmentId = s.intInventoryShipmentId
        WHERE si.intInventoryShipmentId = @InventoryShipmentId AND s.intOrderType = 1 AND si.intLineNo > @intContractDetailId
    END
			
	--INVOICE intergration
	SELECT @intPricingTypeId = CTD.intPricingTypeId FROM tblICInventoryShipmentItem ISI 
	LEFT JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = ISI.intLineNo
	WHERE intInventoryShipmentId = @InventoryShipmentId

	IF(ISNULL(@strWhereFinalizedWeight, 'Origin') <> 'Destination' AND ISNULL(@strWhereFinalizedGrade, 'Origin') <> 'Destination' )
	BEGIN
		IF ISNULL(@InventoryShipmentId, 0) != 0 AND EXISTS(SELECT TOP 1 1 FROM tblICInventoryShipmentItem WHERE ysnAllowInvoice = 1 AND intInventoryShipmentId = @InventoryShipmentId)
		BEGIN
			EXEC @intInvoiceId = dbo.uspARCreateInvoiceFromShipment @InventoryShipmentId, @intUserId, NULL, 1, 1;
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