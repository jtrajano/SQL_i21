CREATE Function dbo.fnRKGetLatestClosingPrice
(@intFutureMarketId int,@intFutureMonthId int,@ClosingDate datetime)

RETURNS NUMERIC(18,6) AS  
BEGIN
DECLARE @result AS NUMERIC(18,6) 

	    DECLARE @Month nvarchar(10)
		DECLARE @Year nvarchar(10)
		DECLARE @FromDate datetime
		SET @Year= DATEPART(yy, @ClosingDate)
		SET @Month= DATEPART(MM, @ClosingDate)

		SELECT @FromDate= CONVERT(DATETIME,@Year+'-'+@Month+'-'+'01')
		SELECT  TOP 1 @result= dblLastSettle  FROM tblRKFuturesSettlementPrice p 
		JOIN tblRKFutSettlementPriceMarketMap pm  ON p.intFutureSettlementPriceId=pm.intFutureSettlementPriceId 
		WHERE p.intFutureMarketId=@intFutureMarketId and pm.intFutureMonthId=@intFutureMonthId 
		AND dtmPriceDate BETWEEN @FromDate AND @ClosingDate
		ORDER BY dtmPriceDate DESC
		
 RETURN @result;
END

