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

DECLARE @SALES_CONTRACT AS NVARCHAR(50) = 'Sales Contract'
		,@SALES_ORDER AS NVARCHAR(50) = 'SalesOrder'
		,@TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'

DECLARE @intTicketId AS INT = @intSourceTransactionId
DECLARE @dblRemainingUnits AS DECIMAL (38,20)
DECLARE @dblRemainingQuantity AS DECIMAL (38,20)
DECLARE @dblRemainingUnitStorage AS DECIMAL (38,20)
DECLARE @LineItems AS ScaleTransactionTableType
DECLARE @strTransactionId NVARCHAR(40) = NULL
DECLARE @intDirectType AS INT = 3
DECLARE @intTicketItemUOMId INT
DECLARE @intOrderId INT
DECLARE @intLoadContractId AS INT
DECLARE @dblLoadScheduledUnits AS NUMERIC(12,4)
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
		,@ysnDPStorage AS BIT;

SELECT @intLoadId = intLoadId
	, @dblTicketFreightRate = dblFreightRate
	, @intScaleStationId = intScaleSetupId
	, @ysnDeductFreightFarmer = ysnFarmerPaysFreight
	, @strWhereFinalizedWeight = strWeightFinalized
	, @strWhereFinalizedWeight = strGradeFinalized
	, @intTicketItemUOMId = intItemUOMIdTo
	, @intItemId = intItemId
FROM vyuSCTicketScreenView where @intTicketId = @intTicketId

SELECT	@ysnDPStorage = ST.ysnDPOwnedType 
FROM dbo.tblGRStorageType ST WHERE 
ST.strStorageTypeCode = @strDistributionOption

DECLARE @ErrMsg              NVARCHAR(MAX),
        @dblBalance          NUMERIC(12,4),                    
        
        @dblNewBalance       NUMERIC(12,4),
        @strInOutFlag        NVARCHAR(4),
        @dblQuantity         NUMERIC(12,4),
        @strAdjustmentNo     NVARCHAR(50)

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
				SELECT @intLoadContractId = LGLD.intSContractDetailId, @dblLoadScheduledUnits = LGLD.dblQuantity FROM tblLGLoad LGL 
				INNER JOIN tblLGLoadDetail LGLD
				ON LGL.intLoadId = LGLD.intLoadId
				WHERE LGL.intLoadId = @intLoadId
			END
			IF @intLoadContractId IS NULL
			BEGIN 
				RAISERROR('Unable to find load contract details. Try Again.', 11, 1);
				GOTO _Exit
			END
			BEGIN
			SET @dblLoadScheduledUnits = @dblLoadScheduledUnits * -1;
			EXEC uspCTUpdateScheduleQuantity @intLoadContractId, @dblLoadScheduledUnits, @intUserId, @intTicketId, 'Scale'
			END
		END
 		IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
 		BEGIN
 			SET @intOrderId = 1
 		END
 		ELSE
 		BEGIN
 			SET @intOrderId = 4
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
				   IF	ISNULL(@intLoopContractId,0) != 0
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
				)
				EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblRemainingUnitStorage , @intEntityId, @strDistributionOption, NULL
				SELECT TOP 1 @dblRemainingUnitStorage = dblQty FROM @ItemsForItemShipment IIS
				SET @dblRemainingUnits = (@dblRemainingUnits - @dblRemainingUnitStorage)
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
								,intStorageLocationId
								,ysnIsStorage 
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

	EXEC dbo.uspSCAddScaleTicketToItemShipment @intTicketId ,@intUserId ,@ItemsForItemShipment ,@intEntityId ,@intOrderId ,@InventoryShipmentId OUTPUT;

	SELECT	@strTransactionId = ship.strShipmentNumber
	FROM	dbo.tblICInventoryShipment ship	        
	WHERE	ship.intInventoryShipmentId = @InventoryShipmentId		
	
	EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @intUserId;
			
	--INVOICE intergration
	SELECT @intPricingTypeId = CTD.intPricingTypeId FROM tblICInventoryShipmentItem ISI 
	LEFT JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = ISI.intLineNo
	WHERE intInventoryShipmentId = @InventoryShipmentId

	IF ISNULL(@InventoryShipmentId, 0) != 0 AND (ISNULL(@intPricingTypeId,0) <= 1 OR ISNULL(@intPricingTypeId,0) = 6) AND ISNULL(@strWhereFinalizedWeight, 'Origin') = 'Origin' AND ISNULL(@strWhereFinalizedGrade, 'Origin') = 'Origin'
	BEGIN
		EXEC @intInvoiceId = dbo.uspARCreateInvoiceFromShipment @InventoryShipmentId, @intUserId, NULL;
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
GO
