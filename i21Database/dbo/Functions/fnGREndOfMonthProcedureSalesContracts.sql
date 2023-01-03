CREATE FUNCTION dbo.fnGREndOfMonthProcedureSalesContracts(
	@dtmPeriodDate DATETIME
	,@intCommodityId INT
	,@intLocationId INT
    ,@intPricingTypeId INT
)
RETURNS TABLE
AS
RETURN
SELECT
    R.*
    ,dblBasis = ISNULL(PRICE.dblBasis, 0)
    ,dblPrice = PRICE.dblSettlementPrice
    ,dblWeightedAvg = ISNULL(WAVG.dblWeightedAvg, 0)
    ,dblPerUnitGainLoss = (ISNULL(PRICE.dblBasis, 0) + PRICE.dblSettlementPrice) - ISNULL(WAVG.dblWeightedAvg, 0)
    ,dblExtended = ((ISNULL(PRICE.dblBasis, 0) + PRICE.dblSettlementPrice) - ISNULL(WAVG.dblWeightedAvg, 0)) * R.dblBalance
FROM (
    SELECT
        PT.strPricingType
        ,C.intCommodityId
        ,C.strCommodityCode
        ,CL.intCompanyLocationId
        ,CL.strLocationNumber
        ,FM.intFutureMarketId
        ,FM.strFutMarketName
        ,FMM.intFutureMonthId
        ,FMM.strFutureMonth
        ,FMM.dtmSpotDate
        ,FMM.dtmLastTradingDate
        ,dblBalance = SUM(ISNULL(BAL.dblBalance, 0))
    FROM tblCTContractHeader CTH
    INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CTH.intPricingTypeId
    INNER JOIN tblCTContractDetail CTD ON CTD.intContractHeaderId = CTH.intContractHeaderId
    INNER JOIN tblICItem I ON I.intItemId = CTD.intItemId
    INNER JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
    INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CTD.intCompanyLocationId
    INNER JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CTD.intFutureMarketId
    INNER JOIN tblRKFuturesMonth FMM ON FMM.intFutureMonthId = CTD.intFutureMonthId AND FMM.dtmLastTradingDate IS NOT NULL
    OUTER APPLY (
        SELECT TOP 1 SH.dblBalance
        FROM tblCTSequenceHistory SH
        WHERE SH.intContractDetailId = CTD.intContractDetailId
        AND SH.dtmHistoryCreated <= @dtmPeriodDate
        ORDER BY SH.dtmHistoryCreated DESC
    ) BAL
    WHERE BAL.dblBalance > 0
    AND C.intCommodityId = @intCommodityId
    AND CL.intCompanyLocationId = @intLocationId
    AND CTH.intPricingTypeId = @intPricingTypeId
    AND CTH.intContractTypeId = 2
    GROUP BY
        PT.strPricingType
        ,C.intCommodityId
        ,C.strCommodityCode
        ,CL.intCompanyLocationId
        ,CL.strLocationNumber
        ,FM.intFutureMarketId
        ,FM.strFutMarketName
        ,FMM.intFutureMonthId
        ,FMM.strFutureMonth
        ,FMM.dtmSpotDate
        ,FMM.dtmLastTradingDate
) R
OUTER APPLY dbo.fnRKGetFutureAndBasisPrice (1,R.intCommodityId,right(convert(varchar, R.dtmSpotDate, 106),8),3,R.intFutureMarketId,R.intFutureMonthId,R.intCompanyLocationId,NULL,0,NULL,NULL) PRICE
OUTER APPLY (
    SELECT dblWeightedAvg = SUM(IT.dblComputedValue) / SUM(IT.dblQty)
    FROM tblCTContractHeader CTH2
    INNER JOIN tblCTContractDetail CTD2 ON CTD2.intContractHeaderId = CTH2.intContractHeaderId
    INNER JOIN tblICItem I2 ON I2.intItemId = CTD2.intItemId
    INNER JOIN tblICCommodity C2 ON C2.intCommodityId = I2.intCommodityId
    INNER JOIN tblICInventoryShipmentItem ISD ON ISD.intLineNo = CTD2.intContractDetailId AND ISD.intOrderId = CTH2.intContractHeaderId
    INNER JOIN tblICInventoryShipment ISH ON ISH.intInventoryShipmentId = ISD.intInventoryShipmentId
    INNER JOIN tblICInventoryTransaction IT ON IT.intTransactionDetailId = ISD.intInventoryShipmentItemId AND IT.strTransactionId = ISH.strShipmentNumber
    WHERE ISH.dtmShipDate BETWEEN R.dtmSpotDate AND R.dtmLastTradingDate
    AND ISH.intShipFromLocationId = R.intCompanyLocationId
    AND C2.intCommodityId = R.intCommodityId
    AND (IT.dblQty < 0)
) WAVG
WHERE ISNULL(PRICE.dblSettlementPrice, 0) > 0
AND WAVG.dblWeightedAvg IS NOT NULL

GO