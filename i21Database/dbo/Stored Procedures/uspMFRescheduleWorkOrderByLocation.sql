CREATE PROCEDURE dbo.uspMFRescheduleWorkOrderByLocation (@strXML NVARCHAR(MAX),@ysnScheduleByManufacturingCell int=0
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@tblMFWorkOrder AS ScheduleTable
		,@idoc INT
		,@intLocationId INT
		,@dtmFromDate DATETIME
		,@dtmToDate DATETIME
		,@intUserId INT
		,@intManufacturingCellId int
		,@intScheduleId int
		,@ysnStandard bit
		,@intConcurrencyId int
		,@tblMFScheduleConstraint AS ScheduleConstraintTable
		,@intCalendarId int

	DECLARE @tblMFSequence TABLE (
		intWorkOrderId INT
		,intExecutionOrder INT
		,dtmTargetDate DATETIME
		,intNoOfFlushes int
		)
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

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intUserId = intUserId
		,@intLocationId = intLocationId
		,@dtmFromDate = dtmFromDate
		,@dtmToDate = dtmToDate
		,@intManufacturingCellId=intManufacturingCellId
		,@intScheduleId=intScheduleId
		,@ysnStandard=ysnStandard
		,@intCalendarId=intCalendarId
		,@intConcurrencyId=intConcurrencyId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intUserId INT
			,intLocationId INT
			,dtmFromDate DATETIME
			,dtmToDate DATETIME
			,intManufacturingCellId INT
			,intScheduleId int
			,ysnStandard bit
			,intConcurrencyId int
			,intCalendarId int
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
		,ysnPicked
		,intLocationId
		,intPackTypeId
		,intItemUOMId
		,intUnitMeasureId
		,intScheduleId
		,ysnFrozen
		,intNoOfSelectedMachine
		,intSetupDuration
		,strComments
		,strNote
		,strAdditionalComments
		,intNoOfFlushes
		,strWIPItemNo
		,dtmEarliestStartDate 
		)
	SELECT x.intManufacturingCellId
		,x.intWorkOrderId
		,x.intItemId
		,x.dblQuantity
		,x.dblBalance
		,ISNULL(x.dtmEarliestDate,W.dtmEarliestDate)
		,x.dtmExpectedDate
		,ISNULL(x.dtmLatestDate,W.dtmLatestDate)
		,x.dtmExpectedDate
		,2
		,x.intStatusId
		,x.intExecutionOrder
		,MC1.intManufacturingCellId AS intFirstPreferenceCellId
		,MC2.intManufacturingCellId AS intSecondPreferenceCellId
		,MC3.intManufacturingCellId AS intThirdPreferenceCellId
		,0
		,0
		,@intLocationId
		,x.intPackTypeId
		,x.intItemUOMId
		,x.intUnitMeasureId
		,x.intScheduleId
		,x.ysnFrozen
		,x.intNoOfSelectedMachine
		,x.intSetupDuration
		,x.strComments
		,x.strNote
		,x.strAdditionalComments
		,x.intNoOfFlushes
		,x.strWIPItemNo
		,x.dtmEarliestStartDate 
		FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
			intManufacturingCellId INT
			,intWorkOrderId INT
			,intScheduleId int
			,intItemId INT
			,intUnitMeasureId INT
			,intItemUOMId INT
			,dblQuantity NUMERIC(18, 6)
			,dblBalance NUMERIC(18, 6)
			,dtmEarliestDate DATETIME
			,dtmExpectedDate DATETIME
			,dtmLatestDate DATETIME
			,dtmTargetDate Datetime
			,intStatusId INT
			,intExecutionOrder INT
			,intPackTypeId INT
			,intScheduleWorkOrderId INT
			,ysnFrozen BIT
			,intSetupDuration INT
			,intNoOfSelectedMachine int
			,strComments NVARCHAR(MAX)
			,strNote NVARCHAR(MAX)
			,strAdditionalComments NVARCHAR(MAX)
			,intNoOfFlushes int
			,strWIPItemNo nvarchar(50)
			,dtmEarliestStartDate datetime
			) x
	JOIN dbo.tblMFWorkOrder W on W.intWorkOrderId =x.intWorkOrderId
	LEFT JOIN dbo.tblICItemFactory F1 ON F1.intFactoryId = @intLocationId
		AND F1.intItemId = x.intItemId
	LEFT JOIN dbo.tblICItemFactoryManufacturingCell MC1 ON MC1.intItemFactoryId = F1.intItemFactoryId
		AND MC1.intPreference = 1
	LEFT JOIN dbo.tblICItemFactory F2 ON F2.intFactoryId = @intLocationId
		AND F2.intItemId = x.intItemId
	LEFT JOIN dbo.tblICItemFactoryManufacturingCell MC2 ON MC2.intItemFactoryId = F2.intItemFactoryId
		AND MC2.intPreference = 2
	LEFT JOIN dbo.tblICItemFactory F3 ON F3.intFactoryId = @intLocationId
		AND F3.intItemId = x.intItemId
	LEFT JOIN dbo.tblICItemFactoryManufacturingCell MC3 ON MC3.intItemFactoryId = F3.intItemFactoryId
		AND MC3.intPreference = 3
	ORDER BY x.intManufacturingCellId
		,x.dtmExpectedDate
		,x.intItemId
