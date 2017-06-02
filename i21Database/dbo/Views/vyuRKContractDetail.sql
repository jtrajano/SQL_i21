CREATE VIEW vyuRKContractDetail

AS

SELECT c.strCommodityCode,
		c.intCommodityId,
		ch.intContractHeaderId,
	    strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
		,ct.strContractType+ ' ' + pt.strPricingType [strType]
		,strLocationName,
		dtmEndDate,
		isnull((cd.dblBalance),0) dblBalance,
		cd.intUnitMeasureId
		,cd.intPricingTypeId,
		ch.intContractTypeId
		,cl.intCompanyLocationId
		,ct.strContractType 
		,pt.strPricingType
		,ium.intCommodityUnitMeasureId,
		intContractDetailId,
		cd.intContractStatusId,
		intEntityId
		,cd.intCurrencyId
FROM tblCTContractDetail cd
	JOIN tblCTContractHeader ch on ch.intContractHeaderId=cd.intContractHeaderId AND cd.intContractStatusId <> 3
	JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId
	JOIN tblCTPricingType pt on pt.intPricingTypeId=cd.intPricingTypeId
	JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	cd.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 