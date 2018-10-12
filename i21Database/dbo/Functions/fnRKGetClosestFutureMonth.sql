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
	
	SELECT TOP 1 @FutureMonth = DATEPART(mm,dtmFutureMonthsDate)
	FROM tblRKFuturesMonth
	WHERE intFutureMarketId = @FutureMarketId
		AND dtmFutureMonthsDate >= CONVERT(DATETIME,LTRIM(RTRIM(@Year))+'-'+REPLACE(@Month,' ','')+'-01')
	ORDER BY 
		ABS (DATEPART(mm,dtmFutureMonthsDate) - DATEPART(mm, CONVERT(DATETIME,LTRIM(RTRIM(@Year))+'-'+REPLACE(@Month,' ','')+'-01'))) ASC
		,intYear ASC
	RETURN @FutureMonth
END
