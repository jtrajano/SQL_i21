CREATE VIEW  vyuRKCollateralNotMapping

AS 

SELECT 
	  intCollateralId
	, strContractNumber
	, strItemNo
	, strCommodityCode
	, strLocationName
	, strUnitMeasure 
FROM tblRKCollateral c
JOIN tblICCommodity co on c.intCommodityId=co.intCommodityId
LEFT JOIN tblICItem itm on itm.intItemId = c.intItemId
JOIN tblICUnitMeasure m on m.intUnitMeasureId=c.intUnitMeasureId
JOIN tblSMCompanyLocation l on l.intCompanyLocationId=c.intLocationId
LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId=ch.intContractHeaderId