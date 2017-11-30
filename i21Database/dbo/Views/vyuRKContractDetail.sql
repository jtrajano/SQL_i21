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
		SUM(PFD.dblQuantity) dblQuantity,
		CDT.intUnitMeasureId
		,CDT.intPricingTypeId,
		ch.intContractTypeId
		,cl.intCompanyLocationId
		,ct.strContractType 
		,pt.strPricingType
		,ium.intCommodityUnitMeasureId,
		CDT.intContractDetailId,
		CDT.intContractStatusId,
		intEntityId
		,CDT.intCurrencyId
    FROM    tblCTPriceFixationDetail  PFD
    JOIN    tblCTPriceFixation   PFX ON PFX.intPriceFixationId   = PFD.intPriceFixationId
    JOIN    tblCTContractDetail   CDT ON CDT.intContractDetailId  = PFX.intContractDetailId and CDT.intPricingTypeId IN (1,2)
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId <> 3
	JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId
	JOIN tblCTPricingType pt on pt.intPricingTypeId=CDT.intPricingTypeId
	JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	CDT.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND CDT.intUnitMeasureId=ium.intUnitMeasureId 
    WHERE   CDT.dblQuantity >   isnull(CDT.dblInvoicedQty,0) 
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
						intEntityId
						,CDT.intCurrencyId
    )
	SELECT * FROM (
    SELECT   strCommodityCode,
		intCommodityId,
		intContractHeaderId,
	    strContractNumber
		,strLocationName,
		dtmEndDate,
		dblQuantity dblBalance,
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
    FROM    Pricing

    UNION ALL

    SELECT  c.strCommodityCode,
		c.intCommodityId,
		ch.intContractHeaderId,
	   ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
		,cl.strLocationName,
		CDT.dtmEndDate,
		CDT.dblBalance - PRC.dblQuantity AS dblBalance,
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
    FROM    tblCTContractDetail CDT
    JOIN    Pricing     PRC ON CDT.intContractDetailId = PRC.intContractDetailId and CDT.intPricingTypeId IN (1,2)
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId <> 3
	JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId
	JOIN tblCTPricingType pt on pt.intPricingTypeId=CDT.intPricingTypeId
	JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	CDT.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND CDT.intUnitMeasureId=ium.intUnitMeasureId 
    WHERE   CDT.dblQuantity <> PRC.dblQuantity AND CDT.dblQuantity >   isnull(CDT.dblInvoicedQty,0) 

    UNION ALL

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
		intEntityId
		,CDT.intCurrencyId
		,CASE WHEN CDT.intPricingTypeId = 1 THEN ct.strContractType+' Priced' ELSE ct.strContractType+' Basis' END AS strType
    FROM    tblCTContractDetail CDT
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId <> 3
	JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId and CDT.intPricingTypeId IN (1,2)
	JOIN tblCTPricingType pt on pt.intPricingTypeId=CDT.intPricingTypeId
	JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	CDT.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND CDT.intUnitMeasureId=ium.intUnitMeasureId 
    WHERE   CDT.intContractDetailId NOT IN (SELECT intContractDetailId FROM Pricing)
    AND CDT.dblQuantity >   isnull(CDT.dblInvoicedQty,0) 

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
		intEntityId
		,CDT.intCurrencyId
		,CASE WHEN CDT.intPricingTypeId = 3 THEN ct.strContractType+'HTA' END AS strType
    FROM    tblCTContractDetail CDT
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=CDT.intContractHeaderId AND CDT.intContractStatusId <> 3
	JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId and CDT.intPricingTypeId =3
	JOIN tblCTPricingType pt on pt.intPricingTypeId=CDT.intPricingTypeId
	JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	CDT.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND CDT.intUnitMeasureId=ium.intUnitMeasureId 
    WHERE   CDT.intContractDetailId NOT IN (SELECT intContractDetailId FROM Pricing)
    AND CDT.dblQuantity >   isnull(CDT.dblInvoicedQty,0) 
) t 