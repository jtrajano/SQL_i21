CREATE VIEW [dbo].[vyuCTGetAvailablePriceForVoucher]

AS

SELECT intId
	, intContractHeaderId
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
	, ysnMultiplePriceFixation
FROM (
	SELECT
		intId = pfd.intPriceFixationDetailId
		, pf.intContractHeaderId
		, pf.intContractDetailId
		, pf.intPriceFixationId
		, pfd.intPriceFixationDetailId
		, pfd.dtmFixationDate
		, pfd.dblQuantity
		, pfd.dblLoadPriced
		, dblFinalprice = dbo.fnCTConvertToSeqFXCurrency(cd.intContractDetailId, pc.intFinalCurrencyId, iu.intItemUOMId, (CASE WHEN ct.ysnMultiplePriceFixation = 1 THEN cd.dblCashPrice ELSE  pfd.dblFinalPrice END))
		, dblBilledQuantity = (CASE WHEN ISNULL(cd.intNoOfLoad, 0) = 0 THEN ISNULL(SUM(dbo.fnCTConvertQtyToTargetItemUOM(bd.intUnitOfMeasureId, cd.intItemUOMId, bd.dblQtyReceived)), 0) ELSE pfd.dblQuantity END)
		, intBilledLoad = (CASE WHEN ISNULL(cd.intNoOfLoad, 0) = 0 THEN 0 ELSE ISNULL(COUNT(DISTINCT bd.intBillId), 0) END)
		, intPriceItemUOMId = pfd.intQtyItemUOMId
		, cd.intPricingTypeId
		, cd.intFreightTermId 
		, cd.intCompanyLocationId 
		, pc.intPriceContractId
		, pc.strPriceContractNo
		, ysnMultiplePriceFixation = 0
	FROM tblCTPriceFixation pf
	LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = pf.intContractDetailId      
	LEFT JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId      
	LEFT JOIN tblCTPriceFixationDetail pfd ON pfd.intPriceFixationId = pf.intPriceFixationId      
	LEFT JOIN tblCTPriceFixationDetailAPAR ap ON ap.intPriceFixationDetailId = pfd.intPriceFixationDetailId      
	LEFT JOIN tblAPBillDetail bd ON bd.intBillDetailId = ap.intBillDetailId AND bd.intInventoryReceiptChargeId is null and bd.intItemId = cd.intItemId
	LEFT JOIN tblICCommodityUnitMeasure co ON co.intCommodityUnitMeasureId = pfd.intPricingUOMId      
	LEFT JOIN tblICItemUOM iu ON iu.intItemId = cd.intItemId AND iu.intUnitMeasureId = co.intUnitMeasureId
	OUTER APPLY (
		SELECT TOP 1 ysnMultiplePriceFixation  from tblCTContractHeader a where a.intContractHeaderId = cd.intContractHeaderId
	) ct
	GROUP BY 
		pf.intContractHeaderId
		, pf.intContractDetailId
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
		, ct.ysnMultiplePriceFixation
		, cd.dblCashPrice

	UNION ALL


	SELECT
		intId = pfd.intPriceFixationDetailId
		, pf.intContractHeaderId
		, pf.intContractDetailId
		, pf.intPriceFixationId
		, pfd.intPriceFixationDetailId
		, pfd.dtmFixationDate
		, pfd.dblQuantity
		, pfd.dblLoadPriced
		, dblFinalprice = dbo.fnCTConvertToSeqFXCurrency(cd.intContractDetailId, pc.intFinalCurrencyId, iu.intItemUOMId, cd.dblCashPrice)
		, dblBilledQuantity = (CASE WHEN ISNULL(cd.intNoOfLoad, 0) = 0 THEN ISNULL(SUM(dbo.fnCTConvertQtyToTargetItemUOM(bd.intUnitOfMeasureId, cd.intItemUOMId, bd.dblQtyReceived)), 0) ELSE pfd.dblQuantity END)
		, intBilledLoad = (CASE WHEN ISNULL(cd.intNoOfLoad, 0) = 0 THEN 0 ELSE ISNULL(COUNT(DISTINCT bd.intBillId), 0) END)
		, intPriceItemUOMId = cd.intItemUOMId
		, cd.intPricingTypeId
		, cd.intFreightTermId 
		, cd.intCompanyLocationId 
		, pc.intPriceContractId
		, pc.strPriceContractNo
		, ysnMultiplePriceFixation = 1
	FROM tblCTPriceFixation pf
	JOIN tblCTContractHeader ch on ch.intContractHeaderId = pf.intContractHeaderId
	join tblCTContractDetail cd on cd.intContractHeaderId = ch.intContractHeaderId and cd.intContractSeq = 1
	LEFT JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId      
	LEFT JOIN tblCTPriceFixationDetail pfd ON pfd.intPriceFixationId = pf.intPriceFixationId
	LEFT JOIN tblAPBillDetail bd ON bd.intContractHeaderId = ch.intContractHeaderId AND bd.intInventoryReceiptChargeId is null and bd.intItemId = cd.intItemId
	LEFT JOIN tblICCommodityUnitMeasure co ON co.intCommodityUnitMeasureId = pfd.intPricingUOMId      
	LEFT JOIN tblICItemUOM iu ON iu.intItemId = cd.intItemId AND iu.intUnitMeasureId = co.intUnitMeasureId
	WHERE ch.ysnMultiplePriceFixation = 1
	GROUP BY
		pf.intContractHeaderId
		, pf.intContractDetailId
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
		, cd.intItemUOMId
		, pc.intPriceContractId
		, pc.strPriceContractNo
		, cd.dblCashPrice

	UNION ALL
	
	SELECT
		intId = cd.intContractDetailId
		, cd.intContractHeaderId
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
		, ysnMultiplePriceFixation = ch.ysnMultiplePriceFixation
	FROM tblCTContractDetail cd
    join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
	left join (
		select
			a.intBillId
			,a.intContractDetailId
			,a.intUnitOfMeasureId
			,a.dblQtyReceived
            ,a.intItemId
		from
			tblAPBillDetail a
			join tblAPBill b on b.intBillId = a.intBillId
		where
			b.intTransactionType = 1
			and isnull(a.intSettleStorageId,0) = 0
			and a.intInventoryReceiptChargeId is null

		) bd on bd.intContractDetailId = cd.intContractDetailId and bd.intItemId = cd.intItemId
	CROSS APPLY (
		SELECT intPricingCount = COUNT(*)
		FROM tblCTPriceFixation pf
		WHERE isnull(pf.intContractDetailId,0) = (case when ch.ysnMultiplePriceFixation = 1 then 0 else cd.intContractDetailId end) and pf.intContractHeaderId = ch.intContractHeaderId
	) noPrice
	WHERE cd.dblCashPrice IS NOT NULL
		AND noPrice.intPricingCount = 0
	GROUP BY cd.intContractDetailId
		, cd.intContractHeaderId
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
		, ch.ysnMultiplePriceFixation
) tbl
WHERE (tbl.dblQuantity - tbl.dblBilledQuantity) > 0
	OR (tbl.dblLoadPriced - tbl.intBilledLoad) > 0