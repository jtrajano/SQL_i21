CREATE PROCEDURE [dbo].[uspSCProcessToInventoryShipment]
	 @intSourceTransactionId AS INT
	,@strSourceType AS NVARCHAR(100) 
	,@intUserId AS INT
	,@dblNetUnits AS DECIMAL (13,3)
	,@dblCost AS DECIMAL (9,5)
	,@intEntityId AS INT
	,@intContractId AS INT
	,@strDistributionOption AS NVARCHAR(3)
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
DECLARE @dblRemainingUnits AS DECIMAL (13,3)
DECLARE @dblRemainingQuantity AS DECIMAL (13,3)
DECLARE @dblRemainingUnitStorage AS DECIMAL (13,3)
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

BEGIN
    SELECT TOP 1 @intLoadId = ST.intLoadId, @dblTicketFreightRate = ST.dblFreightRate, @intScaleStationId = ST.intScaleSetupId,
	@ysnDeductFreightFarmer = ST.ysnFarmerPaysFreight
	FROM dbo.tblSCTicket ST WHERE
	ST.intTicketId = @intTicketId
END

DECLARE @ErrMsg                    NVARCHAR(MAX),
              @dblBalance          NUMERIC(12,4),                    
              @intItemId           INT,
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

 		BEGIN 
 			SELECT	@intTicketItemUOMId = UM.intItemUOMId, @intItemId = SC.intItemId
 				FROM dbo.tblICItemUOM UM	
 				  JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
 			WHERE SC.intTicketId = @intTicketId AND UM.ysnStockUnit = 1
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
				DECLARE @dblLoopContractUnits NUMERIC(12,4);
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
				   --EXEC uspCTUpdateScheduleQuantity @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale'
				   EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
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
			EXEC dbo.uspICValidateProcessToInventoryShipment @ItemsForItemShipment;
		END
		ELSE
			BEGIN
			SET @dblRemainingUnitStorage = (@dblRemainingUnits * -1);
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
			EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblRemainingUnitStorage , @intEntityId, @strDistributionOption, NULL
			SELECT TOP 1 @dblRemainingUnitStorage = dblQty FROM @ItemsForItemShipment IIS
			SET @dblRemainingUnitStorage = (@dblRemainingUnits - @dblRemainingUnitStorage)
			IF(@dblRemainingUnitStorage IS NULL OR @dblRemainingUnitStorage > 0)
			BEGIN
				INSERT INTO @LineItems (
				intContractDetailId,
				dblUnitsDistributed,
				dblUnitsRemaining,
				dblCost)
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
					   --EXEC uspCTUpdateScheduleQuantity @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale'
					   EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
				   
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
				IF(@dblRemainingUnits != @dblNetUnits)
				BEGIN
					UPDATE @LineItems set intTicketId = @intTicketId
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
					SELECT	intItemId = ScaleTicket.intItemId
							,intLocationId = ItemLocation.intItemLocationId 
							,intItemUOMId = ItemUOM.intItemUOMId
							,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
							,dblQty = @dblRemainingUnits 
							,dblUOMQty = ItemUOM.dblUnitQty
							,dblCost = ScaleTicket.dblUnitBasis + dblUnitPrice
							,dblSalesPrice = 0
							,intCurrencyId = ScaleTicket.intCurrencyId
							,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
							,intTransactionId = ScaleTicket.intTicketId
							,strTransactionId = ScaleTicket.strTicketNumber
							,intTransactionTypeId = @intDirectType
							,intTransactionDetailId = NULL
							,intLotId = NULL 
							,intSubLocationId = ScaleTicket.intSubLocationId
							,intStorageLocationId = ScaleTicket.intStorageLocationId
							,ysnIsStorage = 0
					FROM	dbo.tblSCTicket ScaleTicket
							INNER JOIN dbo.tblICItemUOM ItemUOM ON ScaleTicket.intItemId = ItemUOM.intItemId
							INNER JOIN dbo.tblICItemLocation ItemLocation ON ScaleTicket.intItemId = ItemLocation.intItemId 
							AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
					WHERE	ScaleTicket.intTicketId = @intTicketId AND ItemUOM.ysnStockUnit = 1
				END
				SET @dblRemainingUnits = 0
			END
	END

	BEGIN 
		EXEC dbo.uspSCAddScaleTicketToItemShipment @intTicketId ,@intUserId ,@ItemsForItemShipment ,@intEntityId ,@intOrderId ,@InventoryShipmentId OUTPUT;
	END

	BEGIN 
	SELECT	@strTransactionId = ship.strShipmentNumber
	FROM	dbo.tblICInventoryShipment ship	        
	WHERE	ship.intInventoryShipmentId = @InventoryShipmentId		
	END
	SELECT @strLotTracking = strLotTracking FROM tblICItem WHERE intItemId = @intItemId
	IF @strLotTracking = 'No' -- temporary fixes for 16.2
	--IF @strLotTracking != 'Yes - Manual'
		BEGIN
			EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @intUserId;
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
