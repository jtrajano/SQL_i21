CREATE FUNCTION [dbo].[fnFACalendarDatesWithQuarter] 
(
	@dtmPlacedInService DATETIME,
	@ysnUseFiscalPeriod BIT = 0
)

RETURNS @tblCalendarWithQuarter TABLE (
	intRowId INT,
	intFiscalYearId INT,
	intFiscalYearPeriodId INT,
	strFiscalYear NVARCHAR(50),
	dtmStartDate DATETIME,
	dtmEndDate DATETIME,
	dtmFiscalYearStartDate DATETIME,
	dtmFiscalYearEndDate DATETIME,
	intQuarter INT
)
AS
BEGIN

DECLARE
	@intCounter INT = 0,
	@intRow INT = 0,
	@intQuarter INT = 1

IF (ISNULL(@ysnUseFiscalPeriod, 0) = 1) -- Base the Quarters from the Fiscal Period
BEGIN
	DECLARE @tbl TABLE (
		intRowId INT,
		intFiscalYearId INT,
		intFiscalYearPeriodId INT,
		strFiscalYear NVARCHAR(50),
		dtmStartDate DATETIME,
		dtmEndDate DATETIME,
		dtmFiscalYearStartDate DATETIME,
		dtmFiscalYearEndDate DATETIME,
		ysnProcessed BIT NULL DEFAULT(0)
	)
	DECLARE
		@intFiscalYearId INT

	-- Get the FiscalYearPeriod that the PlacedInService date falls into
	SELECT @intFiscalYearId = intFiscalYearId FROM tblGLFiscalYearPeriod
	WHERE @dtmPlacedInService BETWEEN dtmStartDate AND dtmEndDate

	INSERT INTO @tbl
		SELECT 
			ROW_NUMBER() OVER(ORDER BY FYP.dtmStartDate),
			FY.intFiscalYearId, 
			FYP.intGLFiscalYearPeriodId, 
			FY.strFiscalYear, 
			FYP.dtmStartDate, 
			FYP.dtmEndDate, 
			FY.dtmDateFrom, 
			FY.dtmDateTo, 0
		FROM tblGLFiscalYearPeriod FYP
		JOIN tblGLFiscalYear FY ON FY.intFiscalYearId = FYP.intFiscalYearId
		WHERE FYP.intFiscalYearId = @intFiscalYearId

	WHILE EXISTS(SELECT TOP 1 1 FROM @tbl WHERE ysnProcessed = 0)
	BEGIN
		SELECT TOP 1 @intRow = intRowId FROM @tbl WHERE ysnProcessed = 0 ORDER BY dtmStartDate
	
		IF (@intCounter = 3) -- 3 months per quarter
		BEGIN
			SET @intCounter = 0
			SET @intQuarter += 1
		END

		SET @intCounter += 1

		INSERT INTO @tblCalendarWithQuarter
		SELECT intRowId, intFiscalYearId, intFiscalYearPeriodId, strFiscalYear, dtmStartDate, dtmEndDate, dtmFiscalYearStartDate, dtmFiscalYearEndDate, @intQuarter FROM @tbl WHERE intRowId = @intRow

		UPDATE @tbl SET ysnProcessed = 1 WHERE intRowId = @intRow
	END
END
ELSE -- Base the Quarters from the default calendar period. Used in Tax Depreciation.
BEGIN
	DECLARE 
		@strYear NVARCHAR(50), 
		@dtmFiscalStartDate DATETIME, 
		@dtmFiscalEndDate DATETIME, 
		@intQuarterCounter INT = 0

	SET @strYear = YEAR(@dtmPlacedInService)
 
	WHILE @intRow < 12
	BEGIN
		DECLARE 
			@dtmStartDate DATETIME,
			@dtmEndDate	DATETIME

		SET @intRow += 1
		SET @dtmStartDate = CAST((CAST(@strYear AS NVARCHAR) + '-' + @intRow + '-01') AS DATETIME)
		SET @dtmEndDate = CAST((CAST(EOMONTH(@dtmStartDate) AS NVARCHAR) + ' 23:59:59.000') AS DATETIME)

		IF (@intRow = 1)
			SET @dtmFiscalStartDate = @dtmStartDate
		IF (@intRow = 12)
			SET @dtmFiscalEndDate = @dtmEndDate

		IF (@intQuarterCounter = 3) -- 3 months per quarter
		BEGIN
			SET @intQuarterCounter = 0
			SET @intQuarter += 1
		END

		SET @intQuarterCounter += 1

		INSERT INTO @tblCalendarWithQuarter(intRowId, strFiscalYear, dtmStartDate, dtmEndDate, intQuarter) 
		VALUES (
			@intRow, 
			@strYear,
			@dtmStartDate, 
			@dtmEndDate,
			@intQuarter
		)
	END

	 UPDATE @tblCalendarWithQuarter SET dtmFiscalYearStartDate = @dtmFiscalStartDate, dtmFiscalYearEndDate = @dtmFiscalEndDate
END

RETURN
END