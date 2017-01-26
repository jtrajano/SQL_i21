CREATE FUNCTION [dbo].[fnTMGetSeasonYear]
(
	@dtmDate DATETIME
	,@intClockId INT
)
RETURNS @tblReturnValue TABLE(
	intSeasonYear INT
)

BEGIN
	DECLARE @intSeasonYear INT

	IF EXISTS(SELECT TOP 1 1 FROM tblTMDegreeDayReading WHERE dtmDate <= @dtmDate AND intClockID = @intClockId AND ysnSeasonStart = 1)
	BEGIN
		INSERT INTO @tblReturnValue (intSeasonYear) 
		SELECT TOP 1 YEAR(dtmDate) 
		FROM tblTMDegreeDayReading 
		WHERE dtmDate <= @dtmDate 
			AND intClockID = @intClockId 
			AND ysnSeasonStart = 1
		ORDER BY dtmDate DESC
	END
	ELSE
	BEGIN
		IF NOT EXISTS( SELECT TOP 1 1 FROM tblTMDegreeDayReading WHERE dtmDate < @dtmDate AND intClockID = @intClockId )
		BEGIN
			INSERT INTO @tblReturnValue (intSeasonYear) 
			SELECT YEAR(@dtmDate)
		END
		ELSE
		BEGIN
			INSERT INTO @tblReturnValue (intSeasonYear) 
			SELECT TOP 1 YEAR(dtmDate) 
			FROM tblTMDegreeDayReading 
			WHERE dtmDate < @dtmDate AND intClockID = @intClockId
			ORDER BY dtmDate ASC
		END
	END

	RETURN
END

GO