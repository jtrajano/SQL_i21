CREATE PROCEDURE uspMFCheckContamination (
	@tblMFWorkOrder ScheduleTable READONLY
	,@intLocationId INT
	)
AS
BEGIN
	DECLARE @intNoOfCCFailed INT
		,@tblMFCCWorkOrder ScheduleTable
		,@intWorkOrderId INT
		,@dtmEarliestDate DATETIME
		,@dtmExpectedDate DATETIME
		,@dtmLatestDate DATETIME
		,@dtmTargetDate DATETIME
		,@intTargetDateId INT
		,@intTargetPreferenceCellId INT

	INSERT INTO @tblMFCCWorkOrder (
		intManufacturingCellId
		,intWorkOrderId
		,intItemId
		,intExecutionOrder
		,dtmEarliestDate
		,dtmExpectedDate
		,dtmLatestDate
		,dtmTargetDate
		,intTargetDateId
		,intTargetPreferenceCellId
		,intFirstPreferenceCellId
		,intSecondPreferenceCellId
		,intThirdPreferenceCellId
		,intNoOfFlushes
		,ysnPicked
		)
	SELECT intManufacturingCellId
		,intWorkOrderId
		,intItemId
		,intExecutionOrder
		,dtmEarliestDate
		,dtmExpectedDate
		,dtmLatestDate
		,dtmExpectedDate
		,2
		,1
		,intFirstPreferenceCellId
		,intSecondPreferenceCellId
		,intThirdPreferenceCellId
		,0
		,0
	FROM @tblMFWorkOrder
	WHERE intStatusId = 3

	DECLARE @tblMFCheckCC TABLE (
		intWorkOrderId INT
		,intNoOfFlushes INT
		)
	DECLARE @tblMFSequence TABLE (
		intWorkOrderId INT
		,intExecutionOrder INT
		,dtmTargetDate DATETIME
		,intNoOfFlushes int
		)

	LOOP1:

	DELETE
	FROM @tblMFCheckCC

	INSERT INTO @tblMFCheckCC (
		intWorkOrderId
		,intNoOfFlushes
		)
	SELECT W1.intWorkOrderId
		,isnull(MAX(ICD2.intNoOfFlushes), 0)
	FROM @tblMFCCWorkOrder AS W1
	JOIN @tblMFCCWorkOrder AS W2 ON W1.intExecutionOrder - 1 = W2.intExecutionOrder
		AND W1.intManufacturingCellId = W2.intManufacturingCellId
	JOIN dbo.tblMFRecipe R ON R.intItemId = W2.intItemId
		AND R.intLocationId = @intLocationId
		AND R.ysnActive = 1
	JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
	JOIN dbo.tblMFItemContamination IC1 ON IC1.intItemId = W1.intItemId
	JOIN dbo.tblMFItemContamination IC2 ON IC2.intItemId = RI.intItemId
	JOIN dbo.tblMFItemContaminationDetail ICD2 ON ICD2.intItemContaminationId = IC2.intItemContaminationId
		AND ICD2.intItemGroupId = IC1.intItemGroupId
	WHERE (
			(
				RI.ysnYearValidationRequired = 1
				AND CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101)) BETWEEN RI.dtmValidFrom
					AND RI.dtmValidTo
				)
			OR (
				RI.ysnYearValidationRequired = 0
				AND DATEPART(dy, GETDATE()) BETWEEN DATEPART(dy, RI.dtmValidFrom)
					AND DATEPART(dy, RI.dtmValidTo)
				)
			)
	GROUP BY W1.intWorkOrderId

	--DECLARE @v XML = (SELECT * FROM @tblMFCheckCC FOR XML AUTO)

	UPDATE W
	SET W.intNoOfFlushes = C.intNoOfFlushes
	FROM @tblMFCCWorkOrder W
	JOIN @tblMFCheckCC C ON W.intWorkOrderId = C.intWorkOrderId

	SELECT @intNoOfCCFailed = COUNT(intNoOfFlushes)
	FROM @tblMFCCWorkOrder
	WHERE intNoOfFlushes > 0
		AND ysnPicked = 0

	IF @intNoOfCCFailed > 0
	BEGIN
		SELECT TOP 1 @intWorkOrderId = intWorkOrderId
			,@dtmEarliestDate = dtmEarliestDate
			,@dtmExpectedDate = dtmExpectedDate
			,@dtmLatestDate = dtmLatestDate
			,@dtmTargetDate = dtmTargetDate
			,@intTargetDateId = intTargetDateId
			,@intTargetPreferenceCellId = intTargetPreferenceCellId
		FROM @tblMFCCWorkOrder
		WHERE intNoOfFlushes > 0
			AND ysnPicked = 0
		ORDER BY dtmTargetDate

		IF @intTargetDateId = 2
		BEGIN
			SELECT @dtmTargetDate = @dtmEarliestDate
		END
		ELSE
		BEGIN
			SELECT @dtmTargetDate = @dtmTargetDate + 1
		END

		IF @dtmTargetDate BETWEEN @dtmEarliestDate
				AND @dtmLatestDate
		BEGIN
			UPDATE @tblMFCCWorkOrder
			SET dtmTargetDate = @dtmTargetDate
				,intTargetDateId = 1
			WHERE intWorkOrderId = @intWorkOrderId
		END
		ELSE
		BEGIN
			UPDATE @tblMFCCWorkOrder
			SET dtmTargetDate = @dtmExpectedDate
				,intManufacturingCellId = CASE 
					WHEN @intTargetPreferenceCellId = 1
						THEN intSecondPreferenceCellId
					WHEN @intTargetPreferenceCellId = 2
						THEN intThirdPreferenceCellId
					END
				,intTargetPreferenceCellId = CASE 
					WHEN @intTargetPreferenceCellId = 1
						THEN 2
					WHEN @intTargetPreferenceCellId = 2
						THEN 3
					END
				,@intTargetDateId = 2
				,ysnPicked = CASE 
					WHEN @intTargetPreferenceCellId = 1
						AND intSecondPreferenceCellId IS NULL
						THEN 1
					WHEN @intTargetPreferenceCellId = 2
						AND intThirdPreferenceCellId IS NULL
						THEN 1
					END
			WHERE intWorkOrderId = @intWorkOrderId
		END

		DELETE
		FROM @tblMFSequence

		INSERT INTO @tblMFSequence (
			intWorkOrderId
			,intExecutionOrder
			)
		SELECT intWorkOrderId
			,Row_Number() OVER (
				PARTITION BY W.intManufacturingCellId ORDER BY W.intManufacturingCellId
					,W.dtmTargetDate
					,W.intItemId
				)
		FROM @tblMFCCWorkOrder W

		UPDATE W
		SET W.intExecutionOrder = S.intExecutionOrder
		FROM @tblMFCCWorkOrder W
		JOIN @tblMFSequence S ON S.intWorkOrderId = W.intWorkOrderId

		GOTO LOOP1
	END

	DELETE
	FROM @tblMFSequence

	INSERT INTO @tblMFSequence
	SELECT W.intWorkOrderId
		,Row_Number() OVER (
			PARTITION BY W.intManufacturingCellId ORDER BY W.intManufacturingCellId
				,WS.intSequenceNo Desc
				,CASE 
					WHEN WS.intStatusId = 3
						THEN W1.intExecutionOrder
					ELSE W.intExecutionOrder
					END
			)
		,Isnull(W1.dtmTargetDate, W.dtmTargetDate)
		,ISNULL(W1.intNoOfFlushes,0) AS intNoOfFlushes
	FROM @tblMFWorkOrder W
	JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
	LEFT JOIN @tblMFCCWorkOrder W1 ON W1.intWorkOrderId = W.intWorkOrderId

	--DECLARE @v1 XML = (SELECT * FROM @tblMFSequence FOR XML AUTO)

	SELECT S.intWorkOrderId
		,S.intExecutionOrder
		,S.dtmTargetDate
		,S.intNoOfFlushes
	FROM @tblMFSequence S
END
