CREATE PROCEDURE uspMFUpdateWorkOrderPriority (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intScheduleId INT
		,@dtmCurrentDate DATETIME
		,@intUserId INT
		,@intConcurrencyId INT
		,@intManufacturingCellId INT
		,@intLocationId INT
		,@intBlendAttributeId INT
		,@strBlendAttributeValue NVARCHAR(50)
		,@intMachineId INT

	SELECT @intBlendAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Blend Category'

	SELECT @strBlendAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intAttributeId = @intBlendAttributeId

	SELECT @dtmCurrentDate = GetDate()

	DECLARE @tblMFScheduleWorkOrder TABLE (
		intRecordId INT identity(1, 1)
		,intManufacturingCellId INT
		,intWorkOrderId INT
		,intItemId INT
		,intItemUOMId INT
		,intUnitMeasureId INT
		,dblQuantity NUMERIC(18, 6)
		,dblBalance NUMERIC(18, 6)
		,dtmExpectedDate DATETIME
		,intStatusId INT
		,intExecutionOrder INT
		,strComments NVARCHAR(MAX)
		,strNote NVARCHAR(MAX)
		,strAdditionalComments NVARCHAR(MAX)
		,intNoOfSelectedMachine INT
		,dtmEarliestStartDate DATETIME
		,intPackTypeId INT
		,dtmPlannedStartDate DATETIME
		,dtmPlannedEndDate DATETIME
		,intPlannedShiftId INT
		,intDuration INT
		,intChangeoverDuration INT
		,intScheduleWorkOrderId INT
		,intSetupDuration INT
		,dtmChangeoverStartDate DATETIME
		,dtmChangeoverEndDate DATETIME
		,ysnFrozen BIT
		,intConcurrencyId INT
		,intSequenceId INT
		,intDemandRatio INT
		,dtmEarliestDate DATETIME
		,dtmLatestDate DATETIME
		,intNoOfFlushes INT
		)
	DECLARE @tblMFScheduleConstraint TABLE (
		intScheduleConstraintId INT identity(1, 1)
		,intScheduleRuleId INT
		,intPriorityNo INT
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	INSERT INTO @tblMFScheduleConstraint (
		intScheduleRuleId
		,intPriorityNo
		)
	SELECT intScheduleRuleId
		,intPriorityNo
	FROM OPENXML(@idoc, 'root/ScheduleRules/ScheduleRule', 2) WITH (
			intScheduleRuleId INT
			,intPriorityNo INT
			,ysnSelect BIT
			)
	WHERE ysnSelect = 1
	ORDER BY intPriorityNo

	SELECT @intManufacturingCellId = intManufacturingCellId
		,@intScheduleId = intScheduleId
		,@intConcurrencyId = intConcurrencyId
		,@intUserId = intUserId
		,@intLocationId = intLocationId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intManufacturingCellId INT
			,intScheduleId INT
			,intConcurrencyId INT
			,intUserId INT
			,intLocationId INT
			)

	INSERT INTO @tblMFScheduleWorkOrder (
		intManufacturingCellId
		,intWorkOrderId
		,intItemId
		,intItemUOMId
		,intUnitMeasureId
		,dblQuantity
		,dblBalance
		,dtmExpectedDate
		,intStatusId
		,intExecutionOrder
		,strComments
		,strNote
		,strAdditionalComments
		,intNoOfSelectedMachine
		,dtmEarliestStartDate
		,intPackTypeId
		,dtmPlannedStartDate
		,dtmPlannedEndDate
		,intPlannedShiftId
		,intDuration
		,intChangeoverDuration
		,intSetupDuration
		,dtmChangeoverStartDate
		,dtmChangeoverEndDate
		,intScheduleWorkOrderId
		,ysnFrozen
		,intConcurrencyId
		,intSequenceId
		,intDemandRatio
		,dtmEarliestDate
		,dtmLatestDate
		,intNoOfFlushes
		)
	SELECT x.intManufacturingCellId
		,x.intWorkOrderId
		,x.intItemId
		,x.intItemUOMId
		,x.intUnitMeasureId
		,x.dblQuantity
		,x.dblBalance
		,x.dtmExpectedDate
		,x.intStatusId
		,Row_number() OVER (
			ORDER BY x.intSequenceNo DESC
				,x.intExecutionOrder
				,x.ysnEOModified DESC
			) AS intExecutionOrder
		,x.strComments
		,x.strNote
		,x.strAdditionalComments
		,x.intNoOfSelectedMachine
		,x.dtmEarliestStartDate
		,x.intPackTypeId
		,x.dtmPlannedStartDate
		,x.dtmPlannedEndDate
		,x.intPlannedShiftId
		,x.intDuration
		,x.intChangeoverDuration
		,x.intSetupDuration
		,x.dtmChangeoverStartDate
		,x.dtmChangeoverEndDate
		,x.intScheduleWorkOrderId
		,x.ysnFrozen
		,@intConcurrencyId
		,x.intSequenceNo
		,x.intDemandRatio
		,x.dtmEarliestDate
		,x.dtmLatestDate
		,x.intNoOfFlushes
	FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
			intManufacturingCellId INT
			,intWorkOrderId INT
			,intItemId INT
			,intUnitMeasureId INT
			,intItemUOMId INT
			,dblQuantity NUMERIC(18, 6)
			,dblBalance NUMERIC(18, 6)
			,dtmExpectedDate DATETIME
			,intStatusId INT
			,intExecutionOrder INT
			,strComments NVARCHAR(MAX)
			,strNote NVARCHAR(MAX)
			,strAdditionalComments NVARCHAR(MAX)
			,intNoOfSelectedMachine INT
			,dtmEarliestStartDate DATETIME
			,intPackTypeId INT
			,dtmPlannedStartDate DATETIME
			,dtmPlannedEndDate DATETIME
			,intPlannedShiftId INT
			,intDuration INT
			,intChangeoverDuration INT
			,intSetupDuration INT
			,dtmChangeoverStartDate DATETIME
			,dtmChangeoverEndDate DATETIME
			,intScheduleWorkOrderId INT
			,ysnFrozen BIT
			,intSequenceNo INT
			,ysnEOModified BIT
			,intDemandRatio INT
			,dtmEarliestDate DATETIME
			,dtmLatestDate DATETIME
			,intNoOfFlushes INT
			) x
	WHERE x.intStatusId <> 1
	ORDER BY x.intExecutionOrder

	INSERT INTO @tblMFScheduleWorkOrder (
		intManufacturingCellId
		,intWorkOrderId
		,intItemId
		,intItemUOMId
		,intUnitMeasureId
		,dblQuantity
		,dblBalance
		,dtmExpectedDate
		,intStatusId
		,intExecutionOrder
		,strComments
		,strNote
		,strAdditionalComments
		,intNoOfSelectedMachine
		,dtmEarliestStartDate
		,intPackTypeId
		,dtmPlannedStartDate
		,dtmPlannedEndDate
		,intPlannedShiftId
		,intDuration
		,intChangeoverDuration
		,intSetupDuration
		,dtmChangeoverStartDate
		,dtmChangeoverEndDate
		,intScheduleWorkOrderId
		,ysnFrozen
		,intConcurrencyId
		,intSequenceId
		,intDemandRatio
		,dtmEarliestDate
		,dtmLatestDate
		,intNoOfFlushes
		)
	SELECT x.intManufacturingCellId
		,x.intWorkOrderId
		,x.intItemId
		,x.intItemUOMId
		,x.intUnitMeasureId
		,x.dblQuantity
		,x.dblBalance
		,x.dtmExpectedDate
		,x.intStatusId
		,x.intExecutionOrder
		,x.strComments
		,x.strNote
		,x.strAdditionalComments
		,x.intNoOfSelectedMachine
		,x.dtmEarliestStartDate
		,x.intPackTypeId
		,x.dtmPlannedStartDate
		,x.dtmPlannedEndDate
		,x.intPlannedShiftId
		,x.intDuration
		,x.intChangeoverDuration
		,x.intSetupDuration
		,x.dtmChangeoverStartDate
		,x.dtmChangeoverEndDate
		,x.intScheduleWorkOrderId
		,x.ysnFrozen
		,@intConcurrencyId
		,x.intSequenceNo
		,x.intDemandRatio
		,x.dtmEarliestDate
		,x.dtmLatestDate
		,x.intNoOfFlushes
	FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
			intManufacturingCellId INT
			,intWorkOrderId INT
			,intItemId INT
			,intUnitMeasureId INT
			,intItemUOMId INT
			,dblQuantity NUMERIC(18, 6)
			,dblBalance NUMERIC(18, 6)
			,dtmExpectedDate DATETIME
			,intStatusId INT
			,intExecutionOrder INT
			,strComments NVARCHAR(MAX)
			,strNote NVARCHAR(MAX)
			,strAdditionalComments NVARCHAR(MAX)
			,intNoOfSelectedMachine INT
			,dtmEarliestStartDate DATETIME
			,intPackTypeId INT
			,dtmPlannedStartDate DATETIME
			,dtmPlannedEndDate DATETIME
			,intPlannedShiftId INT
			,intDuration INT
			,intChangeoverDuration INT
			,intSetupDuration INT
			,dtmChangeoverStartDate DATETIME
			,dtmChangeoverEndDate DATETIME
			,intScheduleWorkOrderId INT
			,ysnFrozen BIT
			,intSequenceNo INT
			,intDemandRatio INT
			,dtmEarliestDate DATETIME
			,dtmLatestDate DATETIME
			,intNoOfFlushes INT
			) x
	WHERE x.intStatusId = 1
	ORDER BY x.intExecutionOrder

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
		,@intScheduleId AS intScheduleId
		,W.strWorkOrderNo
		,SL.dblQuantity
		,SL.dtmEarliestDate
		,SL.dtmExpectedDate
		,SL.dtmLatestDate
		,SL.dblQuantity - W.dblProducedQuantity AS dblBalanceQuantity
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
		,SL.intExecutionOrder
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
		,@dtmCurrentDate dtmCreated
		,@intUserId intCreatedUserId
		,@dtmCurrentDate dtmLastModified
		,@intUserId intLastModifiedUserId
		,WS.intSequenceNo
		,W.ysnIngredientAvailable
		,W.dtmLastProducedDate
		,CONVERT(BIT, 0) AS ysnEOModified
		,SL.intDemandRatio
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
	FROM tblMFWorkOrder W
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
		AND W.intManufacturingCellId = @intManufacturingCellId
		AND W.intStatusId <> 13
	LEFT JOIN tblMFPackType P ON P.intPackTypeId = I.intPackTypeId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblMFWorkOrderProductionType PT ON PT.intProductionTypeId = W.intProductionTypeId
	LEFT JOIN @tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
	JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = SL.intStatusId
	LEFT JOIN dbo.tblMFShift SH ON SH.intShiftId = SL.intPlannedShiftId
	LEFT JOIN dbo.tblMFManufacturingCell C ON C.intManufacturingCellId = SL.intManufacturingCellId
	JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
		AND R.intLocationId = W.intLocationId
		AND R.ysnActive = 1
	LEFT JOIN tblMFMachine M ON M.intMachineId = @intMachineId
	LEFT JOIN dbo.tblICUnitMeasure U1 ON U1.intUnitMeasureId = M.intBatchSizeUOMId
	ORDER BY WS.intSequenceNo DESC
		,SL.intExecutionOrder

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
	LEFT JOIN @tblMFScheduleConstraint SC ON SC.intScheduleRuleId = R.intScheduleRuleId
	WHERE R.intLocationId = @intLocationId
		AND R.ysnActive = 1

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
