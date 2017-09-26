CREATE PROCEDURE uspMFReleaseReservation @intOrderHeaderId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ItemsToReserve AS dbo.ItemReservationTableType
	,@intInventoryTransactionType AS INT = 5
	,@intTransactionId INT
	,@strTransactionId NVARCHAR(50)
	,@intInventoryShipmentId INT
	,@strReferenceNo NVARCHAR(50)
	,@strOrderType NVARCHAR(50)

SELECT @strOrderType = OT.strOrderType
	,@strReferenceNo = strReferenceNo
FROM tblMFOrderHeader OH
JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
WHERE intOrderHeaderId = @intOrderHeaderId

SELECT @intInventoryShipmentId = intInventoryShipmentId
FROM tblICInventoryShipment
WHERE strShipmentNumber = @strReferenceNo

IF @strOrderType = 'INVENTORY SHIPMENT STAGING'
BEGIN
	SELECT @intTransactionId = @intInventoryShipmentId

	SELECT @strTransactionId = @strReferenceNo

	EXEC dbo.uspICCreateStockReservation @ItemsToReserve
		,@intTransactionId
		,@intInventoryTransactionType

	INSERT INTO @ItemsToReserve (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intLotId
		,intSubLocationId
		,intStorageLocationId
		,dblQty
		,intTransactionId
		,strTransactionId
		,intTransactionTypeId
		)
	SELECT intItemId = T.intItemId
		,intItemLocationId = IL.intItemLocationId
		,intItemUOMId = T.intItemUOMId
		,intLotId = T.intLotId
		,intSubLocationId = SL.intSubLocationId
		,intStorageLocationId = T.intFromStorageLocationId
		,dblQty = T.dblPickQty
		,intTransactionId = @intTransactionId
		,strTransactionId = @strTransactionId
		,intTransactionTypeId = @intInventoryTransactionType
	FROM tblMFTask T
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = T.intFromStorageLocationId
	JOIN tblICItemLocation IL ON IL.intItemId = T.intItemId
		AND IL.intLocationId = SL.intLocationId
	WHERE T.intOrderHeaderId = @intOrderHeaderId

	EXEC dbo.uspICCreateStockReservation @ItemsToReserve
		,@intTransactionId
		,@intInventoryTransactionType
END
