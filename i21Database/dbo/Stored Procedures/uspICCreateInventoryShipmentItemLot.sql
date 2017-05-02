CREATE PROCEDURE [dbo].[uspICCreateInventoryShipmentItemLot]
	@intInventoryShipmentItemId int,
	@intLotId int,
	@dblShipQty NUMERIC(38,20),
	@dblGrossWgt NUMERIC(38,20) = 0,
	@dblTareWgt NUMERIC(38,20) = 0
AS
	
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

-- Create a unique transaction name. 
DECLARE @TransactionName AS VARCHAR(500) = 'Create Shipment Lot' + CAST(NEWID() AS NVARCHAR(100));

DECLARE 
	@intInventoryShipmentId INT,
	@ItemId INT,
	@ItemNo NVARCHAR(50),
	@LotTracked BIT = 0,

	@LotNo NVARCHAR(50),
	@AvailableQty NUMERIC(38,20)


-- Check if Line Item exists
IF NOT EXISTS( SELECT TOP 1 1 FROM tblICInventoryShipmentItem WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId)
BEGIN
	-- Inventory Shipment Line Item does not exist.  
	EXEC uspICRaiseError 80067; 
	GOTO Post_Exit  
END
ELSE
BEGIN
	SELECT TOP 1 
		@intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
		,@ItemId = Item.intItemId
		, @ItemNo = Item.strItemNo
		, @LotTracked = (CASE WHEN Item.strLotTracking = 'No' THEN 0 ELSE 1 END)
	FROM tblICInventoryShipmentItem ShipmentItem
		LEFT JOIN tblICItem Item ON Item.intItemId = ShipmentItem.intItemId
	WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId
END

-- Check if Item is Lot Tracked
IF (@LotTracked = 0)
BEGIN
	-- Item % is not a lot tracked item and cannot ship lots.  
	EXEC uspICRaiseError 80068, @ItemNo
	GOTO Post_Exit  
END

-- Check if Lot exists
IF NOT EXISTS( SELECT TOP 1 1 FROM tblICLot WHERE intLotId = @intLotId)
BEGIN
	-- Invalid lot.  
	EXEC uspICRaiseError 80020; 
	GOTO Post_Exit  
END
ELSE
BEGIN
	SELECT TOP 1 
		@LotNo = strLotNumber,
		@AvailableQty = dblAvailableQty
	FROM vyuICGetLot
	WHERE intLotId = @intLotId
END

-- Check if Qty Shipped is greater than available Lot Qty
IF (@dblShipQty > @AvailableQty)
BEGIN
	-- % has only % available quantity. Cannot ship more than the available qty.  
	EXEC uspICRaiseError 80069, @LotNo, @AvailableQty;
	GOTO Post_Exit  
END

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
BEGIN TRAN @TransactionName
SAVE TRAN @TransactionName

BEGIN TRY
	-- Begin creation of shipment item lot
	INSERT INTO tblICInventoryShipmentItemLot(intInventoryShipmentItemId, intLotId, dblQuantityShipped, dblGrossWeight, dblTareWeight)
	VALUES (@intInventoryShipmentItemId, @intLotId, @dblShipQty, @dblGrossWgt, @dblTareWgt)

	-- Begin Reservation of lot
	EXEC uspICReserveStockForInventoryShipment @intInventoryShipmentId
END TRY
BEGIN CATCH
	GOTO With_Rollback_Exit
END CATCH

GOTO Post_Exit

-- This is our immediate exit in case of exceptions controlled by this stored procedure
With_Rollback_Exit:
IF @@TRANCOUNT > 1 
BEGIN 
	ROLLBACK TRAN @TransactionName
	COMMIT TRAN @TransactionName
END

Post_Exit: