CREATE VIEW [dbo].[vyuCTGetAvailablePriceForVoucher]

AS

SELECT intId
	, intContractDetailId
	, intPriceFixationId
	, intPriceFixationDetailId
	, dtmFixationDate
	, dblQuantity
	, dblFinalprice
	, dblBilledQuantity
	, dblAvailableQuantity = tbl.dblQuantity - tbl.dblBilledQuantity
	, tbl.dblLoadPriced
	, tbl.intBilledLoad
	, intAvailableLoad = ISNULL(tbl.dblLoadPriced, 0) - ISNULL(tbl.intBilledLoad, 0)
	, intPriceItemUOMId
	, intPricingTypeId
	, intFreightTermId
	, intCompanyLocationId
	, intPriceContractId
	, strPriceContractNo
FROM (
	SELECT
		intId = pfd.intPriceFixationDetailId
		, pf.intContractDetailId
		, pf.intPriceFixationId
		, pfd.intPriceFixationDetailId
		, pfd.dtmFixationDate
		, pfd.dblQuantity
		, pfd.dblLoadPriced
		, dblFinalprice = dbo.fnCTConvertToSeqFXCurrency(cd.intContractDetailId, pc.intFinalCurrencyId, iu.intItemUOMId, pfd.dblFinalPrice)
		, dblBilledQuantity = (CASE WHEN ISNULL(cd.intNoOfLoad, 0) = 0 THEN ISNULL(SUM(dbo.fnCTConvertQtyToTargetItemUOM(bd.intUnitOfMeasureId, cd.intItemUOMId, bd.dblQtyReceived)), 0) ELSE pfd.dblQuantity END)
		, intBilledLoad = (CASE WHEN ISNULL(cd.intNoOfLoad, 0) = 0 THEN 0 ELSE ISNULL(COUNT(DISTINCT bd.intBillId), 0) END)
		, intPriceItemUOMId = pfd.intQtyItemUOMId
		, cd.intPricingTypeId
		, cd.intFreightTermId 
		, cd.intCompanyLocationId 
		, pc.intPriceContractId
		, pc.strPriceContractNo
	FROM tblCTPriceFixation pf
	LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = pf.intContractDetailId      
	LEFT JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId      
	LEFT JOIN tblCTPriceFixationDetail pfd ON pfd.intPriceFixationId = pf.intPriceFixationId      
	LEFT JOIN tblCTPriceFixationDetailAPAR ap ON ap.intPriceFixationDetailId = pfd.intPriceFixationDetailId      
	LEFT JOIN tblAPBillDetail bd ON bd.intBillDetailId = ap.intBillDetailId AND ISNULL(bd.intSettleStorageId, 0) = 0 AND bd.intInventoryReceiptChargeId is null
	LEFT JOIN tblICCommodityUnitMeasure co ON co.intCommodityUnitMeasureId = pfd.intPricingUOMId      
	LEFT JOIN tblICItemUOM iu ON iu.intItemId = cd.intItemId AND iu.intUnitMeasureId = co.intUnitMeasureId
	GROUP BY pf.intContractDetailId
		, pf.intPriceFixationId
		, pfd.intPriceFixationDetailId
		, pfd.dtmFixationDate
		, pfd.dblQuantity
		, pfd.dblLoadPriced
		, cd.intContractDetailId
		, pc.intFinalCurrencyId
		, iu.intItemUOMId
		, pfd.dblFinalPrice
		, cd.intNoOfLoad
		, cd.intPricingTypeId
		, cd.intFreightTermId
		, cd.intCompanyLocationId
		, pfd.intQtyItemUOMId
		, pc.intPriceContractId
		, pc.strPriceContractNo
	
	UNION ALL SELECT
		intId = cd.intContractDetailId
		, cd.intContractDetailId
		, intPriceFixationId = NULL
		, intPriceFixationDetailId = NULL
		, dtmFixationDate = NULL
		, cd.dblQuantity
		, dblLoadPriced = (cd.dblQuantity / cd.dblQuantityPerLoad)
		, dblFinalprice = dbo.fnCTConvertToSeqFXCurrency(cd.intContractDetailId, cd.intCurrencyId, cd.intPriceItemUOMId, cd.dblCashPrice)
		, dblBilledQuantity = (CASE WHEN ISNULL(cd.intNoOfLoad, 0) = 0 THEN ISNULL(sum(dbo.fnCTConvertQtyToTargetItemUOM(bd.intUnitOfMeasureId, cd.intItemUOMId, bd.dblQtyReceived)), 0) ELSE cd.dblQuantity END)
		, intBilledLoad = (CASE WHEN ISNULL(cd.intNoOfLoad, 0) = 0 THEN 0 ELSE ISNULL(COUNT(DISTINCT bd.intBillId), 0) END)
		, intPriceItemUOMId = cd.intItemUOMId
		, cd.intPricingTypeId
		, cd.intFreightTermId
		, cd.intCompanyLocationId
		, intPriceContractId = NULL
		, strPriceContractNo = NULL
	FROM tblCTContractDetail cd
	LEFT JOIN tblAPBillDetail bd1 ON bd1.intContractDetailId = cd.intContractDetailId AND ISNULL(bd1.intSettleStorageId, 0) = 0 AND bd1.intInventoryReceiptChargeId IS NULL
	LEFT JOIN tblAPBill b ON b.intBillId = bd1.intBillId AND b.intTransactionType = 1
	LEFT JOIN tblAPBillDetail bd ON bd.intContractDetailId = cd.intContractDetailId AND ISNULL(bd.intSettleStorageId, 0) = 0 AND bd.intBillId = b.intBillId AND bd.intInventoryReceiptChargeId IS NULL
	CROSS APPLY (
		SELECT intPricingCount = COUNT(*)
		FROM tblCTPriceFixation pf
		WHERE pf.intContractDetailId = cd.intContractDetailId
	) noPrice
	WHERE cd.dblCashPrice IS NOT NULL
		AND noPrice.intPricingCount = 0
	GROUP BY cd.intContractDetailId
		, cd.dblQuantity
		, cd.dblQuantityPerLoad
		, cd.intCurrencyId
		, cd.dblCashPrice
		, cd.intNoOfLoad
		, cd.intPriceItemUOMId
		, cd.intPricingTypeId
		, cd.intFreightTermId
		, cd.intCompanyLocationId
		, cd.intItemUOMId
) tbl
WHERE (tbl.dblQuantity - tbl.dblBilledQuantity) > 0
	OR (tbl.dblLoadPriced - tbl.intBilledLoad) > 0