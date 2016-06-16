CREATE PROCEDURE uspWHConfirmPickForShipment 
					@strShipmentNo NVARCHAR(100), 
					@intUserId INT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intMinId INT
	DECLARE @intLotId INT
	DECLARE @intShipmentItemId INT
	DECLARE @intLotItemId INT
	DECLARE @dblLotQty NUMERIC(18, 6)
	DECLARE @dblLotWeight NUMERIC(18, 6)

	IF NOT EXISTS (
			SELECT 1
			FROM tblWHPickForShipment
			WHERE strShipmentNo = @strShipmentNo
			)
	BEGIN
		RAISERROR ('NO LOT HAS BEEN STAGED FOR THIS SHIPMENT NO', 11, 1)
	END

	SELECT @intMinId = MIN(id)
	FROM tblWHPickForShipment
	WHERE strShipmentNo = @strShipmentNo

	WHILE (@intMinId IS NOT NULL)
	BEGIN
		SET @intLotId = 0
		SET @intShipmentItemId = NULL
		SET @dblLotQty = 0
		SET @intLotItemId = 0

		SELECT @intLotId = intLotId
		FROM tblWHPickForShipment
		WHERE id = @intMinId

		SELECT @dblLotQty = dblQty, 
			   @intLotItemId = intItemId, 
			   @dblLotWeight = dblWeight
		FROM tblICLot
		WHERE intLotId = @intLotId

		SELECT @intShipmentItemId = intInventoryShipmentItemId
		FROM tblICInventoryShipmentItem i
		JOIN tblICInventoryShipment s ON i.intInventoryShipmentId = s.intInventoryShipmentId
		WHERE s.strShipmentNumber = @strShipmentNo
			AND intItemId = @intLotItemId

		INSERT INTO tblICInventoryShipmentItemLot(intInventoryShipmentItemId, intLotId, dblQuantityShipped, dblGrossWeight, dblTareWeight)
		VALUES (@intShipmentItemId, @intLotId, @dblLotQty, @dblLotWeight, 0)
	
		DELETE FROM tblWHPickForShipment WHERE id = @intMinId
												 
		SELECT @intMinId = MIN(id)
		FROM tblWHPickForShipment WHERE strShipmentNo = @strShipmentNo AND id > @intMinId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH
GO