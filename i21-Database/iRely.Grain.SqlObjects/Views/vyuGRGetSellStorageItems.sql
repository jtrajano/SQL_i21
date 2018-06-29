CREATE VIEW [dbo].[vyuGRGetSellStorageItems]
AS   
SELECT DISTINCT
 intItemId				= CS.intItemId
,strItemNo				= Item.strItemNo
,ysnExchangeTraded		= Com.ysnExchangeTraded
,intFutureMarketId		= ISNULL(Com.intFutureMarketId,0)
,dblPriceCheckMin		= Com.dblPriceCheckMin
,dblPriceCheckMax		= Com.dblPriceCheckMax
,intCommodityId			= Com.intCommodityId
,intCommodityStockUomId = UOM.intItemUOMId
FROM tblGRCustomerStorage CS
JOIN tblICItem Item ON Item.intItemId = CS.intItemId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId
JOIN tblICCommodity Com ON Com.intCommodityId=Item.intCommodityId
JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = Com.intCommodityId AND CU.ysnStockUnit = 1
JOIN tblICItemUOM UOM ON UOM.intItemId=Item.intItemId AND UOM.intUnitMeasureId=CU.intUnitMeasureId 
Where CS.dblOpenBalance >0 AND ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=1
