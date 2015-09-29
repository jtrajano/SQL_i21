CREATE TYPE [dbo].[ScheduleTable] AS TABLE
(
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
	,intNoOfUnit INT
	,dblConversionFactor NUMERIC(18, 6)
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
	,strWIPItemNo nvarchar(50)
	,strPackName nvarchar(50)
)
