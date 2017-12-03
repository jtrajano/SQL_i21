CREATE VIEW  vyuRKM2MInquiryTranNotMapping

AS 

SELECT DISTINCT 
bd.intM2MInquiryId,
		intM2MInquiryTransactionId
		,strCommodityCode
		,strFutMarketName
		,strFutureMonth
		,strName strEntityName
		,strItemNo		
 FROM tblRKM2MInquiryTransaction bd
join tblRKM2MInquiry mb on mb.intM2MInquiryId=bd.intM2MInquiryId
join tblICCommodity c on c.intCommodityId=bd.intCommodityId
join tblEMEntity e on e.intEntityId=bd.intEntityId
LEFT JOIN tblICItem i on i.intItemId=bd.intItemId
LEFT JOIN tblRKFutureMarket m on m.intFutureMarketId=bd.intFutureMarketId
LEFT JOIN tblRKFuturesMonth mo on mo.intFutureMonthId=bd.intFutureMonthId