CREATE FUNCTION dbo.fnGREndOfMonthProcedurePurchaseContracts(
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
    ,dblBasis = BASIS.dblBasis
    ,dblPrice = PRICE.dblSettlementPrice
    ,dblWeightedAvg = WAVG.dblWeightedAvg
    ,dblPerUnitGainLoss = (BASIS.dblBasis + PRICE.dblSettlementPrice) - WAVG.dblWeightedAvg
    ,dblExtended = ((BASIS.dblBasis + PRICE.dblSettlementPrice) - WAVG.dblWeightedAvg) * R.dblBalance
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
        ,EOM.dtmEndOfMonth
        ,dblBalance = SUM(ISNULL(BAL.dblBalance, CTD.dblBalance))
    FROM tblCTContractHeader CTH
    INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CTH.intPricingTypeId
    INNER JOIN tblCTContractDetail CTD ON CTD.intContractHeaderId = CTH.intContractHeaderId
    INNER JOIN tblICItem I ON I.intItemId = CTD.intItemId
    INNER JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
    INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CTD.intCompanyLocationId
    INNER JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CTD.intFutureMarketId
    INNER JOIN tblRKFuturesMonth FMM ON FMM.intFutureMonthId = CTD.intFutureMonthId
    OUTER APPLY (SELECT dtmEndOfMonth = ISNULL(FMM.dtmLastTradingDate, EOMONTH(FMM.dtmFutureMonthsDate))) EOM
    OUTER APPLY (
        SELECT TOP 1 SH.dblBalance
        FROM tblCTSequenceHistory SH
        WHERE SH.intContractDetailId = CTD.intContractDetailId
        AND SH.dtmHistoryCreated <= @dtmPeriodDate
        ORDER BY SH.dtmHistoryCreated DESC
    ) BAL
    WHERE ISNULL(BAL.dblBalance, CTD.dblBalance) > 0
    AND C.intCommodityId = @intCommodityId
    AND CL.intCompanyLocationId = @intLocationId
    AND CTH.intPricingTypeId = @intPricingTypeId
    AND CTH.intContractTypeId = 1
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
        ,EOM.dtmEndOfMonth
) R
OUTER APPLY dbo.fnRKGetFutureAndBasisPrice (1,R.intCommodityId,right(convert(varchar, R.dtmSpotDate, 106),8),3,R.intFutureMarketId,R.intFutureMonthId,R.intCompanyLocationId,NULL,0,NULL,NULL) PRICE
OUTER APPLY (SELECT dblBasis = CASE WHEN R.strPricingType = 'HTA' THEN 0 ELSE ISNULL(PRICE.dblBasis, 0) END ) BASIS
OUTER APPLY (
    SELECT dblWeightedAvg = SUM(IT.dblComputedValue) / SUM(IT.dblQty)
    FROM tblCTContractHeader CTH2
    INNER JOIN tblCTContractDetail CTD2 ON CTD2.intContractHeaderId = CTH2.intContractHeaderId
    INNER JOIN tblICItem I2 ON I2.intItemId = CTD2.intItemId
    INNER JOIN tblICCommodity C2 ON C2.intCommodityId = I2.intCommodityId
    INNER JOIN tblICInventoryReceiptItem IRI ON IRI.intContractDetailId = CTD2.intContractDetailId
    INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
    INNER JOIN tblICInventoryTransaction IT ON IT.intTransactionDetailId = IRI.intInventoryReceiptItemId AND IT.strTransactionId = IR.strReceiptNumber
    WHERE IR.dtmReceiptDate BETWEEN R.dtmSpotDate AND R.dtmEndOfMonth
    AND IR.intLocationId = R.intCompanyLocationId
    AND C2.intCommodityId = R.intCommodityId
) WAVG
-- WHERE ISNULL(PRICE.dblSettlementPrice, 0) > 0
-- AND WAVG.dblWeightedAvg IS NOT NULL

GO