CREATE PROCEDURE [dbo].[uspICLinkInventoryShipmentTransaction]
	@intShipmentId int,
	@ysnIsCreate bit = true
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

--Begin Transaction
BEGIN TRAN InventoryTransactionLink
SAVE TRAN InventoryTransactionLink

--Start Try Statement
BEGIN TRY

--User Define Type Variable
DECLARE @TransactionLink udtICTransactionLinks

IF @ysnIsCreate = 1
BEGIN

	INSERT INTO @TransactionLink (
		strOperation, -- Operation
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
	)
	SELECT
		'Create',
		intSrcId = ShipmentItemSource.intOrderId, 
		strSrcTransactionNo = COALESCE(ShipmentItemSource.strOrderNumber, 'Missing Transaction No'), 
		strSrcModuleName = 
		CASE 
			WHEN Shipment.intOrderType = 0 THEN 'None'
			WHEN Shipment.intOrderType = 1 THEN 'Sales Contract'
			WHEN Shipment.intOrderType = 2 THEN 'Sales Order'
			WHEN Shipment.intOrderType = 3 THEN 'Transfer Order'
			WHEN Shipment.intOrderType = 4 THEN 'Direct'
			WHEN Shipment.intOrderType = 5 THEN 'Item Contract'
			WHEN Shipment.intOrderType = 6 THEN 'AG Work Order'
		END COLLATE Latin1_General_CI_AS
		, 
		strSrcTransactionType = 
		CASE 
			WHEN Shipment.intOrderType = 0 THEN 'None'
			WHEN Shipment.intOrderType = 1 THEN 'Sales Contract'
			WHEN Shipment.intOrderType = 2 THEN 'Sales Order'
			WHEN Shipment.intOrderType = 3 THEN 'Transfer Order'
			WHEN Shipment.intOrderType = 4 THEN 'Direct'
			WHEN Shipment.intOrderType = 5 THEN 'Item Contract'
			WHEN Shipment.intOrderType = 6 THEN 'AG Work Order'
		END COLLATE Latin1_General_CI_AS
		,
		intDestId = Shipment.intInventoryShipmentId,
		strDestTransactionNo = COALESCE(Shipment.strShipmentNumber, 'Missing Transaction No'),
		'Inventory',
		'Inventory Shipment'
    FROM dbo.tblICInventoryShipment Shipment
	INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
	ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
	INNER JOIN dbo.vyuICGetShipmentItemSource ShipmentItemSource
	ON ShipmentItem.intInventoryShipmentItemId = ShipmentItemSource.intInventoryShipmentItemId
	WHERE ShipmentItemSource.intOrderId IS NOT NULL 
	AND Shipment.intInventoryShipmentId = @intShipmentId

	EXEC dbo.uspICAddTransactionLinks @TransactionLink

	GOTO Link_Exit
END

IF @ysnIsCreate = 0
BEGIN

	DECLARE @strShipmentNumber AS VARCHAR(50) 

	SELECT @strShipmentNumber = strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = @intShipmentId;

	EXEC dbo.uspICDeleteTransactionLinks 
		@intShipmentId, 
		@strShipmentNumber, 
		'Inventory Shipment',
		'Inventory'

	GOTO Link_Exit
END

END TRY

--Catch Errors and Rollback
BEGIN CATCH

	--Rollback Exit
	GOTO Link_Rollback_Exit

END CATCH

--Rollback Transaction
Link_Rollback_Exit:
BEGIN 
	ROLLBACK TRAN InventoryTransactionLink
END

Link_Exit:
BEGIN
	COMMIT TRAN InventoryTransactionLink
END