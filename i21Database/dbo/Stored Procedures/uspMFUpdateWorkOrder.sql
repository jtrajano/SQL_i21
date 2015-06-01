﻿CREATE PROCEDURE [dbo].[uspMFUpdateWorkOrder] (@strXML NVARCHAR(MAX),@intConcurrencyId Int Output)
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

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@strWorkOrderNo = strWorkOrderNo
		,@dtmOrderDate = dtmOrderDate
		,@intManufacturingProcessId = intManufacturingProcessId
		,@intManufacturingCellId = intManufacturingCellId
		,@dtmPlannedDate = dtmPlannedDate
		,@intPlannedShiftId = intPlannedShiftId
		,@intItemId = intItemId
		,@dblQuantity = dblQuantity
		,@intItemUOMId = intItemUOMId
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
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,strWorkOrderNo NVARCHAR(50)
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
			)

	BEGIN TRANSACTION

	SELECT @intPrevExecutionOrder = intExecutionOrder,@intConcurrencyId=ISNULL(intConcurrencyId,0)+1
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

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
		END
		ELSE
		BEGIN --Move downward
			UPDATE dbo.tblMFWorkOrder
			SET intExecutionOrder = intExecutionOrder - 1
			WHERE intManufacturingCellId = @intManufacturingCellId
				AND dtmPlannedDate = @dtmPlannedDate
				AND intExecutionOrder BETWEEN @intPrevExecutionOrder
					AND @intExecutionOrder
		END
	END

	UPDATE dbo.tblMFWorkOrder
	SET strWorkOrderNo = @strWorkOrderNo
		,dtmOrderDate = @dtmOrderDate
		,intManufacturingProcessId = @intManufacturingProcessId
		,intItemId = @intItemId
		,dblQuantity = @dblQuantity
		,intItemUOMId = @intItemUOMId
		,intStatusId = 1
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
		,dtmLastModified = GetDate()
		,intLastModifiedUserId = @intUserId
		,intConcurrencyId=@intConcurrencyId
	WHERE intWorkOrderId = @intWorkOrderId

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


