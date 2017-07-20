CREATE PROCEDURE uspMFPickAlternateLotForWorkOrder @intLotId INT
	,@strAlternateLotNo NVARCHAR(50)
	,@strLotSourceLocation NVARCHAR(50)
	,@intOrderHeaderId INT
	,@intTaskId INT
AS
BEGIN TRY
	DECLARE @intAlternateLotId INT
		,@intStorageLocationId INT
		,@dblAlternateLotQty NUMERIC(38, 20)
		,@dblAlternateLotWeight NUMERIC(38, 20)
		,@dtmAlternateLotExpiryDate DATETIME
		,@intTransactionCount INT
		,@dblRequiredTaskQty NUMERIC(18, 6)
		,@dblRequiredTaskWeight NUMERIC(18, 6)
		,@strErrMsg NVARCHAR(MAX)
		,@intItemId INT
		,@intAlternateItemId INT
		,@intLotStatusId INT
		,@intBondStatusId INT
		,@strPrimaryStatus NVARCHAR(50)
		,@intCustomerLabelTypeId INT
		,@intEntityCustomerId INT
		,@strReferenceNo NVARCHAR(50)
		,@dblLotPickQty NUMERIC(18, 6)

	SELECT @intStorageLocationId = intStorageLocationId
	FROM tblICStorageLocation
	WHERE strName = @strLotSourceLocation

	SELECT @intAlternateLotId = intLotId
		,@dblAlternateLotQty = CASE 
			WHEN intWeightUOMId IS NOT NULL
				THEN dblWeight
			ELSE dblQty
			END
		,@dblAlternateLotWeight = dblWeight
	FROM tblICLot
	WHERE strLotNumber = @strAlternateLotNo
		AND intStorageLocationId = @intStorageLocationId
		AND dblQty > 0

	SELECT @dblRequiredTaskWeight = dblWeight
		,@dblRequiredTaskQty = dblQty
		,@dblLotPickQty=dblPickQty 
	FROM tblMFTask
	WHERE intTaskId = @intTaskId

	--IF(@dblAlternateLotQty > @dblRequiredTaskQty)
	--BEGIN
	--	SET @strErrMsg = 'AVAILABLE QTY IN THE SCANNED LOT IS MORE THAN THE REQUIRED QTY. CANNOT CONTINUE.'
	--	RAISERROR (@strErrMsg,16,1)
	--END
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
		,@intAlternateItemId = intItemId
		,@dtmAlternateLotExpiryDate = dtmExpiryDate
	FROM tblICLot
	WHERE intLotId = @intAlternateLotId

	SELECT @intItemId = intItemId
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @strPrimaryStatus = strPrimaryStatus
	FROM tblICLotStatus
	WHERE intLotStatusId = @intLotStatusId

	IF (@intItemId <> @intAlternateItemId)
	BEGIN
		RAISERROR (
				'ALTERNATE LOT BELONGS TO A DIFFERENT ITEM. CANNOT CONTINUE.'
				,16
				,1
				)
	END

	IF (@dtmAlternateLotExpiryDate < GETDATE())
	BEGIN
		RAISERROR (
				'SCANNED LOT HAS EXPIRED.'
				,16
				,1
				)
	END

	IF EXISTS (

				SELECT 1
				FROM tblMFTask
				WHERE intLotId = @intAlternateLotId
				AND intTaskStateId <>4
			) AND @intLotId <> @intAlternateLotId
	BEGIN
			RAISERROR (
					'SCANNED LOT IS ASSOCIATED WITH A DIFFERENT TASK. CANNOT CONTINUE'
					,16
					,1
					)

	END

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

	SELECT @strReferenceNo = strReferenceNo
	FROM tblMFOrderHeader OH
	JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @intEntityCustomerId = intEntityCustomerId
	FROM tblICInventoryShipment
	WHERE strShipmentNumber = @strReferenceNo

	SELECT @intCustomerLabelTypeId = intCustomerLabelTypeId
	FROM tblMFItemOwner
	WHERE intOwnerId = @intEntityCustomerId
		AND intCustomerLabelTypeId IS NOT NULL

		IF @intCustomerLabelTypeId IS NULL
	BEGIN
		SELECT @intCustomerLabelTypeId = 0
	END

	BEGIN TRANSACTION

	IF @intOrderHeaderId IS NOT NULL
		AND EXISTS (
			SELECT *
			FROM tblMFOrderHeader
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intOrderTypeId = 1
			)
		AND EXISTS (
			SELECT 1
			FROM tblMFTask
			WHERE intLotId = @intLotId
				AND intTaskId = @intTaskId
			)
	BEGIN
		DECLARE @dblPickQty NUMERIC(38, 20)
			,@intPickItemUOMId INT

		SELECT @dblPickQty = NULL
			,@intPickItemUOMId = NULL

		SELECT @dblPickQty = dblQty
			,@intPickItemUOMId = intItemUOMId
		FROM tblICLot
		WHERE intLotId = @intAlternateLotId

		UPDATE tblMFTask
		SET intLotId = @intAlternateLotId
			,intFromStorageLocationId = @intStorageLocationId
			,dblPickQty = @dblPickQty
			,intItemUOMId = @intPickItemUOMId
		WHERE intLotId = @intLotId
			AND intTaskId = @intTaskId

		IF @intCustomerLabelTypeId = 2
		BEGIN
			UPDATE tblMFOrderManifest
			SET intLotId = @intAlternateLotId
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intLotId = @intLotId
		END
	END
	ELSE
	BEGIN
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

			IF @intCustomerLabelTypeId = 2
			BEGIN
				UPDATE tblMFOrderManifest
				SET intLotId = @intAlternateLotId
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intLotId = @intLotId
			END
		END
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
