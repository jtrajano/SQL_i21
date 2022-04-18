CREATE VIEW [dbo].[vyuRKGetAllocatedContractsGainOrLossHeader]

AS

SELECT H.intAllocatedContractsGainOrLossHeaderId
    , H.strRecordName
    , H.intCommodityId
	, c.strCommodityCode
    , H.intBasisEntryId
	, b.dtmM2MBasisDate
    , H.intFutureSettlementPriceId
	, sp.dtmPriceDate
    , H.intPriceUOMId
	, strPriceUOM = pUOM.strUnitMeasure
    , H.intQtyUOMId
	, strQtyUOM = qUOM.strUnitMeasure
    , H.intCurrencyId
	, cur.strCurrency
    , H.dtmTransactionUpTo
    , H.intLocationId
	, loc.strLocationName
    , H.intMarketZoneId
	, mz.strMarketZoneCode
    , H.dtmPostDate
    , H.dtmReverseDate
    , H.dtmLastReversalDate
    , H.ysnPosted
    , H.dtmCreatedDate
    , H.dtmUnpostDate
    , H.strBatchId
    , H.intCompanyId
    , H.intConcurrencyId
	, ysnEvaluationByLocation = ISNULL(companyConfig.ysnEvaluationByLocation, CAST(0 AS BIT))
	, ysnEvaluationByMarketZone = ISNULL(companyConfig.ysnEvaluationByMarketZone, CAST(0 AS BIT))
	, ysnEvaluationByOriginPort = ISNULL(companyConfig.ysnEvaluationByOriginPort, CAST(0 AS BIT))
	, ysnEvaluationByDestinationPort = ISNULL(companyConfig.ysnEvaluationByDestinationPort, CAST(0 AS BIT))
	, ysnEvaluationByCropYear = ISNULL(companyConfig.ysnEvaluationByCropYear, CAST(0 AS BIT))
	, ysnEvaluationByStorageLocation = ISNULL(companyConfig.ysnEvaluationByStorageLocation, CAST(0 AS BIT))
	, ysnEvaluationByStorageUnit = ISNULL(companyConfig.ysnEvaluationByStorageUnit, CAST(0 AS BIT))
FROM tblRKAllocatedContractsGainOrLossHeader H
LEFT JOIN tblICCommodity c ON c.intCommodityId = H.intCommodityId
LEFT JOIN tblRKM2MBasis b ON b.intM2MBasisId = H.intBasisEntryId
LEFT JOIN tblRKFuturesSettlementPrice sp ON sp.intFutureSettlementPriceId = H.intFutureSettlementPriceId
LEFT JOIN tblICUnitMeasure pUOM ON pUOM.intUnitMeasureId = H.intPriceUOMId
LEFT JOIN tblICUnitMeasure qUOM ON qUOM.intUnitMeasureId = H.intQtyUOMId
LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = H.intCurrencyId
LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = H.intLocationId
LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = H.intMarketZoneId
OUTER APPLY (
	SELECT TOP 1 
	  ysnEvaluationByLocation
	, ysnEvaluationByMarketZone
	, ysnEvaluationByOriginPort
	, ysnEvaluationByDestinationPort
	, ysnEvaluationByCropYear
	, ysnEvaluationByStorageLocation
	, ysnEvaluationByStorageUnit
	FROM tblRKCompanyPreference
) companyConfig