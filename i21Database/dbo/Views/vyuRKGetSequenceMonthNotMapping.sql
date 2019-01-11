CREATE VIEW vyuRKGetSequenceMonthNotMapping

AS

SELECT bd.intCommodityId
	, bd.intFutureMarketId
	, strDeliveryMonth = bd.strDeliveryMonth COLLATE Latin1_General_CI_AS
	, bd.intFutureMonthId
	, bd.dblBasis
	, bd.intCompanyLocationId
	, intM2MGrainBasisId
	, strCommodityCode
	, strFutMarketName
	, (strFutureMonth + ' (' + strSymbol + ')') COLLATE Latin1_General_CI_AS strFutureMonth
	, strLocationName
FROM tblRKM2MGrainBasis bd
JOIN tblRKM2MBasis mb on mb.intM2MBasisId=bd.intM2MBasisId
JOIN tblICCommodity c on c.intCommodityId=bd.intCommodityId
JOIN tblRKFutureMarket m on m.intFutureMarketId=bd.intFutureMarketId
JOIN tblRKFuturesMonth cur on cur.intFutureMonthId=bd.intFutureMonthId
JOIN tblSMCompanyLocation l on bd.intCompanyLocationId= l.intCompanyLocationId