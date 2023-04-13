CREATE FUNCTION [dbo].[fnSTGetCurrentBusinessDay] 
(
	@intStoreId AS INT
)
RETURNS DATETIME
AS BEGIN

    DECLARE			@dtmCurrentBusinessDay DATETIME

    SELECT			TOP 1 
	--@dtmCurrentBusinessDay =  ISNULL(DATEADD(DAY, 1, dtmCheckoutDate), GETDATE()) 
	@dtmCurrentBusinessDay =  ISNULL(dtmCheckoutDate, GETDATE())  
	FROM			tblSTCheckoutHeader
	WHERE			intStoreId = @intStoreId --AND strCheckoutStatus = 'Posted'
	ORDER BY		dtmCheckoutDate DESC

    RETURN			@dtmCurrentBusinessDay
END