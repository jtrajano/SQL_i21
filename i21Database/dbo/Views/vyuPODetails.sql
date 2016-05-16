﻿CREATE VIEW [dbo].[vyuPODetails]
AS
SELECT
 A.intOrderStatusId
 ,B.intPurchaseDetailId
 ,B.intPurchaseId
 ,A.strPurchaseOrderNumber
 ,A.intCurrencyId
 ,B.intItemId
 ,B.intUnitOfMeasureId
 ,B.intAccountId
 ,B.intStorageLocationId
 ,B.intSubLocationId
 ,B.intLocationId
 ,I.strLocationName AS strShipToLocation
 ,J.strLocationName AS strShipFromLocation
 ,B.dblQtyOrdered
 ,B.dblQtyReceived
 ,B.dblQtyContract
 ,B.dblVolume
 ,B.dblWeight
 ,B.dblDiscount
 ,B.dblCost
 ,B.dblTotal
 ,B.dblTax
 ,B.dtmExpectedDate
 ,B.[strMiscDescription] AS strDescription
 ,B.strPONumber
 ,B.intLineNo
 ,C.strVendorId
 ,C.intEntityVendorId
 ,C2.strName
 ,D.strItemNo
 ,D.strLotTracking
 ,D.intCommodityId
 ,D.intLifeTime
 ,D.strLifeTimeType
 ,H.strUnitMeasure AS strUOM
 ,ISNULL(E.dblUnitQty,0) AS dblItemUOMCF
 ,intStockUOM = ISNULL((SELECT TOP 1 intItemUOMId FROM tblICItemUOM ItemUOM WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = E.intItemUOMId),0)
 ,strStockUOM = (SELECT TOP 1 strUnitMeasure FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = E.intItemUOMId)
 ,strStockUOMType = (SELECT TOP 1 strUnitType FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = E.intItemUOMId)
 ,dblStockUOMCF = ISNULL((SELECT TOP 1 dblUnitQty FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = E.intItemUOMId),0)
 ,F.strSubLocationName
 ,G.strName AS strStorageName
 ,ysnCompleted = CAST((CASE WHEN A.intOrderStatusId IN (1, 2, 7) AND B.dblQtyOrdered != B.dblQtyReceived THEN 0 ELSE 1 END) AS BIT)
 ,D.strType
FROM tblPOPurchase A
 INNER JOIN  tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
 INNER JOIN (tblAPVendor C INNER JOIN tblEntity C2 ON C.intEntityVendorId = C2.intEntityId) ON A.[intEntityVendorId] = C.intEntityVendorId
 LEFT JOIN tblICItem D ON B.intItemId = D.intItemId
 LEFT JOIN tblICItemUOM E ON B.intUnitOfMeasureId = E.intItemUOMId
 LEFT JOIN tblICUnitMeasure H ON E.intUnitMeasureId = H.intUnitMeasureId
 LEFT JOIN tblSMCompanyLocationSubLocation F ON B.intSubLocationId = F.intCompanyLocationSubLocationId
 LEFT JOIN tblICStorageLocation G ON B.intStorageLocationId = G.intStorageLocationId
 INNER JOIN dbo.tblSMCompanyLocation I ON A.intShipToId = I.intCompanyLocationId
 LEFT JOIN tblEntityLocation J ON A.intEntityVendorId = J.intEntityId AND A.intShipFromId = J.intEntityLocationId
 WHERE D.strType NOT IN ('Service','Software','Non-Inventory','Other Charge')