CREATE VIEW vyuLGInsurancePremiumFactor

AS

SELECT IP.intInsurancePremiumFactorId
	, IP.strPolicyNumber
	, IP.intEntityId
	, E.strName AS strInsurer
	, IP.dtmValidFrom
	, IP.dtmValidTo
	, IP.dblInboundWarehouse
	, IP.intCommodityId
	, strCommodity = com.strCommodityCode
	, IP.intCommodityAttributeId
	, strProductType = comAtt.strDescription
FROM tblLGInsurancePremiumFactor IP
JOIN tblEMEntity E ON E.intEntityId = IP.intEntityId
LEFT JOIN tblICCommodity com ON com.intCommodityId = IP.intCommodityId
LEFT JOIN tblICCommodityAttribute comAtt ON comAtt.intCommodityAttributeId = IP.intCommodityAttributeId AND comAtt.strType = 'ProductType'