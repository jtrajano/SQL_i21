CREATE PROCEDURE [dbo].[uspMFTransferPickListForProduction] @intWorkOrderId INT
	,@intLocationId INT
	,@intProductionStagingLocationId INT
	,@intUserId INT
AS
BEGIN TRY
	DECLARE @intPickListId INT
	DECLARE @intManufacturingProcessId INT
	DECLARE @intLotId INT
	DECLARE @intNewSubLocationId INT
	DECLARE @strLotNumber NVARCHAR(50)
	DECLARE @intNewLotId INT
	DECLARE @intItemId INT
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @intMinWorkOrder INT
	DECLARE @intMinParentLot INT
	DECLARE @intMinChildLot INT
	DECLARE @intParentLotId INT
	DECLARE @dblReqQty NUMERIC(38, 20)
	DECLARE @dblAvailableQty NUMERIC(38, 20)
	DECLARE @dtmCurrentDateTime DATETIME = GETDATE()
	DECLARE @index INT
	DECLARE @id INT
	DECLARE @intBlendItemId INT
	DECLARE @dblWeightPerUnit NUMERIC(38, 20)
	DECLARE @intItemUOMId INT
	DECLARE @intItemIssuedUOMId INT
	DECLARE @strInActiveLots NVARCHAR(MAX)
	DECLARE @intPickListDetailId INT
		,@dtmProductionDate DATETIME
		,@intShiftId INT
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@dblInputWeight NUMERIC(38, 20)
		,@intItemTypeId INT
		,@intCategoryId INT
	DECLARE @strBulkItemXml NVARCHAR(max)
		,@dblPickQuantity NUMERIC(38, 20)
		,@intPickUOMId INT
		,@intQtyItemUOMId INT
		,@intMachineId INT

	IF ISNULL(@intProductionStagingLocationId, 0) = 0
		RAISERROR (
				'Blend Staging Location is not defined.'
				,16
				,1
				)

	SELECT @intNewSubLocationId = intSubLocationId
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intProductionStagingLocationId

	DECLARE @tblChildLot TABLE (
		intRowNo INT Identity(1, 1)
		,intStageLotId INT
		,strStageLotNumber NVARCHAR(50)
		,intItemId INT
		,dblAvailableQty NUMERIC(38, 20)
		,intItemUOMId INT
		,intItemIssuedUOMId INT
		,dblWeightPerUnit NUMERIC(38, 20)
		,dblPickQuantity NUMERIC(38, 20)
		,intPickUOMId INT
		,intPickListDetailId INT
		)

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	SELECT @intPickListId = intPickListId
		,@intBlendItemId = intItemId
		,@dtmProductionDate = dtmPlannedDate
		,@intShiftId = intPlannedShiftId
		,@intMachineId = intMachineId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF (
			SELECT intKitStatusId
			FROM tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId
			) = 8
	BEGIN
		SET @ErrMsg = 'The Work Order is already transferred.'

		RAISERROR (
				@ErrMsg
				,16
				,1
				)
	END

	IF (
			SELECT intStatusId
			FROM tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId
			) = 13
	BEGIN
		SET @ErrMsg = 'The Work Order is already completed.'

		RAISERROR (
				@ErrMsg
				,16
				,1
				)
	END

	--Only Active lots are allowed to transfer
	SELECT @strInActiveLots = COALESCE(@strInActiveLots + ', ', '') + l.strLotNumber
	FROM tblMFPickListDetail tpl
	JOIN tblICLot l ON tpl.intLotId = l.intLotId
	JOIN tblICLotStatus ls ON l.intLotStatusId = ls.intLotStatusId
	WHERE tpl.intPickListId = @intPickListId
		AND ls.strPrimaryStatus <> 'Active'

	IF ISNULL(@strInActiveLots, '') <> ''
	BEGIN
		SET @ErrMsg = 'Lots ' + @strInActiveLots + ' are not active. Unable to perform transfer operation.'

		RAISERROR (
				@ErrMsg
				,16
				,1
				)
	END

	--validate shortage of inventory
	EXEC uspMFValidateTransferKit @intWorkOrderId
		,0
		,1

	BEGIN TRAN

	--Create Reservation
	--Get Bulk Items From Reserved Lots
	SET @strBulkItemXml = '<root>'

	--Bulk Item
	SELECT @strBulkItemXml = COALESCE(@strBulkItemXml, '') + '<lot>' + '<intItemId>' + convert(VARCHAR, sr.intItemId) + '</intItemId>' + '<intItemUOMId>' + convert(VARCHAR, sr.intItemUOMId) + '</intItemUOMId>' + '<dblQuantity>' + convert(VARCHAR, sr.dblQty) + '</dblQuantity>' + '</lot>'
	FROM tblICStockReservation sr
	WHERE sr.intTransactionId = @intPickListId
		AND sr.intInventoryTransactionType = 34
		AND ISNULL(sr.intLotId, 0) = 0
		AND sr.intItemId NOT IN (
			SELECT intItemId
			FROM tblMFPickListDetail
			WHERE intPickListId = @intPickListId
			)

	SET @strBulkItemXml = @strBulkItemXml + '</root>'

	IF LTRIM(RTRIM(@strBulkItemXml)) = '<root></root>'
		SET @strBulkItemXml = ''

	EXEC uspMFDeleteLotReservationByPickList @intPickListId = @intPickListId

	--Get the child Lots attached to Pick List
	DELETE
	FROM @tblChildLot

	INSERT INTO @tblChildLot (
		intStageLotId
		,strStageLotNumber
		,intItemId
		,dblAvailableQty
		,intItemUOMId
		,intItemIssuedUOMId
		,dblWeightPerUnit
		,dblPickQuantity
		,intPickUOMId
		,intPickListDetailId
		)
	SELECT l.intLotId
		,l.strLotNumber
		,l.intItemId
		,pld.dblQuantity
		,pld.intItemUOMId
		,pld.intItemIssuedUOMId
		,CASE 
			WHEN ISNULL(l.dblWeightPerQty, 0) = 0
				THEN 1
			ELSE l.dblWeightPerQty
			END AS dblWeightPerQty
		,pld.dblPickQuantity
		,pld.intPickUOMId
		,pld.intPickListDetailId
	FROM tblMFPickListDetail pld
	JOIN tblICLot l ON pld.intStageLotId = l.intLotId
	WHERE pld.intPickListId = @intPickListId
		AND pld.intLotId = pld.intStageLotId
	
	UNION --Non Lot Tracked
	
	SELECT 0
		,''
		,pld.intItemId
		,0
		,pld.intItemUOMId
		,pld.intItemIssuedUOMId
		,1
		,pld.dblQuantity
		,pld.intPickUOMId
		,pld.intPickListDetailId
	FROM tblMFPickListDetail pld
	JOIN tblICItem i ON pld.intItemId = i.intItemId
	WHERE pld.intPickListId = @intPickListId
		AND i.strLotTracking = 'No'

	SELECT @intMinChildLot = Min(intRowNo)
	FROM @tblChildLot

	WHILE (@intMinChildLot IS NOT NULL) --Loop Child Lot.
	BEGIN
		SELECT @dblPickQuantity = NULL
			,@intPickUOMId = NULL
			,@intQtyItemUOMId = NULL

		SELECT @intLotId = intStageLotId
			,@strLotNumber = strStageLotNumber
			,@dblReqQty = dblAvailableQty
			,@intItemId = intItemId
			,@dblWeightPerUnit = dblWeightPerUnit
			,@dblPickQuantity = dblPickQuantity
			,@intPickUOMId = intPickUOMId
			,@intQtyItemUOMId = intItemUOMId
			,@intPickListDetailId = intPickListDetailId
		FROM @tblChildLot
		WHERE intRowNo = @intMinChildLot

		--Non Lot Tracked Item
		IF ISNULL(@intLotId, 0) = 0
		BEGIN
			EXEC uspMFKitItemMove @intPickListDetailId
				,@intProductionStagingLocationId
				,@intUserId

			INSERT INTO tblMFWorkOrderInputLot (
				intWorkOrderId
				,intLotId
				,intItemId
				,dblQuantity
				,intItemUOMId
				,dblIssuedQuantity
				,intItemIssuedUOMId
				,intSequenceNo
				,dtmCreated
				,intCreatedUserId
				,dtmLastModified
				,intLastModifiedUserId
				,intRecipeItemId
				,intStorageLocationId
				,dtmProductionDate
				,intShiftId
				,dtmActualInputDateTime
				,dtmBusinessDate
				,intBusinessShiftId
				)
			SELECT @intWorkOrderId
				,NULL
				,@intItemId
				,@dblPickQuantity
				,@intPickUOMId
				,@dblPickQuantity
				,@intPickUOMId
				,NULL
				,@dtmCurrentDateTime
				,@intUserId
				,@dtmCurrentDateTime
				,@intUserId
				,NULL
				,@intProductionStagingLocationId
				,@dtmProductionDate
				,@intShiftId
				,@dtmCurrentDateTime
				,@dtmBusinessDate
				,@intBusinessShiftId

			GOTO NEXT_RECORD
		END

		SET @intNewLotId = NULL

		SELECT TOP 1 @intNewLotId = intLotId
		FROM tblICLot
		WHERE strLotNumber = @strLotNumber
			AND intItemId = @intItemId
			AND intLocationId = @intLocationId
			AND intSubLocationId = @intNewSubLocationId
			AND intStorageLocationId = @intProductionStagingLocationId --And dblQty > 0

		--IF NOT EXISTS(SELECT *FROM dbo.tblICLot WHERE intLotId=@intLotId AND (intItemUOMId=@intPickUOMId OR intWeightUOMId =@intPickUOMId ))
		--BEGIN
		--	SELECT @dblPickQuantity=@dblReqQty
		--	SELECT @intPickUOMId=@intQtyItemUOMId
		--END
		IF ISNULL(@intNewLotId, 0) = 0 --Move
		BEGIN
			EXEC [uspMFLotMove] @intLotId = @intLotId
				,@intNewSubLocationId = @intNewSubLocationId
				,@intNewStorageLocationId = @intProductionStagingLocationId
				,@dblMoveQty = @dblPickQuantity
				,@intMoveItemUOMId = @intPickUOMId
				,@intUserId = @intUserId

			SELECT TOP 1 @intNewLotId = intLotId
			FROM tblICLot
			WHERE strLotNumber = @strLotNumber
				AND intItemId = @intItemId
				AND intLocationId = @intLocationId
				AND intSubLocationId = @intNewSubLocationId
				AND intStorageLocationId = @intProductionStagingLocationId --And dblQty > 0
		END
		ELSE --Merge
			EXEC [uspMFLotMerge] @intLotId = @intLotId
				,@intNewLotId = @intNewLotId
				,@dblMergeQty = @dblPickQuantity
				,@intMergeItemUOMId = @intPickUOMId
				,@intUserId = @intUserId

		INSERT INTO tblMFWorkOrderInputLot (
			intWorkOrderId
			,intLotId
			,intItemId
			,dblQuantity
			,intItemUOMId
			,dblIssuedQuantity
			,intItemIssuedUOMId
			,intSequenceNo
			,dtmCreated
			,intCreatedUserId
			,dtmLastModified
			,intLastModifiedUserId
			,intRecipeItemId
			,intStorageLocationId
			,dtmProductionDate
			,intShiftId
			,dtmActualInputDateTime
			,dtmBusinessDate
			,intBusinessShiftId
			)
		SELECT @intWorkOrderId
			,@intNewLotId
			,@intItemId
			,dblPickQuantity
			,intPickUOMId
			,dblPickQuantity
			,intPickUOMId
			,NULL
			,@dtmCurrentDateTime
			,@intUserId
			,@dtmCurrentDateTime
			,@intUserId
			,NULL
			,@intProductionStagingLocationId
			,@dtmProductionDate
			,@intShiftId
			,@dtmCurrentDateTime
			,@dtmBusinessDate
			,@intBusinessShiftId
		FROM @tblChildLot
		WHERE intRowNo = @intMinChildLot

		UPDATE tblMFPickListDetail
		SET intStageLotId = @intNewLotId
		WHERE intPickListDetailId = @intPickListDetailId

		SELECT @dblInputWeight = NULL

		SELECT @dblInputWeight = dblPickQuantity
		FROM @tblChildLot
		WHERE intRowNo = @intMinChildLot

		IF NOT EXISTS (
				SELECT *
				FROM tblMFProductionSummary
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId = @intItemId
					AND IsNULL(intMachineId, 0) = IsNULL(@intMachineId, 0)
				)
		BEGIN
			SELECT @intCategoryId = intCategoryId
			FROM dbo.tblICItem
			WHERE intItemId = @intItemId

			SELECT @intItemTypeId = (
					CASE 
						WHEN RS.intRecipeSubstituteItemId IS NULL
							THEN 1
						ELSE 3
						END
					)
			FROM dbo.tblMFWorkOrderRecipeItem RI
			LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RS ON RS.intRecipeItemId = RI.intRecipeItemId
			WHERE RI.intWorkOrderId = @intWorkOrderId
				AND RI.intRecipeItemTypeId = 1
				AND (
					RI.intItemId = @intItemId
					OR RS.intSubstituteItemId = @intItemId
					)

			INSERT INTO tblMFProductionSummary (
				intWorkOrderId
				,intItemId
				,dblOpeningQuantity
				,dblOpeningOutputQuantity
				,dblOpeningConversionQuantity
				,dblInputQuantity
				,dblConsumedQuantity
				,dblOutputQuantity
				,dblOutputConversionQuantity
				,dblCountQuantity
				,dblCountOutputQuantity
				,dblCountConversionQuantity
				,dblCalculatedQuantity
				,intItemTypeId
				,intMachineId
				)
			SELECT @intWorkOrderId
				,@intItemId
				,0
				,0
				,0
				,@dblInputWeight
				,0
				,0
				,0
				,0
				,0
				,0
				,0
				,@intItemTypeId
				,@intMachineId
		END
		ELSE
		BEGIN
			UPDATE tblMFProductionSummary
			SET dblInputQuantity = dblInputQuantity + @dblInputWeight
			WHERE intWorkOrderId = @intWorkOrderId
				AND intItemId = @intItemId
				AND IsNULL(intMachineId, 0) = IsNULL(@intMachineId, 0)
		END

		NEXT_RECORD:

		SELECT @intMinChildLot = Min(intRowNo)
		FROM @tblChildLot
		WHERE intRowNo > @intMinChildLot
	END --End Loop Child Lots

	EXEC [uspMFCreateLotReservation] @intWorkOrderId = @intWorkOrderId
		,@ysnReservationByParentLot = 0
		,@strBulkItemXml = @strBulkItemXml

	UPDATE tblMFWorkOrder
	SET intKitStatusId = 8
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = @dtmCurrentDateTime
		,intStagingLocationId = @intProductionStagingLocationId
		,dtmStagedDate = @dtmCurrentDateTime
	WHERE intWorkOrderId = @intWorkOrderId

	COMMIT TRAN
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
