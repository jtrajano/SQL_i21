CREATE PROCEDURE [dbo].[uspICAddSalesOrderToItemShipment]
	@SalesOrderId AS INT
	,@intUserId AS INT
	,@InventoryShipmentId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryShipment AS INT = 30;
DECLARE @ShipmentNumber AS NVARCHAR(20)

DECLARE @ShipmentType_SalesContract AS NVARCHAR(100) = 'Sales Contract'
DECLARE @ShipmentType_SalesOrder AS NVARCHAR(100) = 'Sales Order'
DECLARE @ShipmentType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'

DECLARE @intSalesContractType AS INT = 1
DECLARE @intSalesOrderType AS INT = 2
DECLARE @intTransferOrderType AS INT = 3

-- Get the transaction id 
EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryShipment, @ShipmentNumber OUTPUT 

IF @ShipmentNumber IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.
	RAISERROR(50030, 11, 1);
	RETURN;
END 

-- Insert the Inventory Shipment header 
		--INSERT INTO dbo.tblICInventoryShipment (

		--)
		--SELECT 	

		--FROM	dbo.tblSalesOrder SO
		--WHERE	SO.intSalesOrderId = @SalesOrderId

-- Get the identity value from tblICInventoryShipment
SELECT @InventoryShipmentId = SCOPE_IDENTITY()

IF @InventoryShipmentId IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the Inventory Shipment. An error stopped the process from Purchase Order to Inventory Shipment.
	RAISERROR(50031, 11, 1);
	RETURN;
END

-- Insert the Inventory Shipment detail items 
	--INSERT INTO dbo.tblICInventoryShipmentItem (

	--)
	--SELECT	

	--FROM	dbo.tblSalesOrderDetail SODetail INNER JOIN dbo.tblICItemUOM ItemUOM			
	--			ON ItemUOM.intItemId = SODetail.intItemId
	--			AND ItemUOM.intItemUOMId = SODetail.intUnitOfMeasureId
	--		INNER JOIN dbo.tblICUnitMeasure UOM
	--			ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	--WHERE	SODetail.intPurchaseId = @SalesOrderId
	--		AND dbo.fnIsStockTrackingItem(SODetail.intItemId) = 1

-- Re-update the total cost 
	--UPDATE	Shipment
	--SET		dblInvoiceAmount = (
	--			SELECT	ISNULL(SUM(ISNULL(ShipmentItem.dblOpenReceive, 0) * ISNULL(ShipmentItem.dblUnitCost, 0)) , 0)
	--			FROM	dbo.tblICInventoryShipmentItem ShipmentItem
	--			WHERE	ShipmentItem.intInventoryShipmentId = Shipment.intInventoryShipmentId
	--		)
	--FROM	dbo.tblICInventoryShipment Shipment 
	--WHERE	Shipment.intInventoryShipmentId = @InventoryShipmentId
