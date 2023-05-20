CREATE VIEW [dbo].[vyuApiGetPurchaseTaxDetail]
AS 

SELECT
      pt.intPurchaseDetailTaxId
    , c.intCategoryId
    , i.strItemNo
    , i.intItemId
    , c.strCategoryCode
    , tc.strTaxClass
    , td.strTaxCode
    , td.intTaxCodeId
    , tc.intTaxClassId
    , ysnTaxMatched = CAST(1 AS BIT)
    , pod.intPurchaseId
    , ysnSpecialTax = CAST(1 AS BIT)
    , pt.ysnTaxExempt
    , ysnInvalidSetup = CAST(0 AS BIT)
    , dblTax = pt.dblTax
    , pt.dblRate
    , pod.dblStandardWeight
    , pt.strCalculationMethod
    , pt.ysnTaxAdjusted
    , pt.dblAdjustedTax
    , pt.intPurchaseDetailId
FROM tblPOPurchaseDetail pod
JOIN tblPOPurchaseDetailTax pt ON pt.intPurchaseDetailId = pod.intPurchaseDetailId
JOIN tblSMTaxClass tc ON tc.intTaxClassId = pt.intTaxClassId
JOIN tblSMTaxCode td ON td.intTaxCodeId = pt.intTaxCodeId
JOIN tblICItem i ON i.intItemId = pod.intItemId
JOIN tblICCategory c ON c.intCategoryId = i.intCategoryId
