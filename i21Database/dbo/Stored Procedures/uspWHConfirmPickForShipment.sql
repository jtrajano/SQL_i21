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
			SELECT *
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
		SET @intShipmentItemId = 0
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

		EXEC uspICCreateInventoryShipmentItemLot @intInventoryShipmentItemId = @intShipmentItemId, 
												 @intLotId = @intLotId, 
												 @dblShipQty = @dblLotQty, 
												 @dblGrossWgt = @dblLotWeight, 
												 @dblTareWgt = 0
												 
		SELECT @intMinId = MIN(id)
		FROM tblWHPickForShipment WHERE id > @intMinId
	END
	
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH
GO