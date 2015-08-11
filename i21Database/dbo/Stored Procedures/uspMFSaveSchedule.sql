CREATE PROCEDURE [dbo].[uspMFSaveSchedule] (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT
		,@intScheduleId INT
		,@strScheduleNo NVARCHAR
		,@intCalendarId INT
		,@intManufacturingCellId INT
		,@ysnStandard BIT
		,@intLocationId INT
		,@intConcurrencyId INT
		,@intUserId INT
		,@dtmCurrentDate DATETIME

	SELECT @dtmCurrentDate = GETDATE()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intScheduleId = intScheduleId
		,@strScheduleNo = strScheduleNo
		,@intCalendarId = intCalendarId
		,@intManufacturingCellId = intManufacturingCellId
		,@ysnStandard = ysnStandard
		,@intLocationId = intLocationId
		,@intConcurrencyId = intConcurrencyId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intScheduleId INT
			,strScheduleNo NVARCHAR
			,intCalendarId INT
			,intManufacturingCellId INT
			,ysnStandard BIT
			,intLocationId INT
			,intConcurrencyId INT
			,intUserId INT
			)

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF @intScheduleId IS NULL
	BEGIN
		IF @strScheduleNo IS NULL
			EXEC dbo.uspSMGetStartingNumber 63
				,@strScheduleNo OUTPUT

		INSERT INTO dbo.tblMFSchedule (
			strScheduleNo
			,dtmScheduleDate
			,intCalendarId
			,intManufacturingCellId
			,ysnStandard
			,intLocationId
			,intConcurrencyId
			,dtmCreated
			,intCreatedUserId
			,dtmLastModified
			,intLastModifiedUserId
			)
		VALUES (
			@strScheduleNo
			,@dtmCurrentDate
			,@intCalendarId
			,@intManufacturingCellId
			,@ysnStandard
			,@intLocationId
			,1
			,@dtmCurrentDate
			,@intUserId
			,@dtmCurrentDate
			,@intUserId
			)

		SELECT @intScheduleId = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		IF @ysnStandard = 1
		BEGIN
			UPDATE tblMFSchedule
			SET ysnStandard = 0
			WHERE intManufacturingCellId = @intManufacturingCellId
		END

		UPDATE dbo.tblMFSchedule
		SET ysnStandard = @ysnStandard
			,intConcurrencyId = intConcurrencyId + 1
			,dtmLastModified = @dtmCurrentDate
			,intLastModifiedUserId = @intUserId
		WHERE intScheduleId = @intScheduleId
	END

	INSERT INTO dbo.tblMFScheduleWorkOrder (
		intScheduleId
		,intWorkOrderId
		,intDuration
		,intExecutionOrder
		,intChangeoverDuration
		,intSetupDuration
		,dtmChangeoverStartDate
		,dtmChangeoverEndDate
		,dtmPlannedStartDate
		,dtmPlannedEndDate
		,intPlannedShiftId
		,intNoOfSelectedMachine
		,strComments
		,strNote
		,strAdditionalComments
		,dtmEarliestStartDate
		,ysnFrozen
		,intConcurrencyId
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		)
	SELECT @intScheduleId
		,x.intWorkOrderId
		,x.intDuration
		,x.intExecutionOrder
		,x.intChangeoverDuration
		,x.intSetupDuration
		,x.dtmChangeoverStartDate
		,x.dtmChangeoverEndDate
		,x.dtmPlannedStartDate
		,x.dtmPlannedEndDate
		,x.intPlannedShiftId
		,x.intNoOfSelectedMachine
		,x.strComments
		,x.strNote
		,x.strAdditionalComments
		,x.dtmEarliestStartDate
		,x.ysnFrozen
		,1
		,@dtmCurrentDate
		,@intUserId
		,@dtmCurrentDate
		,@intUserId
	FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
			intScheduleWorkOrderId INT
			,intWorkOrderId INT
			,intDuration INT
			,intExecutionOrder INT
			,intChangeoverDuration INT
			,intSetupDuration INT
			,dtmChangeoverStartDate DATETIME
			,dtmChangeoverEndDate DATETIME
			,dtmPlannedStartDate DATETIME
			,dtmPlannedEndDate DATETIME
			,intPlannedShiftId INT
			,intNoOfSelectedMachine INT
			,strComments NVARCHAR(MAX)
			,strNote NVARCHAR(MAX)
			,strAdditionalComments NVARCHAR(MAX)
			,dtmEarliestStartDate DATETIME
			,ysnFrozen BIT
			,intConcurrencyId INT
			,dtmCreated DATETIME
			,intCreatedUserId INT
			,dtmLastModified DATETIME
			,intLastModifiedUserId INT
			) x
	WHERE x.intScheduleWorkOrderId IS NULL

	UPDATE tblMFScheduleWorkOrder
	SET intDuration = x.intDuration
		,intExecutionOrder = x.intExecutionOrder
		,intChangeoverDuration = x.intChangeoverDuration
		,intSetupDuration = x.intSetupDuration
		,dtmChangeoverStartDate = x.dtmChangeoverStartDate
		,dtmChangeoverEndDate = x.dtmChangeoverEndDate
		,dtmPlannedStartDate = x.dtmPlannedStartDate
		,dtmPlannedEndDate = x.dtmPlannedEndDate
		,intPlannedShiftId = x.intPlannedShiftId
		,intNoOfSelectedMachine = x.intNoOfSelectedMachine
		,strComments = x.strComments
		,strNote = x.strNote
		,strAdditionalComments = x.strAdditionalComments
		,dtmEarliestStartDate = x.dtmEarliestStartDate
		,ysnFrozen = x.ysnFrozen
		,intConcurrencyId = Isnull(intConcurrencyId, 0) + 1
	FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
			intScheduleWorkOrderId INT
			,intWorkOrderId INT
			,intDuration INT
			,intExecutionOrder INT
			,intChangeoverDuration INT
			,intSetupDuration INT
			,dtmChangeoverStartDate DATETIME
			,dtmChangeoverEndDate DATETIME
			,dtmPlannedStartDate DATETIME
			,dtmPlannedEndDate DATETIME
			,intPlannedShiftId INT
			,intNoOfSelectedMachine INT
			,strComments NVARCHAR(MAX)
			,strNote NVARCHAR(MAX)
			,strAdditionalComments NVARCHAR(MAX)
			,dtmEarliestStartDate DATETIME
			,ysnFrozen BIT
			,intStatusId INT
			) x
	WHERE x.intScheduleWorkOrderId = tblMFScheduleWorkOrder.intScheduleWorkOrderId
		AND x.intWorkOrderId = tblMFScheduleWorkOrder.intWorkOrderId
		AND x.intScheduleWorkOrderId IS NOT NULL
		AND x.intStatusId <> 1

	DELETE
	FROM dbo.tblMFScheduleWorkOrder
	WHERE EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
					intScheduleWorkOrderId INT
					,intWorkOrderId INT
					,intStatusId INT
					) x
			WHERE x.intScheduleWorkOrderId = tblMFScheduleWorkOrder.intScheduleWorkOrderId
				AND x.intWorkOrderId = tblMFScheduleWorkOrder.intWorkOrderId
				AND x.intStatusId = 1
			)

	INSERT INTO tblMFScheduleWorkOrderDetail (
		intScheduleWorkOrderId
		,intWorkOrderId
		,intScheduleId
		,dtmPlannedStartDate
		,dtmPlannedEndDate
		,intPlannedShiftId
		,intDuration
		,dblPlannedQty
		,intSequenceNo
		,intCalendarDetailId
		,intConcurrencyId
		)
	SELECT (
			SELECT intScheduleWorkOrderId
			FROM tblMFScheduleWorkOrder W
			WHERE W.intWorkOrderId = x.intWorkOrderId
				AND W.intScheduleId = @intScheduleId
			)
		,intWorkOrderId
		,@intScheduleId
		,dtmPlannedStartDate
		,dtmPlannedEndDate
		,intPlannedShiftId
		,intDuration
		,dblPlannedQty
		,intSequenceNo
		,intCalendarDetailId
		,1
	FROM OPENXML(@idoc, 'root/WorkOrderDetails/WorkOrderDetail', 2) WITH (
			intWorkOrderId INT
			,dtmPlannedStartDate DATETIME
			,dtmPlannedEndDate DATETIME
			,intPlannedShiftId INT
			,intDuration INT
			,dblPlannedQty NUMERIC(18, 6)
			,intSequenceNo INT
			,intCalendarDetailId INT
			) x

	INSERT INTO tblMFScheduleMachineDetail (
		intScheduleWorkOrderDetailId
		,intWorkOrderId
		,intScheduleId
		,intCalendarMachineId
		,intCalendarDetailId
		,intConcurrencyId
		)
	SELECT (
			SELECT intScheduleWorkOrderDetailId
			FROM tblMFScheduleWorkOrderDetail WD
			JOIN tblMFScheduleWorkOrder W ON W.intScheduleWorkOrderId = WD.intScheduleWorkOrderId
			WHERE W.intWorkOrderId = x.intWorkOrderId
				AND W.intScheduleId = @intScheduleId
				AND WD.intCalendarDetailId = x.intCalendarDetailId
			)
		,intWorkOrderId
		,@intScheduleId
		,intCalendarMachineId
		,intCalendarDetailId
		,1
	FROM OPENXML(@idoc, 'root/MachineDetails/MachineDetail', 2) WITH (
			intWorkOrderId INT
			,intCalendarMachineId INT
			,intCalendarDetailId INT
			) x

	INSERT INTO tblMFScheduleConstraintDetail (
		intScheduleWorkOrderId
		,intWorkOrderId
		,intScheduleId
		,intScheduleRuleId
		,dtmChangeoverStartDate
		,dtmChangeoverEndDate
		,intDuration
		,intConcurrencyId
		)
	SELECT (
			SELECT intScheduleWorkOrderId
			FROM tblMFScheduleWorkOrder W
			WHERE W.intWorkOrderId = x.intWorkOrderId
				AND W.intScheduleId = @intScheduleId
			)
		,intWorkOrderId
		,@intScheduleId
		,intScheduleRuleId
		,dtmChangeoverStartDate
		,dtmChangeoverEndDate
		,intDuration
		,1
	FROM OPENXML(@idoc, 'root/ConstraintDetails/ConstraintDetail', 2) WITH (
			intWorkOrderId INT
			,intScheduleRuleId INT
			,dtmChangeoverStartDate DATETIME
			,dtmChangeoverEndDate DATETIME
			,intDuration INT
			) x

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


