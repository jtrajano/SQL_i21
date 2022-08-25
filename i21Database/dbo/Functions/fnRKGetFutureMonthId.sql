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
			AND strFutureMonth = @FutureMonth COLLATE Latin1_General_CI_AS

	RETURN @FutureMonthId
END