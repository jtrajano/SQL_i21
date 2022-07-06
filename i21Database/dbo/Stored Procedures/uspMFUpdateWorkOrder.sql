CREATE PROCEDURE [dbo].[uspMFUpdateWorkOrder] (
	@strXML NVARCHAR(MAX)
	,@intConcurrencyId INT OUTPUT
	)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@dblQuantity NUMERIC(18, 6)
		,@intUserId INT
		,@intItemId INT
		,@strLotNumber NVARCHAR(50)
		,@strVendorLotNo NVARCHAR(50)
		,@strWorkOrderNo NVARCHAR(50)
		,@strReferenceNo NVARCHAR(50)
		,@intItemUOMId INT
		,@intManufacturingCellId INT
		,@dblBatchSize NUMERIC(18, 6)
		,@intLocationId INT
		,@dtmPlannedDate DATETIME
		,@intPlannedShiftId INT
		,@intManufacturingProcessId INT
		,@intStorageLocationId INT
		,@intExecutionOrder INT
		,@intSubLocationId INT
		,@intProductionTypeId INT
		,@strSpecialInstruction NVARCHAR(MAX)
		,@strComment NVARCHAR(MAX)
		,@intParentWorkOrderId INT
		,@intSalesRepresentativeId INT
		,@intCustomerId INT
		,@strSalesOrderNo NVARCHAR(50)
		,@intSupervisorId INT
		,@intPrevExecutionOrder INT
		,@dtmOrderDate DATETIME
		,@dtmExpectedDate DATETIME
		,@ysnIngredientAvailable BIT
		,@intMaxExecutionOrder INT
		,@intDepartmentId INT
		,@intTransactionCount INT
		,@intBlendRequirementId INT
		,@intUnitMeasureId INT
		,@dtmCurrentDate DATETIME
		,@dtmPrevPlannedDate DATETIME
		,@intSalesOrderLineItemId INT
		,@intLoadId INT
		,@intWarehouseRateMatrixHeaderId INT
		,@intMachineId INT
		,@intStatusId INT

	SELECT @dtmCurrentDate = GETDATE()

	SELECT @intTransactionCount = @@TRANCOUNT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@strWorkOrderNo = strWorkOrderNo
		,@strReferenceNo = strReferenceNo
		,@dtmOrderDate = dtmOrderDate
		,@intManufacturingProcessId = intManufacturingProcessId
		,@intManufacturingCellId = intManufacturingCellId
		,@dblBatchSize = dblBatchSize
		,@dtmPlannedDate = dtmPlannedDate
		,@intPlannedShiftId = intPlannedShiftId
		,@intItemId = intItemId
		,@dblQuantity = dblQuantity
		,@intItemUOMId = intItemUOMId
		,@dtmExpectedDate = dtmExpectedDate
		,@intExecutionOrder = intExecutionOrder
		,@intUserId = intUserId
		,@strLotNumber = strLotNumber
		,@strVendorLotNo = strVendorLotNo
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@intProductionTypeId = intProductionTypeId
		,@strSpecialInstruction = strSpecialInstruction
		,@strComment = strComment
		,@intParentWorkOrderId = intParentWorkOrderId
		,@intSalesRepresentativeId = intSalesRepresentativeId
		,@intCustomerId = intCustomerId
		,@strSalesOrderNo = strSalesOrderNo
		,@intSupervisorId = intSupervisorId
		,@ysnIngredientAvailable = ysnIngredientAvailable
		,@intDepartmentId = intDepartmentId
		,@intSalesOrderLineItemId = intSalesOrderLineItemId
		,@intLoadId = intLoadId
		,@intWarehouseRateMatrixHeaderId = intWarehouseRateMatrixHeaderId
		,@intMachineId = intMachineId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,strWorkOrderNo NVARCHAR(50)
			,strReferenceNo NVARCHAR(50)
			,dtmOrderDate DATETIME
			,dtmExpectedDate DATETIME
			,intManufacturingProcessId INT
			,intManufacturingCellId INT
			,dblBatchSize NUMERIC(18, 6)
			,dtmPlannedDate DATETIME
			,intPlannedShiftId INT
			,intItemId INT
			,dblQuantity NUMERIC(18, 6)
			,intItemUOMId INT
			,intExecutionOrder INT
			,intUserId INT
			,strLotNumber NVARCHAR(50)
			,strVendorLotNo NVARCHAR(50)
			,intLocationId INT
			,intSubLocationId INT
			,intStorageLocationId INT
			,intProductionTypeId INT
			,strSpecialInstruction NVARCHAR(MAX)
			,strComment NVARCHAR(MAX)
			,intParentWorkOrderId INT
			,intSalesRepresentativeId INT
			,intCustomerId INT
			,strSalesOrderNo NVARCHAR(50)
			,intSupervisorId INT
			,ysnIngredientAvailable BIT
			,intDepartmentId INT
			,intSalesOrderLineItemId INT
			,intLoadId INT
			,intWarehouseRateMatrixHeaderId INT
			,intMachineId INT
			)

	IF EXISTS (
			SELECT *
			FROM tblMFWorkOrder
			WHERE strLotNumber = @strLotNumber
				AND intWorkOrderId <> @intWorkOrderId
			)
		AND @strLotNumber <> ''
	BEGIN
		RAISERROR (
				'Lot Id already exists. It should be unique'
				,11
				,1
				)
	END

	SELECT @intPrevExecutionOrder = intExecutionOrder
		,@intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
		,@intBlendRequirementId = intBlendRequirementId
		,@dtmPrevPlannedDate = dtmPlannedDate
		,@intStatusId = intStatusId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF @intPrevExecutionOrder <> @intExecutionOrder
	BEGIN
		SELECT @intMaxExecutionOrder = Count(*)
		FROM dbo.tblMFWorkOrder
		WHERE intManufacturingCellId = @intManufacturingCellId
			AND dtmPlannedDate = @dtmPlannedDate
			AND intStatusId <> 13

		IF @intExecutionOrder > @intMaxExecutionOrder
			OR 0 > @intExecutionOrder
		BEGIN
			RAISERROR (
					'Execution order entered is out of range.'
					,11
					,1
					)
		END
	END

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF NOT EXISTS (
			SELECT *
			FROM tblMFSchedule
			WHERE ysnStandard = 1
			)
		AND @dtmPrevPlannedDate <> @dtmPlannedDate
	BEGIN
		UPDATE tblMFStageWorkOrder
		SET dtmPlannedDate = @dtmPlannedDate
		WHERE intWorkOrderId = @intWorkOrderId
	END

	IF @intPrevExecutionOrder <> @intExecutionOrder
	BEGIN
		IF @intPrevExecutionOrder > @intExecutionOrder --Move upward
		BEGIN
			UPDATE dbo.tblMFWorkOrder
			SET intExecutionOrder = intExecutionOrder + 1
			WHERE intManufacturingCellId = @intManufacturingCellId
				AND dtmPlannedDate = @dtmPlannedDate
				AND intExecutionOrder BETWEEN @intExecutionOrder
					AND @intPrevExecutionOrder
				AND intStatusId <> 13
		END
		ELSE
		BEGIN --Move downward
			UPDATE dbo.tblMFWorkOrder
			SET intExecutionOrder = intExecutionOrder - 1
			WHERE intManufacturingCellId = @intManufacturingCellId
				AND dtmPlannedDate = @dtmPlannedDate
				AND intExecutionOrder BETWEEN @intPrevExecutionOrder
					AND @intExecutionOrder
				AND intStatusId <> 13
		END
	END

	UPDATE dbo.tblMFWorkOrder
	SET strWorkOrderNo = @strWorkOrderNo
		,strReferenceNo = @strReferenceNo
		,dtmOrderDate = @dtmOrderDate
		,intManufacturingProcessId = @intManufacturingProcessId
		,intItemId = @intItemId
		,dblQuantity = @dblQuantity
		,intItemUOMId = @intItemUOMId
		,intManufacturingCellId = @intManufacturingCellId
		,dblBatchSize = @dblBatchSize
		,intStorageLocationId = @intStorageLocationId
		,intSubLocationId = @intSubLocationId
		,intLocationId = @intLocationId
		,strLotNumber = @strLotNumber
		,strVendorLotNo = @strVendorLotNo
		,dtmPlannedDate = @dtmPlannedDate
		,intPlannedShiftId = @intPlannedShiftId
		,dtmExpectedDate = @dtmExpectedDate
		,intExecutionOrder = ISNULL(@intExecutionOrder, 1)
		,intProductionTypeId = @intProductionTypeId
		,strSpecialInstruction = @strSpecialInstruction
		,strComment = @strComment
		,intParentWorkOrderId = @intParentWorkOrderId
		,intSalesOrderLineItemId = @intSalesOrderLineItemId
		,intSalesRepresentativeId = @intSalesRepresentativeId
		,intSupervisorId = @intSupervisorId
		,intCustomerId = @intCustomerId
		,ysnIngredientAvailable = @ysnIngredientAvailable
		,intDepartmentId = @intDepartmentId
		,intLoadId = @intLoadId
		,intWarehouseRateMatrixHeaderId = @intWarehouseRateMatrixHeaderId
		,intMachineId = @intMachineId
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
		,intConcurrencyId = @intConcurrencyId
	WHERE intWorkOrderId = @intWorkOrderId

	IF @intStatusId IN (
			9
			,10
			)
	BEGIN
		DELETE
		FROM tblMFWorkOrderPreStage
		WHERE intWorkOrderId = @intWorkOrderId
			AND strRowState = 'Modified'
			AND intStatusId IS NULL

		INSERT INTO dbo.tblMFWorkOrderPreStage (
			intWorkOrderId
			,intWorkOrderStatusId
			,intUserId
			,strRowState
			)
		SELECT @intWorkOrderId
			,9
			,@intUserId
			,'Modified'
	END

	INSERT INTO dbo.tblMFWorkOrderProductSpecification (
		intWorkOrderId
		,strParameterName
		,strParameterValue
		,intConcurrencyId
		)
	SELECT @intWorkOrderId
		,strParameterName
		,strParameterValue
		,1
	FROM OPENXML(@idoc, 'root/WorkOrderProductSpecifications/WorkOrderProductSpecification', 2) WITH (
			intWorkOrderProductSpecificationId INT
			,strParameterName NVARCHAR(50)
			,strParameterValue NVARCHAR(MAX)
			,strRowState NVARCHAR(50)
			) x
	WHERE x.intWorkOrderProductSpecificationId = 0
		AND x.strRowState = 'ADDED'

	UPDATE tblMFWorkOrderProductSpecification
	SET strParameterName = x.strParameterName
		,strParameterValue = x.strParameterValue
		,intConcurrencyId = Isnull(intConcurrencyId, 0) + 1
	FROM OPENXML(@idoc, 'root/WorkOrderProductSpecifications/WorkOrderProductSpecification', 2) WITH (
			intWorkOrderProductSpecificationId INT
			,strParameterName NVARCHAR(50)
			,strParameterValue NVARCHAR(MAX)
			,strRowState NVARCHAR(50)
			) x
	WHERE x.intWorkOrderProductSpecificationId = tblMFWorkOrderProductSpecification.intWorkOrderProductSpecificationId
		AND x.strRowState = 'MODIFIED'

	DELETE
	FROM dbo.tblMFWorkOrderProductSpecification
	WHERE intWorkOrderId = @intWorkOrderId
		AND EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/WorkOrderProductSpecifications/WorkOrderProductSpecification', 2) WITH (
					intWorkOrderProductSpecificationId INT
					,strRowState NVARCHAR(50)
					) x
			WHERE x.intWorkOrderProductSpecificationId = tblMFWorkOrderProductSpecification.intWorkOrderProductSpecificationId
				AND x.strRowState = 'DELETE'
			)

	INSERT INTO dbo.tblMFWorkOrderWarehouseRateMatrixDetail (
		intWorkOrderId
		,intWarehouseRateMatrixDetailId
		,dblQuantity
		,dblProcessedQty
		,dblEstimatedAmount
		,dblActualAmount
		,dblDifference
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		,intConcurrencyId
		)
	SELECT @intWorkOrderId
		,intWarehouseRateMatrixDetailId
		,dblQuantity
		,dblProcessedQty
		,dblEstimatedAmount
		,dblActualAmount
		,dblDifference
		,@dtmCurrentDate
		,intUserId
		,@dtmCurrentDate
		,intUserId
		,1 intConcurrencyId
	FROM OPENXML(@idoc, 'root/WarehouseRateMatrixDetails/WarehouseRateMatrixDetail', 2) WITH (
			intWorkOrderWarehouseRateMatrixDetailId INT
			,intWarehouseRateMatrixDetailId INT
			,dblQuantity NUMERIC(18, 6)
			,dblProcessedQty NUMERIC(18, 6)
			,dblEstimatedAmount NUMERIC(18, 6)
			,dblActualAmount NUMERIC(18, 6)
			,dblDifference NUMERIC(18, 6)
			,intUserId INT
			,strRowState NVARCHAR(50)
			) x
	WHERE x.intWorkOrderWarehouseRateMatrixDetailId = 0
		AND x.strRowState = 'ADDED'

	UPDATE dbo.tblMFWorkOrderWarehouseRateMatrixDetail
	SET dblQuantity = x.dblQuantity
		,dblProcessedQty = x.dblProcessedQty
		,dblEstimatedAmount = x.dblEstimatedAmount
		,dblActualAmount = x.dblActualAmount
		,dblDifference = x.dblDifference
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = x.intUserId
		,intConcurrencyId = Isnull(intConcurrencyId, 0) + 1
	FROM OPENXML(@idoc, 'root/WarehouseRateMatrixDetails/WarehouseRateMatrixDetail', 2) WITH (
			intWorkOrderWarehouseRateMatrixDetailId INT
			,dblQuantity NUMERIC(18, 6)
			,dblProcessedQty NUMERIC(18, 6)
			,dblEstimatedAmount NUMERIC(18, 6)
			,dblActualAmount NUMERIC(18, 6)
			,dblDifference NUMERIC(18, 6)
			,intUserId INT
			,strRowState NVARCHAR(50)
			) x
	WHERE x.intWorkOrderWarehouseRateMatrixDetailId = tblMFWorkOrderWarehouseRateMatrixDetail.intWorkOrderWarehouseRateMatrixDetailId
		AND x.strRowState = 'MODIFIED'

	DELETE
	FROM dbo.tblMFWorkOrderWarehouseRateMatrixDetail
	WHERE intWorkOrderId = @intWorkOrderId
		AND EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/WarehouseRateMatrixDetails/WarehouseRateMatrixDetail', 2) WITH (
					intWorkOrderWarehouseRateMatrixDetailId INT
					,strRowState NVARCHAR(50)
					) x
			WHERE x.intWorkOrderWarehouseRateMatrixDetailId = tblMFWorkOrderWarehouseRateMatrixDetail.intWorkOrderWarehouseRateMatrixDetailId
				AND x.strRowState = 'DELETE'
			)

	IF @intBlendRequirementId IS NOT NULL
	BEGIN
		SELECT @intUnitMeasureId = intUnitMeasureId
		FROM tblICItemUOM
		WHERE intItemUOMId = @intItemUOMId

		UPDATE tblMFBlendRequirement
		SET intItemId = @intItemId
			,dblQuantity = @dblQuantity
			,intUOMId = @intUnitMeasureId
			,dtmDueDate = @dtmExpectedDate
			,intLocationId = @intLocationId
			,dblIssuedQty = @dblQuantity
			,intLastModifiedUserId = @intUserId
			,dtmLastModified = @dtmCurrentDate
		WHERE intBlendRequirementId = @intBlendRequirementId
	END

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
