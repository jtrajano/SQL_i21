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
				51130
				,11
				,1
				)

		RETURN
	END

	SELECT @intAttributeId = intAttributeId
	FROM dbo.tblMFAttribute
	WHERE strAttributeName = 'Is Cycle Count Mandatory'

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
				51131
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
					51132
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

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblMFWorkOrder
			WHERE intCountStatusId = 13
				AND intWorkOrderId = @intPriorWorkOrderId
			)
		AND @intPriorWorkOrderId IS NOT NULL
	BEGIN
		RAISERROR (
				51133
				,11
				,1
				)
	END
	
		IF EXISTS (
			SELECT *
			FROM dbo.tblMFRecipeItem ri
			JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
			WHERE r.ysnActive = 1
				AND r.intItemId = @intItemId
				AND r.intLocationId = @intLocationId
				AND ri.intRecipeItemTypeId = 1
				AND (
					(
						ri.ysnYearValidationRequired = 1
						AND CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101)) BETWEEN ri.dtmValidFrom
							AND ri.dtmValidTo
						)
					OR (
						ri.ysnYearValidationRequired = 0
						AND DATEPART(dy, GETDATE()) BETWEEN DATEPART(dy, ri.dtmValidFrom)
							AND DATEPART(dy, ri.dtmValidTo)
						)
					)
					AND intStorageLocationId is null
			)
	BEGIN
		RAISERROR (
				51134
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
