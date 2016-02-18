CREATE PROCEDURE dbo.uspMFRescheduleWorkOrderByLocation (
	@intLocationId INT
	,@dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@intUserId INT
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@tblMFWorkOrder AS ScheduleTable
	DECLARE @tblMFSequence TABLE (
		intWorkOrderId INT
		,intExecutionOrder INT
		,dtmTargetDate DATETIME
		)

	INSERT INTO @tblMFWorkOrder (
		intManufacturingCellId
		,intWorkOrderId
		,intItemId
		,dblQuantity
		,dblBalance
		,dtmEarliestDate
		,dtmExpectedDate
		,dtmLatestDate
		,dtmTargetDate
		,intTargetDateId
		,intStatusId
		,intExecutionOrder
		,intFirstPreferenceCellId
		,intSecondPreferenceCellId
		,intThirdPreferenceCellId
		,intTargetPreferenceCellId
		,intNoOfFlushes
		,ysnPicked
		,intLocationId
		,intPackTypeId
		,intItemUOMId
		,intUnitMeasureId
		,intScheduleId
		)
	SELECT W.intManufacturingCellId
		,W.intWorkOrderId
		,W.intItemId
		,W.dblQuantity
		,W.dblQuantity - W.dblProducedQuantity
		,W.dtmEarliestDate
		,W.dtmExpectedDate
		,W.dtmLatestDate
		,W.dtmExpectedDate
		,2
		,CASE 
			WHEN W.intStatusId = 1
				THEN 3
			ELSE W.intStatusId
			END
		,ROW_NUMBER() OVER (
			PARTITION BY W.intManufacturingCellId ORDER BY W.intManufacturingCellId
				,W.dtmExpectedDate
				,W.intItemId
			)
		,MC1.intManufacturingCellId AS intFirstPreferenceCellId
		,MC2.intManufacturingCellId AS intSecondPreferenceCellId
		,MC3.intManufacturingCellId AS intThirdPreferenceCellId
		,1
		,0
		,0
		,W.intLocationId
		,I.intPackTypeId
		,W.intItemUOMId
		,IU.intUnitMeasureId
		,S.intScheduleId
	FROM dbo.tblMFWorkOrder W
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
		AND ysnIncludeSchedule = 1
	LEFT JOIN dbo.tblICItemFactory F1 ON F1.intFactoryId = W.intLocationId
		AND F1.intItemId = W.intItemId
	LEFT JOIN dbo.tblICItemFactoryManufacturingCell MC1 ON MC1.intItemFactoryId = F1.intItemFactoryId
		AND MC1.intPreference = 1
	LEFT JOIN dbo.tblICItemFactory F2 ON F2.intFactoryId = W.intLocationId
		AND F2.intItemId = W.intItemId
	LEFT JOIN dbo.tblICItemFactoryManufacturingCell MC2 ON MC2.intItemFactoryId = F2.intItemFactoryId
		AND MC2.intPreference = 2
	LEFT JOIN dbo.tblICItemFactory F3 ON F3.intFactoryId = W.intLocationId
		AND F3.intItemId = W.intItemId
	LEFT JOIN dbo.tblICItemFactoryManufacturingCell MC3 ON MC3.intItemFactoryId = F3.intItemFactoryId
		AND MC3.intPreference = 3
	LEFT JOIN dbo.tblMFSchedule S ON S.intManufacturingCellId = W.intManufacturingCellId
		AND S.intLocationId = @intLocationId
		AND ysnStandard = 1
	WHERE W.intStatusId <> 13
		AND W.intLocationId = @intLocationId
		AND W.intManufacturingCellId IS NOT NULL
	ORDER BY W.intManufacturingCellId
		,W.dtmExpectedDate
		,W.intItemId

	INSERT INTO @tblMFSequence
	EXEC dbo.uspMFCheckContamination @tblMFWorkOrder
		,@intLocationId

	UPDATE W
	SET W.intExecutionOrder = S.intExecutionOrder
		,W.dtmTargetDate = S.dtmTargetDate
	FROM @tblMFWorkOrder W
	JOIN @tblMFSequence S ON S.intWorkOrderId = W.intWorkOrderId

	EXEC dbo.uspMFRescheduleAndSaveWorkOrder @tblMFWorkOrder = @tblMFWorkOrder
		,@dtmFromDate = @dtmFromDate
		,@dtmToDate = @dtmToDate
		,@intUserId = @intUserId
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

