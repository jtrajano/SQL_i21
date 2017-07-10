CREATE VIEW [dbo].[vyuGRGetSettleItem]
AS 
SELECT DISTINCT
 CS.intEntityId
,CS.intCompanyLocationId    
,CS.intItemId  
,Item.strItemNo
,ST.ysnCustomerStorage
,Com.ysnExchangeTraded
,ISNULL(Com.intFutureMarketId,0) AS intFutureMarketId
,Com.dblPriceCheckMin
,Com.dblPriceCheckMax
,Com.intCommodityId
,UOM.intItemUOMId AS intCommodityStockUomId
FROM tblGRCustomerStorage CS
JOIN tblICItem Item ON Item.intItemId = CS.intItemId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId
JOIN tblICCommodity Com ON Com.intCommodityId=Item.intCommodityId
JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = Com.intCommodityId AND CU.ysnStockUnit = 1
JOIN tblICItemUOM UOM ON UOM.intItemId=Item.intItemId AND UOM.intUnitMeasureId=CU.intUnitMeasureId
WHERE CS.dblOpenBalance >0 AND ISNULL(CS.strStorageType,'') <> 'ITR'
