CREATE PROCEDURE uspMFValidateInventoryShipment (@intInventoryShipmentId INT)
AS
BEGIN
	DECLARE @intBondStatusId INT
		,@strLotNumber NVARCHAR(50)
		,@strMessage NVARCHAR(max)
		,@ysnSendEDIOnRepost BIT

	IF EXISTS (
			SELECT 1
			FROM tblICInventoryShipmentItem SI
			JOIN tblICInventoryShipmentItemLot SL ON SI.intInventoryShipmentItemId = SL.intInventoryShipmentItemId
			JOIN tblICLot L ON L.intLotId = SL.intLotId
			JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = L.intStorageLocationId
			JOIN dbo.tblMFInventoryShipmentRestrictionType R ON R.intRestrictionId = SL1.intRestrictionId
			WHERE SI.intInventoryShipmentId = @intInventoryShipmentId
			)
	BEGIN
		SELECT @strLotNumber = L.strLotNumber
		FROM tblICInventoryShipmentItem SI
		JOIN tblICInventoryShipmentItemLot SL ON SI.intInventoryShipmentItemId = SL.intInventoryShipmentItemId
		JOIN tblICLot L ON L.intLotId = SL.intLotId
		JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = L.intStorageLocationId
		JOIN dbo.tblMFInventoryShipmentRestrictionType R ON R.intRestrictionId = SL1.intRestrictionId
		WHERE SI.intInventoryShipmentId = @intInventoryShipmentId

		SELECT @strMessage = 'Lot/Pallet ' + @strLotNumber + ' is in a restricted storage unit. Please choose lot/pallet from another storage unit that is not restricted.'

		RAISERROR (
				@strMessage
				,16
				,1
				)
	END

	SELECT @intBondStatusId = intBondStatusId
			,@ysnSendEDIOnRepost=ysnSendEDIOnRepost
	FROM tblMFCompanyPreference

	IF @ysnSendEDIOnRepost=1
	BEGIN
		Update tblMFEDI945
		Set ysnStatus=0
		WHERE intInventoryShipmentId = @intInventoryShipmentId
	END

	IF EXISTS (
			SELECT *
			FROM tblICInventoryShipmentItem SI
			JOIN tblICInventoryShipmentItemLot SL ON SI.intInventoryShipmentItemId = SL.intInventoryShipmentItemId
			JOIN dbo.tblICLot L ON L.intLotId = SL.intLotId
			JOIN dbo.tblICLotStatus LS on LS.intLotStatusId =L.intLotStatusId 
			WHERE SI.intInventoryShipmentId = @intInventoryShipmentId
				AND LS.strPrimaryStatus<>'Active'
			)
	BEGIN
		SELECT @strLotNumber = L.strLotNumber
		FROM dbo.tblICInventoryShipmentItem SI
		JOIN dbo.tblICInventoryShipmentItemLot SL ON SI.intInventoryShipmentItemId = SL.intInventoryShipmentItemId
		JOIN dbo.tblICLot L ON L.intLotId = SL.intLotId
		JOIN dbo.tblICLotStatus LS on LS.intLotStatusId =L.intLotStatusId 
		WHERE SI.intInventoryShipmentId = @intInventoryShipmentId
			AND LS.strPrimaryStatus<>'Active'

		SELECT @strMessage = 'Lot/Pallet ' + @strLotNumber + ' is not active. Please choose active lot/pallet to continue.'

		RAISERROR (
				@strMessage
				,16
				,1
				)
	END

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
END
