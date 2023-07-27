CREATE PROCEDURE [dbo].[uspMFGetScheduleWorkOrder] 
(
	@intManufacturingCellId		INT
  , @intScheduleId				INT
  , @intCalendarId				INT
  , @dtmFromDate				DATETIME = NULL
  , @dtmToDate					DATETIME = NULL
)
AS
/****************************************************************
	Title: Schedule Work Order
	Description: 23.1 Merging of Old Codes
	JIRA: MFG-4651
	Created By: Jonathan Valenzuela
	Date: 07/07/2023
*****************************************************************/
DECLARE @dtmCurrentDate						DATETIME
	  , @tblMFWorkOrderSchedule				ScheduleTable
	  , @ysnAutoPriorityOrderByDemandRatio	BIT
	  , @ysnDisplayNewOrderByExpectedDate	BIT
	  , @intLocationId						INT
	  , @ysnCheckCrossContamination			BIT
	  , @intBlendAttributeId				INT
	  , @strBlendAttributeValue				NVARCHAR(50)
	  , @strCellName						NVARCHAR(50)
	  , @strName							NVARCHAR(50)
	  , @intMachineId						INT

SELECT @intBlendAttributeId = intAttributeId
FROM tblMFAttribute
WHERE strAttributeName = 'Blend Category'

SELECT @strBlendAttributeValue = strAttributeValue
FROM tblMFManufacturingProcessAttribute
WHERE intAttributeId = @intBlendAttributeId

DECLARE @tblWorkOrderDemandRatio TABLE (
	intWorkOrderId INT
	,intDemandRatio INT
	)
DECLARE @tblMFWorkOrderCC TABLE (
	intWorkOrderId INT
	,intExecutionOrder INT
	,intCCFailed INT
	)
DECLARE @tblMFDisplayNewOrderByExpectedDate ScheduleTable
DECLARE @tblMFWorkOrderScheduleCC ScheduleTable

SELECT @dtmCurrentDate = GETDATE()

SELECT @ysnAutoPriorityOrderByDemandRatio = ysnAutoPriorityOrderByDemandRatio
	,@ysnDisplayNewOrderByExpectedDate = ysnDisplayNewOrderByExpectedDate
	,@ysnCheckCrossContamination = ysnCheckCrossContamination
FROM dbo.tblMFCompanyPreference

SELECT @intLocationId = intLocationId
FROM dbo.tblMFManufacturingCell
WHERE intManufacturingCellId = @intManufacturingCellId

IF @dtmFromDate IS NULL
BEGIN
	SELECT @dtmFromDate = @dtmCurrentDate

	SELECT @dtmToDate = @dtmFromDate + intDefaultGanttChartViewDuration
	FROM tblMFCompanyPreference
END

IF @ysnAutoPriorityOrderByDemandRatio = 1
BEGIN
	INSERT INTO @tblMFWorkOrderSchedule (
		intWorkOrderId
		,intItemId
		,intExecutionOrder
		,intLocationId
		)
	SELECT W.intWorkOrderId
		,W.intItemId
		,SL.intExecutionOrder
		,W.intLocationId
	FROM dbo.tblMFWorkOrder W
	LEFT JOIN dbo.tblMFSchedule S ON S.intScheduleId = @intScheduleId
	LEFT JOIN dbo.tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
		AND S.intScheduleId = SL.intScheduleId
	WHERE W.intStatusId <> 13
		AND W.intManufacturingCellId = @intManufacturingCellId

	INSERT INTO @tblWorkOrderDemandRatio (
		intWorkOrderId
		,intDemandRatio
		)
	EXEC dbo.uspMFCalculateDemandRatio @tblMFWorkOrderSchedule
END

