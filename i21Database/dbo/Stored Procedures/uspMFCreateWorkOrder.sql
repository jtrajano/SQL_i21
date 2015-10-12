CREATE PROCEDURE [dbo].uspMFCreateWorkOrder (@strXML NVARCHAR(MAX),@intWorkOrderId INT OUTPUT,@strWorkOrderNo NVARCHAR(50) OUTPUT)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@dblQuantity NUMERIC(18, 6)
		,@intUserId INT
		,@intItemId INT
		,@strLotNumber NVARCHAR(50)
		,@strVendorLotNo NVARCHAR(50)
		,@intItemUOMId INT
		,@intManufacturingCellId INT
		,@intLocationId INT
		,@dtmPlannedDate DATETIME
		,@intPlannedShiftId INT
		,@intManufacturingProcessId INT
		,@intStorageLocationId INT
		,@intExecutionOrder INT
		,@dtmCurrentDate DATETIME
		,@intSubLocationId INT
		,@intProductionTypeId INT
		,@strSpecialInstruction NVARCHAR(MAX)
		,@strComment NVARCHAR(MAX)
		,@intParentWorkOrderId INT
		,@intSalesRepresentativeId INT
		,@intCustomerId INT
		,@strSalesOrderNo NVARCHAR(50)
		,@intSupervisorId INT
		,@intStatusId INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @strWorkOrderNo = strWorkOrderNo
		,@intManufacturingProcessId = intManufacturingProcessId
		,@intManufacturingCellId = intManufacturingCellId
		,@dtmPlannedDate = dtmPlannedDate
		,@intPlannedShiftId = intPlannedShiftId
		,@intItemId = intItemId
		,@dblQuantity = dblQuantity
		,@intItemUOMId = intItemUOMId
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
		,@intStatusId = intStatusId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			strWorkOrderNo NVARCHAR(50)
			,intManufacturingProcessId INT
			,intManufacturingCellId INT
			,dtmPlannedDate DATETIME
			,intPlannedShiftId INT
			,intItemId INT
			,dblQuantity NUMERIC(18, 6)
			,intItemUOMId INT
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
			,intStatusId INT
			)

	BEGIN TRANSACTION

	SELECT @dtmCurrentDate = GetDate()

	IF @strWorkOrderNo IS NULL
		OR @strWorkOrderNo = ''
	BEGIN
		EXEC dbo.uspSMGetStartingNumber 70
			,@strWorkOrderNo OUTPUT
	END

	SELECT @intExecutionOrder = Max(intExecutionOrder) + 1
	FROM dbo.tblMFWorkOrder
	WHERE dtmPlannedDate = @dtmPlannedDate

	INSERT INTO dbo.tblMFWorkOrder (
		strWorkOrderNo
		,intManufacturingProcessId
		,intItemId
		,dblQuantity
		,intItemUOMId
		,intStatusId
		,intManufacturingCellId
		,intStorageLocationId
		,intLocationId
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		,strLotNumber
		,strVendorLotNo
		,dtmPlannedDate
		,intPlannedShiftId
		,dtmExpectedDate
		,intExecutionOrder
		,dtmActualProductionStartDate
		,intProductionTypeId
		,strSpecialInstruction
		,strComment
		,intParentWorkOrderId
		,intSalesRepresentativeId
		,intSupervisorId
		,dtmOrderDate
		)
	SELECT @strWorkOrderNo
		,@intManufacturingProcessId
		,@intItemId
		,@dblQuantity
		,@intItemUOMId
		,@intStatusId
		,@intManufacturingCellId
		,@intStorageLocationId
		,@intLocationId
		,@dtmCurrentDate
		,@intUserId
		,@dtmCurrentDate
		,@intUserId
		,@strLotNumber
		,@strVendorLotNo
		,@dtmPlannedDate
		,@intPlannedShiftId
		,@dtmPlannedDate
		,ISNULL(@intExecutionOrder, 1)
		,@dtmCurrentDate
		,@intProductionTypeId
		,@strSpecialInstruction
		,@strComment
		,@intParentWorkOrderId
		,@intSalesRepresentativeId
		,@intSupervisorId
		,@dtmPlannedDate

	SET @intWorkOrderId = SCOPE_IDENTITY()

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
		)
	SELECT @intWorkOrderId
		,intLotId
		,intItemId
		,dblWeight
		,intWeightUOMId
		,dblQty
		,intItemUOMId
		,NULL
		,GetDate()
		,@intUserId
		,GetDate()
		,@intUserId
	FROM OPENXML(@idoc, 'root/Lots/Lot', 2) WITH (
			intLotId INT
			,intItemId INT
			,dblWeight NUMERIC(18, 6)
			,intWeightUOMId INT
			,dblQty NUMERIC(18, 6)
			,intItemUOMId INT
			,intUserId INT
			) x

	INSERT INTO tblMFWorkOrderConsumedLot (
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
		)
	SELECT @intWorkOrderId
		,intLotId
		,intItemId
		,dblWeight
		,intWeightUOMId
		,dblQty
		,intItemUOMId
		,NULL
		,GetDate()
		,@intUserId
		,GetDate()
		,@intUserId
	FROM OPENXML(@idoc, 'root/Lots/Lot', 2) WITH (
			intLotId INT
			,intItemId INT
			,dblWeight NUMERIC(18, 6)
			,intWeightUOMId INT
			,dblQty NUMERIC(18, 6)
			,intItemUOMId INT
			,intUserId INT
			) x

	--Create Reservation
	EXEC [uspMFCreateLotReservation] @intWorkOrderId = @intWorkOrderId
		,@ysnReservationByParentLot = 0

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
GO


