CREATE PROCEDURE [dbo].[uspMFCreateLotReservation] @intWorkOrderId INT
	,@ysnReservationByParentLot BIT = 0
	,@strBulkItemXml NVARCHAR(max) = ''
AS
DECLARE @ItemsToReserve AS dbo.ItemReservationTableType;
DECLARE @intInventoryTransactionType AS INT = 8
DECLARE @strInvalidItemNo AS NVARCHAR(50)
DECLARE @intInvalidItemId AS INT
DECLARE @intLocationId INT
DECLARE @idoc INT
DECLARE @strWorkOrderNo NVARCHAR(50)
DECLARE @tblBulkItem AS TABLE (
	intItemId INT
	,dblQuantity NUMERIC(38, 20)
	,intItemUOMId INT
	)

SELECT @intLocationId = intLocationId
	,@strWorkOrderNo = strWorkOrderNo
FROM tblMFWorkOrder
WHERE intWorkOrderId = @intWorkOrderId

IF ISNULL(@strBulkItemXml, '') <> ''
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strBulkItemXml

	INSERT INTO @tblBulkItem (
		intItemId
		,dblQuantity
		,intItemUOMId
		)
	SELECT intItemId
		,dblQuantity
		,intItemUOMId
	FROM OPENXML(@idoc, 'root/lot', 2) WITH (
			intItemId INT
			,dblQuantity NUMERIC(38, 20)
			,intItemUOMId INT
			)

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc
END

IF @ysnReservationByParentLot = 0
BEGIN
	IF (
			SELECT COUNT(1)
			FROM tblMFWorkOrderConsumedLot
			WHERE intWorkOrderId = @intWorkOrderId
			) > 0
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
		SELECT intItemId = wcl.intItemId
			,intItemLocationId = l.intItemLocationId
			,intItemUOMId = wcl.intItemUOMId
			,intLotId = wcl.intLotId
			,intSubLocationId = l.intSubLocationId
			,intStorageLocationId = l.intStorageLocationId
			,dblQty = wcl.dblQuantity
			,intTransactionId = wcl.intWorkOrderId
			,strTransactionId = w.strWorkOrderNo
			,intTransactionTypeId = @intInventoryTransactionType
		FROM tblMFWorkOrderConsumedLot wcl
		JOIN tblMFWorkOrder w ON w.intWorkOrderId = wcl.intWorkOrderId
		JOIN tblICLot l ON l.intLotId = wcl.intLotId
		WHERE wcl.intWorkOrderId = @intWorkOrderId

		--Non Lot Tracked Item
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
		SELECT intItemId = wcl.intItemId
			,intItemLocationId = (
				SELECT TOP 1 intItemLocationId
				FROM tblICItemLocation
				WHERE intItemId = wcl.intItemId
					AND intLocationId = @intLocationId
				)
			,intItemUOMId = wcl.intItemUOMId
			,intLotId = wcl.intLotId
			,intSubLocationId = wcl.intSubLocationId
			,intStorageLocationId = wcl.intStorageLocationId
			,dblQty = wcl.dblQuantity
			,intTransactionId = wcl.intWorkOrderId
			,strTransactionId = w.strWorkOrderNo
			,intTransactionTypeId = @intInventoryTransactionType
		FROM tblMFWorkOrderConsumedLot wcl
		JOIN tblMFWorkOrder w ON w.intWorkOrderId = wcl.intWorkOrderId
		WHERE wcl.intWorkOrderId = @intWorkOrderId
			AND ISNULL(wcl.intLotId, 0) = 0
	END
	ELSE
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
		SELECT intItemId = wcl.intItemId
			,intItemLocationId = l.intItemLocationId
			,intItemUOMId = wcl.intItemUOMId
			,intLotId = wcl.intLotId
			,intSubLocationId = l.intSubLocationId
			,intStorageLocationId = l.intStorageLocationId
			,dblQty = wcl.dblQuantity
			,intTransactionId = wcl.intWorkOrderId
			,strTransactionId = w.strWorkOrderNo
			,intTransactionTypeId = @intInventoryTransactionType
		FROM tblMFWorkOrderInputLot wcl
		JOIN tblMFWorkOrder w ON w.intWorkOrderId = wcl.intWorkOrderId
		JOIN tblICLot l ON l.intLotId = wcl.intLotId
		WHERE wcl.intWorkOrderId = @intWorkOrderId
