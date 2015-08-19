CREATE PROCEDURE uspMFUpdateWorkOrderPriority (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intScheduleId int
		,@dtmCurrentDate datetime
		,@intUserId int
		,@intConcurrencyId int
		,@intManufacturingCellId int
		
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
		,intSequenceId int
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intManufacturingCellId = intManufacturingCellId
		,@intScheduleId = intScheduleId
		,@intConcurrencyId = intConcurrencyId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intManufacturingCellId INT
			,intScheduleId INT
			,intConcurrencyId INT
			,intUserId INT
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
		,Row_number() OVER (ORDER BY x.intSequenceId Desc,x.intExecutionOrder
			) as intExecutionOrder
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
		,x.intSequenceId
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
			,intSequenceId int
			) x Where x.intStatusId<>1
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
		,x.intSequenceId
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
			,intSequenceId int
			) x Where x.intStatusId=1
	ORDER BY x.intExecutionOrder
	

	SELECT C.intManufacturingCellId
		,C.strCellName
		,W.intWorkOrderId
		,@intScheduleId AS intScheduleId
		,W.strWorkOrderNo
		,W.dblQuantity
		,W.dtmExpectedDate
		,W.dblQuantity - W.dblProducedQuantity AS dblBalanceQuantity
		,W.dblProducedQuantity
		,W.strComment AS strWorkOrderComments
		,W.dtmOrderDate
		,(
			SELECT TOP 1 strItemNo
			FROM dbo.tblMFRecipeItem RI
			JOIN dbo.tblICItem WI ON RI.intItemId = WI.intItemId
			WHERE RI.intRecipeId = R.intRecipeId
				AND WI.strType = 'Blend'
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
	FROM tblMFWorkOrder W
	JOIN dbo.tblMFManufacturingCell C ON C.intManufacturingCellId = W.intManufacturingCellId AND W.intManufacturingCellId = @intManufacturingCellId
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	LEFT JOIN tblMFPackType P ON P.intPackTypeId = I.intPackTypeId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblMFWorkOrderProductionType PT ON PT.intProductionTypeId = W.intProductionTypeId
	LEFT JOIN @tblMFScheduleWorkOrder SL ON SL.intWorkOrderId = W.intWorkOrderId
		JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = SL.intStatusId
		AND W.intStatusId <> 13
	LEFT JOIN dbo.tblMFShift SH ON SH.intShiftId = SL.intPlannedShiftId
	JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
		AND R.intLocationId = C.intLocationId
		AND R.ysnActive = 1
	ORDER BY WS.intSequenceNo DESC
		,SL.intExecutionOrder

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
