CREATE FUNCTION [dbo].[fnFAGetPreviousMonthPeriodEndDateFromDate]
(
	@dtmInputDate DATETIME,
	@ysnUseFiscalPeriod BIT = 0
)
RETURNS DATETIME
AS
BEGIN
	DECLARE 
		@dtmDate DATETIME

	IF (ISNULL(@ysnUseFiscalPeriod, 0) = 1)
		SELECT TOP 1 @dtmDate = CONVERT(DATE, dtmEndDate) FROM tblGLFiscalYearPeriod WHERE @dtmInputDate > CONVERT(DATE, dtmEndDate) ORDER BY dtmEndDate DESC
	ELSE
		SET @dtmDate = CAST(CEILING(CAST( DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, (DATEADD(m, -1, @dtmInputDate))) + 1, 0)) AS FLOAT)) AS DATETIME)

	RETURN @dtmDate
END