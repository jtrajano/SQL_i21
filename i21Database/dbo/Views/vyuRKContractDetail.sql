CREATE VIEW vyuRKContractDetail

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
		,max(CDT.dblQuantity) dblQuantity
	FROM    tblCTPriceFixationDetail  PFD
    JOIN    tblCTPriceFixation   PFX ON PFX.intPriceFixationId   = PFD.intPriceFixationId
    JOIN    tblCTContractDetail   CDT ON CDT.intContractDetailId  = PFX.intContractDetailId and CDT.intPricingTypeId IN (1,2)
	JOIN	tblICItem			 IM	ON	IM.intItemId				=	CDT.intItemId
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId  not in(2,3,6)
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
						,IM.strItemNo,ch.dtmContractDate,strEntityName,ch.strCustomerContract)


	SELECT * FROM (
    SELECT   strCommodityCode,
		intCommodityId,
		intContractHeaderId,
	    strContractNumber
		,strLocationName,
		dtmEndDate,
		dblPricedQuantity - dblRecQty  dblBalance,
		intUnitMeasureId
		,intPricingTypeId,
		intContractTypeId
		,intCompanyLocationId
		,strContractType 
		,strPricingType
		,intCommodityUnitMeasureId,
		intContractDetailId,
		intContractStatusId,
		intEntityId
		,intCurrencyId
		,strContractType+' Priced' AS strType	
		,intItemId
		,strItemNo,dtmContractDate,strEntityName,strCustomerContract
    FROM    Pricing  WHERE intPricingTypeId=1

    UNION ALL

    SELECT  c.strCommodityCode,
		c.intCommodityId,
		ch.intContractHeaderId,
	   ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
		,cl.strLocationName,
		CDT.dtmEndDate,
		PRC.dblQuantity-dblPricedQuantity AS dblBalance,
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
		,ct.strContractType+' Basis' AS strType
		,IM.intItemId
		,IM.strItemNo,ch.dtmContractDate,EY.strEntityName,ch.strCustomerContract
    FROM    tblCTContractDetail CDT
    JOIN    Pricing     PRC ON CDT.intContractDetailId = PRC.intContractDetailId and CDT.intPricingTypeId IN (2)
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId  not in(2,3,6)
	JOIN	vyuCTEntity							EY	ON	EY.intEntityId						=		ch.intEntityId			AND														
														1 = (
															CASE 
																WHEN ch.intContractTypeId = 1 AND EY.strEntityType = 'Vendor' THEN 1 
																WHEN ch.intContractTypeId <> 1 AND EY.strEntityType = 'Customer' THEN 1 
																ELSE 0
															END
														) 
	JOIN	tblICItem			 IM	ON	IM.intItemId				=	CDT.intItemId
	JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId
	JOIN tblCTPricingType pt on pt.intPricingTypeId=CDT.intPricingTypeId
	JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	CDT.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND CDT.intUnitMeasureId=ium.intUnitMeasureId 
    WHERE  dblPricedQuantity >= dblRecQty

	UNION ALL

    SELECT  c.strCommodityCode,
		c.intCommodityId,
		ch.intContractHeaderId,
	   ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
		,cl.strLocationName,
		CDT.dtmEndDate,
		PRC.dblPricedQuantity-dblRecQty AS dblBalance,
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
		,ct.strContractType+' Priced' AS strType
		,IM.intItemId
		,IM.strItemNo,ch.dtmContractDate,EY.strEntityName,ch.strCustomerContract
    FROM    tblCTContractDetail CDT
    JOIN    Pricing     PRC ON CDT.intContractDetailId = PRC.intContractDetailId and CDT.intPricingTypeId IN (2)
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId  not in(2,3,6)
	JOIN	vyuCTEntity							EY	ON	EY.intEntityId						=		ch.intEntityId			AND														
														1 = (
															CASE 
																WHEN ch.intContractTypeId = 1 AND EY.strEntityType = 'Vendor' THEN 1 
																WHEN ch.intContractTypeId <> 1 AND EY.strEntityType = 'Customer' THEN 1 
																ELSE 0
															END
														) 
	JOIN	tblICItem			 IM	ON	IM.intItemId				=	CDT.intItemId
	JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId
	JOIN tblCTPricingType pt on pt.intPricingTypeId=CDT.intPricingTypeId
	JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	CDT.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND CDT.intUnitMeasureId=ium.intUnitMeasureId 
    WHERE  dblPricedQuantity > dblRecQty

	UNION ALL

    SELECT  c.strCommodityCode,
		c.intCommodityId,
		ch.intContractHeaderId,
	   ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
		,cl.strLocationName,
		CDT.dtmEndDate,
		CDT.dblQuantity-dblRecQty AS dblBalance,
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
		,ct.strContractType+' Basis' AS strType
		,IM.intItemId
		,IM.strItemNo,ch.dtmContractDate,EY.strEntityName,ch.strCustomerContract
    FROM    tblCTContractDetail CDT
    JOIN    Pricing     PRC ON CDT.intContractDetailId = PRC.intContractDetailId and CDT.intPricingTypeId IN (2)
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId  not in(2,3,6)
	JOIN	vyuCTEntity							EY	ON	EY.intEntityId						=		ch.intEntityId			AND														
														1 = (
															CASE 
																WHEN ch.intContractTypeId = 1 AND EY.strEntityType = 'Vendor' THEN 1 
																WHEN ch.intContractTypeId <> 1 AND EY.strEntityType = 'Customer' THEN 1 
																ELSE 0
															END
														) 
	JOIN	tblICItem			 IM	ON	IM.intItemId				=	CDT.intItemId
	JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId
	JOIN tblCTPricingType pt on pt.intPricingTypeId=CDT.intPricingTypeId
	JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	CDT.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND CDT.intUnitMeasureId=ium.intUnitMeasureId 
    WHERE  dblPricedQuantity < dblRecQty

    UNION ALL

    SELECT  
	c.strCommodityCode,
		c.intCommodityId,
		ch.intContractHeaderId,
	    strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
		,strLocationName,
		dtmEndDate,
		CDT.dblBalance,
		CDT.intUnitMeasureId
		,CDT.intPricingTypeId,
		ch.intContractTypeId
		,cl.intCompanyLocationId
		,ct.strContractType 
		,pt.strPricingType
		,ium.intCommodityUnitMeasureId,
		CDT.intContractDetailId,
		CDT.intContractStatusId,
		EY.intEntityId
		,CDT.intCurrencyId
		,case when pt.intPricingTypeId=1 then ct.strContractType+' Priced'  else  ct.strContractType+' Basis' end AS strType
		,IM.intItemId
		,IM.strItemNo,ch.dtmContractDate,strEntityName,ch.strCustomerContract
    FROM    tblCTContractDetail CDT
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId  not in(2,3,6)
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
    WHERE   CDT.intContractDetailId NOT IN (SELECT intContractDetailId FROM Pricing)
   
	UNION 

	 SELECT  
	c.strCommodityCode,
		c.intCommodityId,
		ch.intContractHeaderId,
	    strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
		,strLocationName,
		dtmEndDate,
		CDT.dblBalance dblBalance,
		CDT.intUnitMeasureId
		,CDT.intPricingTypeId,
		ch.intContractTypeId
		,cl.intCompanyLocationId
		,ct.strContractType 
		,pt.strPricingType
		,ium.intCommodityUnitMeasureId,
		CDT.intContractDetailId,
		CDT.intContractStatusId,
		EY.intEntityId
		,CDT.intCurrencyId
		,ct.strContractType+' '+strPricingType AS strType
		,IM.intItemId
		,IM.strItemNo,ch.dtmContractDate,strEntityName,ch.strCustomerContract
    FROM tblCTContractDetail CDT
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId  not in(2,3,6)
	JOIN	vyuCTEntity							EY	ON	EY.intEntityId						=		ch.intEntityId			AND														
														1 = (
															CASE 
																WHEN ch.intContractTypeId = 1 AND EY.strEntityType = 'Vendor' THEN 1 
																WHEN ch.intContractTypeId <> 1 AND EY.strEntityType = 'Customer' THEN 1 
																ELSE 0
															END
														) 
	JOIN	tblICItem			 IM	ON	IM.intItemId				=	CDT.intItemId
	JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId and CDT.intPricingTypeId not in (1,2)
	JOIN tblCTPricingType pt on pt.intPricingTypeId=CDT.intPricingTypeId
	JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	CDT.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND CDT.intUnitMeasureId=ium.intUnitMeasureId 
    WHERE   CDT.intContractDetailId NOT IN (SELECT intContractDetailId FROM Pricing)
    AND CDT.dblQuantity >   isnull(CDT.dblInvoicedQty,0) and isnull(CDT.dblBalance,0) > 0
) t