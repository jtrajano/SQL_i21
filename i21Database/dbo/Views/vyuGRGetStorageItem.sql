CREATE VIEW [dbo].[vyuGRGetStorageItem]
AS  
SELECT DISTINCT
    CS.intEntityId
    ,CS.intCompanyLocationId    
    ,CS.intItemId  
    ,Item.strItemNo
    ,Item.strDescription
    ,ST.ysnCustomerStorage
    ,COM.ysnExchangeTraded
    ,intFutureMarketId = ISNULL(COM.intFutureMarketId,0)
    ,COM.dblPriceCheckMin
    ,COM.dblPriceCheckMax
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
    ,strItemUnitMeasure = UM.strUnitMeasure
    ,strItemSymbol = UM.strSymbol
FROM tblGRCustomerStorage CS
JOIN tblICItem Item 
    ON Item.intItemId = CS.intItemId
JOIN tblICItemUOM UOM 
    ON UOM.intItemId = Item.intItemId
		AND UOM.ysnStockUnit = 1
JOIN tblICCommodity COM
	ON COM.intCommodityId = Item.intCommodityId
JOIN tblGRStorageType ST 
    ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
JOIN tblICUnitMeasure UM
	ON UM.intUnitMeasureId = UOM.intUnitMeasureId
WHERE CS.dblOpenBalance > 0 