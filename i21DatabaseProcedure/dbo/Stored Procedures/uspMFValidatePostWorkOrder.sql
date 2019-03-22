CREATE PROCEDURE uspMFValidatePostWorkOrder (
	@intWorkOrderId INT
	,@ysnYieldAdjustmentAllowed BIT = 1
	,@intUserId INT
	)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intAttributeId INT
		,@intManufacturingProcessId INT
		,@strAttributeValue NVARCHAR(MAX)
		,@intCycleCountSessionId INT
		,@intPriorWorkOrderId INT
		,@intItemId INT
		,@dtmPlannedDateTime DATETIME
		,@intLocationId int
		,@dtmCurrentDate datetime
		,@dtmCurrentDateTime datetime
		,@intDayOfYear int
	
	Select @dtmCurrentDateTime	=GETDATE()
	Select @dtmCurrentDate		=CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))
	Select @intDayOfYear		=DATEPART(dy,@dtmCurrentDateTime)

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@intItemId = intItemId
		,@dtmPlannedDateTime = dtmPlannedDate
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF EXISTS (
			SELECT 1
			FROM dbo.tblMFWorkOrder
			WHERE intCountStatusId = 13
				AND intWorkOrderId = @intWorkOrderId
			)
	BEGIN
		RAISERROR (
				'Production run already trued up.'
				,11
				,1
				)

		RETURN
	END

	SELECT @intAttributeId = intAttributeId
	FROM dbo.tblMFAttribute
	WHERE strAttributeName = 'Is Cycle Count Required'

	SELECT @strAttributeValue = strAttributeValue
	FROM dbo.tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intAttributeId = @intAttributeId
		AND intLocationId=@intLocationId

	IF @strAttributeValue = 'True'
		AND NOT EXISTS (
			SELECT *
			FROM tblMFProcessCycleCountSession
			WHERE intWorkOrderId = @intWorkOrderId
			)
	BEGIN
		RAISERROR (
				'Cycle count entries for the run not available, cannot proceed.'
				,11
				,1
				)

		RETURN
	END

	SELECT @intCycleCountSessionId = intCycleCountSessionId
	FROM tblMFProcessCycleCountSession
	WHERE intWorkOrderId = @intWorkOrderId

	IF (
			SELECT Count(*)
			FROM tblMFProcessCycleCount
			WHERE intCycleCountSessionId = @intCycleCountSessionId
			) > 0
		IF EXISTS (
				SELECT *
				FROM tblMFProcessCycleCount
				WHERE intCycleCountSessionId = @intCycleCountSessionId
					AND dblQuantity IS NULL
				)
		BEGIN
			RAISERROR (
					'Please complete and save Cycle count entries for all the items before posting adjustment.'
					,11
					,1
					)

			RETURN
		END

	SELECT TOP 1 @intPriorWorkOrderId = intWorkOrderId
	FROM dbo.tblMFWorkOrder W
	LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
	WHERE intItemId = @intItemId
		AND intManufacturingProcessId = @intManufacturingProcessId
		AND W.intStatusId<>13
		AND (
			CASE 
				WHEN intPlannedShiftId IS NOT NULL
					THEN dtmPlannedDate + dtmShiftStartTime + intStartOffset
				ELSE dtmPlannedDate
				END
			) < @dtmPlannedDateTime
		AND intWorkOrderId <> @intWorkOrderId
	ORDER BY CASE 
			WHEN intPlannedShiftId IS NOT NULL
				THEN dtmPlannedDate + dtmShiftStartTime + intStartOffset
			ELSE dtmPlannedDate
			END

	--IF EXISTS (
	--		SELECT 1
	--		FROM dbo.tblMFWorkOrder
	--		WHERE intCountStatusId = 10
	--			AND intWorkOrderId = @intPriorWorkOrderId
	--		)
	--	AND @intPriorWorkOrderId IS NOT NULL
	--BEGIN
	--	RAISERROR (
	--			'Production run(s) prior to the current run has not been trued up, True up the earlier runs and proceed.'
	--			,11
	--			,1
	--			)
	--END
	
		IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrderRecipeItem ri
			WHERE ri.intWorkOrderId = @intWorkOrderId
				AND ri.intRecipeItemTypeId = 1
				AND ri.intConsumptionMethodId=2
				AND (
					(
						ri.ysnYearValidationRequired = 1
						AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
							AND ri.dtmValidTo
						)
					OR (
						ri.ysnYearValidationRequired = 0
						AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
							AND DATEPART(dy, ri.dtmValidTo)
						)
					)
					AND intStorageLocationId is null
			)
	BEGIN
		RAISERROR (
				'No default consumption unit configured, cannot consume.'
				,11
				,1
				)
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
