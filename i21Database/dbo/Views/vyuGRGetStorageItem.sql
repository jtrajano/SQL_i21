
CREATE VIEW [dbo].[vyuGRGetStorageItem]
AS  
SELECT DISTINCT
    CS.intEntityId
    ,CS.intCompanyLocationId    
    ,CS.intItemId  
    ,Item.strItemNo
    ,Item.strDescription
    ,ST.ysnCustomerStorage
    ,Com.ysnExchangeTraded
    ,ISNULL(Com.intFutureMarketId,0) AS intFutureMarketId
    ,Com.dblPriceCheckMin
    ,Com.dblPriceCheckMax
    ,CS.intCommodityId
    ,UOM.intItemUOMId AS intCommodityStockUomId
    ,ISNULL(CS.intItemUOMId, UOM.intItemUOMId) AS intItemUOMId
    ,CAST(
        CASE
            WHEN ST.ysnCustomerStorage = 0 THEN 1
            WHEN ST.ysnCustomerStorage = 1 AND ST.strOwnedPhysicalStock = 'Customer' THEN 1
            ELSE 0
        END AS BIT
    ) AS ysnShowInStorage
FROM tblGRCustomerStorage CS
JOIN tblICItem Item 
    ON Item.intItemId = CS.intItemId
JOIN tblGRStorageType ST 
    ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
JOIN tblICCommodity Com 
    ON Com.intCommodityId = Item.intCommodityId
JOIN tblICCommodityUnitMeasure CU 
    ON CU.intCommodityId = Com.intCommodityId 
        AND CU.ysnStockUnit = 1
JOIN tblICItemUOM UOM 
    ON UOM.intItemId = Item.intItemId 
        AND UOM.intUnitMeasureId = CU.intUnitMeasureId
WHERE CS.dblOpenBalance > 0 