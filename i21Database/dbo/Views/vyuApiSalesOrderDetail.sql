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
    , vd.dblQtyShipped
    , vd.dblQtyOrdered
    , vd.dblDiscount
    , vd.dblTotalTax
    , vd.strTaxGroup
    , vd.strSubLocation strStorageLocation
    , vd.strStorageLocation strStorageUnit
    , vd.dblStandardWeight
    , vd.dblTotal
    , st.dblUnitOnHand
    , st.dblOrderCommitted
    , st.dblOnOrder
    , st.dblBackOrder
FROM vyuSOGetSalesOrderDetail vd
JOIN vyuSOGetSalesOrder o ON o.intSalesOrderId = vd.intSalesOrderId
LEFT JOIN vyuICItemUOM u ON u.intItemUOMId = vd.intItemUOMId
LEFT JOIN tblICItem i ON i.intItemId = vd.intItemId
LEFT JOIN vyuICGetItemStock st ON st.intItemId = i.intItemId 
    AND st.intSubLocationId IS NULL
    AND st.intStorageLocationId IS NULL
    AND st.intIssueUOMId = vd.intItemUOMId
    AND st.intLocationId = o.intCompanyLocationId
    AND st.ysnActive = 1
    AND (NOT ((N'Discontinued' = st.[strStatus]) AND (st.[strStatus] IS NOT NULL)))