CREATE FUNCTION [dbo].[fnRKGetFutureMonthId]
(
	@FutureMarketId INT
	,@FutureMonth NVARCHAR(10)
)
RETURNS INT

AS

BEGIN
	DECLARE @FutureMonthId INT
	
	SELECT TOP 1 @FutureMonthId = intFutureMonthId
	FROM tblRKFuturesMonth
	WHERE intFutureMarketId = @FutureMarketId
			AND strFutureMonth = @FutureMonth

	RETURN @FutureMonthId
END