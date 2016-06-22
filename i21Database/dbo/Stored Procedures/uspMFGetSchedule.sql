CREATE PROCEDURE uspMFGetSchedule (
	@intManufacturingCellId INT
	,@intScheduleId INT
	,@dtmFromDate DATETIME = NULL
	,@dtmToDate DATETIME = NULL
	)
AS
DECLARE @dtmCurrentDate DATETIME
	,@tblMFWorkOrderSchedule ScheduleTable
	,@ysnAutoPriorityOrderByDemandRatio BIT
	,@ysnDisplayNewOrderByExpectedDate BIT
	,@intLocationId int
	,@ysnCheckCrossContamination bit
	,@intBlendAttributeId INT
	,@strBlendAttributeValue NVARCHAR(50)

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

Declare @tblMFWorkOrderScheduleCC ScheduleTable

SELECT @dtmCurrentDate = GETDATE()

SELECT @ysnAutoPriorityOrderByDemandRatio = ysnAutoPriorityOrderByDemandRatio
	,@ysnDisplayNewOrderByExpectedDate = ysnDisplayNewOrderByExpectedDate
	,@ysnCheckCrossContamination=ysnCheckCrossContamination
FROM dbo.tblMFCompanyPreference

SELECT @intLocationId =intLocationId 
FROM dbo.tblMFManufacturingCell 
WHERE intManufacturingCellId =@intManufacturingCellId 

IF @dtmFromDate IS NULL
BEGIN
	SELECT @dtmFromDate = @dtmCurrentDate

	SELECT @dtmToDate = @dtmFromDate + intDefaultGanttChartViewDuration
	FROM tblMFCompanyPreference
END

IF @intScheduleId > 0
BEGIN
	SELECT S.intScheduleId
		,S.strScheduleNo
		,S.dtmScheduleDate
		,S.intCalendarId
		,SC.strName
		,S.intManufacturingCellId
		,MC.strCellName
		,S.ysnStandard
		,S.intLocationId
		,S.intConcurrencyId
		,S.dtmCreated
		,S.intCreatedUserId
		,S.dtmLastModified
		,S.intLastModifiedUserId
		,@dtmFromDate AS dtmFromDate
		,@dtmToDate AS dtmToDate
	FROM dbo.tblMFSchedule S
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = S.intManufacturingCellId
	JOIN dbo.tblMFScheduleCalendar SC ON SC.intCalendarId = S.intCalendarId
	WHERE intScheduleId = @intScheduleId

	SELECT @intManufacturingCellId = S.intManufacturingCellId,
			@intLocationId =intLocationId 
	FROM dbo.tblMFSchedule S
	WHERE S.intScheduleId = @intScheduleId
END
ELSE
BEGIN
	SELECT 0 AS intScheduleId
		,'' AS strScheduleNo
		,@dtmCurrentDate AS dtmScheduleDate
		,0 AS intCalendarId
		,'' AS strName
		,@intManufacturingCellId AS intManufacturingCellId
		,'' AS strCellName
		,CONVERT(BIT, 0) AS ysnStandard
		,0 AS intLocationId
		,0 AS intConcurrencyId
		,@dtmCurrentDate AS dtmCreated
		,0 AS intCreatedUserId
		,@dtmCurrentDate AS dtmLastModified
		,0 AS intLastModifiedUserId
		,@dtmFromDate AS dtmFromDate
		,@dtmToDate AS dtmToDate
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

