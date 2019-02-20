CREATE VIEW vyuRKGetStock
AS
SELECT 
	s.intCurExpStockId,
	s.intConcurrencyId,
	s.intCurrencyExposureId,
	s.intContractDetailId,
	s.strLotNumber,
	s.intStorageLocationId,
	s.intItemId,
	s.intFutureMarketId,
	s.strSpotMonth,
	isnull(s.dblClosingPrice,0) dblSettlementPrice,
	s.dblMarketPremium,
	s.intMarketPremiumCurrencyId,
	s.intMarketPremiumUOMId,
	s.dblMarketPrice,
	s.intMarketPriceCurrencyId,
	s.intMarketPriceUOMId,
	s.dblQuantity dblQty,
	s.dblValue,
	s.intCompanyId,i.strItemNo, m.strFutMarketName,strUnitMeasure,
	(ch.strContractNumber + '-' + convert(nvarchar, cd.intContractSeq)) COLLATE Latin1_General_CI_AS strContractNumber,
	strName,
	 (c.strCurrency + '/' + um.strUnitMeasure) COLLATE Latin1_General_CI_AS strMarketPremiumUOM
	 ,strCurrency strMarketPriceUOM
FROM tblRKCurExpStock s
join tblCTContractDetail cd on s.intContractDetailId=cd.intContractDetailId
join tblCTContractHeader ch on cd.intContractHeaderId=ch.intContractHeaderId
JOIN tblICStorageLocation sl on sl.intStorageLocationId=s.intStorageLocationId
JOIN tblICItem i on s.intItemId=i.intItemId
JOIN tblRKFutureMarket m on m.intFutureMarketId=s.intFutureMarketId
JOIN tblICUnitMeasure um on um.intUnitMeasureId=s.intMarketPremiumUOMId
JOIN tblSMCurrency c on c.intCurrencyID=s.intMarketPriceUOMId