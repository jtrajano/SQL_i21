CREATE FUNCTION [dbo].fnTMGetNextJulianDeliveryDate
(
	@intSiteId INT
)
RETURNS DATETIME AS
BEGIN
	DECLARE @dtmLastDeliveryDate DATETIME
	DECLARE @dtmNextDeliveryDate DATETIME
	
	----GET Site info
	SELECT @dtmLastDeliveryDate = dtmLastDeliveryDate
	FROM tblTMSite
	WHERE intSiteID = @intSiteId
	
	
	SELECT TOP 1 @dtmNextDeliveryDate = dtmStartDate
	FROM tblTMSiteJulianCalendar
	WHERE intSiteID = @intSiteId
		AND ((dtmEndDate > @dtmLastDeliveryDate AND dtmStartDate <= @dtmLastDeliveryDate)
			  OR (	ysnAutoRenew = 1 
					AND CAST((CAST(MONTH(dtmEndDate) AS NVARCHAR(2)) + REPLACE(STR(DAY(dtmEndDate), 2), SPACE(1), '0')) AS INT) > CAST((CAST(MONTH(@dtmLastDeliveryDate) AS NVARCHAR(2)) + REPLACE(STR(DAY(@dtmLastDeliveryDate), 2), SPACE(1), '0')) AS INT)
					AND CAST((CAST(MONTH(dtmStartDate) AS NVARCHAR(2)) + REPLACE(STR(DAY(dtmStartDate), 2), SPACE(1), '0')) AS INT) < CAST((CAST(MONTH(@dtmLastDeliveryDate) AS NVARCHAR(2)) + REPLACE(STR(DAY(@dtmLastDeliveryDate), 2), SPACE(1), '0')) AS INT)
				))
	
	RETURN @dtmNextDeliveryDate
END
GO