END
ELSE
BEGIN
	DECLARE @tblMFPickLot TABLE (
		intRecordId INT identity(1, 1) 
		,intItemId INT
		,intParentLotId INT
		,intLotId INT
		,dblQuantity NUMERIC(18, 6)
		,intItemUOMId INT
		,intStorageLocationId INT
		)
	DECLARE @tblMFPickedLot TABLE (
				intWorkOrderId int
		,intItemId INT
		,intParentLotId INT
		,intLotId INT
		,dblQuantity NUMERIC(18, 6)
		,intItemUOMId INT
		,intStorageLocationId INT
		)
	DECLARE @intRecordId INT
		,@intParentLotId INT
		,@dblReqQuantity NUMERIC(18, 6)
		,@LotQty NUMERIC(18, 6)
		,@intLotId INT
		,@intItemId int
			,@intItemUOMId int
			,@intStorageLocationId int

	INSERT INTO @tblMFPickLot (
		intItemId
		,intParentLotId
		,dblQuantity
		,intItemUOMId
		,intStorageLocationId
		)
	SELECT intItemId
		,intParentLotId
		,dblQuantity
		,intItemUOMId
		,intStorageLocationId
	FROM tblMFWorkOrderInputParentLot wcl
	WHERE wcl.intWorkOrderId = @intWorkOrderId

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblMFPickLot

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @intParentLotId = NULL
			,@dblReqQuantity = NULL
			,@intItemId = NULL
			,@intItemUOMId = NULL
			,@intStorageLocationId = NULL

		SELECT @intItemId = intItemId
			,@intParentLotId = intParentLotId
			,@dblReqQuantity = dblQuantity
			,@intItemUOMId = intItemUOMId
			,@intStorageLocationId = intStorageLocationId
		FROM @tblMFPickLot
		WHERE intRecordId = @intRecordId

		WHILE @dblReqQuantity > 0
		BEGIN
			SELECT @LotQty = NULL
				,@intLotId = NULL

			SELECT @LotQty = (
					CASE 
						WHEN intWeightUOMId IS NULL
							THEN dblQty
						ELSE dblWeight
						END
					) - IsNULL((
						SELECT SUM(SR.dblQty)
						FROM tblICStockReservation SR
						WHERE SR.intLotId = L.intLotId
						), 0)
				,@intLotId = intLotId
			FROM tblICLot L
			WHERE intParentLotId = @intParentLotId
				AND intLocationId=@intLocationId
				AND (
					CASE 
						WHEN intWeightUOMId IS NULL
							THEN dblQty
						ELSE dblWeight
						END
					) - IsNULL((
						SELECT SUM(SR.dblQty)
						FROM tblICStockReservation SR
						WHERE SR.intLotId = L.intLotId
						), 0) > 0

			IF @dblReqQuantity > @LotQty
			BEGIN
				INSERT INTO @tblMFPickedLot (
					intWorkOrderId
					,intItemId
					,intParentLotId
					,intLotId
					,dblQuantity
					,intItemUOMId
					,intStorageLocationId
					)
				SELECT 
					@intWorkOrderId
					,@intItemId
					,@intParentLotId
					,@intLotId
					,@LotQty
					,@intItemUOMId
					,@intStorageLocationId

				SELECT @dblReqQuantity = @dblReqQuantity - @LotQty
			END
			ELSE
			BEGIN
				INSERT INTO @tblMFPickedLot (
					intWorkOrderId
					,intItemId
					,intParentLotId
					,intLotId
					,dblQuantity
					,intItemUOMId
					,intStorageLocationId
					)
				SELECT 
					@intWorkOrderId
					,@intItemId
					,@intParentLotId
					,@intLotId
					,@dblReqQuantity
					,@intItemUOMId
					,@intStorageLocationId

				SELECT @dblReqQuantity = 0

				BREAK
			END
		END

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFPickLot
		WHERE intRecordId > @intRecordId
	END

	INSERT INTO tblICStockReservation (
		intItemId
		,intLocationId
		,intItemLocationId
		,intItemUOMId
		,intParentLotId
		,intStorageLocationId
		,dblQty
		,intTransactionId
		,strTransactionId
		,intInventoryTransactionType
		,intLotId 
		)
	SELECT intItemId = wcl.intItemId
		,@intLocationId AS intLocationId
		,intItemLocationId = il.intItemLocationId
		,intItemUOMId = wcl.intItemUOMId
		,intParentLotId = wcl.intParentLotId
		,intStorageLocationId = wcl.intStorageLocationId
		,dblQty = wcl.dblQuantity
		,intTransactionId = wcl.intWorkOrderId
		,strTransactionId = w.strWorkOrderNo
		,intTransactionTypeId = @intInventoryTransactionType
		,intLotId=wcl.intLotId
	FROM @tblMFPickedLot wcl
	JOIN tblMFWorkOrder w ON w.intWorkOrderId = wcl.intWorkOrderId
	JOIN tblICItemLocation il ON wcl.intItemId = il.intItemId
		AND il.intLocationId = @intLocationId
	WHERE wcl.intWorkOrderId = @intWorkOrderId
END

--Insert Bulk Items if any
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
SELECT intItemId = bi.intItemId
	,intItemLocationId = il.intItemLocationId
	,intItemUOMId = bi.intItemUOMId
	,intLotId = NULL
	,intSubLocationId = NULL
	,intStorageLocationId = NULL
	,dblQty = bi.dblQuantity
	,intTransactionId = @intWorkOrderId
	,strTransactionId = @strWorkOrderNo
	,intTransactionTypeId = @intInventoryTransactionType
FROM @tblBulkItem bi
JOIN tblICItemLocation il ON bi.intItemId = il.intItemId
WHERE il.intLocationId = @intLocationId

-- Validate the reservation 
--EXEC dbo.uspICValidateStockReserves 
--	@ItemsToReserve
--	,@strInvalidItemNo OUTPUT 
--	,@intInvalidItemId OUTPUT 
-- If there are enough stocks, let the system create the reservations
IF EXISTS (
		SELECT *
		FROM @ItemsToReserve
		)
BEGIN
	EXEC dbo.uspICCreateStockReservation @ItemsToReserve
		,@intWorkOrderId
		,@intInventoryTransactionType
END