--IF @ysnCheckCrossContamination = 1
--BEGIN
--	INSERT INTO @tblMFWorkOrderScheduleCC (
--		intWorkOrderId
--		,intItemId
--		,intExecutionOrder
--		,intLocationId
--		,strRecipeGroupName 
--		,intExecutionOrder 
--		)
--	SELECT W.intWorkOrderId
--		,W.intItemId
--		,SL.intExecutionOrder
--		,W.intLocationId
--		,RG.strRecipeGroupName
--		,ROW_NUMBER() OVER (
--			ORDER BY W.intManufacturingCellId
--				,W.dtmExpectedDate
--				,RG.strRecipeGroupName
--				,I.strItemName
--			)
--	FROM dbo.tblMFWorkOrder W
--	JOIN dbo.tblICItem I ON I.intItemId=W.intItemId
--	LEFT JOIN dbo.tblMFSchedule S ON S.intScheduleId = @intScheduleId
--	LEFT JOIN dbo.tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
--		AND S.intScheduleId = SL.intScheduleId
--	JOIN dbo.tblMFRecipe R ON R.intItemId=W.intItemId AND R.intLocationId =@intLocationId  AND R.ysnActive =1
--	JOIN dbo.tblMFRecipeGroup RG on RG.intRecipeGroupId=R.intRecipeGropupId 
--	WHERE W.intStatusId = 3-- We need to get only Open status orders
--		AND W.intManufacturingCellId = @intManufacturingCellId

--	INSERT INTO @tblMFWorkOrderCC
--	 (
--		intWorkOrderId
--		,intExecutionOrder
--		,intCCFailed
--		)
--	EXEC dbo.uspMFCheckCC @tblMFWorkOrderScheduleCC

--	--SET s.Targetdate = s.ExpectedDate
--	--	,s.byWhichDate = 1
--	--	,s.EO = st.EO
--	--	,s.intCCFailed = ISNULL(st.intCCFailed, 0)
--	--	,IsAlternateLine = 0
--	--	,SEO = 0
--	--FROM stgischWOScheduleMain s
--	--JOIN @tblMFWorkOrder st ON st.intRecordId = s.intRecordId
--END

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
		,Isnull(dtmPlannedStartDate,W.dtmExpectedDate)
		,I.intPackTypeId
		,(
			SELECT TOP 1 strItemNo
			FROM dbo.tblMFRecipeItem RI
			JOIN dbo.tblICItem WI ON RI.intItemId = WI.intItemId
			JOIN dbo.tblICCategory C on C.intCategoryId =WI.intCategoryId
			WHERE RI.intRecipeId = R.intRecipeId
				AND C.strCategoryCode = @strBlendAttributeValue
				AND RI.intRecipeItemTypeId=1
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
		,SL.intExecutionOrder, W.dtmExpectedDate 

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
			SELECT Top 1 @intExecutionOrder = intExecutionOrder
			FROM @tblMFDisplayNewOrderByExpectedDate
			WHERE intItemId = @intItemId
				AND intPackTypeId = @intPackTypeId
				AND Convert(datetime,Convert(char,dtmPlannedStartDate)) = @dtmExpectedDate
				AND intRecordId <> @intRecordId
		ORDER BY dtmPlannedStartDate DESC
				,intExecutionOrder DESC

		IF @intExecutionOrder IS NULL
			SELECT Top 1 @intExecutionOrder = intExecutionOrder
			FROM @tblMFDisplayNewOrderByExpectedDate
			WHERE intItemId = @intItemId
				AND Convert(datetime,Convert(char,dtmPlannedStartDate)) = @dtmExpectedDate
				AND intRecordId <> @intRecordId
			ORDER BY dtmPlannedStartDate DESC
				,intExecutionOrder DESC

		IF @intExecutionOrder IS NULL
			SELECT Top 1 @intExecutionOrder = intExecutionOrder
			FROM @tblMFDisplayNewOrderByExpectedDate
			WHERE Convert(datetime,Convert(char,dtmPlannedStartDate)) <= @dtmExpectedDate
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

SELECT C.intManufacturingCellId
	,C.strCellName
	,W.intWorkOrderId
	,Isnull(S.intScheduleId, 0) intScheduleId
	,W.strWorkOrderNo
	,W.dblQuantity
	,ISNULL(W.dtmEarliestDate,W.dtmExpectedDate) AS dtmEarliestDate 
	,W.dtmExpectedDate
	,ISNULL(W.dtmLatestDate,W.dtmExpectedDate) AS dtmLatestDate
	,W.dblQuantity - W.dblProducedQuantity AS dblBalanceQuantity
	,W.dblProducedQuantity
	,W.strComment AS strWorkOrderComments
	,W.dtmOrderDate
	,W.dtmLastProducedDate
	,(
		SELECT TOP 1 strItemNo
		FROM dbo.tblMFRecipeItem RI
		JOIN dbo.tblICItem WI ON RI.intItemId = WI.intItemId
		JOIN dbo.tblICCategory C on C.intCategoryId =WI.intCategoryId
		WHERE RI.intRecipeId = R.intRecipeId
			AND C.strCategoryCode = @strBlendAttributeValue
			AND RI.intRecipeItemTypeId=1
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
						--,Case when @ysnAutoPriorityOrderByDemandRatio=1 and W.intStatusId=3 Then strWIPItemNo Else SL.intExecutionOrder end
					)
			END) AS intExecutionOrder
	,SL.intChangeoverDuration
	,SL.intSetupDuration
	,SL.strComments
	,SL.strNote
	,SL.strAdditionalComments
	,SL.intNoOfSelectedMachine
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
	,IsNULL(SL.intNoOfFlushes,0) AS intNoOfFlushes
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
		ELSE SL.intExecutionOrder
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

