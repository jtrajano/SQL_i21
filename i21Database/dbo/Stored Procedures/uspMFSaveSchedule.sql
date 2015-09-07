CREATE PROCEDURE [dbo].[uspMFSaveSchedule] (@strXML NVARCHAR(MAX),@intScheduleId INT OUTPUT,@intConcurrencyId int OUTPUT)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT
		,@strScheduleNo NVARCHAR(50)
		,@intCalendarId INT
		,@intManufacturingCellId INT
		,@ysnStandard BIT
		,@intLocationId INT
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

	SELECT @intConcurrencyId=intConcurrencyId from tblMFSchedule Where intScheduleId = @intScheduleId

	DELETE FROM dbo.tblMFScheduleWorkOrder WHERE intScheduleId =@intScheduleId 

	INSERT INTO dbo.tblMFScheduleWorkOrder (
		intScheduleId
		,intWorkOrderId
		,intStatusId
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
		,x.intStatusId
		,x.intDuration
		,ROW_NUMBER() OVER (ORDER BY x.intExecutionOrder) as intExecutionOrder
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
			,intStatusId int
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
	Where x.intStatusId<>1

	IF @ysnStandard=1
	BEGIN
		UPDATE tblMFWorkOrder 
		SET intStatusId =(CASE WHEN @intManufacturingCellId =x.intManufacturingCellId THEN x.intStatusId ELSE 1 END)
			,dblQuantity =x.dblQuantity
			,intManufacturingCellId =x.intManufacturingCellId
			,intPlannedShiftId =x.intPlannedShiftId
			,dtmPlannedDate =x.dtmPlannedDate
			,intExecutionOrder =x.intExecutionOrder 
		FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
				intWorkOrderId INT
				,intStatusId int
				,dblQuantity numeric(18,6)
				,intManufacturingCellId int
				,intPlannedShiftId int
				,dtmPlannedDate datetime
				,intExecutionOrder int) x 
	END
	
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
		,x.intWorkOrderId
		,@intScheduleId
		,x.dtmPlannedStartDate
		,x.dtmPlannedEndDate
		,x.intPlannedShiftId
		,x.intDuration
		,x.dblPlannedQty
		,x.intSequenceNo
		,x.intCalendarDetailId
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
	JOIN tblMFScheduleWorkOrder W on x.intWorkOrderId=W.intWorkOrderId 
	WHERE W.intScheduleId = @intScheduleId

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
		,x.intWorkOrderId
		,@intScheduleId
		,x.intCalendarMachineId
		,x.intCalendarDetailId
		,1
	FROM OPENXML(@idoc, 'root/MachineDetails/MachineDetail', 2) WITH (
			intWorkOrderId INT
			,intCalendarMachineId INT
			,intCalendarDetailId INT
			) x 
	JOIN tblMFScheduleWorkOrder W on x.intWorkOrderId=W.intWorkOrderId
	WHERE W.intScheduleId = @intScheduleId

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
		,x.intWorkOrderId
		,@intScheduleId
		,x.intScheduleRuleId
		,x.dtmChangeoverStartDate
		,x.dtmChangeoverEndDate
		,x.intDuration
		,1
	FROM OPENXML(@idoc, 'root/ConstraintDetails/ConstraintDetail', 2) WITH (
			intWorkOrderId INT
			,intScheduleRuleId INT
			,dtmChangeoverStartDate DATETIME
			,dtmChangeoverEndDate DATETIME
			,intDuration INT
			) x 
	JOIN tblMFScheduleWorkOrder W on x.intWorkOrderId=W.intWorkOrderId
	WHERE W.intScheduleId = @intScheduleId

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


