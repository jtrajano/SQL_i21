CREATE FUNCTION [dbo].[fnSTGetCurrentBusinessDay] 
(
	@intStoreId AS INT
)
RETURNS DATETIME
AS BEGIN

	DECLARE			@dtmCurrentDate DATETIME
    DECLARE			@dtmCurrentBusinessDay DATETIME

	SET	@dtmCurrentDate  = CONVERT(date, DATEADD(DAY, -1, GETDATE()))

    SELECT			TOP 1 
					@dtmCurrentBusinessDay = CASE
												WHEN @dtmCurrentDate = ISNULL(dtmCheckoutDate, GETDATE()) AND strCheckoutStatus = 'Posted'
												THEN ISNULL(dtmCheckoutDate, GETDATE()) 
												WHEN @dtmCurrentDate != ISNULL(dtmCheckoutDate, GETDATE()) AND strCheckoutStatus = 'Posted'
												THEN ISNULL(DATEADD(DAY, 1,dtmCheckoutDate), GETDATE())
												WHEN @dtmCurrentDate != ISNULL(dtmCheckoutDate, GETDATE()) AND strCheckoutStatus != 'Posted'
												THEN ISNULL(dtmCheckoutDate, GETDATE())
												ELSE GETDATE()
												END
	FROM			tblSTCheckoutHeader
	WHERE			intStoreId = @intStoreId
	ORDER BY		dtmCheckoutDate DESC

    RETURN			@dtmCurrentBusinessDay
END