CREATE VIEW vyuQMProductGroupDetailSearch
AS
SELECT intPriorityGroupId		= PG.intPriorityGroupId
	 , intPriorityGroupDetailId	= PGD.intPriorityGroupDetailId
	 , intSortId				= PG.intSortId
	 , intConcurrencyId			= PGD.intConcurrencyId
	 , intSortDetailId			= PGD.intSortId
	 , intProductTypeId			= PGD.intProductTypeId
	 , intOriginId				= PGD.intOriginId
	 , intExtensionId			= PGD.intExtensionId
	 , intItemId				= PGD.intItemId
	 , strProductType			= PT.strDescription
	 , strOrigin				= O.strDescription
	 , strExtension				= PL.strDescription
	 , strItemDescription		= ITEM.strItemNo
FROM tblQMPriorityGroupDetail PGD
LEFT JOIN tblQMPriorityGroup PG ON PGD.intPriorityGroupId = PG.intPriorityGroupId
LEFT JOIN tblICCommodityAttribute PT ON PGD.intProductTypeId = PT.intCommodityAttributeId AND PT.strType = 'ProductType'
LEFT JOIN tblICCommodityAttribute O ON PGD.intOriginId = O.intCommodityAttributeId AND O.strType = 'Origin'
LEFT JOIN tblICCommodityProductLine PL ON PGD.intExtensionId = PL.intCommodityProductLineId
LEFT JOIN tblICItem ITEM ON PGD.intItemId = ITEM.intItemId