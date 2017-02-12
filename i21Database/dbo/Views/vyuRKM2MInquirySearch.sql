CREATE VIEW vyuRKM2MInquirySearch

AS 

SELECT i.intM2MInquiryId,i.strRecordName,b.dtmM2MBasisDate,p.dtmPriceDate,m.strUnitMeasure,m1.strUnitMeasure as strPriceUOM,c.strCurrency,
	   i.dtmTransactionUpTo,i.strRateType,cc.strCommodityCode,cl.strLocationName,z.strMarketZoneCode
FROM tblRKM2MInquiry i
JOIN tblRKM2MBasis b on i.intM2MBasisId=b.intM2MBasisId
LEFT JOIN tblRKFuturesSettlementPrice p on i.intFutureSettlementPriceId=p.intFutureSettlementPriceId
JOIN tblICUnitMeasure m on m.intUnitMeasureId=i.intUnitMeasureId
JOIN tblICUnitMeasure m1 on m1.intUnitMeasureId=i.intPriceItemUOMId
JOIN tblSMCurrency c on c.intCurrencyID=i.intCurrencyId
LEFT JOIN tblICCommodity cc on cc.intCommodityId=i.intCommodityId
LEFT JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=i.intCompanyLocationId
LEFT JOIN tblARMarketZone z on z.intMarketZoneId=i.intMarketZoneId