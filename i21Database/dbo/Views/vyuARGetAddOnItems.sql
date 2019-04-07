CREATE VIEW [dbo].[vyuARGetAddOnItems]
AS 
SELECT intItemAddOnId		= ITEMADDON.intItemAddOnId
	 , intItemId			= ITEMADDON.intItemId
     , intComponentItemId	= ITEMADDON.intAddOnItemId
	 , intItemUnitMeasureId	= ITEMADDON.intItemUOMId
	 , intUnitMeasureId		= ITEMUOM.intUnitMeasureId
	 , intCompanyLocationId	= ITEMLOCATION.intLocationId
	 , intSubLocationId		= ITEMLOCATION.intSubLocationId
	 , intStorageLocationId	= ITEMLOCATION.intStorageLocationId
	 , strDescription		= ITEM.strDescription
	 , strItemNo			= ITEM.strItemNo
	 , strUnitMeasure		= ITEMUOM.strUnitMeasure
	 , strStorageLocation	= STORAGELOCATION.strName
	 , strStorageUnit		= SUBLOCATION.strSubLocationName
	 , dblQuantity			= ITEMADDON.dblQuantity
	 , dblPrice				= dbo.fnICConvertUOMtoStockUnit(ITEMADDON.intAddOnItemId, ITEMADDON.intItemUOMId, 1) * ITEMLOCATION.dblSalePrice
	 , ysnAutoAdd			= ITEMADDON.ysnAutoAdd
FROM dbo.tblICItemAddOn ITEMADDON WITH (NOLOCK)
INNER JOIN (
	SELECT intItemId
		 , strDescription
		 , strItemNo
	FROM dbo.tblICItem WITH (NOLOCK)
) ITEM ON ITEMADDON.intAddOnItemId = ITEM.intItemId
INNER JOIN (
	SELECT intItemId
		 , intItemUOMId
		 , UOM.intUnitMeasureId
		 , UOM.strUnitMeasure
	FROM dbo.tblICItemUOM IUOM WITH (NOLOCK)
	INNER JOIN (
		SELECT intUnitMeasureId
			 , strUnitMeasure
		FROM dbo.tblICUnitMeasure WITH (NOLOCK)
	) UOM ON IUOM.intUnitMeasureId = UOM.intUnitMeasureId
) ITEMUOM ON ITEMADDON.intItemUOMId = ITEMUOM.intItemUOMId
INNER JOIN (
	SELECT intItemId			= IL.intItemId
		 , intLocationId		= IL.intLocationId
		 , intSubLocationId		= IL.intSubLocationId
		 , intStorageLocationId	= IL.intStorageLocationId
		 , dblSalePrice			= ISNULL(ITEMPRICING.dblSalePrice, 0)
	FROM dbo.tblICItemLocation IL WITH (NOLOCK)
	INNER JOIN (
		SELECT intCompanyLocationId 
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
	) COMPANYLOCATION ON COMPANYLOCATION.intCompanyLocationId = IL.intLocationId
	LEFT JOIN (
		SELECT intItemId
			 , intItemLocationId 
			 , dblSalePrice
		FROM dbo.tblICItemPricing WITH (NOLOCK)
	) ITEMPRICING ON IL.intItemId = ITEMPRICING.intItemId AND IL.intItemLocationId = ITEMPRICING.intItemLocationId	
) ITEMLOCATION ON ITEMLOCATION.intItemId = ITEM.intItemId AND ITEMLOCATION.intLocationId IS NOT NULL
LEFT JOIN (
	SELECT intStorageLocationId
		 , strName
	FROM dbo.tblICStorageLocation WITH (NOLOCK)
) STORAGELOCATION ON STORAGELOCATION.intStorageLocationId = ITEMLOCATION.intStorageLocationId
LEFT JOIN (
	SELECT intCompanyLocationSubLocationId
		 , strSubLocationName
	FROM dbo.tblSMCompanyLocationSubLocation WITH (NOLOCK)
) SUBLOCATION ON SUBLOCATION.intCompanyLocationSubLocationId = ITEMLOCATION.intSubLocationId