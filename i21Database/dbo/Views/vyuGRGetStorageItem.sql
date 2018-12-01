
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
    ,intFutureMarketId = ISNULL(Com.intFutureMarketId,0)
    ,Com.dblPriceCheckMin
    ,Com.dblPriceCheckMax
    ,CS.intCommodityId
    ,intCommodityStockUomId = UOM.intItemUOMId
    ,intItemUOMId = ISNULL(CS.intItemUOMId, UOM.intItemUOMId)
    ,ysnShowInStorage = CAST(
							CASE
								WHEN ST.ysnCustomerStorage = 0 THEN 1
								WHEN ST.ysnCustomerStorage = 1 AND ST.strOwnedPhysicalStock = 'Customer' THEN 1
								ELSE 0
							END AS BIT
						)
    ,ysnStorageItemReady = CAST(
                                CASE
                                    WHEN ysnTransferStorage = 1 THEN 1
                                    ELSE 
                                        CASE
                                            WHEN CS.intTicketId IS NOT NULL THEN 1
                                            WHEN CS.intDeliverySheetId IS NOT NULL THEN (SELECT ysnPost FROM tblSCDeliverySheet WHERE intDeliverySheetId = CS.intDeliverySheetId)
                                        END
                                END AS BIT
                            )
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