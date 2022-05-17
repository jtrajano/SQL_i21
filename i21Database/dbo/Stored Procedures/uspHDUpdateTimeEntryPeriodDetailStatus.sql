CREATE PROCEDURE [dbo].[uspHDUpdateTimeEntryPeriodDetailStatus]
AS
BEGIN
	UPDATE tblHDTimeEntryPeriodDetail
	SET strBillingPeriodStatus = 'Closed'
	WHERE dtmBillingPeriodStart <= GETDATE() AND
		  dtmBillingPeriodEnd >= GETDATE()
END
GO