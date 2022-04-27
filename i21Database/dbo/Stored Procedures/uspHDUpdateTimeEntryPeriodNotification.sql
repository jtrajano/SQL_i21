CREATE PROCEDURE [dbo].[uspHDUpdateTimeEntryPeriodNotification] (
	@TimeEntryPeriodNotificationId int

)
AS
BEGIN

	UPDATE tblHDTimeEntryPeriodNotification
	SET ysnSent = 1, dtmDateSent = GETDATE()
	WHERE intTimeEntryPeriodNotificationId = @TimeEntryPeriodNotificationId

END
GO