CREATE PROCEDURE uspMFValidateInventoryShipment (@intInventoryShipmentId INT)
AS
BEGIN
	DECLARE @intBondStatusId INT
		,@strLotNumber NVARCHAR(50)
		,@strMessage NVARCHAR(max)
		,@ysnSendEDIOnRepost BIT

	SELECT @intBondStatusId = intBondStatusId
			,@ysnSendEDIOnRepost=ysnSendEDIOnRepost
	FROM tblMFCompanyPreference

	IF @intBondStatusId IS NULL
		RETURN

	IF @intBondStatusId IS NOT NULL
		AND EXISTS (
			SELECT *
			FROM tblICInventoryShipmentItem SI
			JOIN tblICInventoryShipmentItemLot SL ON SI.intInventoryShipmentItemId = SL.intInventoryShipmentItemId
			JOIN tblMFLotInventory LI ON LI.intLotId = SL.intLotId
			WHERE SI.intInventoryShipmentId = @intInventoryShipmentId
				AND LI.intBondStatusId = @intBondStatusId
			)
	BEGIN
		SELECT @strLotNumber = L.strLotNumber
		FROM dbo.tblICInventoryShipmentItem SI
		JOIN dbo.tblICInventoryShipmentItemLot SL ON SI.intInventoryShipmentItemId = SL.intInventoryShipmentItemId
		JOIN dbo.tblICLot L ON L.intLotId = SL.intLotId
		JOIN dbo.tblMFLotInventory LI ON LI.intLotId = SL.intLotId
		WHERE SI.intInventoryShipmentId = @intInventoryShipmentId
			AND LI.intBondStatusId = @intBondStatusId

		SELECT @strMessage = 'Lot/Pallet ' + @strLotNumber + ' is not bond released. Please choose bond released lot/pallet to continue.'

		RAISERROR (
				@strMessage
				,16
				,1
				)
	END
	IF @ysnSendEDIOnRepost=1
	BEGIN
		Update tblMFEDI945
		Set ysnStatus=0
		WHERE intInventoryShipmentId = @intInventoryShipmentId
	END
END
