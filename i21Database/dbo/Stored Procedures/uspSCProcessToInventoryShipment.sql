-- exec uspSCProcessToInventoryShipment 79, 'SalesOrder', 1, 524.893, 4.44, 3610, NULL, 'SPT', 0

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
DECLARE @LineItems AS ScaleTransactionTableType
DECLARE @strTransactionId NVARCHAR(40) = NULL
DECLARE @intDirectType AS INT = 3
DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT
DECLARE @intOrderId INT

DECLARE @ErrMsg                    NVARCHAR(MAX),
              @dblBalance          NUMERIC(12,4),                    
              @intItemId           INT,
              @dblNewBalance       NUMERIC(12,4),
              @strInOutFlag        NVARCHAR(4),
              @dblQuantity         NUMERIC(12,4),
              @strAdjustmentNo     NVARCHAR(50)

BEGIN TRY
 		IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
 		BEGIN
 			SET @intOrderId = 1
 		END
 		ELSE
 		BEGIN
 			SET @intOrderId = 4
 		END
 		BEGIN 
 			SELECT	@intTicketUOM = UOM.intUnitMeasureId
 			FROM	dbo.tblSCTicket SC	        
 					JOIN dbo.tblICCommodityUnitMeasure UOM On SC.intCommodityId  = UOM.intCommodityId
 			WHERE	SC.intTicketId = @intTicketId AND UOM.ysnStockUnit = 1		
 		END
 
 		BEGIN 
 			SELECT	@intTicketItemUOMId = UM.intItemUOMId
 				FROM	dbo.tblICItemUOM UM	
 				  JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
 			WHERE	UM.intUnitMeasureId =@intTicketUOM AND SC.intTicketId = @intTicketId
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
		SELECT TOP 1 @dblRemainingUnits = LI.dblUnitsRemaining FROM @LineItems LI
		IF(@dblRemainingUnits IS NULL)
		BEGIN
		SET @dblRemainingUnits = @dblNetUnits
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
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId 
				,ysnIsCustody
				)
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
						,strTransactionId = ScaleTicket.intTicketNumber
						,intTransactionTypeId = @intDirectType 
						,intLotId = NULL 
						,intSubLocationId = ScaleTicket.intSubLocationId
						,intStorageLocationId = ScaleTicket.intStorageLocationId
						,ysnIsCustody = 1
				FROM	dbo.tblSCTicket ScaleTicket
						INNER JOIN dbo.tblICItemUOM ItemUOM
							ON ScaleTicket.intItemId = ItemUOM.intItemId
							AND @intTicketItemUOMId = ItemUOM.intItemUOMId
						INNER JOIN dbo.tblICItemLocation ItemLocation
							ON ScaleTicket.intItemId = ItemLocation.intItemId
							-- Use "Ship To" because this is where the items in the PO will be delivered by the Vendor. 
							AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
							INNER JOIN dbo.tblICCommodityUnitMeasure TicketCommodityUOM On ScaleTicket.intCommodityId  = TicketCommodityUOM.intCommodityId
						AND TicketCommodityUOM.ysnStockUnit = 1
				WHERE	ScaleTicket.intTicketId = @intTicketId

			-- Validate the items to shipment 
			EXEC dbo.uspICValidateProcessToInventoryShipment @ItemsForItemShipment; 

			---- Add the items into inventory shipment > sales order type. 
			BEGIN 
				EXEC dbo.uspSCAddScaleTicketToItemShipment 
					  @intTicketId
					 ,@intUserId
					 ,@ItemsForItemShipment
					 ,@intEntityId
					 ,4
					 ,@InventoryShipmentId OUTPUT;
			END

			BEGIN 
			SELECT	@strTransactionId = ship.strShipmentNumber
			FROM	dbo.tblICInventoryShipment ship	        
			WHERE	ship.intInventoryShipmentId = @InventoryShipmentId		
			END

			EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @intUserId, @intEntityId;
		END
		IF (@dblRemainingUnits = @dblNetUnits)
		RETURN
		DELETE FROM @ItemsForItemShipment
		UPDATE @LineItems set intTicketId = @intTicketId
		END
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
		,strTransactionId
		,intTransactionTypeId
		,intTransactionDetailId
		,intLotId
		,intSubLocationId
		,intStorageLocationId 
		,ysnIsCustody
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

		--select * from @ItemsForItemShipment

	-- Validate the items to shipment 
	EXEC dbo.uspICValidateProcessToInventoryShipment @ItemsForItemShipment; 

	---- Add the items into inventory shipment > sales order type. 
	BEGIN 
		EXEC dbo.uspSCAddScaleTicketToItemShipment 
			  @intTicketId
			 ,@intUserId
			 ,@ItemsForItemShipment
			 ,@intEntityId
			 ,@intOrderId
			 ,@InventoryShipmentId OUTPUT;
	END

	BEGIN 
	SELECT	@strTransactionId = ship.strShipmentNumber
	FROM	dbo.tblICInventoryShipment ship	        
	WHERE	ship.intInventoryShipmentId = @InventoryShipmentId		
	END

	EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @intUserId, @intEntityId;

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


