CREATE VIEW [dbo].[vyuICGetBundleItem]
	AS
	
--SELECT ItemBundle.intItemBundleId
--	, ItemBundle.intItemId
--	, Item.strItemNo
--	, strItemDescription = Item.strDescription
--	, ItemBundle.intBundleItemId
--	, strComponent = BundleComponent.strItemNo
--	, strComponentDescription = BundleComponent.strDescription
--	, ItemBundle.strDescription
--	, ItemBundle.dblQuantity
--	, ItemBundle.intItemUnitMeasureId
--	, dblConversionFactor = ItemUOM.dblUnitQty
--	, UOM.strUnitMeasure
--	, ItemUOM.dblUnitQty
--	, ItemBundle.dblMarkUpOrDown
--	, ItemBundle.dtmBeginDate
--	, ItemBundle.dtmEndDate
--FROM	tblICItemBundle ItemBundle
--		LEFT JOIN tblICItem Item ON Item.intItemId = ItemBundle.intItemId
--		LEFT JOIN tblICItem BundleComponent ON BundleComponent.intItemId = ItemBundle.intBundleItemId
--		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ItemBundle.intItemUnitMeasureId
--		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId

SELECT	ItemBundle.intItemBundleId
		,ItemBundle.intItemId
		,Item.strItemNo
		,ItemBundle.intBundleItemId
		,strComponentItemNo = BundleComponent.strItemNo
		,strDescription = BundleComponent.strDescription
		,ItemBundle.dblQuantity
		,ItemBundle.intItemUnitMeasureId
		,UOM.strUnitMeasure
		,ItemBundle.dblMarkUpOrDown
		,ItemBundle.dtmBeginDate
		,ItemBundle.dtmEndDate
		,ItemBundle.intConcurrencyId
FROM	tblICItemBundle ItemBundle
		LEFT JOIN tblICItem Item ON Item.intItemId = ItemBundle.intItemId
		LEFT JOIN tblICItem BundleComponent ON BundleComponent.intItemId = ItemBundle.intBundleItemId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ItemBundle.intItemUnitMeasureId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId