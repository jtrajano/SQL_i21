CREATE VIEW [dbo].[vyuRKGetCollateral]
	AS 
	SELECT 
	  intCollateralId
	, strReceiptNo
	, dtmOpenDate
	, c.strType
	, ysnIncludeInPriceRiskAndCompanyTitled
	, c.intItemId
	, c.intCommodityId
	, intLocationId
	, strCustomer
	, dblOriginalQuantity
	, dblRemainingQuantity
	, c.intUnitMeasureId
	, c.intContractHeaderId
	, intTransNo
	, strComments
	, strContractNumber
	, strItemNo
	, strCommodityCode
	, strLocationName
	, strUnitMeasure 
FROM tblRKCollateral c
JOIN tblICCommodity co on c.intCommodityId = co.intCommodityId
LEFT JOIN tblICItem itm on itm.intItemId = c.intItemId
JOIN tblICUnitMeasure m on m.intUnitMeasureId = c.intUnitMeasureId
JOIN tblSMCompanyLocation l on l.intCompanyLocationId = c.intLocationId
LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId = ch.intContractHeaderId