IF @ysnDisplayNewOrderByExpectedDate = 1
BEGIN
	INSERT INTO @tblMFDisplayNewOrderByExpectedDate (
		intWorkOrderId
		,intItemId
		,dtmExpectedDate
		,dtmPlannedStartDate
		,intPackTypeId
		,strWIPItemNo
		,intExecutionOrder
		,intStatusId
		)
	SELECT W.intWorkOrderId
		,W.intItemId
		,W.dtmExpectedDate
		,Isnull(dtmPlannedStartDate, W.dtmExpectedDate)
		,I.intPackTypeId
		,(
			SELECT TOP 1 strItemNo
			FROM dbo.tblMFRecipeItem RI
			JOIN dbo.tblICItem WI ON RI.intItemId = WI.intItemId
			JOIN dbo.tblICCategory C ON C.intCategoryId = WI.intCategoryId
			WHERE RI.intRecipeId = R.intRecipeId
				AND C.strCategoryCode = @strBlendAttributeValue
				AND RI.intRecipeItemTypeId = 1
			) AS strWIPItemNo
		,Row_number() OVER (
			ORDER BY WS.intSequenceNo DESC
				,SL.intExecutionOrder
			)
		,W.intStatusId
	FROM dbo.tblMFWorkOrder W
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	LEFT JOIN dbo.tblMFSchedule S ON S.intScheduleId = @intScheduleId
	LEFT JOIN dbo.tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
		AND S.intScheduleId = SL.intScheduleId
	JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = IsNULL(SL.intStatusId, W.intStatusId)
	JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
		AND R.intLocationId = W.intLocationId
		AND R.ysnActive = 1
	WHERE W.intStatusId <> 13
		AND W.intManufacturingCellId = @intManufacturingCellId
	ORDER BY WS.intSequenceNo DESC
		,SL.intExecutionOrder
		,W.dtmExpectedDate

	DECLARE @intRecordId INT
		,@intItemId INT
		,@dtmExpectedDate DATETIME
		,@intPackTypeId INT
		,@strWIPItemNo NVARCHAR(50)
		,@intExecutionOrder INT

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblMFDisplayNewOrderByExpectedDate
	WHERE intStatusId = 1

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @intItemId = NULL
			,@dtmExpectedDate = NULL
			,@intPackTypeId = NULL
			,@strWIPItemNo = NULL
			,@intExecutionOrder = NULL

		SELECT @intItemId = intItemId
			,@dtmExpectedDate = dtmExpectedDate
			,@intPackTypeId = intPackTypeId
			,@strWIPItemNo = strWIPItemNo
		FROM @tblMFDisplayNewOrderByExpectedDate
		WHERE intRecordId = @intRecordId

		SELECT @intExecutionOrder = intExecutionOrder
		FROM @tblMFDisplayNewOrderByExpectedDate
		WHERE intItemId = @intItemId
			AND intPackTypeId = @intPackTypeId
			AND strWIPItemNo = @strWIPItemNo
			AND dtmPlannedStartDate = @dtmExpectedDate
			AND intRecordId <> @intRecordId
		ORDER BY dtmPlannedStartDate DESC
			,intExecutionOrder DESC

		IF @intExecutionOrder IS NULL
			SELECT TOP 1 @intExecutionOrder = intExecutionOrder
			FROM @tblMFDisplayNewOrderByExpectedDate
			WHERE intItemId = @intItemId
				AND intPackTypeId = @intPackTypeId
				AND Convert(DATETIME, Convert(CHAR, dtmPlannedStartDate)) = @dtmExpectedDate
				AND intRecordId <> @intRecordId
			ORDER BY dtmPlannedStartDate DESC
				,intExecutionOrder DESC

		IF @intExecutionOrder IS NULL
			SELECT TOP 1 @intExecutionOrder = intExecutionOrder
			FROM @tblMFDisplayNewOrderByExpectedDate
			WHERE intItemId = @intItemId
				AND Convert(DATETIME, Convert(CHAR, dtmPlannedStartDate)) = @dtmExpectedDate
				AND intRecordId <> @intRecordId
			ORDER BY dtmPlannedStartDate DESC
				,intExecutionOrder DESC

		IF @intExecutionOrder IS NULL
			SELECT TOP 1 @intExecutionOrder = intExecutionOrder
			FROM @tblMFDisplayNewOrderByExpectedDate
			WHERE Convert(DATETIME, Convert(CHAR, dtmPlannedStartDate)) <= @dtmExpectedDate
				AND intRecordId <> @intRecordId
			ORDER BY dtmPlannedStartDate DESC
				,intExecutionOrder DESC

		IF @intExecutionOrder IS NULL
			SELECT @intExecutionOrder = 0

		UPDATE @tblMFDisplayNewOrderByExpectedDate
		SET intExecutionOrder = intExecutionOrder + 1
		WHERE intExecutionOrder > @intExecutionOrder

		UPDATE @tblMFDisplayNewOrderByExpectedDate
		SET intExecutionOrder = @intExecutionOrder + 1
		WHERE intRecordId = @intRecordId

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFDisplayNewOrderByExpectedDate
		WHERE intRecordId > @intRecordId
			AND intStatusId = 1
	END
