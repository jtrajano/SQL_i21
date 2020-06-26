CREATE VIEW vyuRKM2MInquiryTranNotMapping

AS

SELECT DISTINCT bd.intM2MInquiryId
	, intM2MInquiryTransactionId
	, strCommodityCode
	, strFutMarketName
	, mo.strFutureMonth
	, strName strEntityName
	, strItemNo
	, mz.strMarketZoneCode strMarketZoneCode
	, strLocationName strLocationName
	, cd.dtmStartDate
	, cd.dtmEndDate
	, strSpreadMonth = smo.strFutureMonth
	, strPeriodTo = SUBSTRING(CONVERT(NVARCHAR(20),cd.dtmEndDate,106),4,8) COLLATE Latin1_General_CI_AS
	, strStartDate = CONVERT(NVARCHAR(20),cd.dtmStartDate,106) COLLATE Latin1_General_CI_AS
	, strEndDate = CONVERT(NVARCHAR(20),cd.dtmEndDate,106) COLLATE Latin1_General_CI_AS
FROM tblRKM2MInquiryTransaction bd
JOIN tblRKM2MInquiry mb ON mb.intM2MInquiryId = bd.intM2MInquiryId
JOIN tblICCommodity c ON c.intCommodityId = bd.intCommodityId
LEFT JOIN tblEMEntity e ON e.intEntityId = bd.intEntityId
LEFT JOIN tblICItem i ON i.intItemId = bd.intItemId
LEFT JOIN tblRKFutureMarket m ON m.intFutureMarketId = bd.intFutureMarketId
LEFT JOIN tblRKFuturesMonth mo ON mo.intFutureMonthId = bd.intFutureMonthId
LEFT JOIN tblRKFuturesMonth smo ON smo.intFutureMonthId = bd.intSpreadMonthId
LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = bd.intMarketZoneId
LEFT JOIN tblSMCompanyLocation co ON co.intCompanyLocationId = bd.intCompanyLocationId
LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = bd.intContractDetailId