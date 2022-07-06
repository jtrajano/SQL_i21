CREATE FUNCTION [dbo].[fnFAGetMonthPeriodFromDate]
(
	@dtmInputDate DATETIME,
	@ysnUseFiscalPeriod BIT = 0
)
RETURNS @tblMonthPeriod TABLE(
	dtmStartDate DATETIME,
	dtmEndDate DATETIME,
	intDays INT
)
AS
BEGIN
	DECLARE @tbl TABLE(
		dtmStartDate DATETIME,
		dtmEndDate DATETIME,
		intDays INT
	)

	IF(ISNULL(@ysnUseFiscalPeriod, 0) = 1)
	BEGIN
		INSERT INTO @tblMonthPeriod
		SELECT 
			CONVERT(DATE, dtmStartDate),
			CONVERT(DATE, dtmEndDate),
			DATEDIFF(DAY, dtmStartDate, dtmEndDate) + 1
		FROM tblGLFiscalYearPeriod WHERE @dtmInputDate BETWEEN dtmStartDate AND dtmEndDate
	END
	ELSE
	BEGIN
		INSERT INTO @tblMonthPeriod
		SELECT 
			DATEADD(mm, DATEDIFF(mm, 0, @dtmInputDate), 0), -- first day of input date's month
			DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @dtmInputDate) + 1, 0)), -- last day of input date's month
			DATEDIFF(DAY, DATEADD(mm, DATEDIFF(mm, 0, @dtmInputDate), 0), DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @dtmInputDate) + 1, 0))) + 1 -- total number of days within the month
	END

	INSERT INTO @tblMonthPeriod SELECT * FROM @tbl

	RETURN
END