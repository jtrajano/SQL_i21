﻿CREATE VIEW  vyuRKM2MInquiryNotMapping

AS 

SELECT intM2MInquiryId
		,strCommodityCode
		,strCurrency
		,strMarketZoneCode
		,strLocationName
		,strUnitMeasure
		,dtmM2MBasisDate
		,dtmPriceDate dtmFutureSettlementDate
FROM tblRKM2MInquiry bd
JOIN tblRKM2MBasis bas on bas.intM2MBasisId=bd.intM2MBasisId
JOIN tblSMCurrency cur on cur.intCurrencyID=bd.intCurrencyId
JOIN tblRKFuturesSettlementPrice sc on sc.intFutureSettlementPriceId=bd.intFutureSettlementPriceId
LEFT join tblICCommodity c on c.intCommodityId=bd.intCommodityId
LEFT JOIN tblICUnitMeasure um on um.intUnitMeasureId=bd.intUnitMeasureId
LEFT JOIN tblARMarketZone z on z.intMarketZoneId=bd.intMarketZoneId
LEFT JOIN tblSMCompanyLocation l on l.intCompanyLocationId=bd.intCompanyLocationId