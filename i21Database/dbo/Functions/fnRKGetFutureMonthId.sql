CREATE FUNCTION [dbo].[fnRKGetFutureMonthId]
(
	@FutureMarketId INT
	, @Year NVARCHAR(10)
	, @Month NVARCHAR(10)
)
RETURNS INT

AS

BEGIN

	DECLARE @FutureMonthId INT
	
	SElECT TOP 1 @FutureMonthId = intFutureMonthId
	FROM tblRKFuturesMonth
	WHERE intFutureMarketId = @FutureMarketId
		AND dtmFutureMonthsDate >= CONVERT(DATETIME,LTRIM(RTRIM(@Year))+'-'+REPLACE(@Month,' ','')+'-01')
	ORDER BY dtmFutureMonthsDate ASC

	RETURN @FutureMonthId
END