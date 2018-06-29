CREATE PROCEDURE [dbo].[uspMFUpdateWorkOrder] (@strXML NVARCHAR(MAX),@intConcurrencyId Int Output)
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
		,@ysnIngredientAvailable bit
		,@intMaxExecutionOrder int
		,@intDepartmentId int
		,@intTransactionCount INT
		,@intBlendRequirementId int
		,@intUnitMeasureId int
		,@dtmCurrentDate DATETIME

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
		,@dtmPlannedDate = dtmPlannedDate
		,@intPlannedShiftId = intPlannedShiftId
		,@intItemId = intItemId
		,@dblQuantity = dblQuantity
		,@intItemUOMId = intItemUOMId
		,@dtmExpectedDate=dtmExpectedDate
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
		,@ysnIngredientAvailable=ysnIngredientAvailable
		,@intDepartmentId=intDepartmentId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,strWorkOrderNo NVARCHAR(50)
			,strReferenceNo NVARCHAR(50)
			,dtmOrderDate DATETIME
			,dtmExpectedDate DATETIME
			,intManufacturingProcessId INT
			,intManufacturingCellId INT
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
			,ysnIngredientAvailable bit
			,intDepartmentId int
			)

	IF EXISTS (
		SELECT *
		FROM tblMFWorkOrder
		WHERE strLotNumber = @strLotNumber and intWorkOrderId <>@intWorkOrderId 
	) and @strLotNumber<>''
	BEGIN
		RAISERROR (
				'Lot Id already exists. It should be unique'
				,11
				,1
				)
	END

	SELECT @intPrevExecutionOrder = intExecutionOrder,@intConcurrencyId=ISNULL(intConcurrencyId,0)+1,@intBlendRequirementId = intBlendRequirementId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF @intPrevExecutionOrder <> @intExecutionOrder
	BEGIN
		SELECT @intMaxExecutionOrder=Count(*)
		FROM dbo.tblMFWorkOrder
		WHERE intManufacturingCellId = @intManufacturingCellId
		AND dtmPlannedDate = @dtmPlannedDate
		AND intStatusId <>13

		if @intExecutionOrder>@intMaxExecutionOrder or 0>@intExecutionOrder
		Begin
			RAISERROR (
				'Execution order entered is out of range.'
				,11
				,1
				)
		End
			
	END
	
	IF @intTransactionCount = 0
	BEGIN TRANSACTION

	
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
					AND intStatusId <>13
		END
		ELSE
		BEGIN --Move downward
			UPDATE dbo.tblMFWorkOrder
			SET intExecutionOrder = intExecutionOrder - 1
			WHERE intManufacturingCellId = @intManufacturingCellId
				AND dtmPlannedDate = @dtmPlannedDate
				AND intExecutionOrder BETWEEN @intPrevExecutionOrder
					AND @intExecutionOrder
					AND intStatusId <>13
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
		,intSalesRepresentativeId = @intSalesRepresentativeId
		,intSupervisorId = @intSupervisorId
		,intCustomerId = @intCustomerId
		,ysnIngredientAvailable=@ysnIngredientAvailable
		,intDepartmentId=@intDepartmentId
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
		,intConcurrencyId=@intConcurrencyId
	WHERE intWorkOrderId = @intWorkOrderId

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
			,strRowState nvarchar(50)
			) x
	WHERE x.intWorkOrderProductSpecificationId = 0 and x.strRowState='ADDED'

	Update tblMFWorkOrderProductSpecification
	Set strParameterName=x.strParameterName
		,strParameterValue=x.strParameterValue
		,intConcurrencyId=Isnull(intConcurrencyId,0)+1
	FROM OPENXML(@idoc, 'root/WorkOrderProductSpecifications/WorkOrderProductSpecification', 2) WITH (
			intWorkOrderProductSpecificationId INT
			,strParameterName NVARCHAR(50)
			,strParameterValue NVARCHAR(MAX)
			,strRowState nvarchar(50)
			) x
	WHERE x.intWorkOrderProductSpecificationId = tblMFWorkOrderProductSpecification.intWorkOrderProductSpecificationId and x.strRowState='MODIFIED'

	DELETE
	FROM dbo.tblMFWorkOrderProductSpecification
	WHERE intWorkOrderId = @intWorkOrderId
		AND EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/WorkOrderProductSpecifications/WorkOrderProductSpecification', 2) WITH (intWorkOrderProductSpecificationId INT,strRowState nvarchar(50)) x
			WHERE x.intWorkOrderProductSpecificationId = tblMFWorkOrderProductSpecification.intWorkOrderProductSpecificationId and x.strRowState='DELETE'
			)

	If @intBlendRequirementId is not null
	Begin
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
	End
	
	IF @intTransactionCount = 0
	COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0 AND @intTransactionCount = 0
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


