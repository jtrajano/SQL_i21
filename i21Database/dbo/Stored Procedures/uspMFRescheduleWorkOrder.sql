CREATE PROCEDURE uspMFRescheduleWorkOrder (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @strScheduleType NVARCHAR(50)
		,@intAttributeId INT
		,@strAttributeValue NVARCHAR(50)
		,@intBlendAttributeId INT
		,@strBlendAttributeValue NVARCHAR(50)

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Schedule Type'

	SELECT @strScheduleType = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intAttributeId = @intAttributeId

	IF @strScheduleType IS NULL
		OR @strScheduleType = ''
	BEGIN
		SELECT @strScheduleType = strScheduleType
		FROM dbo.tblMFCompanyPreference
	END

	IF @strScheduleType = 'Backward Schedule'
	BEGIN
		EXEC dbo.uspMFRescheduleWorkOrderByLocation @strXML = @strXML
			,@ysnScheduleByManufacturingCell = 1

		RETURN
	END

	DECLARE @idoc INT
	,@ErrMsg NVARCHAR(MAX)
		,@intManufacturingCellId INT

		,@intCalendarId INT
		,@intScheduleId INT
		,@intConcurrencyId INT
		,@dtmCurrentDateTime DATETIME
		,@dtmCurrentDate DATETIME
		,@intUserId INT
		,@intLocationId INT
		,@ysnStandard BIT
		,@dtmFromDate DATETIME
		,@dtmToDate DATETIME
		,@tblMFScheduleWorkOrder AS ScheduleTable
		,@tblMFScheduleConstraint AS ScheduleConstraintTable


	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

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
		,@intCalendarId = intCalendarId
		,@intScheduleId = Isnull(intScheduleId, 0)
		,@intConcurrencyId = intConcurrencyId
		,@intUserId = intUserId
		,@intLocationId = intLocationId
		,@ysnStandard = ysnStandard
		,@dtmFromDate = dtmFromDate
		,@dtmToDate = dtmToDate
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intManufacturingCellId INT
			,intCalendarId INT
			,intScheduleId INT
			,intConcurrencyId INT
			,intUserId INT
			,intLocationId INT
			,ysnStandard BIT
			,dtmFromDate DATETIME
			,dtmToDate DATETIME
			)

	INSERT INTO @tblMFScheduleWorkOrder (
		intManufacturingCellId
		,intWorkOrderId
		,intItemId
		,intItemUOMId
		,intUnitMeasureId
		,dblQuantity
		,dblBalance
		,dtmEarliestDate
		,dtmExpectedDate
		,dtmLatestDate
		,intStatusId
		,intExecutionOrder
		,strComments
		,strNote
		,strAdditionalComments
		,intNoOfSelectedMachine
		,dtmEarliestStartDate
		,intPackTypeId
		,strPackName
		,intNoOfUnit
		,dblConversionFactor
		,intScheduleWorkOrderId
		,ysnFrozen
		,intConcurrencyId
		,strWIPItemNo
		,intSetupDuration
		,ysnPicked
		,intDemandRatio
		,intNoOfFlushes
		)
	SELECT x.intManufacturingCellId
		,x.intWorkOrderId
		,x.intItemId
		,x.intItemUOMId
		,x.intUnitMeasureId
		,x.dblQuantity
		,x.dblBalance
		,x.dtmEarliestDate
		,x.dtmExpectedDate
		,x.dtmLatestDate
		,x.intStatusId
		,x.intExecutionOrder
		,x.strComments
		,CASE 
			WHEN @dtmCurrentDate > x.dtmExpectedDate
				THEN 'Past Expected Date'
			END strNote
		,x.strAdditionalComments
		,x.intNoOfSelectedMachine
		,x.dtmEarliestStartDate
		,MC.intPackTypeId
		,P.strPackName
		,x.dblBalance * PTD.dblConversionFactor
		,PTD.dblConversionFactor
		,x.intScheduleWorkOrderId
		,x.ysnFrozen
		,@intConcurrencyId
		,x.strWIPItemNo
		,x.intSetupDuration
		,0 AS ysnPicked
		,x.intDemandRatio
		,x.intNoOfFlushes
	FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
			intManufacturingCellId INT
			,intWorkOrderId INT
			,intItemId INT
			,intUnitMeasureId INT
			,intItemUOMId INT
			,dblQuantity NUMERIC(18, 6)
			,dblBalance NUMERIC(18, 6)
			,dtmEarliestDate DATETIME
			,dtmExpectedDate DATETIME
			,dtmLatestDate DATETIME
			,intStatusId INT
			,intExecutionOrder INT
			,strComments NVARCHAR(MAX)
			,strNote NVARCHAR(MAX)
			,strAdditionalComments NVARCHAR(MAX)
			,intNoOfSelectedMachine INT
			,dtmEarliestStartDate DATETIME
			,intPackTypeId INT
			,intScheduleWorkOrderId INT
			,ysnFrozen BIT
			,strWIPItemNo NVARCHAR(50)
			,intSetupDuration INT
			,intDemandRatio INT
			,intNoOfFlushes INT
			) x
	LEFT JOIN dbo.tblMFManufacturingCellPackType MC ON MC.intManufacturingCellId = x.intManufacturingCellId
		AND MC.intPackTypeId = x.intPackTypeId
	LEFT JOIN tblMFPackType P ON P.intPackTypeId = x.intPackTypeId
	LEFT JOIN dbo.tblMFPackTypeDetail PTD ON PTD.intPackTypeId = x.intPackTypeId
		AND PTD.intTargetUnitMeasureId = x.intUnitMeasureId
		AND PTD.intSourceUnitMeasureId = MC.intLineCapacityUnitMeasureId
	ORDER BY x.intExecutionOrder

	EXEC dbo.uspMFRescheduleAndSaveWorkOrderByForward 
			@tblMFScheduleWorkOrder
			,@intManufacturingCellId 
			,@intCalendarId 
			,@intScheduleId 
			,@intConcurrencyId 
			,@intUserId 
			,@intLocationId 
			,@ysnStandard 
			,@dtmFromDate 
			,@dtmToDate 
			,@tblMFScheduleConstraint
			,0
			,1

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
