CREATE VIEW vyuRKGetItemList
AS
SELECT 
	 I.strItemNo
	,I.intItemId
	,C.intCommodityId 
	,C.strCommodityCode
	,IUOM.intUnitMeasureId
	,UM.strUnitMeasure
FROM tblICItem I  
INNER JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
INNER JOIN tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId AND ysnStockUnit = 1
INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IUOM.intUnitMeasureId
WHERE strType = 'Inventory'
