CREATE VIEW [dbo].[vyuApiGetTaxDetail]
AS 

SELECT
      st.intSalesOrderDetailTaxId
    , c.intCategoryId
    , i.strItemNo
    , i.intItemId
    , c.strCategoryCode
    , tc.strTaxClass
    , td.strTaxCode
    , td.intTaxCodeId
    , tc.intTaxClassId
    , ysnTaxMatched = CAST(1 AS BIT)
    , sod.intSalesOrderId
    , ysnSpecialTax = CAST(1 AS BIT)
    , st.ysnTaxExempt
    , st. ysnInvalidSetup
    , dblTax = st.dblTax
    , st.dblRate
    , sod.dblStandardWeight
    , st.strCalculationMethod
    , st.ysnTaxAdjusted
    , st.dblAdjustedTax
    , st.intSalesOrderDetailId
FROM tblSOSalesOrderDetail sod
JOIN tblSOSalesOrderDetailTax st ON st.intSalesOrderDetailId = sod.intSalesOrderDetailId
JOIN tblSMTaxClass tc ON tc.intTaxClassId = st.intTaxClassId
JOIN tblSMTaxCode td ON td.intTaxCodeId = st.intTaxCodeId
JOIN tblICItem i ON i.intItemId = sod.intItemId
JOIN tblICCategory c ON c.intCategoryId = i.intCategoryId
