CREATE PROCEDURE uspMFRemoveReservation (@intInventoryShipmentId INT = NULL)
AS
BEGIN
	DECLARE @tblICStockReservation TABLE (intTransactionId INT)
	DECLARE @tblICFinalStockReservation TABLE (intTransactionId INT)
	DECLARE @intTransactionId INT
		,@ItemsToUnReserve AS dbo.ItemReservationTableType

	DELETE
	FROM tblMFOrderHeader
	OUTPUT deleted.intOrderHeaderId
	INTO @tblICStockReservation
	WHERE intOrderTypeId = 5
		AND strReferenceNo NOT IN (
			SELECT S.strShipmentNumber
			FROM tblICInventoryShipment S
			)

	DELETE T
	OUTPUT deleted.intOrderHeaderId
	INTO @tblICStockReservation
	FROM tblMFTask T
	JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = T.intOrderHeaderId
		AND OH.intOrderTypeId = 5
		AND T.intTaskStateId <> 4
	JOIN tblICInventoryShipment S ON S.strShipmentNumber = OH.strReferenceNo
		AND S.ysnPosted = 1

	DELETE T
	OUTPUT deleted.intOrderHeaderId
	INTO @tblICStockReservation
	FROM tblMFTask T
	JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = T.intOrderHeaderId
		AND OH.intOrderTypeId = 1
		AND T.intTaskStateId <> 4
	JOIN tblMFStageWorkOrder SW ON SW.intOrderHeaderId = T.intOrderHeaderId
	JOIN tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
		AND W.intStatusId = 13

	INSERT INTO @tblICStockReservation
	SELECT OH.intOrderHeaderId
	FROM tblICInventoryShipment Inv
	JOIN tblMFOrderHeader OH ON OH.strReferenceNo = Inv.strShipmentNumber
		AND Inv.ysnPosted = 1
	JOIN tblICStockReservation SR ON SR.intTransactionId = OH.intOrderHeaderId
		AND intInventoryTransactionType = 34
	WHERE SR.ysnPosted <> 1

	INSERT INTO @tblICFinalStockReservation
	SELECT DISTINCT intTransactionId
	FROM @tblICStockReservation

	SELECT @intTransactionId = MIN(intTransactionId)
	FROM @tblICFinalStockReservation

	WHILE @intTransactionId IS NOT NULL
	BEGIN
		EXEC dbo.uspICCreateStockReservation @ItemsToUnReserve
			,@intTransactionId
			,34

		SELECT @intTransactionId = MIN(intTransactionId)
		FROM @tblICFinalStockReservation
		WHERE intTransactionId > @intTransactionId
	END
END
