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

DECLARE @ErrMsg                    NVARCHAR(MAX),
              @dblBalance          NUMERIC(12,4),                    
              @intItemId           INT,
              @dblNewBalance       NUMERIC(12,4),
              @strInOutFlag        NVARCHAR(4),
              @dblQuantity         NUMERIC(12,4),
              @strAdjustmentNo     NVARCHAR(50)

BEGIN TRY
		IF @strDistributionOption = 'CNT'
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
		SELECT TOP 1 @dblRemainingUnits = LI.dblUnitsRemaining FROM @LineItems LI
		IF(@dblRemainingUnits IS NULL)
		BEGIN
		SET @dblRemainingUnits = @dblNetUnits
		END
		IF(@dblRemainingUnits > 0)
		BEGIN
			INSERT INTO @LineItems (
			intContractDetailId,
			dblUnitsDistributed,
			dblUnitsRemaining,
			dblCost) values (NULL, @dblRemainingUnits, 0, @dblCost)
		END
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
		,intLotId
		,intSubLocationId
		,intStorageLocationId 
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
	IF @strSourceType = @SALES_ORDER
	BEGIN 
		EXEC dbo.uspSCAddScaleTicketToItemShipment 
			  @intTicketId
			 ,@intUserId
			 ,@ItemsForItemShipment
			 ,@intEntityId
			 ,@InventoryShipmentId OUTPUT;
	END

	BEGIN 
	SELECT	@strTransactionId = ship.strShipmentNumber
	FROM	dbo.tblICInventoryShipment ship	        
	WHERE	ship.intInventoryShipmentId = @InventoryShipmentId		
	END

	--EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @intUserId, @intEntityId;

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


