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
		,@dtmAlternateLotExpiryDate DATETIME
		,@intTransactionCount INT
		,@strErrMsg NVARCHAR(MAX)
		,@intItemId INT
		,@intAlternateItemId INT
		,@intLotStatusId INT
		,@intBondStatusId INT
		,@strPrimaryStatus NVARCHAR(50)
		,@intCustomerLabelTypeId INT
		,@intEntityCustomerId INT
		,@strReferenceNo NVARCHAR(50)
		,@intAlternateParentLotId INT
		,@intParentLotId INT
		,@ysnPickByLotCode BIT
		,@intLotCodeStartingPosition INT
		,@intLotCodeNoOfDigits INT
		,@intLotCode INT
		,@intAlternateLotCode INT
		,@intAllowablePickDayRange INT
		,@dblAlternatePickQty NUMERIC(18, 6)
		,@dblShort NUMERIC(18, 6)
		,@dblAlternateTaskQty NUMERIC(18, 6)
		,@intAlternateOrderHeaderId INT
		,@intAlternateTaskId INT
		,@intLocationId INT
		,@ysnPickAllowed BIT
		,@intSubLocationId INT

	SELECT @intItemId = intItemId
		,@intParentLotId = intParentLotId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
	FROM tblICLot
	WHERE intLotId = @intLotId

	IF (@intItemId <> @intAlternateItemId)
	BEGIN
		RAISERROR (
				'ALTERNATE LOT BELONGS TO A DIFFERENT ITEM. CANNOT CONTINUE.'
				,16
				,1
				)
	END

	SELECT @intStorageLocationId = intStorageLocationId
	FROM tblICStorageLocation
	WHERE strName = @strLotSourceLocation
		AND intSubLocationId = @intSubLocationId
		AND intLocationId = @intLocationId

	SELECT @intAlternateLotId = intLotId
		,@dblAlternateLotQty = dblQty
		,@intLotStatusId = intLotStatusId
		,@intAlternateItemId = intItemId
		,@dtmAlternateLotExpiryDate = dtmExpiryDate
		,@intAlternateParentLotId = intParentLotId
	FROM tblICLot
	WHERE strLotNumber = @strAlternateLotNo
		AND intStorageLocationId = @intStorageLocationId
		AND dblQty > 0

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

	IF (GETDATE() > @dtmAlternateLotExpiryDate)
	BEGIN
		RAISERROR (
				'SCANNED LOT HAS EXPIRED.'
				,16
				,1
				)
	END

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

	SELECT @ysnPickByLotCode = ysnPickByLotCode
		,@intLotCodeStartingPosition = intLotCodeStartingPosition
		,@intLotCodeNoOfDigits = intLotCodeNoOfDigits
	FROM tblMFCompanyPreference

	SELECT @intAllowablePickDayRange = intAllowablePickDayRange
	FROM tblMFCompanyPreference

	IF @intLotId <> @intAlternateLotId
		AND @ysnPickByLotCode = 1
	BEGIN
		SELECT @intLotCode = CONVERT(INT, Substring(strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
		FROM tblICParentLot
		WHERE intParentLotId = @intParentLotId

		SELECT @intAlternateLotCode = CONVERT(INT, Substring(strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
		FROM tblICParentLot
		WHERE intParentLotId = @intAlternateParentLotId

		IF @intAlternateLotCode - @intLotCode > @intAllowablePickDayRange
		BEGIN
			RAISERROR (
					'ALTERNATE PALLET IS NOT ALLOWABLE PICK DAY RANGE.'
					,16
					,1
					)
		END
	END

	SELECT @intBondStatusId = intBondStatusId
		,@ysnPickAllowed = ysnPickAllowed
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

	IF @ysnPickAllowed = 0
	BEGIN
		RAISERROR (
				'SCANNED LOT IS NOT ALLOWED.'
				,16
				,1
				)
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
