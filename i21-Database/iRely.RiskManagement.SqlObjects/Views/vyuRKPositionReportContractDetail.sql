CREATE VIEW vyuRKPositionReportContractDetail

AS

WITH Pricing AS
    (
    SELECT  c.strCommodityCode,
		c.intCommodityId,
		ch.intContractHeaderId,
	    strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
		,strLocationName,
		dtmEndDate,
		SUM(PFD.dblQuantity) dblPricedQuantity,
		SUM(CDT.dblBalance) dblBalanceQuantity,
		CDT.intUnitMeasureId
		,CDT.intPricingTypeId,
		ch.intContractTypeId
		,cl.intCompanyLocationId
		,ct.strContractType 
		,pt.strPricingType
		,ium.intCommodityUnitMeasureId,
		CDT.intContractDetailId,
		CDT.intContractStatusId,
		ch.intEntityId
		,CDT.intCurrencyId
		,IM.intItemId
		,IM.strItemNo,ch.dtmContractDate,strEntityName,ch.strCustomerContract
		,max(CDT.dblQuantity-CDT.dblBalance) dblRecQty
		,dbo.fnCTConvertQtyToTargetCommodityUOM(ch.intCommodityId,CDT.intUnitMeasureId,fm.intUnitMeasureId, max(CDT.dblQuantity-CDT.dblBalance))/fm.dblContractSize dblRecLots
		,max(CDT.dblQuantity) dblQuantity
		,fm.intFutureMarketId
		,fm.strFutMarketName
		,b.intBookId
		,b.strBook
		,IM.intProductTypeId
		,pty.strDescription strProductType
		,IM.intProductLineId
		,ptl.strDescription strProductLine
		,mo.intFutureMonthId,strFutureMonth,fm.intUnitMeasureId intFutMarketUOM,dtmFutureMonthsDate,ysnExpired,strSymbol,dblContractSize,intItemUOMId
		 ,dbo.fnCTConvertQtyToTargetCommodityUOM(ch.intCommodityId,CDT.intUnitMeasureId,fm.intUnitMeasureId, max(CDT.dblQuantity-CDT.dblBalance))/fm.dblContractSize dblNoOfLots,
		  dbo.fnCTConvertQtyToTargetCommodityUOM(ch.intCommodityId,CDT.intUnitMeasureId,fm.intUnitMeasureId, max(PFD.dblQuantity))/fm.dblContractSize dblLotsFixed,
		dblYield,isnull(ysnDeltaHedge,0) ysnDeltaHedge,CA.strDescription AS	strItemOrigin,IM.strDescription strItemDescription	
		,intMultiCompanyId,strCompanyName	,
		 CONVERT(VARCHAR(11), CDT.dtmStartDate, 106) +'-'+CONVERT(VARCHAR(11), CDT.dtmEndDate, 106) strShipmentPeriod
	FROM    tblCTPriceFixationDetail  PFD
    JOIN    tblCTPriceFixation   PFX ON PFX.intPriceFixationId   = PFD.intPriceFixationId
    JOIN    tblCTContractDetail   CDT ON CDT.intContractDetailId  = PFX.intContractDetailId and CDT.intPricingTypeId IN (1,2)
	JOIN	tblICItem			 IM	ON	IM.intItemId				=	CDT.intItemId
	JOIN	tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId  not in(2,3,6)
	JOIN	vyuCTEntity							EY	ON	EY.intEntityId						=		ch.intEntityId			AND														
														1 = (
															CASE 
																WHEN ch.intContractTypeId = 1 AND EY.strEntityType = 'Vendor' THEN 1 
																WHEN ch.intContractTypeId <> 1 AND EY.strEntityType = 'Customer' THEN 1 
																ELSE 0
															END
														) 
	JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId
	JOIN tblCTPricingType pt on pt.intPricingTypeId=CDT.intPricingTypeId
	JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	CDT.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND CDT.intUnitMeasureId=ium.intUnitMeasureId
	join tblRKFutureMarket fm on CDT.intFutureMarketId=fm.intFutureMarketId
	join tblRKFuturesMonth mo on mo.intFutureMonthId=CDT.intFutureMonthId
	LEFT JOIN tblCTBook b on b.intBookId=case when isnull(CDT.intBookId,0)=0 then (SELECT DISTINCT b.intBookId from tblCTBookVsEntity e
																	join tblCTContractHeader ch on ch.intEntityId=e.intEntityId
																	join tblCTBook b on b.intBookId=ch.intBookId) else CDT.intBookId end
	LEFT JOIN tblSMMultiCompany comp on comp.intMultiCompanyId=ch.intCompanyId
	LEFT JOIN tblICCommodityAttribute			CA	ON	CA.intCommodityAttributeId	=	IM.intOriginId		
	
	
	LEFT JOIN tblICCommodityAttribute pty on IM.intProductTypeId=pty.intCommodityAttributeId and pty.strType='ProductType'
	LEFT JOIN tblICCommodityProductLine ptl on IM.intProductLineId=ptl.intCommodityProductLineId 
   WHERE   CDT.dblQuantity >   isnull(CDT.dblInvoicedQty,0) and isnull(CDT.dblBalance,0) > 0  
    GROUP BY c.strCommodityCode,
						c.intCommodityId,
						ch.intContractHeaderId,
						strContractNumber ,intContractSeq
						,strLocationName,
						dtmEndDate,		
						CDT.intUnitMeasureId
						,CDT.intPricingTypeId,
						ch.intContractTypeId
						,cl.intCompanyLocationId
						,ct.strContractType 
						,pt.strPricingType
						,ium.intCommodityUnitMeasureId,
						CDT.intContractDetailId,
						CDT.intContractStatusId,
						ch.intEntityId
						,CDT.intCurrencyId,	
						IM.intItemId
						,IM.strItemNo,ch.dtmContractDate,strEntityName,ch.strCustomerContract,fm.intFutureMarketId,fm.strFutMarketName
		,b.intBookId,b.strBook,IM.intProductTypeId,pty.strDescription,IM.intProductLineId,ptl.strDescription,mo.intFutureMonthId,strFutureMonth,
		fm.intUnitMeasureId,dtmFutureMonthsDate,ysnExpired,strSymbol,dblContractSize,intItemUOMId,CDT.dblNoOfLots,dblYield,ch.intCommodityId,PFX.dblLotsFixed
		, ysnDeltaHedge,CA.strDescription,IM.strDescription,intMultiCompanyId,strCompanyName,CDT.dtmStartDate,dtmEndDate)

 
	SELECT * FROM (
    SELECT   strCommodityCode,
		intCommodityId,
		intContractHeaderId,
	    strContractNumber
		,strLocationName,
		dtmEndDate,
		((dblPricedQuantity - dblRecQty)* case when isnull(dblYield,0)=0 then 1 else dblYield/100 end)   dblBalance,
		intUnitMeasureId
		,1 intPricingTypeId,
		intContractTypeId
		,intCompanyLocationId
		,strContractType 
		,strPricingType
		,intCommodityUnitMeasureId,
		intContractDetailId,
		intContractStatusId,
		intEntityId
		,intCurrencyId
		,' Priced' AS strType	
		,intItemId
		,strItemNo,dtmContractDate,strEntityName,strCustomerContract,
		 intFutureMarketId
		,strFutMarketName
		,intBookId
		,strBook
		,intProductTypeId,strProductType,intProductLineId,strProductLine,intFutureMonthId,strFutureMonth,intUnitMeasureId intFutMarketUOM
		,dtmFutureMonthsDate,ysnExpired,strSymbol,dblContractSize,intItemUOMId,
		((dblLotsFixed)* case when isnull(dblYield,0)=0 then 1 else dblYield/100 end)
		dblNoOfLots,isnull(ysnDeltaHedge,0) ysnDeltaHedge,strItemOrigin,strItemDescription,intMultiCompanyId,strCompanyName,strShipmentPeriod
    FROM    Pricing  WHERE intPricingTypeId=1 

    UNION 

    SELECT  c.strCommodityCode,
		c.intCommodityId,
		ch.intContractHeaderId,
	   ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
		,cl.strLocationName,
		CDT.dtmEndDate,
		((PRC.dblQuantity-dblPricedQuantity)* case when isnull(PRC.dblYield,0)=0 then 1 else PRC.dblYield/100 end)  AS dblBalance,
		CDT.intUnitMeasureId
		,2 intPricingTypeId,
		ch.intContractTypeId
		,cl.intCompanyLocationId
		,ct.strContractType 
		,pt.strPricingType
		,ium.intCommodityUnitMeasureId,
		CDT.intContractDetailId,
		CDT.intContractStatusId,
		ch.intEntityId
		,CDT.intCurrencyId
		,' Basis' AS strType
		,IM.intItemId
		,IM.strItemNo,ch.dtmContractDate,PRC.strEntityName,ch.strCustomerContract
	    ,PRC.intFutureMarketId
		,strFutMarketName
		,PRC.intBookId
		,PRC.strBook
		,IM.intProductTypeId,strProductType,IM.intProductLineId,strProductLine,PRC.intFutureMonthId,strFutureMonth,PRC.intUnitMeasureId intFutMarketUOM
		,dtmFutureMonthsDate,ysnExpired,strSymbol,dblContractSize,PRC.intItemUOMId,
		((PRC.dblNoOfLots-PRC.dblLotsFixed)* case when isnull(PRC.dblYield,0)=0 then 1 else PRC.dblYield/100 end)
		 dblNoOfLots,isnull(ysnDeltaHedge,0) ysnDeltaHedge,strItemOrigin,strItemDescription,intMultiCompanyId,strCompanyName,strShipmentPeriod
    FROM    tblCTContractDetail CDT
    JOIN    Pricing     PRC ON CDT.intContractDetailId = PRC.intContractDetailId and CDT.intPricingTypeId IN (2)
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId  not in(2,3,6)
	JOIN	tblICItem			 IM	ON	IM.intItemId				=	CDT.intItemId
	JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId
	JOIN tblCTPricingType pt on pt.intPricingTypeId=CDT.intPricingTypeId
	JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	CDT.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND CDT.intUnitMeasureId=ium.intUnitMeasureId 
    WHERE  dblPricedQuantity >= dblRecQty

	UNION 

    SELECT  c.strCommodityCode,
		c.intCommodityId,
		ch.intContractHeaderId,
	   ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
		,cl.strLocationName,
		CDT.dtmEndDate,
		((PRC.dblPricedQuantity-dblRecQty)* case when isnull(PRC.dblYield,0)=0 then 1 else PRC.dblYield/100 end) AS dblBalance,
		CDT.intUnitMeasureId
		,1 intPricingTypeId,
		ch.intContractTypeId
		,cl.intCompanyLocationId
		,ct.strContractType 
		,pt.strPricingType
		,ium.intCommodityUnitMeasureId,
		CDT.intContractDetailId,
		CDT.intContractStatusId,
		ch.intEntityId
		,CDT.intCurrencyId
		,' Priced' AS strType
		,IM.intItemId
		,IM.strItemNo,ch.dtmContractDate,PRC.strEntityName,ch.strCustomerContract
		,PRC.intFutureMarketId
		,strFutMarketName
		,PRC.intBookId
		,PRC.strBook
		,IM.intProductTypeId,strProductType,IM.intProductLineId,strProductLine,PRC.intFutureMonthId,strFutureMonth,PRC.intUnitMeasureId intFutMarketUOM
		,dtmFutureMonthsDate,ysnExpired,strSymbol,dblContractSize,PRC.intItemUOMId,
		((PRC.dblLotsFixed-dblRecLots)* case when isnull(PRC.dblYield,0)=0 then 1 else PRC.dblYield/100 end),isnull(ysnDeltaHedge,0) ysnDeltaHedge
		,strItemOrigin,strItemDescription,intMultiCompanyId,strCompanyName,strShipmentPeriod
    FROM    tblCTContractDetail CDT
    JOIN    Pricing     PRC ON CDT.intContractDetailId = PRC.intContractDetailId and CDT.intPricingTypeId IN (2)
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId  not in(2,3,6)
	JOIN	tblICItem			 IM	ON	IM.intItemId				=	CDT.intItemId
	JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId
	JOIN tblCTPricingType pt on pt.intPricingTypeId=CDT.intPricingTypeId
	JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	CDT.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND CDT.intUnitMeasureId=ium.intUnitMeasureId 
    WHERE  dblPricedQuantity > dblRecQty

	UNION 

    SELECT  c.strCommodityCode,
		c.intCommodityId,
		ch.intContractHeaderId,
	   ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
		,cl.strLocationName,
		CDT.dtmEndDate,
		((CDT.dblQuantity-dblRecQty)* case when isnull(PRC.dblYield,0)=0 then 1 else PRC.dblYield/100 end) AS dblBalance,
		CDT.intUnitMeasureId
		,2 intPricingTypeId,
		ch.intContractTypeId
		,cl.intCompanyLocationId
		,ct.strContractType 
		,pt.strPricingType
		,ium.intCommodityUnitMeasureId,
		CDT.intContractDetailId,
		CDT.intContractStatusId,
		ch.intEntityId
		,CDT.intCurrencyId
		,' Basis' AS strType
		,IM.intItemId
		,IM.strItemNo,ch.dtmContractDate,PRC.strEntityName,ch.strCustomerContract
		,PRC.intFutureMarketId
		,strFutMarketName
		,PRC.intBookId
		,PRC.strBook
		,IM.intProductTypeId,strProductType,IM.intProductLineId,strProductLine,PRC.intFutureMonthId,strFutureMonth,PRC.intUnitMeasureId intFutMarketUOM
		,dtmFutureMonthsDate,ysnExpired,strSymbol,dblContractSize,PRC.intItemUOMId, 
		((CDT.dblNoOfLots- PRC.dblRecLots)* case when isnull(PRC.dblYield,0)=0 then 1 else PRC.dblYield/100 end),isnull(ysnDeltaHedge,0) ysnDeltaHedge
		,strItemOrigin,strItemDescription,intMultiCompanyId,strCompanyName,strShipmentPeriod
    FROM    tblCTContractDetail CDT
    JOIN    Pricing     PRC ON CDT.intContractDetailId = PRC.intContractDetailId and CDT.intPricingTypeId IN (2)
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId  not in(2,3,6)
	JOIN	tblICItem			 IM	ON	IM.intItemId				=	CDT.intItemId
	JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId
	JOIN tblCTPricingType pt on pt.intPricingTypeId=CDT.intPricingTypeId
	JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	CDT.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND CDT.intUnitMeasureId=ium.intUnitMeasureId 
    WHERE  dblPricedQuantity < dblRecQty

    UNION 

    SELECT  
	c.strCommodityCode,
		c.intCommodityId,
		ch.intContractHeaderId,
	    strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
		,strLocationName,
		dtmEndDate,
		(CDT.dblBalance* case when isnull(dblYield,0)=0 then 1 else dblYield/100 end)  dblBalance,
		CDT.intUnitMeasureId
		,case when pt.intPricingTypeId=1 then 1  else  2 end intPricingTypeId,
		ch.intContractTypeId
		,cl.intCompanyLocationId
		,ct.strContractType 
		,pt.strPricingType
		,ium.intCommodityUnitMeasureId,
		CDT.intContractDetailId,
		CDT.intContractStatusId,
		EY.intEntityId
		,CDT.intCurrencyId
		,case when pt.intPricingTypeId=1 then ' Priced'  else  ' Basis' end AS strType
		,IM.intItemId
		,IM.strItemNo,ch.dtmContractDate,strEntityName,ch.strCustomerContract
		,fm.intFutureMarketId
		,strFutMarketName
		,b.intBookId
		,b.strBook
		,IM.intProductTypeId
		,pty.strDescription strProductType
		,IM.intProductLineId
		,ptl.strDescription strProductLine,mo.intFutureMonthId,strFutureMonth,fm.intUnitMeasureId intFutMarketUOM
		,dtmFutureMonthsDate,ysnExpired,strSymbol,dblContractSize,intItemUOMId

			,((dbo.fnCTConvertQtyToTargetCommodityUOM(ch.intCommodityId,CDT.intUnitMeasureId,fm.intUnitMeasureId, (CDT.dblBalance))/fm.dblContractSize)
			* case when isnull(dblYield,0)=0 then 1 else dblYield/100 end)			
			,isnull(ysnDeltaHedge,0) ysnDeltaHedge
			,CA.strDescription AS	strItemOrigin,IM.strDescription strItemDescription,intMultiCompanyId,strCompanyName,
			CONVERT(VARCHAR(11), CDT.dtmStartDate, 106) +'-'+CONVERT(VARCHAR(11), CDT.dtmEndDate, 106)
    FROM    tblCTContractDetail CDT
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId  not in(2,3,6) and dblBalance> 0
	JOIN	vyuCTEntity							EY	ON	EY.intEntityId						=		ch.intEntityId			AND														
														1 = (
															CASE 
																WHEN ch.intContractTypeId = 1 AND EY.strEntityType = 'Vendor' THEN 1 
																WHEN ch.intContractTypeId <> 1 AND EY.strEntityType = 'Customer' THEN 1 
																ELSE 0
															END
														) 
	JOIN	tblICItem			 IM	ON	IM.intItemId				=	CDT.intItemId
	JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId and CDT.intPricingTypeId IN (1,2)
	JOIN tblCTPricingType pt on pt.intPricingTypeId=CDT.intPricingTypeId
	JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	CDT.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND CDT.intUnitMeasureId=ium.intUnitMeasureId 
	JOIN tblRKFutureMarket fm on fm.intFutureMarketId=CDT.intFutureMarketId
	join tblRKFuturesMonth mo on mo.intFutureMonthId=CDT.intFutureMonthId
	LEFT JOIN tblCTBook b on b.intBookId=case when isnull(CDT.intBookId,0)=0 then (SELECT DISTINCT b.intBookId from tblCTBookVsEntity e
																	join tblCTContractHeader ch on ch.intEntityId=e.intEntityId
																	join tblCTBook b on b.intBookId=ch.intBookId) else CDT.intBookId end	
	LEFT JOIN tblSMMultiCompany comp on comp.intMultiCompanyId=ch.intCompanyId
	LEFT JOIN tblICCommodityAttribute			CA	ON	CA.intCommodityAttributeId	=	IM.intOriginId	
	LEFT JOIN tblICCommodityAttribute pty on IM.intProductTypeId=pty.intCommodityAttributeId and pty.strType='ProductType'
	LEFT JOIN tblICCommodityProductLine ptl on IM.intProductLineId=ptl.intCommodityProductLineId 
    WHERE   CDT.intContractDetailId not in(select intContractDetailId from Pricing)
	and dblBalance <> 0
) t  