CREATE VIEW [dbo].[vyuApiPurchaseOrderDetail]
AS
SELECT
      pd.intPurchaseDetailId
    , po.intPurchaseId
    , pd.intItemId
    , i.strItemNo
    , i.strDescription AS strItemDescription
    , pd.strMiscDescription
    , pd.intUnitOfMeasureId
    , um.strUnitMeasure
    , pd.strAdditionalInfo
    , pd.dblCost
    , pd.dblCostUnitQty
    , pd.dblDiscount
    , pd.dblForexRate
    , pd.dblNetWeight
    , pd.dblQtyContract
    , pd.dblQtyOrdered
    , pd.dblQtyReceived
    , pd.dblStandardWeight
    , pd.dblTax
    , pd.dblTotal
    , pd.dblUnitQty
    , pd.dblVolume
    , pd.dblWeight
    , pd.dblWeightUnitQty
    , pd.intSubLocationId AS intStorageLocationId
    , sbl.strSubLocationName AS strStorageLocation
    , pd.intStorageLocationId AS intStorageUnitId
    , su.strName AS strStorageUnit
    , acc.strAccountId
    , acc.strAccountGroup
    , acc.strDescription strAccountDescription
FROM tblPOPurchase po
JOIN tblPOPurchaseDetail pd ON pd.intPurchaseId = po.intPurchaseId
LEFT JOIN tblICItem i ON i.intItemId = pd.intItemId
LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = pd.intUnitOfMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation sbl ON sbl.intCompanyLocationSubLocationId = pd.intSubLocationId
LEFT JOIN tblICStorageLocation su ON su.intStorageLocationId = pd.intStorageLocationId
LEFT JOIN vyuGLAccountDetail acc ON acc.intAccountId = pd.intAccountId