END

SELECT @intMachineId = P1.intMachineId
FROM tblMFMachinePackType P1
WHERE P1.intPackTypeId IN (
		SELECT P2.intPackTypeId
		FROM tblMFManufacturingCellPackType P2
		WHERE P2.intManufacturingCellId = @intManufacturingCellId
		)

SELECT C.intManufacturingCellId
	,C.strCellName
	,W.intWorkOrderId
	,Isnull(S.intScheduleId, 0) intScheduleId
	,W.strWorkOrderNo
	,W.dblQuantity
	,ISNULL(W.dtmEarliestDate, W.dtmExpectedDate) AS dtmEarliestDate
	,W.dtmExpectedDate
	,ISNULL(W.dtmLatestDate, W.dtmExpectedDate) AS dtmLatestDate
	,W.dblQuantity - W.dblProducedQuantity AS dblBalanceQuantity
	,W.dblProducedQuantity
	,W.strComment AS strWorkOrderComments
	,W.dtmOrderDate
	,W.dtmLastProducedDate
	,(
		SELECT TOP 1 strItemNo
		FROM dbo.tblMFRecipeItem RI
		JOIN dbo.tblICItem WI ON RI.intItemId = WI.intItemId
		JOIN dbo.tblICCategory C ON C.intCategoryId = WI.intCategoryId
		WHERE RI.intRecipeId = R.intRecipeId
			AND C.strCategoryCode = @strBlendAttributeValue
			AND RI.intRecipeItemTypeId = 1
		) AS strWIPItemNo
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,IU.intItemUOMId
	,U.intUnitMeasureId
	,U.strUnitMeasure
	,WS.intStatusId
	,WS.strName AS strStatusName
	,PT.intProductionTypeId
	,PT.strName AS strProductionType
	,SL.intScheduleWorkOrderId
	,SL.intDuration
	,SL.dtmChangeoverStartDate
	,SL.dtmChangeoverEndDate
	,SL.dtmPlannedStartDate
	,SL.dtmPlannedEndDate
	--,ISNULL(SL.intExecutionOrder, W.intExecutionOrder) intExecutionOrder
	,Convert(INT, CASE 
			WHEN W.intStatusId = 1
				THEN NULL
			ELSE Row_number() OVER (
					ORDER BY WS.intSequenceNo DESC
						,CASE 
							WHEN @ysnAutoPriorityOrderByDemandRatio = 1
								AND W.intStatusId = 3
								THEN WD.intDemandRatio
							ELSE ISNULL(SL.intExecutionOrder, 9999)
							END
						,CASE 
							WHEN @ysnAutoPriorityOrderByDemandRatio = 1
								AND W.intStatusId = 3
								THEN W.intItemId
							ELSE SL.intExecutionOrder
							END
						,CASE 
							WHEN @ysnAutoPriorityOrderByDemandRatio = 1
								AND W.intStatusId = 3
								THEN W.dtmCreated
							ELSE SL.intExecutionOrder
							END
						,CASE 
							WHEN @ysnAutoPriorityOrderByDemandRatio = 1
								AND W.intStatusId = 3
								THEN I.intPackTypeId
							ELSE SL.intExecutionOrder
							END
						--,Case when @ysnAutoPriorityOrderByDemandRatio=1 and W.intStatusId=3 Then strWIPItemNo Else SL.intExecutionOrder end
					)
			END) AS intExecutionOrder
	,SL.intChangeoverDuration
	,SL.intSetupDuration
	,SL.strComments
	,SL.strNote
	,SL.strAdditionalComments
	--,SL.intNoOfSelectedMachine
	,Convert(INT, CASE 
			WHEN W.intStatusId = 1
				THEN SL.intNoOfSelectedMachine
			ELSE IsNULL(SL.intNoOfSelectedMachine, 1)
			END) AS intNoOfSelectedMachine
	,SL.dtmEarliestStartDate
	,SL.intPlannedShiftId
	,SL.ysnFrozen
	,SH.strShiftName
	,P.intPackTypeId
	,P.strPackName
	,Isnull(SL.intConcurrencyId, 0) AS intConcurrencyId
	,SL.dtmCreated
	,SL.intCreatedUserId
	,SL.dtmLastModified
	,SL.intLastModifiedUserId
	,WS.intSequenceNo
	,W.ysnIngredientAvailable
	,CONVERT(BIT, 0) AS ysnEOModified
	,WD.intDemandRatio
	,IsNULL(SL.intNoOfFlushes, 0) AS intNoOfFlushes
	,M.dblBatchSize
	,U1.strUnitMeasure AS strBatchUOM
	,W.dblQuantity / (
		CASE 
			WHEN IsNULL(M.dblBatchSize, 0) = 0
				THEN 1
			ELSE M.dblBatchSize
			END
		) dblNoofBatches
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFManufacturingCell C ON C.intManufacturingCellId = W.intManufacturingCellId
	AND W.intStatusId <> 13
	AND W.intManufacturingCellId = @intManufacturingCellId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
