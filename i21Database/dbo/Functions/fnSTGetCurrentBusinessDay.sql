CREATE FUNCTION [dbo].[fnSTGetCurrentBusinessDay] 
(
	@intStoreId AS INT
)
RETURNS DATETIME
AS BEGIN
	DECLARE			@intCheckoutId			INT
	DECLARE			@dtmCurrentDate			DATETIME
	DECLARE			@dtmCurrentBusinessDay	DATETIME
	DECLARE			@strEoDStatus			VARCHAR(50)

	SELECT DISTINCT TOP 1 
	@intCheckoutId = intCheckoutId,
	@dtmCurrentDate = dtmCheckoutDate,
	@strEoDStatus = strCheckoutStatus
	FROM tblSTCheckoutHeader 
	WHERE intStoreId = @intStoreId 
	ORDER BY intCheckoutId DESC

	SELECT DISTINCT TOP 1
	@dtmCurrentBusinessDay = (CASE WHEN FORMAT(@dtmCurrentDate, 'd','us') = FORMAT(GETDATE(), 'd','us') AND @strEoDStatus = 'Posted' 
									THEN GETDATE()
								WHEN FORMAT(@dtmCurrentDate, 'd','us') = FORMAT(GETDATE(), 'd','us') AND @strEoDStatus <> 'Posted' 
									THEN (SELECT TOP 1 dtmCheckoutDate FROM tblSTCheckoutHeader WHERE intStoreId = @intStoreId ORDER BY intCheckoutId DESC)
								WHEN FORMAT(@dtmCurrentDate, 'd','us') <> FORMAT(GETDATE(), 'd','us') AND @strEoDStatus = 'Posted' 
									THEN (SELECT TOP 1 DATEADD(DAY, 1, dtmCheckoutDate) FROM tblSTCheckoutHeader WHERE intStoreId = @intStoreId AND strCheckoutStatus = 'Posted' ORDER BY intCheckoutId DESC)
								WHEN FORMAT(@dtmCurrentDate, 'd','us') <> FORMAT(GETDATE(), 'd','us') AND @strEoDStatus <> 'Posted' 
									THEN (SELECT TOP 1 dtmCheckoutDate FROM tblSTCheckoutHeader WHERE intStoreId = @intStoreId AND strCheckoutStatus <> 'Posted' ORDER BY intCheckoutId DESC)
							END)

	RETURN @dtmCurrentBusinessDay
END