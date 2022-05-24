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
,I.intCategoryId
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
INNER JOIN tblSTStore ST 
	ON IL.intLocationId = ST.intCompanyLocationId
WHERE I.strLotTracking = 'No'
AND IL.intCostingMethod = 6