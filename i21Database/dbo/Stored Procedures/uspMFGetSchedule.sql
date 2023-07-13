CREATE PROCEDURE [dbo].[uspMFGetSchedule] 
(
	@intManufacturingCellId INT
  , @intScheduleId INT
  , @intCalendarId INT
  , @dtmFromDate DATETIME = NULL
  , @dtmToDate DATETIME = NULL
)
AS

DECLARE @dtmCurrentDate		DATETIME
	  , @intLocationId		INT
	  , @strCellName		NVARCHAR(50)
	  , @strName			NVARCHAR(50)
	  , @intMachineId		INT

SELECT @dtmCurrentDate = GETDATE();

SELECT @intLocationId = intLocationId
FROM dbo.tblMFManufacturingCell
WHERE intManufacturingCellId = @intManufacturingCellId

IF @dtmFromDate IS NULL
	BEGIN
		SELECT @dtmFromDate = @dtmCurrentDate

		SELECT @dtmToDate = @dtmFromDate + intDefaultGanttChartViewDuration
		FROM tblMFCompanyPreference
	END

IF @intScheduleId > 0
	BEGIN
		SELECT S.intScheduleId
			 , S.strScheduleNo
			 , S.dtmScheduleDate
			 , S.intCalendarId
			 , SC.strName
			 , S.intManufacturingCellId
			 , MC.strCellName
			 , S.ysnStandard
			 , S.intLocationId
			 , S.intConcurrencyId
			 , S.dtmCreated
			 , S.intCreatedUserId
			 , S.dtmLastModified
			 , S.intLastModifiedUserId
			 , @dtmFromDate AS dtmFromDate
			 , @dtmToDate AS dtmToDate
		FROM dbo.tblMFSchedule S
		JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = S.intManufacturingCellId
		JOIN dbo.tblMFScheduleCalendar SC ON SC.intCalendarId = S.intCalendarId
		WHERE intScheduleId = @intScheduleId
	END
ELSE
	BEGIN
		IF @intManufacturingCellId IS NOT NULL
			BEGIN
				SELECT @strCellName = strCellName
				FROM tblMFManufacturingCell
				WHERE intManufacturingCellId = @intManufacturingCellId
			END

		IF @intCalendarId IS NOT NULL
			BEGIN
				SELECT @strName = strName
				FROM tblMFScheduleCalendar
				WHERE intCalendarId = @intCalendarId
			END

		SELECT 0						AS intScheduleId
			 , ''						AS strScheduleNo
			 , @dtmCurrentDate			AS dtmScheduleDate
			 , @intCalendarId			AS intCalendarId
			 , @strName					AS strName
			 , @intManufacturingCellId	AS intManufacturingCellId
			 , @strCellName				AS strCellName
			 , CONVERT(BIT, 0)			AS ysnStandard
			 , 0						AS intLocationId
			 , 0						AS intConcurrencyId
			 , @dtmCurrentDate			AS dtmCreated
			 , 0						AS intCreatedUserId
			 , @dtmCurrentDate			AS dtmLastModified
			 , 0						AS intLastModifiedUserId
			 , @dtmFromDate				AS dtmFromDate
			 , @dtmToDate				AS dtmToDate
	END