--,Case when @ysnAutoPriorityOrderByDemandRatio=1 and W.intStatusId=3 Then strWIPItemNo Else SL.intExecutionOrder end
SELECT WD.intScheduleWorkOrderDetailId
	,WD.intScheduleWorkOrderId
	,WD.intWorkOrderId
	,WD.intScheduleId
	,WD.dtmPlannedStartDate
	,WD.dtmPlannedEndDate
	,WD.intPlannedShiftId
	,WD.intDuration
	,WD.dblPlannedQty
	,WD.intSequenceNo
	,WD.intCalendarDetailId
	,WD.intConcurrencyId
FROM dbo.tblMFScheduleWorkOrderDetail WD
WHERE WD.intScheduleId = @intScheduleId

SELECT M.intScheduleMachineDetailId
	,M.intScheduleWorkOrderDetailId
	,M.intWorkOrderId
	,M.intScheduleId
	,M.intCalendarMachineId
	,M.intCalendarDetailId
	,M.intConcurrencyId
FROM dbo.tblMFScheduleMachineDetail M
WHERE M.intScheduleId = @intScheduleId

SELECT C.intScheduleConstraintDetailId
	,C.intScheduleWorkOrderId
	,C.intWorkOrderId
	,C.intScheduleId
	,C.intScheduleRuleId
	,C.dtmChangeoverStartDate
	,C.dtmChangeoverEndDate
	,C.intDuration
	,C.intConcurrencyId
FROM dbo.tblMFScheduleConstraintDetail C
WHERE C.intScheduleId = @intScheduleId

SELECT R.intScheduleRuleId
	,R.strName AS strScheduleRuleName
	,R.intScheduleRuleTypeId
	,RT.strName AS strScheduleRuleTypeName
	,R.ysnActive
	,R.intPriorityNo
	,R.strComments
	,Convert(BIT, CASE 
			WHEN SC.intScheduleConstraintId IS NULL
				THEN 0
			ELSE 1
			END) AS ysnSelect
	,@intScheduleId AS intScheduleId
	,R.intConcurrencyId
FROM dbo.tblMFScheduleRule R
JOIN dbo.tblMFScheduleRuleType RT ON RT.intScheduleRuleTypeId = R.intScheduleRuleTypeId
LEFT JOIN dbo.tblMFScheduleConstraint SC ON SC.intScheduleRuleId = R.intScheduleRuleId
	AND SC.intScheduleId = @intScheduleId
WHERE R.intLocationId = @intLocationId AND R.ysnActive = 1
	
