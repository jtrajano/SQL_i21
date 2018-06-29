CREATE FUNCTION [dbo].[fnCTGetLastSettlementPrice]
(
	@intFutureMarketId	INT,
	@intFuturesMonthId	INT

)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	DECLARE	@dblLastSettle AS NUMERIC(18,6)

	SELECT		TOP 1 @dblLastSettle = MP.dblLastSettle 
	FROM		tblRKFutSettlementPriceMarketMap MP
	JOIN		(	
					SELECT		TOP 1 * 
					FROM		tblRKFuturesSettlementPrice SP
					WHERE		SP.intFutureMarketId = @intFutureMarketId
					ORDER BY	SP.dtmPriceDate DESC
				)SP ON MP.intFutureSettlementPriceId = SP.intFutureSettlementPriceId
	WHERE		intFutureMonthId = @intFuturesMonthId
	ORDER BY	MP.intFutSettlementPriceMonthId DESC

	RETURN @dblLastSettle;	
END