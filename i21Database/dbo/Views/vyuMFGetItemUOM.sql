CREATE VIEW [dbo].[vyuMFGetItemUOM]
AS 
/**
 * Created By: Jonathan Valenzuela
 * Created Date: 02/13/2023
 * Title: Item UOM 
 * JIRA: MFG-4852
 * Return all UOM of an item.
 **/
SELECT ItemUOM.intItemUOMId
	 , ItemUOM.intItemId
	 , Item.strItemNo
	 , ItemUOM.intUnitMeasureId
	 , UOM.strUnitMeasure
	 , UOM.strSymbol
	 , ItemUOM.ysnStockUnit
FROM tblICItem AS Item
LEFT JOIN tblICItemUOM AS ItemUOM ON Item.intItemId = ItemUOM.intItemId
LEFT JOIN tblICUnitMeasure AS UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICUnitMeasure AS WeightUOM ON WeightUOM.intUnitMeasureId = ItemUOM.intWeightUOMId
LEFT JOIN tblICUnitMeasure AS DimensionUOM ON DimensionUOM.intUnitMeasureId = ItemUOM.intDimensionUOMId
LEFT JOIN tblICUnitMeasure AS VolumeUOM ON VolumeUOM.intUnitMeasureId = ItemUOM.intWeightUOMId