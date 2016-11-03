CREATE FUNCTION [dbo].[fnRKGetFutureAndBasisPrice]
(
	@intTicketType int = 1 , -- 1- purchase. 2- sale.
	@intCommodityId int = null,
	@strSeqMonth nvarchar(10),--'Dec 16'
	@intSequenceTypeId int, -- 1.	‘01’ – Returns, Basis($) and Unit of Measure 2.	‘02’ – Returns, Futures($) and Unit of Measure   3. 	‘03’ – Returns, Futures($), Basis ($) and Unit of Measure
	@intFutureMarketId int, 
	@intLocationId int = null,
	@dblBasisCost decimal
)
RETURNS NUMERIC(18, 6)
AS
BEGIN
	DECLARE @calculatedValue AS NUMERIC(18, 6); 
	IF @intSequenceTypeId = 1
	BEGIN
		SELECT TOP 1 @calculatedValue= isnull(dblBasisOrDiscount,0) FROM tblRKM2MBasis b
		JOIN tblRKM2MBasisDetail bd on b.intM2MBasisId=bd.intM2MBasisId 
		WHERE intContractTypeId= @intTicketType
			AND intCommodityId = case when isnull(@intCommodityId,0)=0 then intCommodityId else @intCommodityId end 
			AND strPeriodTo = @strSeqMonth
			AND bd.intFutureMarketId=@intFutureMarketId
			AND isnull(bd.intCompanyLocationId,0) = case when isnull(@intLocationId,0) = 0 then isnull(bd.intCompanyLocationId,0) else @intLocationId end
			AND ISNULL(dblBasisOrDiscount,0) <> 0 	  
		ORDER BY dtmM2MBasisDate Desc
	END
	ELSE IF @intSequenceTypeId = 2
		BEGIN
		SELECT TOP 1 @calculatedValue=isnull(dblLastSettle,0) - @dblBasisCost
		FROM tblRKFuturesSettlementPrice sp
		INNER JOIN tblRKFutSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
		INNER JOIN tblRKFutureMarket m on sp.intFutureMarketId=m.intFutureMarketId
		INNER JOIN tblRKFuturesMonth fm on mm.intFutureMonthId=fm.intFutureMonthId
		WHERE sp.intFutureMarketId=@intFutureMarketId 
		AND  RIGHT(CONVERT(NVARCHAR,dtmFutureMonthsDate,106),8)  = @strSeqMonth	AND dblLastSettle IS NOT NULL
		ORDER BY dtmPriceDate DESC
		END
	ELSE
	BEGIN

	DECLARE @tblRKFutureBasis AS TABLE 
		(
			[dblBasis] NUMERIC(18, 6),
			[strMonth] nvarchar(20)
		) 

	DECLARE @tblRKFuturePrice AS TABLE 
		(
			[dblSettlementPrice] NUMERIC(18, 6),
			[strMonth] nvarchar(20)
		) 
	insert into @tblRKFutureBasis([dblBasis],[strMonth])
	SELECT TOP 1 dblBasisOrDiscount dblBasis,@strSeqMonth strMonth 
	 FROM tblRKM2MBasis b
	JOIN tblRKM2MBasisDetail bd on b.intM2MBasisId=bd.intM2MBasisId 
	JOIN tblICUnitMeasure u on bd.intUnitMeasureId=u.intUnitMeasureId
	WHERE intContractTypeId= @intTicketType
		  AND intCommodityId = case when isnull(@intCommodityId,0)=0 then intCommodityId else @intCommodityId end 
		  AND strPeriodTo = @strSeqMonth
		  AND bd.intFutureMarketId=@intFutureMarketId
		  AND isnull(bd.intCompanyLocationId,0) = case when isnull(@intLocationId,0) = 0 then isnull(bd.intCompanyLocationId,0) else @intLocationId end
		  AND ISNULL(dblBasisOrDiscount,0) <> 0 	  
	ORDER BY dtmM2MBasisDate Desc

	INSERT INTO @tblRKFuturePrice([dblSettlementPrice],[strMonth])
	SELECT TOP 1 isnull(dblLastSettle,0) dblSettlementPrice,@strSeqMonth strMonth
	FROM tblRKFuturesSettlementPrice sp
	INNER JOIN tblRKFutSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
	INNER JOIN tblRKFutureMarket m on sp.intFutureMarketId=m.intFutureMarketId
	INNER JOIN tblICUnitMeasure u on m.intUnitMeasureId=u.intUnitMeasureId
	INNER JOIN tblRKFuturesMonth fm on mm.intFutureMonthId=fm.intFutureMonthId
	WHERE sp.intFutureMarketId=@intFutureMarketId 
		 AND  RIGHT(CONVERT(NVARCHAR,dtmFutureMonthsDate,106),8)  = @strSeqMonth AND dblLastSettle IS NOT NULL
	ORDER BY dtmPriceDate DESC

	SELECT @calculatedValue=isnull(dblSettlementPrice,0)-isnull(dblBasis,0) FROM @tblRKFutureBasis t
	full join @tblRKFuturePrice t1 on t.strMonth=t1.strMonth

 END
	RETURN @calculatedValue
END