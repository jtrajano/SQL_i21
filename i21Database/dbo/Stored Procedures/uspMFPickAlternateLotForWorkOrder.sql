CREATE PROCEDURE uspMFPickAlternateLotForWorkOrder @intLotId INT
	,@strAlternateLotNo NVARCHAR(50)
	,@strLotSourceLocation NVARCHAR(50)
	,@intOrderHeaderId INT
	,@intTaskId INT
AS
BEGIN TRY
	--DECLARE @strOrderLotNo NVARCHAR(50)
	DECLARE @intAlternateLotId INT
	DECLARE @intStorageLocationId INT
	--DECLARE @intPickListId INT
	--DECLARE @intCompanyLocationId INT
	DECLARE @dblAlternateLotQty NUMERIC(38, 20)
	DECLARE @dblAlternateLotWeight NUMERIC(38, 20)
	DECLARE @dtmAlternateLotExpiryDate DATETIME
	--DECLARE @dblReservedLotQtyForPickList NUMERIC(38, 20)
	--DECLARE @dblAlternateLotReservedQty NUMERIC(38, 20)
	--DECLARE @dblAlternateLotAvailableQty NUMERIC(38, 20)
	DECLARE @intTransactionCount INT
	DECLARE @dblRequiredTaskQty NUMERIC(18,6)
	DECLARE @dblRequiredTaskWeight NUMERIC(18,6)
	--DECLARE @strBlendProductionStagingLocation NVARCHAR(100)
	--DECLARE @strKitStagingArea NVARCHAR(100)
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intItemId INT
	DECLARE @intAlternateItemId INT
	DECLARE @intLotStatusId INT
		,@intBondStatusId INT
		,@strPrimaryStatus NVARCHAR(50)

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

	SELECT @dblRequiredTaskWeight = dblWeight
		  ,@dblRequiredTaskQty = dblQty
	FROM tblMFTask WHERE intTaskId = @intTaskId

	--SELECT @strBlendProductionStagingLocation = sl.strName
	--FROM tblSMCompanyLocation cl
	--JOIN tblICStorageLocation sl ON cl.intBlendProductionStagingUnitId = sl.intStorageLocationId
	--WHERE intCompanyLocationId = 1
	--SELECT @strKitStagingArea = sl.strName
	--FROM tblMFAttribute a
	--JOIN tblMFManufacturingProcessAttribute mpa ON mpa.intAttributeId = a.intAttributeId
	--JOIN tblICStorageLocation sl ON sl.intStorageLocationId = mpa.strAttributeValue
	--WHERE a.strAttributeName = 'Kit Staging Location'
	--	AND intManufacturingProcessId = 1

	IF(@dblAlternateLotQty > @dblRequiredTaskQty)
	BEGIN
		SET @strErrMsg = 'AVAILABLE QTY IN THE SCANNED LOT IS MORE THAN THE REQUIRED QTY. CANNOT CONTINUE.'

		RAISERROR (@strErrMsg,16,1)
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

	SELECT @intLotStatusId = intLotStatusId,
		   @intAlternateItemId = intItemId,
		   @dtmAlternateLotExpiryDate = dtmExpiryDate
	FROM tblICLot
	WHERE intLotId = @intAlternateLotId

	SELECT @intItemId = intItemId 
	FROM tblICLot 
	WHERE intLotId = @intLotId

	SELECT @strPrimaryStatus = strPrimaryStatus
	FROM tblICLotStatus
	WHERE intLotStatusId = @intLotStatusId

	IF(@intItemId <> @intAlternateItemId)
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

	IF EXISTS((SELECT 1 FROM tblMFTask WHERE intLotId = @intAlternateLotId))
	BEGIN
	IF (@intLotId <> @intAlternateLotId)
		BEGIN
			RAISERROR (
				'SCANNED LOT IS ASSOCIATED WITH A DIFFERENT TASK. CANNOT CONTINUE'
				,16
				,1
				)
		END
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
