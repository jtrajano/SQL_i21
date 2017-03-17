CREATE VIEW vyuRKGetSequenceMonthNotMapping
AS
SELECT   intM2MGrainBasisId
		,strCommodityCode
		,strFutMarketName
		,strFutureMonth +' ('+strSymbol+')' strFutureMonth
 FROM tblRKM2MGrainBasis bd
JOIN tblRKM2MBasis mb on mb.intM2MBasisId=bd.intM2MBasisId
JOIN tblICCommodity c on c.intCommodityId=bd.intCommodityId
JOIN tblRKFutureMarket m on m.intFutureMarketId=bd.intFutureMarketId
JOIN tblRKFuturesMonth cur on cur.intFutureMonthId=bd.intFutureMonthId