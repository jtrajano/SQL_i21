CREATE VIEW vyuQMSearchCommodityAttribute
AS
SELECT intCommodityId		=	 C.intCommodityId
	 , intCommodityAttributeId	= CA.intCommodityAttributeId
	 , strType					= CA.strType
	 , strDescription			= CA.strDescription
	 , strCommodityCode			= C.strCommodityCode
FROM tblICCommodity C
INNER JOIN tblICCommodityAttribute CA ON C.intCommodityId = CA.intCommodityId
WHERE CA.strType IN ('Origin', 'ProductType')