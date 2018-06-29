CREATE VIEW [dbo].[vyuICGetItemUOM]
	AS 

SELECT 
ItemUOM.intItemUOMId
, ItemUOM.intItemId
, ItemUOM.intUnitMeasureId
, UOM.strUnitMeasure
, UOM.strSymbol
, UOM.strUnitType
, ItemUOM.dblUnitQty
, ItemUOM.dblWeight
, ItemUOM.intWeightUOMId
, strWeightUOM = WeightUOM.strUnitMeasure
, ItemUOM.strUpcCode
, ItemUOM.strLongUPCCode
, ItemUOM.ysnStockUnit
, ItemUOM.ysnAllowPurchase
, ItemUOM.ysnAllowSale
, ItemUOM.dblLength
, ItemUOM.dblWidth
, ItemUOM.dblHeight
, ItemUOM.intDimensionUOMId
, strDimensionUOM = DimensionUOM.strUnitMeasure
, ItemUOM.dblVolume
, ItemUOM.intVolumeUOMId
, strVolumeUOM = VolumeUOM.strUnitMeasure
, ItemUOM.dblMaxQty
, ItemUOM.intSort
FROM tblICItemUOM ItemUOM
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemUOM.intWeightUOMId
LEFT JOIN tblICUnitMeasure DimensionUOM ON DimensionUOM.intUnitMeasureId = ItemUOM.intDimensionUOMId
LEFT JOIN tblICUnitMeasure VolumeUOM ON VolumeUOM.intUnitMeasureId = ItemUOM.intWeightUOMId