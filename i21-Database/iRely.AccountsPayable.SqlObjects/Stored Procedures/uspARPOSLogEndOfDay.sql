CREATE PROCEDURE [dbo].[uspARPOSLogEndOfDay]
	@intPOSLogId AS INT
AS
	IF(@intPOSLogId > 0)
	BEGIN
		UPDATE tblARPOSLog
		SET
			dtmLogout = GETDATE(),
			ysnLoggedIn = 0
		WHERE intPOSLogId = @intPOSLogId OR intPOSLogOriginId = @intPOSLogId
	END
	ELSE
	BEGIN
		RETURN;
	END

RETURN 0
