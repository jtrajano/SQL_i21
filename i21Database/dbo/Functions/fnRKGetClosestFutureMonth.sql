CREATE FUNCTION [dbo].[fnRKGetClosestFutureMonth]
(
	@FutureMarketId INT
	,@Year NVARCHAR(10)
	,@Month NVARCHAR(10)
)
RETURNS INT

AS

BEGIN

	DECLARE @FutureMonth INT
	
	SELECT TOP 1 @FutureMonth = DATEPART(mm,dtmFutureMonthsDate) FROM tblRKFuturesMonth 
	WHERE intFutureMarketId = @FutureMarketId
		AND DATEPART(mm,dtmFutureMonthsDate) >= @Month
	ORDER BY DATEPART(mm,dtmFutureMonthsDate) ASC

	IF(ISNULL(@FutureMonth, 0) = 0)
	BEGIN
		SELECT TOP 1 @FutureMonth = DATEPART(mm,dtmFutureMonthsDate) FROM tblRKFuturesMonth 
		WHERE intFutureMarketId = @FutureMarketId
			AND DATEPART(mm,dtmFutureMonthsDate) <= @Month
		ORDER BY DATEPART(mm,dtmFutureMonthsDate) DESC
	END

	RETURN @FutureMonth
END
