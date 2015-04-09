CREATE PROCEDURE uspMFWarehouseReleaseLot (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @intLotId INT
		,@strLotNumber NVARCHAR(50)
		,@strGTINCaseBarCode NVARCHAR(50)
		,@dblQty NUMERIC(18, 6)
		,@intLocationId INT
		,@intItemId INT
		,@strItemNo NVARCHAR(50)
		,@intLotStatusId INT
		,@strSecondaryStatus NVARCHAR(50)
		,@strPrimaryStatus NVARCHAR(50)
		,@CasesPerPallet INT
		,@dblProduceQty NUMERIC(18, 6)
		,@dblReleaseQty NUMERIC(18, 6)
		,@intProduceUnitMeasureId INT
		,@CurrentDate DATETIME
		,@intShiftId INT
		,@strComment NVARCHAR(MAX)
		,@intManufacturingProcessId INT
		,@intUserId INT
		,@idoc INT
		,@ErrMsg NVARCHAR(MAX)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intLotId = intLotId
		,@strGTINCaseBarCode = strGTINCaseBarCode
		,@dblReleaseQty = dblReleaseQty
		,@intManufacturingProcessId = intManufacturingProcessId
		,@intUserId = intUserId
		,@strComment = strComment
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLotId int
			,strGTINCaseBarCode NVARCHAR(50)
			,dblReleaseQty NUMERIC(18, 6)
			,intManufacturingProcessId INT
			,intUserId INT
			,strComment NVARCHAR(MAX)
			)

	IF @intLotId = 0
		OR @intLotId IS NULL
	BEGIN
		RAISERROR (
				'Invalid Lot'
				,16
				,1
				)

		RETURN
	END

	IF @strGTINCaseBarCode = ''
		OR @strGTINCaseBarCode IS NULL
	BEGIN
		RAISERROR (
				'Invalid GTIN Case code'
				,16
				,1
				)

		RETURN
	END

	SELECT @intLotId = intLotId,@strLotNumber=strLotNumber,@intLocationId=intLocationId
		,@intItemId = intItemId
		,@dblQty = dblQty
		,@intLotStatusId = intLotStatusId
	FROM dbo.tblICLot
	WHERE intLotId = @intLotId

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblMFWorkOrderProducedLot
			WHERE intLotId = @intLotId
			)
	BEGIN
		SET @ErrMsg = 'This lot ' + @strLotNumber + ' was not produced through work order production process; hence this lot cannot be released from this screen. Try changing the lot status using the ''Lot Status Change'' screen available in the Inventory view screen.'

		RAISERROR (
				@ErrMsg
				,16
				,1
				)
	END

	IF @dblQty = 0
		OR EXISTS (
			SELECT 1
			FROM dbo.tblMFWorkOrderProducedLot
			WHERE ysnReleased = 1
				AND intLotId = @intLotId
			)
	BEGIN
		RAISERROR (
				'Lot is already in history!'
				,16
				,1
				)

		RETURN
	END

	SELECT @strSecondaryStatus = strSecondaryStatus
		,@strPrimaryStatus = strPrimaryStatus
	FROM dbo.tblICLotStatus
	WHERE intLotStatusId = @intLotStatusId

	IF @strSecondaryStatus = 'Ghost'
	BEGIN
		RAISERROR (
				'Pallet Lot has been marked as a ghost and cannot be released.Please call Supervisor to reverse this!'
				,16
				,1
				)
	END

	IF @strSecondaryStatus <> 'Quarantined'
		OR (
			@strSecondaryStatus = 'In_Warehouse'
			AND @strPrimaryStatus = 'On_Hold'
			)
		--OR (
		--	@strSecondaryStatus = 'ACTIVE'
		--	AND @strPrimaryStatus = 'ACTIVE'
		--	)
	BEGIN
		RAISERROR (
				'Lot has already been released!.'
				,16
				,1
				)
	END

	SELECT @CasesPerPallet = intLayerPerPallet * intUnitPerLayer
		,@strItemNo = strItemNo
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	IF @CasesPerPallet > 0
		AND @dblReleaseQty > @CasesPerPallet
	BEGIN
		RAISERROR (
				'The pallet lot quantity cannot exceed more than  material''s cases per pallet value. Please check quantity produced.'
				,16
				,1
				)

		RETURN
	END

	IF @strItemNo <> @strGTINCaseBarCode
	BEGIN
		RAISERROR (
				'Item number for GTIN Case Code and Pallet Lot ID is not matching, please scan the appropriate case code.'
				,16
				,1
				)
	END

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblMFRecipe R
			JOIN dbo.tblICLot L ON L.intItemId = R.intItemId
				AND R.intLocationId = @intLocationId
				AND R.intManufacturingProcessId = @intManufacturingProcessId
			)
	BEGIN
		RAISERROR (
				'Invalid material type - you can only release finished goods items!'
				,16
				,1
				)
	END

	SELECT @CurrentDate = Convert(CHAR, Getdate(), 108)

	SELECT @intShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @CurrentDate BETWEEN dtmShiftStartTime
			AND dtmShiftEndTime + intEndOffset

	BEGIN TRANSACTION

	UPDATE dbo.tblMFWorkOrderProducedLot
	SET dblReleaseQty = @dblReleaseQty
		,ysnReleased = 1
		,intReleasedUserId = @intUserId
		,dtmReleasedDate = GETDATE()
		,intReleasedShiftId = @intShiftId
		,strComment = @strComment
		,dtmLastModified = GETDATE()
		,intLastModifiedUserId = @intUserId
	WHERE intLotId = @intLotId

	Update tblICLot Set intLotStatusId =1 Where intLotId=@intLotId

	COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH