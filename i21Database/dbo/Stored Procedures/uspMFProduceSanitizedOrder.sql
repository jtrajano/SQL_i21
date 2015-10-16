CREATE PROCEDURE [dbo].[uspMFProduceSanitizedOrder] (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@dblInputWeight NUMERIC(18, 6)
		,@strOutputLotNumber NVARCHAR(50)
		,@intItemId INT
		,@dblQty NUMERIC(18, 6)
		,@intItemUOMId INT
		,@dblWeightPerQty NUMERIC(18, 6)
		,@dblWeight NUMERIC(18, 6)
		,@intWeightUOMId INT
		,@intStorageLocationId INT
		,@intUserId INT
		,@intUnitPerLayer INT
		,@intLayerPerPallet INT
		,@intNoOfPallet INT
		,@intTransactionCount INT
		,@intLocationId INT
		,@intOutputLotId INT
		,@dtmCreated DATETIME
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@intBatchId INT
		,@intSubLocationId INT
		,@intInputLotId INT
		,@dblInputWeightPerQty NUMERIC(18, 6)
		,@strDefaultStatusForSanitizedLot NVARCHAR(50)
		,@intLotStatusId INT

	--SELECT @strDefaultStatusForSanitizedLot = strDefaultStatusForSanitizedLot
	--FROM dbo.tblMFCompanyPreference
	EXEC dbo.uspSMGetStartingNumber 33
		,@intBatchId OUTPUT

	SELECT @intTransactionCount = @@TRANCOUNT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intInputLotId = intInputLotId
		,@intOutputLotId = intOutputLotId
		,@strOutputLotNumber = strOutputLotNumber
		,@intItemId = intItemId
		,@dblQty = dblQty
		,@intItemUOMId = intItemUOMId
		,@dblWeightPerQty = dblWeightPerQty
		,@dblWeight = dblWeight
		,@intWeightUOMId = intWeightUOMId
		,@intStorageLocationId = intStorageLocationId
		,@intSubLocationId = intSubLocationId
		,@intUserId = intUserId
		,@intUnitPerLayer = intUnitPerLayer
		,@intLayerPerPallet = intLayerPerPallet
		,@intNoOfPallet = intNoOfPallet
		,@intLocationId = intLocationId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intInputLotId INT
			,intOutputLotId INT
			,strOutputLotNumber NVARCHAR(50)
			,intItemId INT
			,dblQty NUMERIC(18, 6)
			,intItemUOMId INT
			,dblWeightPerQty NUMERIC(18, 6)
			,dblWeight NUMERIC(18, 6)
			,intWeightUOMId INT
			,intStorageLocationId INT
			,intSubLocationId INT
			,intUserId INT
			,intUnitPerLayer INT
			,intLayerPerPallet INT
			,intNoOfPallet INT
			,intLocationId INT
			)

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	SELECT @dblInputWeight = dblWeight
		,@dblInputWeightPerQty = dblWeightPerQty
	FROM tblICLot
	WHERE intLotId = @intInputLotId

	IF @dblWeight > @dblInputWeight
	BEGIN
		EXEC uspMFLotAdjustQty @intOutputLotId = @intOutputLotId
			,@dblNewLotQty = dblWeight
			,@intUserId = @intUserId
			,@strReasonCode = 'Production'
			,@strNotes = 'Production - Adjust'
	END

	SELECT @dtmCreated = Getdate()

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCreated, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCreated BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	IF @intOutputLotId IS NULL
	BEGIN
		EXEC dbo.uspMFLotSplit @intOutputLotId = intInputLotId
			,@strNewLotNumber = @strOutputLotNumber
			,@intSplitSubLocationId = @intSubLocationId
			,@intSplitStorageLocationId = @intStorageLocationId
			,@dblSplitQty = @dblQty
			,@intUserId = @intUserId
			,@strNote = 'Sanitized'

		SELECT @intOutputLotId = intLotId
			,@intLotStatusId = intLotStatusId
		FROM tblICLot
		WHERE strLotNumber = @strOutputLotNumber
			AND intStorageLocationId = @intStorageLocationId

		IF (
				SELECT intLotStatusId
				FROM tblICLotStatus
				WHERE strSecondaryStatus = @strDefaultStatusForSanitizedLot
				) <> @intLotStatusId
		BEGIN
			UPDATE tblICLot
			SET intLotStatusId = @intLotStatusId
			WHERE intLotId = @intOutputLotId
		END
	END
	ELSE
	BEGIN
		IF @dblInputWeightPerQty <> @dblWeightPerQty
		BEGIN
			RAISERROR (
					90003
					,14
					,1
					)
		END

		EXEC dbo.uspMFLotMerge @intOutputLotId = @intInputLotId
			,@intNewLotId = @intOutputLotId
			,@dblMergeQty = @dblQty
			,@intUserId = @intUserId
	END

	INSERT INTO dbo.tblMFWorkOrderProducedLot (
		intWorkOrderId
		,intItemId
		,intLotId
		,dblQuantity
		,intItemUOMId
		,dblWeightPerUnit
		,dblPhysicalCount
		,intPhysicalItemUOMId
		,intStorageLocationId
		,dtmBusinessDate
		,intBusinessShiftId
		,dtmProductionDate
		,intShiftId
		,intBatchId
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		)
	SELECT @intWorkOrderId
		,@intItemId
		,@intOutputLotId
		,@dblWeight
		,@intWeightUOMId
		,@dblWeightPerQty
		,@dblQty
		,@intItemUOMId
		,@intStorageLocationId
		,@dtmBusinessDate
		,@intBusinessShiftId
		,@dtmBusinessDate
		,@intBusinessShiftId
		,@intBatchId
		,@dtmCreated
		,@intUserId
		,@dtmCreated
		,@intUserId

	DECLARE @intOrderHeaderId INT
		,@strSanitizationStagingLocation NVARCHAR(50)
		,@intStagingLocationId INT
		,@dblRequiredWeight NUMERIC(18, 6)
		,@intSKUId INT
		,@intRecordId INT
		,@strSourceContainerNo NVARCHAR(50)
		,@intContainerId INT
		,@intDestinationContainerId INT
		,@dblSplitQty NUMERIC(18, 6)
		,@strDestinationContainerNo NVARCHAR(50)
		,@intNewSKUId INT

	SELECT @intOrderHeaderId = intOrderHeaderId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF @intOrderHeaderId > 0
	BEGIN
		SELECT @strSanitizationStagingLocation = strSanitizationStagingLocation
		FROM dbo.tblMFCompanyPreference

		SELECT @intStagingLocationId = intStorageLocationId
		FROM tblICStorageLocation
		WHERE strName = @strSanitizationStagingLocation
			AND intLocationId = @intLocationId

		DECLARE @tblWHSKU TABLE (
			intRecordId INT IDENTITY(1, 1)
			,intItemId INT
			,intLotId INT
			,intSKUId INT
			,intContainerId INT
			,dblQuantity NUMERIC(16, 8)
			,intItemUOMId INT
			,dblWeightperUnit NUMERIC(16, 8)
			,dblWeight NUMERIC(16, 8)
			,intWeightUOMId INT
			)

		INSERT INTO @tblWHSKU (
			intItemId
			,intLotId
			,intSKUId
			,intContainerId
			,dblQuantity
			,intItemUOMId
			,dblWeightperUnit
			,dblWeight
			,intWeightUOMId
			)
		SELECT S.intItemId
			,S.intLotId
			,S.intSKUId
			,C.intContainerId
			,S.dblQuantity
			,L.intItemUOMId
			,S.dblWeightPerUnit
			,S.dblQuantity * S.dblWeightPerUnit
			,L.intWeightUOMId
		FROM dbo.tblWHSKU S
		JOIN dbo.tblWHContainer C ON C.intContainerId = S.intContainerId
		JOIN dbo.tblICLot L ON L.intLotId = S.intLotId
		JOIN dbo.tblItemUOM I ON I.intItemUOMId = L.intItemUOMId
		LEFT JOIN dbo.tblItemUOM W ON W.intItemUOMId = L.intWeightUOMId
		WHERE C.intStorageLocationId = @intStagingLocationId
			AND S.Qty > 0
			AND S.intLotId = @intInputLotId
		ORDER BY S.intSKUId

		SELECT @dblRequiredWeight = @dblWeight

		SELECT intRecordId = MIN(intRecordId)
		FROM @tblWHSKU

		WHILE @intRecordId IS NOT NULL
			AND @dblRequiredWeight > 0
		BEGIN
			SELECT @intSKUId = NULL
				,@dblWeight = NULL

			SELECT @intSKUId = intSKUId
				,@dblWeight = dblWeight
			FROM @tblWHSKU
			WHERE intRecordId = @intRecordId

			IF @dblRequiredWeight >= @dblWeight
			BEGIN
				UPDATE tblWHSKU
				SET intSKUStatusId = 5
				WHERE intSKUId = @intSKUId

				PRINT 'Call Delete SKU'

				INSERT INTO tblMFWorkOrderConsumedSKU (
					intWorkOrderId
					,intItemId
					,intLotId
					,intSKUId
					,intContainerId
					,dblQuantity
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,intBatchId
					,intShiftId
					,dtmCreated
					,intCreatedUserId
					)
				SELECT @intWorkOrderId
					,intItemId
					,intLotId
					,intSKUId
					,intContainerId
					,dblWeight
					,intWeightUOMId
					,dblQuantity
					,intItemUOMId
					,@intBatchId
					,@intBusinessShiftId
					,@dtmCreated
					,@intUserId
				FROM @tblWHSKU
				WHERE intRecordId = @intRecordId

				SELECT @dblRequiredWeight = @dblRequiredWeight - @dblWeight
			END
			ELSE
			BEGIN
				SELECT @strSourceContainerNo = NULL

				SELECT @strSourceContainerNo = strContainerNo
				FROM dbo.tblWHContainer
				WHERE intContainerId = @intContainerId

				DELETE
				FROM tblWHTASK
				WHERE intFromContainerId = @intContainerId

				SELECT @intDestinationContainerId = NULL
					,@dblSplitQty = NULL

				--SELECT @dblSplitQty = dbo.fn_ConvertFloatToDecimal(CASE 
				--			WHEN @ProcessedUOMKey = UOMKey
				--				THEN @RequiredQty
				--			ELSE (
				--					CASE 
				--						WHEN M.StandardUOMKey <> @ProcessedUOMKey
				--							THEN @RequiredQty * s.WeightPerUnit
				--						ELSE @RequiredQty / @SKUWeightperUnit
				--						END
				--					)
				--			END)
				--FROM dbo.tblWHSKU S
				--JOIN dbo.Material M ON M.MaterialKey = S.MaterialKey
				--WHERE S.intSKUId = @intSKUId
				PRINT 'Call Split SKU proc'

				SELECT @intDestinationContainerId = NULL

				SELECT @intDestinationContainerId = intContainerId
				FROM dbo.tblWHContainer
				WHERE strContainerNo = @strDestinationContainerNo

				SELECT @intNewSKUId = NULL

				SELECT @intNewSKUId = intSKUId
				FROM dbo.tblWHSKU
				WHERE intContainerId = @intDestinationContainerId

				UPDATE tblWHSKU
				SET intSKUStatusId = 5
				WHERE intSKUId = @intNewSKUId

				PRINT 'Call Delete SKU proc'

				INSERT INTO tblMFWorkOrderConsumedSKU (
					intWorkOrderId
					,intItemId
					,intLotId
					,intSKUId
					,intContainerId
					,dblQuantity
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,intBatchId
					,intShiftId
					,dtmCreated
					,intCreatedUserId
					)
				SELECT @intWorkOrderId
					,intItemId
					,intLotId
					,intSKUId
					,intContainerId
					,dblWeight
					,intWeightUOMId
					,dblQuantity
					,intItemUOMId
					,@intBatchId
					,@intBusinessShiftId
					,@dtmCreated
					,@intUserId
				FROM @tblWHSKU
				WHERE intRecordId = @intRecordId

				SELECT @dblRequiredWeight = 0
			END

			SELECT intRecordId = MIN(intRecordId)
			FROM @tblWHSKU
			WHERE intRecordId > @intRecordId
		END
	END
END TRY

BEGIN CATCH
END CATCH
