CREATE PROCEDURE [dbo].[uspMFSaveSchedule] (
	@strXML NVARCHAR(MAX)
	,@intScheduleId INT OUTPUT
	,@intConcurrencyId INT OUTPUT
	)
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

	IF @ysnStandard = 1
	BEGIN
		UPDATE dbo.tblMFSchedule
		SET ysnStandard = 0
		WHERE intManufacturingCellId = @intManufacturingCellId
	END

	IF @intScheduleId IS NULL
	BEGIN
		IF @strScheduleNo IS NULL
			--EXEC dbo.uspSMGetStartingNumber 63
			--	,@strScheduleNo OUTPUT
			DECLARE @intSubLocationId INT

		SELECT @intSubLocationId = intSubLocationId
		FROM dbo.tblMFManufacturingCell
		WHERE intManufacturingCellId = @intManufacturingCellId

		EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
			,@intItemId = NULL
			,@intManufacturingId = @intManufacturingCellId
			,@intSubLocationId = @intSubLocationId
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 63
			,@ysnProposed = 0
			,@strPatternString = @strScheduleNo OUTPUT

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
		IF (
				SELECT intConcurrencyId
				FROM dbo.tblMFSchedule
				WHERE intScheduleId = @intScheduleId
				) <> @intConcurrencyId
		BEGIN
			RAISERROR (
					'The data already updated by another user, Please refresh.'
					,11
					,1
					)

			RETURN
		END

		UPDATE dbo.tblMFSchedule
		SET ysnStandard = @ysnStandard
			,intConcurrencyId = intConcurrencyId + 1
			,dtmLastModified = @dtmCurrentDate
			,intLastModifiedUserId = @intUserId
		WHERE intScheduleId = @intScheduleId
	END

	SELECT @intConcurrencyId = intConcurrencyId
	FROM dbo.tblMFSchedule
	WHERE intScheduleId = @intScheduleId

	DELETE
	FROM dbo.tblMFScheduleWorkOrder
	WHERE intScheduleId = @intScheduleId

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
		,intNoOfFlushes
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
		,ROW_NUMBER() OVER (
			ORDER BY x.intExecutionOrder
			) AS intExecutionOrder
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
		,x.intNoOfFlushes
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
			,intStatusId INT
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
			,intNoOfFlushes INT
			,intConcurrencyId INT
			,dtmCreated DATETIME
			,intCreatedUserId INT
			,dtmLastModified DATETIME
			,intLastModifiedUserId INT
			) x
	WHERE x.intStatusId <> 1

	IF @ysnStandard = 1
	BEGIN
		UPDATE dbo.tblMFWorkOrder
		SET intStatusId = (
				CASE 
					WHEN @intManufacturingCellId = x.intManufacturingCellId
						THEN (
								CASE 
									WHEN tblMFWorkOrder.intStatusId IN (
											10
											,13
											)
										THEN tblMFWorkOrder.intStatusId
									ELSE x.intStatusId
									END
								)
					ELSE 1
					END
				)
			,dblQuantity = x.dblQuantity
			,intManufacturingCellId = x.intManufacturingCellId
			,intPlannedShiftId = x.intPlannedShiftId
			,dtmPlannedDate = x.dtmPlannedStartDate
			,intExecutionOrder = x.intExecutionOrder
			,dtmEarliestDate = x.dtmEarliestDate
			,dtmLatestDate = x.dtmLatestDate
			,dtmExpectedDate = x.dtmExpectedDate
		FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
				intWorkOrderId INT
				,intStatusId INT
				,dblQuantity NUMERIC(18, 6)
				,intManufacturingCellId INT
				,intPlannedShiftId INT
				,dtmPlannedStartDate DATETIME
				,intExecutionOrder INT
				,dtmEarliestDate DATETIME
				,dtmLatestDate DATETIME
				,dtmExpectedDate DATETIME
				) x
		WHERE x.intWorkOrderId = tblMFWorkOrder.intWorkOrderId
	END

	INSERT INTO dbo.tblMFScheduleWorkOrderDetail (
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
			FROM dbo.tblMFScheduleWorkOrder W
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
	JOIN dbo.tblMFScheduleWorkOrder W ON x.intWorkOrderId = W.intWorkOrderId
	WHERE W.intScheduleId = @intScheduleId

	INSERT INTO dbo.tblMFScheduleMachineDetail (
		intScheduleWorkOrderDetailId
		,intWorkOrderId
		,intScheduleId
		,intCalendarMachineId
		,intCalendarDetailId
		,intConcurrencyId
		)
	SELECT (
			SELECT intScheduleWorkOrderDetailId
			FROM dbo.tblMFScheduleWorkOrderDetail WD
			JOIN dbo.tblMFScheduleWorkOrder W ON W.intScheduleWorkOrderId = WD.intScheduleWorkOrderId
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
	JOIN dbo.tblMFScheduleWorkOrder W ON x.intWorkOrderId = W.intWorkOrderId
	WHERE W.intScheduleId = @intScheduleId

	INSERT INTO dbo.tblMFScheduleConstraintDetail (
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
			FROM dbo.tblMFScheduleWorkOrder W
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
	JOIN dbo.tblMFScheduleWorkOrder W ON x.intWorkOrderId = W.intWorkOrderId
	WHERE W.intScheduleId = @intScheduleId

	DELETE
	FROM tblMFScheduleConstraint
	WHERE intScheduleId = @intScheduleId

	INSERT INTO dbo.tblMFScheduleConstraint (
		intScheduleId
		,intScheduleRuleId
		)
	SELECT @intScheduleId
		,intScheduleRuleId
	FROM OPENXML(@idoc, 'root/ScheduleRules/ScheduleRule', 2) WITH (
			intScheduleRuleId INT
			,ysnSelect BIT
			)
	WHERE ysnSelect = 1

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


