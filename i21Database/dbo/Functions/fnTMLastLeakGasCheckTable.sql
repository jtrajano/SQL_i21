CREATE FUNCTION [dbo].[fnTMLastLeakGasCheckTable](
	@intSiteId INT
)
RETURNS @tblTableReturn TABLE(
	dtmLastGasCheck DATETIME
	,dtmLastLeakCheck DATETIME
)
AS
BEGIN 
	DECLARE @dtmLastGasCheck DATETIME
	DECLARE @dtmLastLeakCheck DATETIME

	SET @dtmLastGasCheck = (SELECT TOP 1 dtmDate 
							FROM tblTMEvent 
							WHERE intSiteID = @intSiteId
								AND intEventTypeID = (SELECT TOP 1 intEventTypeID FROM tblTMEventType WHERE strEventType = 'Event-003')
							ORDER BY dtmDate DESC)

	SET @dtmLastLeakCheck = (SELECT TOP 1 dtmDate 
							FROM tblTMEvent 
							WHERE intSiteID = @intSiteId
								AND intEventTypeID = (SELECT TOP 1 intEventTypeID FROM tblTMEventType WHERE strEventType = 'Event-004')
							ORDER BY dtmDate DESC)

	INSERT INTO @tblTableReturn (dtmLastGasCheck, dtmLastLeakCheck)
	SELECT @dtmLastGasCheck, @dtmLastLeakCheck

	RETURN 

END	