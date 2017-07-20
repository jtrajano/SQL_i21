CREATE PROCEDURE uspMFPickAlternateLotForShipment @intLotId INT
	,@strAlternateLotNo NVARCHAR(50)
	,@strLotSourceLocation NVARCHAR(50)
	,@strShipmentNo NVARCHAR(100)
AS
BEGIN TRY
	DECLARE @intAlternateLotId INT
		,@intStorageLocationId INT
		,@dblAlternateLotQty NUMERIC(38, 20)
		,@intTransactionCount INT
		,@strErrMsg NVARCHAR(MAX)
		,@intLotStatusId INT
		,@intTaskId INT
		,@intBondStatusId INT
		,@strPrimaryStatus NVARCHAR(50)
		,@dblRequiredTaskQty NUMERIC(18, 6)
		,@dblRequiredTaskWeight NUMERIC(18, 6)
		,@intCustomerLabelTypeId INT
		,@intEntityCustomerId INT
		,@strReferenceNo NVARCHAR(50)
		,@intOrderHeaderId INT

	SELECT @intStorageLocationId = intStorageLocationId
	FROM tblICStorageLocation
	WHERE strName = @strLotSourceLocation

	SELECT @intAlternateLotId = intLotId
		,@dblAlternateLotQty = CASE 
			WHEN intWeightUOMId IS NOT NULL
				THEN dblWeight
			ELSE dblQty
			END
	FROM tblICLot
	WHERE strLotNumber = @strAlternateLotNo
		AND intStorageLocationId = @intStorageLocationId

	SELECT @dblRequiredTaskWeight = dblWeight
		,@dblRequiredTaskQty = dblQty
	FROM tblMFTask
	WHERE intTaskId = @intTaskId

	--IF(@dblAlternateLotQty > @dblRequiredTaskQty)
	--BEGIN
	--	SET @strErrMsg = 'AVAILABLE QTY IN THE SCANNED LOT IS MORE THAN THE REQUIRED QTY. CANNOT CONTINUE.'
	--	RAISERROR (@strErrMsg,16,1)
	--END
	IF (@intLotId <> @intAlternateLotId)
	BEGIN
		SELECT @intTaskId = intTaskId
		FROM tblMFTask T
		WHERE intLotId = @intLotId
	END

	IF ISNULL(@dblAlternateLotQty, 0) <= 0
	BEGIN
		SET @strErrMsg = 'QTY NOT AVAILABLE FOR LOT ' + @strAlternateLotNo + ' ON LOCATION ' + @strLotSourceLocation + '.'

		RAISERROR (
				@strErrMsg
				,16
				,1
				)
	END

	IF ISNULL(@intAlternateLotId, 0) = 0
	BEGIN
		RAISERROR (
				'ALTERNATE LOT DOES NOT EXISTS IN THE SCANNED LOCATION'
				,16
				,1
				)
	END

	SELECT @intLotStatusId = intLotStatusId
	FROM tblICLot
	WHERE intLotId = @intAlternateLotId

	SELECT @strPrimaryStatus = strPrimaryStatus
	FROM tblICLotStatus
	WHERE intLotStatusId = @intLotStatusId

	IF (@strPrimaryStatus <> 'Active')
	BEGIN
		RAISERROR (
				'SCANNED LOT IS NOT ACTIVE. PLEASE SCAN AN ACTIVE LOT TO CONTINUE.'
				,16
				,1
				)
	END

	SELECT @intBondStatusId = intBondStatusId
	FROM tblMFLotInventory
	WHERE intLotId = @intAlternateLotId

	IF @intBondStatusId = 5
	BEGIN
		RAISERROR (
				'SCANNED LOT IS NOT BOND RELEASED. PLEASE SCAN BOND RELEASED LOT TO CONTINUE.'
				,16
				,1
				)
	END

	SELECT @intEntityCustomerId = intEntityCustomerId
	FROM tblICInventoryShipment
	WHERE strShipmentNumber = @strShipmentNo

	SELECT @intCustomerLabelTypeId = intCustomerLabelTypeId
	FROM tblMFItemOwner
	WHERE intOwnerId = @intEntityCustomerId
		AND intCustomerLabelTypeId IS NOT NULL

	IF @intCustomerLabelTypeId IS NULL
	BEGIN
		SELECT @intCustomerLabelTypeId = 0
	END

	SELECT @intOrderHeaderId = intOrderHeaderId
	FROM tblMFOrderHeader OH
	WHERE strReferenceNo = @strShipmentNo

	BEGIN TRANSACTION

	IF EXISTS (
			SELECT 1
			FROM tblMFTask
			WHERE intLotId = @intLotId
				AND intTaskId = @intTaskId
			)
	BEGIN
		UPDATE tblMFTask
		SET intLotId = @intAlternateLotId
			,intFromStorageLocationId = @intStorageLocationId
		WHERE intLotId = @intLotId
			AND intTaskId = @intTaskId
	END

	IF @intCustomerLabelTypeId = 2
	BEGIN
		UPDATE tblMFOrderManifest
		SET intLotId = @intAlternateLotId
		WHERE intOrderHeaderId = @intOrderHeaderId
			AND intLotId = @intLotId
	END

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
Go
