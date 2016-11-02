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
	,strComments NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strNote NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strAdditionalComments NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
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
	,strWIPItemNo nvarchar(50) COLLATE Latin1_General_CI_AS
	,strPackName nvarchar(50) COLLATE Latin1_General_CI_AS
	,ysnPicked bit
	,intLocationId int
	,intDemandRatio int
	,dtmEarliestDate DATETIME
	,dtmLatestDate DATETIME
	,dtmTargetDate DATETIME
	,intTargetDateId int
	,intTargetPreferenceCellId INT
	,intFirstPreferenceCellId INT
	,intSecondPreferenceCellId INT
	,intThirdPreferenceCellId INT
	,intNoOfFlushes int
	,intScheduleId int
	,intNoOfOrgUnit INT
	,intRequiredDuration int
	,intAvailableDuration int
	,ysnUnableToSchedule bit
	,intCalendarDetailId int
	,intPickedWorkOrder int
)
