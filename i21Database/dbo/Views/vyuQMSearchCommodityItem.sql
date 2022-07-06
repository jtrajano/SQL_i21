CREATE VIEW vyuQMSearchCommodityItem
AS
SELECT intItemId			= ITEM.intItemId
	 , intCommodityId		= ITEM.intCommodityId
	 , intOriginId			= ITEM.intOriginId
	 , intProductTypeId		= ITEM.intProductTypeId
	 , intProductLineId		= ITEM.intProductLineId
	 , strItemNo			= ITEM.strItemNo
	 , strCommodityCode		= C.strCommodityCode 
	 , strProductType		= PT.strDescription
	 , strOrigin			= O.strDescription
	 , strProductLine		= CPL.strDescription
FROM tblICItem ITEM
INNER JOIN tblICCommodity C ON ITEM.intCommodityId = C.intCommodityId
LEFT JOIN tblICCommodityAttribute O ON ITEM.intOriginId = O.intCommodityAttributeId AND O.strType = 'Origin'
LEFT JOIN tblICCommodityAttribute PT ON ITEM.intProductTypeId = PT.intCommodityAttributeId AND PT.strType = 'ProductType'
LEFT JOIN tblICCommodityProductLine CPL ON ITEM.intProductLineId = CPL.intCommodityProductLineId