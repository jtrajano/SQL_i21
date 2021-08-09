CREATE VIEW [dbo].[vyuApiSubscriptionHealthStatus]
AS
SELECT DISTINCT 
	u.guiSubscriptionId, u.strName, 
	MAX(u.dtmDateLastUpdated) dtmDateLastUpdated,
	DATEDIFF(DAY, MAX(u.dtmDateLastUpdated), GETUTCDATE()) intDaysSinceLastReported
FROM tblApiMonthlyRequestUsage u
GROUP BY u.guiSubscriptionId, u.strName