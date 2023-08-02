CREATE VIEW [dbo].[vyuAPRestApiVoucherDetail]
AS
SELECT
	  bd.intBillDetailId intVoucherDetailId
	, bd.intBillId intVoucherId
	, ch.strContractNumber
	, cd.intContractSeq
	, bd.intItemId
	, i.strItemNo
	, i.strDescription strItemDescription
	, bds.strSourceNumber
	, bd.strMiscDescription
    , bd.strBundleDescription
    , bd.strComment
    , bd.dblTotal
    , bd.dblBundleTotal
    , bd.dblQtyContract
    , bd.dblQtyOrdered
    , bd.dblQtyReceived
    , bd.dblQtyBundleReceived
    , bd.dblDiscount
    , bd.dblContractCost
    , bd.dblCost
    , bd.dblOldCost
    , bd.dbl1099
    , bd.dblLandedCost
    , bd.dblPrepayPercentage
    , bd.dblWeightUnitQty
    , bd.dblCostUnitQty
    , bd.dblUnitQty
    , bd.dblBundleUnitQty
    , bd.dblNetWeight
    , bd.dblWeight
    , bd.dblActual
    , bd.dblDifference
    , bd.dblVolume
    , bd.dblNetShippedWeight
    , bd.dblWeightLoss
    , bd.dblFranchiseWeight
    , bd.dblFranchiseAmount
    , bd.dblClaimAmount
    , bd.dtmExpectedDate
    , bd.intContractHeaderId
    , bd.intContractDetailId
    , bd.intLoadDetailId
    , bd.intLocationId
	, sl.strName strStorageLocation
	, sc.intTicketId
	, sc.strTicketNumber
	, a.intAccountId
	, a.strAccountId
	, a.strDescription strAccountDescription
	, scd.intInventoryReceiptItemId
	, scd.strDistributionType
	, uom.intItemUOMId
	, uom.strUnitMeasure strUOM
	, costUom.intItemUOMId intCostUOMId
	, costUom.strUnitMeasure strCostUOM
	, weightUom.intItemUOMId intWeightUOMId
	, weightUom.strUnitMeasure strWeightUOM
	, taxGroup.intTaxGroupId
	, taxGroup.strTaxGroup
	, purchaseDetail.intPurchaseDetailId
	, purchase.intPurchaseId
	, purchase.strPurchaseOrderNumber
	, currency.intCurrencyID intCurrencyId
	, currency.strCurrency
	, subLocation.strSubLocationName
	, companyLocation.strLocationName
	, exchange.strCurrencyExchangeRateType
	, load.strLoadNumber
	, tax.strTaxableByOtherTaxes
	, tax.strCalculationMethod
	, tax.dblTax
	, tax.dblRate
	, tax.dblAdjustedTax
	, tax.ysnTaxAdjusted
	, tax.ysnSeparateOnBill
	, tax.ysnCheckOffTax
	, tax.ysnTaxExempt
	, tax.ysnTaxOnly
	, tax.strTaxCode
	, i.strType AS strInventoryItemType
FROM tblAPBillDetail bd
LEFT JOIN tblCTContractHeader ch ON ch.intContractHeaderId = bd.intContractHeaderId
LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = bd.intContractDetailId
LEFT JOIN tblICItem i ON i.intItemId = bd.intItemId
LEFT JOIN vyuAPBillDetailSource bds ON bds.intBillDetailId = bd.intBillDetailId
LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = bd.intStorageLocationId
LEFT JOIN tblSCTicket sc ON sc.intTicketId = bd.intScaleTicketId
LEFT JOIN tblGLAccount a ON a.intAccountId = bd.intAccountId
LEFT JOIN vyuSCGetScaleDistribution scd ON scd.intInventoryReceiptItemId = bd.intInventoryReceiptItemId
LEFT JOIN vyuAPItemUOM uom ON bd.intUnitOfMeasureId = uom.intItemUOMId
LEFT JOIN vyuAPItemUOM costUom ON bd.intCostUOMId = costUom.intItemUOMId
LEFT JOIN vyuAPItemUOM weightUom ON bd.intWeightUOMId = weightUom.intItemUOMId
LEFT JOIN tblSMTaxGroup taxGroup ON bd.intTaxGroupId = taxGroup.intTaxGroupId
LEFT JOIN tblPOPurchaseDetail purchaseDetail ON bd.intPurchaseDetailId = purchaseDetail.intPurchaseDetailId
LEFT JOIN tblPOPurchase purchase ON purchaseDetail.intPurchaseId = purchase.intPurchaseId
LEFT JOIN tblSMCurrency currency ON bd.intCurrencyId = currency.intCurrencyID
LEFT JOIN tblSMCompanyLocationSubLocation subLocation ON bd.intSubLocationId = subLocation.intCompanyLocationSubLocationId
LEFT JOIN tblSMCompanyLocation companyLocation ON bd.intLocationId = subLocation.intCompanyLocationId
LEFT JOIN tblSMCurrencyExchangeRateType exchange ON bd.intCurrencyExchangeRateTypeId = exchange.intCurrencyExchangeRateTypeId
LEFT JOIN tblLGLoadDetail loadDetail ON bd.intLoadDetailId = loadDetail.intLoadDetailId
LEFT JOIN tblLGLoad load ON loadDetail.intLoadId = load.intLoadId
LEFT JOIN vyuAPBillDetailTax tax ON bd.intBillDetailId = tax.intBillDetailId