CREATE PROC uspRKGetFutureAndBasisPrice
	@intTicketType int = 1 , -- 1- purchase. 2- sale.
	@intCommodityId int = null,
	@strSeqMonth nvarchar(10),--'Dec 16'
	@intSequenceTypeId int, -- 1.	‘01’ – Returns, Futures($) and Unit of Measure 2.	‘02’ – Returns, Basis($) and Unit of Measure 3.	‘03’ – Returns, Futures($), Basis ($) and Unit of Measure
	@intFutureMarketId int, 
	@intLocationId int= null	

AS

if @intSequenceTypeId = 1
BEGIN
	SELECT TOP 1 dblBasisOrDiscount dblBasis,strUnitMeasure strBasisUnitMeasure FROM tblRKM2MBasis b
	JOIN tblRKM2MBasisDetail bd on b.intM2MBasisId=bd.intM2MBasisId 
	join tblICUnitMeasure u on bd.intUnitMeasureId=u.intUnitMeasureId
	WHERE intContractTypeId= @intTicketType
		  AND intCommodityId = case when isnull(@intCommodityId,0)=0 then intCommodityId else @intCommodityId end 
		  AND strPeriodTo = @strSeqMonth
		  AND bd.intFutureMarketId=@intFutureMarketId
		  AND isnull(bd.intCompanyLocationId,0) = case when isnull(@intLocationId,0) = 0 then isnull(bd.intCompanyLocationId,0) else @intLocationId end
		  AND ISNULL(dblBasisOrDiscount,0) <> 0 	  
	ORDER BY dtmM2MBasisDate Desc
END
ELSE IF  @intSequenceTypeId = 2
BEGIN
	SELECT TOP 1 isnull(dblLastSettle,0) dblSettlementPrice,strUnitMeasure strPriceUnitMeasure
	FROM tblRKFuturesSettlementPrice sp
	INNER JOIN tblRKFutSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
	INNER JOIN tblRKFutureMarket m on sp.intFutureMarketId=m.intFutureMarketId
	INNER JOIN tblICUnitMeasure u on m.intUnitMeasureId=u.intUnitMeasureId
	INNER JOIN tblRKFuturesMonth fm on mm.intFutureMonthId=fm.intFutureMonthId
		WHERE sp.intFutureMarketId=@intFutureMarketId 
		 AND  RIGHT(CONVERT(NVARCHAR,dtmFutureMonthsDate,106),8)  = @strSeqMonth
		 AND dblLastSettle IS NOT NULL
	ORDER BY dtmPriceDate DESC
END
ELSE IF @intSequenceTypeId = 3
BEGIN
	SELECT TOP 1 dblBasisOrDiscount dblBasis,strUnitMeasure strBasisUnitMeasure,@strSeqMonth strMonth into #temp
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

	SELECT TOP 1 isnull(dblLastSettle,0) dblSettlementPrice,strUnitMeasure strPriceUnitMeasure,@strSeqMonth strMonth into #temp1
	FROM tblRKFuturesSettlementPrice sp
	INNER JOIN tblRKFutSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
	INNER JOIN tblRKFutureMarket m on sp.intFutureMarketId=m.intFutureMarketId
	INNER JOIN tblICUnitMeasure u on m.intUnitMeasureId=u.intUnitMeasureId
	INNER JOIN tblRKFuturesMonth fm on mm.intFutureMonthId=fm.intFutureMonthId
	WHERE sp.intFutureMarketId=@intFutureMarketId 
		 AND  RIGHT(CONVERT(NVARCHAR,dtmFutureMonthsDate,106),8)  = @strSeqMonth AND dblLastSettle IS NOT NULL
	ORDER BY dtmPriceDate DESC

	SELECT dblBasis,strBasisUnitMeasure, dblSettlementPrice,strPriceUnitMeasure FROM #temp t
	full join #temp1 t1 on t.strMonth=t1.strMonth
END