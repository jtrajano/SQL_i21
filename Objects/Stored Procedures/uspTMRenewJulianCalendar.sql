
CREATE PROCEDURE [dbo].[uspTMRenewJulianCalendar]
	 @intSiteId	INT = NULL
AS
BEGIN
	IF(@intSiteId IS NULL)
	BEGIN
		---Mass Renew Here
		SELECT * FROM tblTMSiteJulianCalendar WHERE ysnAutoRenew = 1
	END
	ELSE
	BEGIN
		---Specific Renew Here
		SELECT * 
		FROM tblTMSiteJulianCalendar 
		WHERE ysnAutoRenew = 1
			AND intSiteID = @intSiteId
	END
	
END
GO