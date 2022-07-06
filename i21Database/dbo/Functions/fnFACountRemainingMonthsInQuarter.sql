CREATE FUNCTION [dbo].[fnFACountRemainingMonthsInQuarter]
(
	@dtmPlacedInService DATETIME,
	@ysnUseFiscalPeriod BIT = 0
)
RETURNS INT 
AS
BEGIN
	DECLARE
		@intRemainingMonths INT

	-- Get the quarter that the PlacedInService date falls into.
	-- Count the remaining months within that quarter from the PlacedInService month falls into.
	SELECT @intRemainingMonths = COUNT(1) + 1 FROM dbo.fnFACalendarDatesWithQuarter(@dtmPlacedInService, @ysnUseFiscalPeriod) FQ
	OUTER APPLY (
		SELECT TOP 1 dtmStartDate, dtmEndDate, intQuarter FROM dbo.fnFACalendarDatesWithQuarter(@dtmPlacedInService, @ysnUseFiscalPeriod) WHERE @dtmPlacedInService BETWEEN dtmStartDate AND dtmEndDate
	) CurrentQuarter

	WHERE FQ.dtmStartDate > CurrentQuarter.dtmStartDate AND FQ.intQuarter = CurrentQuarter.intQuarter

	RETURN @intRemainingMonths
END
