CREATE VIEW [dbo].[vyuAPBillDetailImport]
AS
SELECT 
	Contract.strContractNumber,
	Purchase.strPurchaseOrderNumber,
	Item.strItemNo,
	B.intPrepayTypeId,
	Prepay.strText COLLATE Latin1_General_CI_AS AS strPrepayType,
	B.strMiscDescription,
	ItemUOM.strUnitMeasure strUOM,
	B.dblQtyContract,
	B.dblQtyReceived,
	B.dblQtyOrdered,
	B.dblPrepayPercentage,
	B.dblContractCost,
	B.ysnRestricted,
	B.ysnSubCurrency,
	CUR.strCurrency strSubCurrency,
	ExchangeRateType.strCurrencyExchangeRateType,
	B.dblRate,
	B.dblCost,
CostUOM.strUnitMeasure strCostUOM,
	WeightUOM.strUnitMeasure strWeightUOM,
	B.dblNetWeight,
	B.dblNetShippedWeight,
	B.dblWeightLoss,
	B.dblFranchiseWeight,
	B.dblClaimAmount,
	B.dblDiscount,
	B.dblTax,
	B.dblTotal  dblTotal,
	B.dblLandedCost,
	H.strAccountId,
	B.strComment,
	B.dblWeight,
	B.dblVolume,
	B.dtmExpectedDate,
	SN.strSourceNumber,
	Form1099.strText COLLATE Latin1_General_CI_AS AS str1099Form,
	Category1099.strText COLLATE Latin1_General_CI_AS AS str1099Category,
	A.intBillId
	
FROM dbo.tblAPBill A

LEFT JOIN dbo.tblAPBillDetail B ON A.intBillId = B.intBillId
LEFT JOIN dbo.tblAPVendor G  ON G.[intEntityId] = A.intEntityVendorId
LEFT JOIN dbo.tblEMEntity G2 ON G.[intEntityId] = G2.intEntityId
LEFT JOIN tblSMCurrencyExchangeRateType ExchangeRateType ON ExchangeRateType.intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId
LEFT JOIN dbo.vyuAPItemUOM ItemUOM ON B.intUnitOfMeasureId = ItemUOM.intItemUOMId
LEFT JOIN dbo.vyuAPItemUOM CostUOM ON CostUOM.intItemUOMId = B.intCostUOMId
LEFT JOIN dbo.vyuAPItemUOM WeightUOM ON WeightUOM.intItemUOMId = B.intWeightUOMId
LEFT JOIN dbo.vyuAPBillDetailSource SN ON SN.intBillDetailId = B.intBillDetailId
LEFT JOIN dbo.tblCTContractHeader Contract ON Contract.intContractHeaderId = B.intContractHeaderId
LEFT JOIN dbo.tblGLAccount H ON B.intAccountId = H.intAccountId 
LEFT JOIN dbo.tblICItem Item 	ON B.intItemId = Item.intItemId
LEFT JOIN dbo.tblSMCurrency CUR ON CUR.intCurrencyID = A.intCurrencyId
OUTER APPLY(
	SELECT TOP 1 A.strPurchaseOrderNumber from tblPOPurchase A
	JOIN dbo.tblPOPurchaseDetail C
 	ON A.intPurchaseId = C.intPurchaseId
 	WHERE C.intPurchaseDetailId = B.intPurchaseDetailId
)Purchase
OUTER APPLY (SELECT TOP 1 strText FROM dbo.[fnAPGetVoucherForm1099]() where intId = B.int1099Form) Form1099
OUTER APPLY (SELECT TOP 1 strText FROM dbo.[fnAPGetVoucherCategories1099]() WHERE intId = B.int1099Category) Category1099
OUTER APPLY (SELECT TOP 1 strText FROM dbo.[fnAPGetVoucherPrepayType]() WHERE intId = B.intPrepayTypeId) Prepay





GO
