CREATE VIEW [dbo].[vyuPODetails]
AS
SELECT
 A.intOrderStatusId
 ,B.intPurchaseDetailId
 ,B.intPurchaseId
 ,A.strPurchaseOrderNumber
 ,B.intItemId
 ,B.intUnitOfMeasureId
 ,B.intAccountId
 ,B.intTaxId
 ,B.intStorageLocationId
 ,B.intSubLocationId
 ,B.intLocationId
 ,B.dblQtyOrdered
 ,B.dblQtyReceived
 ,B.dblQtyContract
 ,B.dblVolume
 ,B.dblWeight
 ,B.dblDiscount
 ,B.dblCost
 ,B.dblTotal
 ,B.dtmExpectedDate
 ,B.strDescription
 ,B.strPONumber
 ,B.intLineNo
 ,C.strVendorId
 ,C.intVendorId
 ,D.strItemNo
 ,D.strLotTracking
 ,H.strUnitMeasure AS strUOM
 ,E.dblUnitQty AS dblItemUOMCF
 ,intStockUOM = ISNULL((SELECT TOP 1 intItemUOMId FROM tblICItemUOM ItemUOM WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = E.intItemUOMId),0)
 ,strStockUOM = (SELECT TOP 1 strUnitMeasure FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = E.intItemUOMId)
 ,strStockUOMType = (SELECT TOP 1 strUnitType FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = E.intItemUOMId)
 ,dblStockUOMCF = ISNULL((SELECT TOP 1 dblUnitQty FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = E.intItemUOMId),0)
 ,F.strSubLocationName
 ,G.strName AS strStorageName
FROM tblPOPurchase A
 INNER JOIN  tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
 INNER JOIN tblAPVendor C ON A.intVendorId = C.intVendorId
 LEFT JOIN tblICItem D ON B.intItemId = D.intItemId
 LEFT JOIN tblICItemUOM E ON B.intUnitOfMeasureId = E.intItemUOMId
 LEFT JOIN tblICUnitMeasure H ON E.intUnitMeasureId = H.intUnitMeasureId
 LEFT JOIN tblSMCompanyLocationSubLocation F ON B.intSubLocationId = F.intCompanyLocationSubLocationId
 LEFT JOIN tblICStorageLocation G ON B.intStorageLocationId = G.intStorageLocationId