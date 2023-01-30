CREATE VIEW [dbo].[vyuApiSalesOrderDetail]
AS
SELECT
      vd.intItemId
    , vd.intSalesOrderDetailId
    , vd.intSalesOrderId
    , vd.strItemNo
    , vd.intContractSeq
    , vd.strItemDescription
    , vd.ysnItemContract
    , vd.strContractNumber
    , u.strUnitMeasure
    , vd.intUnitMeasureId
    , vd.dblQtyShipped
    , vd.dblQtyOrdered
    , vd.dblQtyAllocated
    , vd.dblDiscount
    , vd.dblPrice
    , vd.dblTotalTax
    , vd.strTaxGroup
    , vd.intTaxGroupId
    , vd.strSubLocation strStorageLocation
    , vd.intSubLocationId intStorageLocationId
    , vd.strStorageLocation strStorageUnit
    , vd.intStorageLocationId intStorageUnitId
    , vd.dblStandardWeight
    , vd.dblTotal
    , st.dblUnitOnHand
    , st.dblOrderCommitted
    , st.dblOnOrder
    , st.dblBackOrder
    , cur.intCurrencyID
    , cur.strCurrency
FROM vyuSOGetSalesOrderDetail vd
JOIN vyuSOGetSalesOrder o ON o.intSalesOrderId = vd.intSalesOrderId
JOIN tblSOSalesOrderDetail sd ON sd.intSalesOrderDetailId = vd.intSalesOrderDetailId
LEFT JOIN vyuICItemUOM u ON u.intItemUOMId = vd.intItemUOMId
LEFT JOIN tblICItem i ON i.intItemId = vd.intItemId
LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = sd.intSubCurrencyId
LEFT JOIN vyuICGetItemStock st ON st.intItemId = i.intItemId 
    AND st.intSubLocationId IS NULL
    AND st.intStorageLocationId IS NULL
    AND st.intIssueUOMId = vd.intItemUOMId
    AND st.intLocationId = o.intCompanyLocationId
    AND st.ysnActive = 1
    AND (NOT ((N'Discontinued' = st.[strStatus]) AND (st.[strStatus] IS NOT NULL)))