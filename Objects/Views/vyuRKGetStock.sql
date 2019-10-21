CREATE VIEW vyuRKGetStock

AS

SELECT s.intCurExpStockId
	, s.intConcurrencyId
	, s.intCurrencyExposureId
	, s.intContractDetailId
	, s.strLotNumber
	, s.intStorageLocationId
	, s.intItemId
	, s.intFutureMarketId
	, s.strSpotMonth
	, dblSettlementPrice = ISNULL(s.dblClosingPrice, 0)
	, s.dblMarketPremium
	, s.intMarketPremiumCurrencyId
	, s.intMarketPremiumUOMId
	, s.dblMarketPrice
	, s.intMarketPriceCurrencyId
	, s.intMarketPriceUOMId
	, dblQty = s.dblQuantity
	, s.dblValue
	, s.intCompanyId
	, i.strItemNo
	, m.strFutMarketName
	, strUnitMeasure
	, strContractNumber = (ch.strContractNumber + '-' + CONVERT(NVARCHAR, cd.intContractSeq)) COLLATE Latin1_General_CI_AS
	, strName
	, strMarketPremiumUOM = (c.strCurrency + '/' + um.strUnitMeasure) COLLATE Latin1_General_CI_AS
	, strMarketPriceUOM = strCurrency
FROM tblRKCurExpStock s
JOIN tblCTContractDetail cd ON s.intContractDetailId = cd.intContractDetailId
JOIN tblCTContractHeader ch ON cd.intContractHeaderId = ch.intContractHeaderId
JOIN tblICStorageLocation sl ON sl.intStorageLocationId = s.intStorageLocationId
JOIN tblICItem i ON s.intItemId = i.intItemId
JOIN tblRKFutureMarket m ON m.intFutureMarketId = s.intFutureMarketId
JOIN tblICUnitMeasure um ON um.intUnitMeasureId = s.intMarketPremiumUOMId
JOIN tblSMCurrency c ON c.intCurrencyID = s.intMarketPriceUOMId