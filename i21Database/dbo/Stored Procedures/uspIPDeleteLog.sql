CREATE PROCEDURE dbo.uspIPDeleteLog (@intNoOfDay INT = 13)
AS
BEGIN
	DECLARE @dtmDate DATETIME

	SELECT @dtmDate = CONVERT(VARCHAR(10), GETDATE() - @intNoOfDay, 126) + ' 00:00:00'

	DELETE
	FROM tblIPLog
	WHERE dtmDate < @dtmDate
END

