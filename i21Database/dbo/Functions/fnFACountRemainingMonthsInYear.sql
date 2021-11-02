CREATE FUNCTION [dbo].[fnFACountRemainingMonthsInYear]
(
	@dtmInputDate DATETIME,
	@ysnUseFiscalPeriod BIT = 0
)
RETURNS INT
AS
BEGIN
	DECLARE 
		@intRemainingMonths INT

	IF (ISNULL(@ysnUseFiscalPeriod, 0) = 1)
	BEGIN
		DECLARE 
			@dtmDate DATETIME,
			@intFiscalYearId INT

		SELECT @dtmDate = dtmEndDate, @intFiscalYearId = intFiscalYearId FROM tblGLFiscalYearPeriod WHERE @dtmInputDate BETWEEN dtmStartDate AND dtmEndDate
		SELECT @intRemainingMonths = COUNT(1) FROM tblGLFiscalYearPeriod WHERE intFiscalYearId = @intFiscalYearId AND dtmEndDate >= @dtmDate

	END
	ELSE
	BEGIN
		DECLARE @tblCalendar TABLE (
			intRowId INT,
			dtmStartDate DATETIME,
			dtmEndDate DATETIME
		)

		DECLARE
			@intCounter INT = 0,
			@strYear NVARCHAR(50)
	
		SET @strYear = YEAR(@dtmInputDate)

		WHILE @intCounter < 12
		BEGIN
			DECLARE
				@dtmCurrentEndDate DATETIME,
				@dtmStartDate DATETIME,
				@dtmEndDate	DATETIME

			SET @intCounter += 1
			SET @dtmStartDate = CAST((CAST(@strYear AS NVARCHAR) + '-' + @intCounter + '-01') AS DATETIME)
			SET @dtmEndDate =  CAST((CAST(EOMONTH(@dtmStartDate) AS NVARCHAR) + ' 23:59:59.000') AS DATETIME)

			INSERT INTO @tblCalendar VALUES (@intCounter, @dtmStartDate, @dtmEndDate)
		END

		SELECT @dtmCurrentEndDate = dtmEndDate FROM @tblCalendar WHERE @dtmInputDate BETWEEN dtmStartDate AND dtmEndDate
		SELECT @intRemainingMonths = COUNT(1) FROM @tblCalendar WHERE dtmEndDate >= @dtmCurrentEndDate
	END

	RETURN ISNULL(@intRemainingMonths, 0)
END