CREATE PROCEDURE uspMFReleaseReservation @intOrderHeaderId INT
	,@ysnDeleteAll BIT = 0
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
	,@strOrderNo NVARCHAR(50)

SELECT @strOrderType = OT.strOrderType
	,@strReferenceNo = strReferenceNo
	,@strOrderNo = strOrderNo
FROM tblMFOrderHeader OH
JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
WHERE intOrderHeaderId = @intOrderHeaderId

SELECT @intInventoryShipmentId = intInventoryShipmentId
FROM tblICInventoryShipment
WHERE strShipmentNumber = @strReferenceNo

IF NOT EXISTS (
		SELECT 1
		FROM tblMFTask
		WHERE intOrderHeaderId = @intOrderHeaderId
		)
BEGIN
	UPDATE tblMFOrderHeader
	SET intOrderStatusId = 1
	WHERE intOrderHeaderId = @intOrderHeaderId
END

IF (@strOrderType = 'INVENTORY SHIPMENT STAGING')
BEGIN
	SELECT @strTransactionId = @strReferenceNo
END
ELSE
BEGIN
	SELECT @strTransactionId = W.strWorkOrderNo
	FROM tblMFStageWorkOrder SW
	JOIN tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
	WHERE SW.intOrderHeaderId = @intOrderHeaderId
END

IF (
		@strOrderType = 'INVENTORY SHIPMENT STAGING'
		OR @strOrderType = 'WO PROD STAGING'
		)
BEGIN
	SELECT @intTransactionId = @intInventoryShipmentId

	SELECT @strTransactionId = @strReferenceNo

	EXEC dbo.uspICCreateStockReservation @ItemsToReserve
		,@intOrderHeaderId
		,34

	IF @ysnDeleteAll = 0
	BEGIN
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
			,intTransactionId = @intOrderHeaderId
			,strTransactionId = @strTransactionId + ' / ' + @strOrderNo
			,intTransactionTypeId = 34
		FROM tblMFTask T
		JOIN tblICStorageLocation SL ON SL.intStorageLocationId = T.intFromStorageLocationId
		JOIN tblICItemLocation IL ON IL.intItemId = T.intItemId
			AND IL.intLocationId = SL.intLocationId
		WHERE T.intOrderHeaderId = @intOrderHeaderId

		EXEC dbo.uspICCreateStockReservation @ItemsToReserve
			,@intOrderHeaderId
			,34
	END
END