IF @strScheduleType = 'Backward Schedule'
	BEGIN

	INSERT INTO @tblMFSequence
	EXEC dbo.uspMFCheckContamination @tblMFWorkOrder
		,@intLocationId

	UPDATE W
	SET W.intExecutionOrder = S.intExecutionOrder
		,W.dtmTargetDate = S.dtmTargetDate
		,W.intNoOfFlushes=S.intNoOfFlushes
	FROM @tblMFWorkOrder W
	JOIN @tblMFSequence S ON S.intWorkOrderId = W.intWorkOrderId

	IF @ysnScheduleByManufacturingCell = 1
	BEGIN
		INSERT INTO @tblMFScheduleConstraint(intScheduleRuleId,intPriorityNo)
		SELECT intScheduleRuleId,intPriorityNo
		FROM OPENXML(@idoc, 'root/ScheduleRules/ScheduleRule', 2) WITH (
				intScheduleRuleId INT
				,intPriorityNo int
				,ysnSelect bit
				)
		WHERE ysnSelect=1
		ORDER BY intPriorityNo
	END
	ELSE
	BEGIN
		INSERT INTO @tblMFScheduleConstraint (
			intScheduleRuleId
			,intPriorityNo
			)
		SELECT intScheduleRuleId
			,intPriorityNo
		FROM tblMFScheduleRule
		WHERE ysnActive = 1
		ORDER BY intPriorityNo
	END

	EXEC dbo.uspMFRescheduleAndSaveWorkOrder @tblMFWorkOrder = @tblMFWorkOrder
		,@dtmFromDate = @dtmFromDate
		,@dtmToDate = @dtmToDate
		,@intUserId = @intUserId
		,@intChartManufacturingCellId=@intManufacturingCellId
		,@ysnScheduleByManufacturingCell=@ysnScheduleByManufacturingCell
		,@intScheduleId=@intScheduleId
		,@ysnStandard = @ysnStandard
		,@intConcurrencyId = @intConcurrencyId
		,@tblMFScheduleConstraint=@tblMFScheduleConstraint
		,@intCalendarId=@intCalendarId
			End
	Else
	Begin
	INSERT INTO @tblMFScheduleConstraint (
			intScheduleRuleId
			,intPriorityNo
			)
		SELECT intScheduleRuleId
			,intPriorityNo
		FROM tblMFScheduleRule
		WHERE ysnActive = 1
		ORDER BY intPriorityNo

		EXEC dbo.uspMFRescheduleAndSaveWorkOrderByForward 
			@tblMFWorkOrder
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
	End
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

