CREATE VIEW [dbo].[vyuSTMarkUpDownItems]
AS
SELECT 
I.strItemNo
,I.strDescription
,UOM.intItemUOMId
,UOM.strUpcCode
,UOM.strLongUPCCode
,UM.strUnitMeasure AS strUnitOfMeasure
,I.intItemId
,IL.intLocationId
,ST.intStoreId
,ST.intStoreNo
,vyupriceHierarchy.dblSalePrice
,vyupriceHierarchyStockUnit.dblSalePrice AS dblRetailItemPerUnit
,vyupriceHierarchyStockUnit.dblSalePrice AS dblStockUnitPrice
,I.intCategoryId,
vyupriceHierarchy.dblLastCost
FROM tblICItem I 
INNER JOIN tblICItemLocation IL 
	ON I.intItemId = IL.intItemId
INNER JOIN tblICItemUOM UOM 
	ON UOM.intItemId = IL.intItemId
INNER JOIN tblICUnitMeasure UM 
	ON UOM.intUnitMeasureId = UM.intUnitMeasureId
--FOR Price hierarchy --
INNER JOIN vyuSTItemHierarchyPricing vyupriceHierarchy
	ON I.intItemId = vyupriceHierarchy.intItemId 
	AND IL.intItemLocationId = vyupriceHierarchy.intItemLocationId
	AND UOM.intItemUOMId = vyupriceHierarchy.intItemUOMId
INNER JOIN ( 
	SELECT SIP.intItemId, intItemLocationId, SIP.intItemUOMId, 
		CASE WHEN UOM.ysnStockUnit = 1
			THEN dblSalePrice 
			ELSE 
			(
				SELECT UOM.dblUnitQty * HP.dblSalePrice 
				FROM vyuSTItemHierarchyPricing HP
				JOIN tblICItemUOM UOMM
					ON HP.intItemUOMId = UOMM.intItemUOMId
					AND UOMM.ysnStockUnit = 1
				WHERE HP.intItemId = SIP.intItemId
				AND HP.intItemLocationId = SIP.intItemLocationId
			)
		END AS dblSalePrice
		FROM vyuSTItemHierarchyPricing SIP
		JOIN tblICItemUOM UOM
		ON SIP.intItemUOMId = UOM.intItemUOMId
	) vyupriceHierarchyStockUnit
	ON I.intItemId = vyupriceHierarchyStockUnit.intItemId 
	AND IL.intItemLocationId = vyupriceHierarchyStockUnit.intItemLocationId
	AND UOM.intItemUOMId = vyupriceHierarchyStockUnit.intItemUOMId
INNER JOIN tblSTStore ST 
	ON IL.intLocationId = ST.intCompanyLocationId
WHERE I.strLotTracking = 'No'
AND ISNULL(I.intCategoryId, 0) <> 0
--AND IL.intCostingMethod = 6