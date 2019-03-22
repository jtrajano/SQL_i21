CREATE PROCEDURE uspMFCloseSanitizationWorkOrder (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intUserId INT
		,@dtmCurrentDate DATETIME
		,@intExecutionOrder INT
		,@intManufacturingCellId INT
		,@dtmPlannedDate DATETIME
		,@intOrderHeaderId INT
		,@intRecordId INT
		,@strLotNumber NVARCHAR(50)
		,@intLotId INT
		,@dblQuantity NUMERIC(38, 20)
		,@intItemUOMId INT
		,@intBatchId INT
		,@dblProducedQuantity NUMERIC(38, 20)
		,@strProducedQuantity NVARCHAR(50)
		,@dblOutputQtyTolerancePercentage NUMERIC(38, 20)
		,@dblCalculatedInputLotToleranceQty NUMERIC(38, 20)
		,@strCalculatedInputLotToleranceQty nvarchar(50)
		,@intUnitMeasureId INT
		,@strUnitMeasure NVARCHAR(50)
		,@intTransactionCount INT
		,@intLocationId int
		
	DECLARE @tblMFWorkOrderConsumedLot TABLE (
		intRecordId INT identity(1, 1)
		,intLotId INT
		,dblQuantity NUMERIC(38, 20)
		,intItemUOMId INT
		,intBatchId INT
		)

	SELECT @dtmCurrentDate = GetDate()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intUserId INT
			)

	IF NOT EXISTS (
			SELECT *
			FROM tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId
			)
	BEGIN
		RAISERROR (
				'The work order that you clicked on no longer exists. This is quite possible, if a packaging operator has deleted the work order and your iMake client is yet to refresh the screen.'
				,11
				,1
				)
	END

	SELECT @intLocationId=intLocationId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	--SELECT @dblOutputQtyTolerancePercentage = dblSanitizationOrderOutputQtyTolerancePercentage
	--FROM dbo.tblMFCompanyPreference
	SELECT dblOutputQtyTolerancePercentage=dblSanitizationOrderOutputQtyTolerancePercentage
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId=@intLocationId

	INSERT INTO @tblMFWorkOrderConsumedLot (
		intLotId
		,dblQuantity
		,intItemUOMId
		,intBatchId
		)
	SELECT intLotId
		,dblQuantity
		,intItemUOMId
		,intBatchId
	FROM dbo.tblMFWorkOrderConsumedLot
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblMFWorkOrderConsumedLot

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @intLotId = NULL
			,@dblQuantity = NULL
			,@intItemUOMId = NULL
			,@intBatchId = NULL

		SELECT @intLotId = intLotId
			,@dblQuantity = dblQuantity
			,@intItemUOMId = intItemUOMId
			,@intBatchId = intBatchId
		FROM @tblMFWorkOrderConsumedLot
		WHERE intRecordId = @intRecordId

		SELECT @dblProducedQuantity = SUM(dblQuantity)
		FROM dbo.tblMFWorkOrderProducedLot
		WHERE intWorkOrderId=@intWorkOrderId AND intInputLotId = @intLotId

		IF @dblProducedQuantity IS NULL
			SELECT @dblProducedQuantity = 0

		SELECT @dblCalculatedInputLotToleranceQty = @dblQuantity - (@dblQuantity * @dblOutputQtyTolerancePercentage / 100)

		IF @dblProducedQuantity < @dblCalculatedInputLotToleranceQty
		BEGIN
			SELECT @intUnitMeasureId = intUnitMeasureId
			FROM dbo.tblICItemUOM
			WHERE intItemUOMId = @intItemUOMId

			SELECT @strUnitMeasure = strUnitMeasure
			FROM dbo.tblICUnitMeasure
			WHERE intUnitMeasureId = @intUnitMeasureId

			SELECT @strLotNumber = strLotNumber
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId

			SELECT @strProducedQuantity = @dblProducedQuantity
			SELECT @strCalculatedInputLotToleranceQty = @dblCalculatedInputLotToleranceQty

			RAISERROR (
					'The quantity you are trying to produce ( %s %s ) is less than the quantity allowed ( %s %s ) for the lot %s.'
					,14
					,1
					,@strProducedQuantity
					,@strUnitMeasure
					,@strCalculatedInputLotToleranceQty
					,@strUnitMeasure
					,@strLotNumber
					)
		END

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFWorkOrderConsumedLot
		WHERE intRecordId > @intRecordId
	END

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	DELETE FROM tblICStockReservation WHERE intTransactionId=@intWorkOrderId

	SELECT @intExecutionOrder = intExecutionOrder
		,@intManufacturingCellId = intManufacturingCellId
		,@dtmPlannedDate = dtmPlannedDate
		,@intOrderHeaderId = intOrderHeaderId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblWHOrderHeader
	SET intOrderStatusId = 10
		,intLastUpdateById = @intUserId
		,dtmLastUpdateOn = @dtmCurrentDate
	WHERE intOrderHeaderId = @intOrderHeaderId

	UPDATE dbo.tblMFWorkOrder
	SET intStatusId = 13
		,dtmCompletedDate = @dtmCurrentDate
		,intExecutionOrder = 0
		,intConcurrencyId = intConcurrencyId + 1
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblMFWorkOrder
	SET intExecutionOrder = intExecutionOrder - 1
	WHERE intManufacturingCellId = @intManufacturingCellId
		AND dtmPlannedDate = @dtmPlannedDate
		AND intExecutionOrder > @intExecutionOrder

	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
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
GO