LEFT JOIN dbo.tblMFPackType P ON P.intPackTypeId = I.intPackTypeId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFWorkOrderProductionType PT ON PT.intProductionTypeId = W.intProductionTypeId
LEFT JOIN dbo.tblMFSchedule S ON S.intScheduleId = @intScheduleId
LEFT JOIN dbo.tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
	AND S.intScheduleId = SL.intScheduleId
LEFT JOIN dbo.tblMFShift SH ON SH.intShiftId = SL.intPlannedShiftId
LEFT JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = IsNULL(SL.intStatusId, W.intStatusId)
JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
	AND R.intLocationId = C.intLocationId
	AND R.ysnActive = 1
LEFT JOIN @tblWorkOrderDemandRatio WD ON W.intWorkOrderId = WD.intWorkOrderId
LEFT JOIN @tblMFDisplayNewOrderByExpectedDate DN ON W.intWorkOrderId = DN.intWorkOrderId
LEFT JOIN @tblMFWorkOrderCC CC ON W.intWorkOrderId = CC.intWorkOrderId
LEFT JOIN tblMFMachine M ON M.intMachineId = @intMachineId
LEFT JOIN dbo.tblICUnitMeasure U1 ON U1.intUnitMeasureId = M.intBatchSizeUOMId
ORDER BY CASE 
		WHEN @ysnDisplayNewOrderByExpectedDate = 1
			THEN DN.intExecutionOrder
		ELSE 0
		END
	,WS.intSequenceNo DESC
	,CASE 
		WHEN @ysnCheckCrossContamination = 1
			AND W.intStatusId = 3
			THEN CC.intExecutionOrder
		ELSE ISNULL(SL.intExecutionOrder, 9999)
		END
	,CASE 
		WHEN @ysnAutoPriorityOrderByDemandRatio = 1
			AND W.intStatusId = 3
			THEN WD.intDemandRatio
		ELSE SL.intExecutionOrder
		END
	,CASE 
		WHEN @ysnAutoPriorityOrderByDemandRatio = 1
			AND W.intStatusId = 3
			THEN W.intItemId
		ELSE SL.intExecutionOrder
		END
	,CASE 
		WHEN @ysnAutoPriorityOrderByDemandRatio = 1
			AND W.intStatusId = 3
			THEN W.dtmCreated
		ELSE SL.intExecutionOrder
		END
	,CASE 
		WHEN @ysnAutoPriorityOrderByDemandRatio = 1
			AND W.intStatusId = 3
			THEN I.intPackTypeId
		ELSE SL.intExecutionOrder
		END
