CREATE VIEW vyuQMProductGroupDetailSearch
AS
SELECT intPriorityGroupId		= PG.intPriorityGroupId
	 , intPriorityGroupDetailId	= PGD.intPriorityGroupDetailId
	 , intSortId				= PG.intSortId
	 , intSortDetailId			= PGD.intSortId
	 , intProductTypeId			= PGD.intProductTypeId
	 , intOriginId				= PGD.intOriginId
	 , intExtensionId			= PGD.intExtensionId
	 , intItemId				= PGD.intItemId
	 , strProductType			= PT.strDescription
	 , strOrigin				= O.strDescription
	 , strExtension				= E.strDescription
	 , strItemDescription		= I.strDescription
FROM tblQMPriorityGroup PG
INNER JOIN tblQMPriorityGroupDetail PGD ON PG.intPriorityGroupId = PGD.intPriorityGroupId
LEFT JOIN tblICCommodityAttribute PT ON PGD.intProductTypeId = PT.intCommodityAttributeId AND PT.strType = 'ProductType'
LEFT JOIN tblICCommodityAttribute O ON PGD.intOriginId = O.intCommodityAttributeId AND O.strType = 'Origin'
LEFT JOIN tblICCommodityAttribute E ON PGD.intExtensionId = E.intCommodityAttributeId AND E.strType = 'Season'
LEFT JOIN tblICItem I ON PGD.intItemId = I.intItemId