﻿CREATE VIEW [dbo].[vyuCTUnforecastedOtherCharges]
	AS
	select
		*
	from
		(
		select
			cc.intContractCostId
			,strEntity =en.strName
			,ch.strContractNumber
			,cd.intContractSeq
			,it.strItemNo
			,cc.dblRate
			,um.strUnitMeasure
					, dblAmount = (CASE	WHEN cc.strCostMethod = 'Per Unit'
								THEN dbo.fnCTConvertQuantityToTargetItemUOM(cd.intItemId, qu.intUnitMeasureId, cm.intUnitMeasureId, cd.dblQuantity) * cc.dblRate * CASE WHEN cd.intCurrencyId != cd.intInvoiceCurrencyId THEN  ISNULL(cc.dblFX, 1) ELSE 1 END
							WHEN cc.strCostMethod = 'Amount'
								THEN cc.dblRate * CASE WHEN cd.intCurrencyId != cd.intInvoiceCurrencyId THEN  ISNULL(cc.dblFX, 1) ELSE 1 END
							WHEN cc.strCostMethod = 'Per Container'
								THEN (cc.dblRate * (CASE WHEN ISNULL(cd.intNumberOfContainers, 1) = 0 THEN 1 ELSE ISNULL(cd.intNumberOfContainers, 1) END)) * CASE WHEN cd.intCurrencyId != cd.intInvoiceCurrencyId THEN  ISNULL(cc.dblFX, 1) ELSE 1 END
							WHEN cc.strCostMethod = 'Percentage'
								THEN 

									CASE WHEN cd.intPricingTypeId <> 2 THEN
										dbo.fnCTConvertQuantityToTargetItemUOM(cd.intItemId, qu.intUnitMeasureId, pu.intUnitMeasureId, cd.dblQuantity) 
										* (cd.dblCashPrice / (CASE WHEN ISNULL(cy2.ysnSubCurrency, CONVERT(BIT, 0)) = CONVERT(BIT, 1) THEN ISNULL(cy2.intCent, 1) ELSE 1 END))
										* cc.dblRate/100 * ISNULL(cc.dblFX, 1)
									ELSE
										CASE WHEN isnull(pf.ysnEnableBudgetForBasisPricing,convert(bit,0)) = CONVERT(BIT, 1) THEN  
											cd.dblTotalBudget  * (cc.dblRate/100) * ISNULL(cc.dblFX, 1)
										ELSE
											dbo.fnCTConvertQuantityToTargetItemUOM(cd.intItemId, qu.intUnitMeasureId, pu.intUnitMeasureId, cd.dblQuantity) 
											* ((fspm.dblLastSettle + cd.dblBasis) / (CASE WHEN ISNULL(cy2.ysnSubCurrency, CONVERT(BIT, 0)) = CONVERT(BIT, 1) THEN ISNULL(cy2.intCent, 1) ELSE 1 END))
											* cc.dblRate/100 * ISNULL(cc.dblFX, 1)
										END
									END

							END)
					/ (CASE WHEN ISNULL(cu.ysnSubCurrency, CONVERT(BIT, 0)) = CONVERT(BIT, 1) THEN ISNULL(cu.intCent, 1) ELSE 1 END)
			,cc.strCostMethod
			,cu.strCurrency
			,cc.dblFX
			,ch.intContractHeaderId
			,cd.intContractDetailId
			,en.intEntityId
			,cu.intCurrencyID
			,cc.intItemUOMId
			,cc.intItemId
			,bd.intBillDetailId
		from
			tblCTContractCost cc
			join tblICItem it on it.intItemId = cc.intItemId
			join tblCTContractDetail cd on cd.intContractDetailId = cc.intContractDetailId
			join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
			join tblEMEntity en on en.intEntityId = cc.intVendorId
			left join tblAPBillDetail bd on bd.intContractHeaderId = ch.intContractHeaderId and bd.intContractDetailId = cd.intContractDetailId and bd.intItemId = cc.intItemId
			left join tblSMCurrency cu on cu.intCurrencyID = cc.intCurrencyId
			left join tblICItemUOM uom on uom.intItemUOMId = cc.intItemUOMId
			left join tblICItemUOM qu on qu.intItemUOMId = cd.intItemUOMId
			left join tblICUnitMeasure um on um.intUnitMeasureId = uom.intUnitMeasureId
			left join tblICItemUOM cm on cm.intUnitMeasureId = uom.intUnitMeasureId and cm.intItemId = cd.intItemId
			left join tblSMCurrency cy2 on cy2.intCurrencyID = cd.intCurrencyId
			left join tblICItemUOM pu on pu.intItemUOMId = cd.intPriceItemUOMId
			left join (
				select
					intFutureMarketId
					,MAX(intFutureSettlementPriceId) intFutureSettlementPriceId
					,MAX( dtmPriceDate) dtmPriceDate
				from
					tblRKFuturesSettlementPrice a
				Group by
					intFutureMarketId, intCommodityMarketId
			)fsp on fsp.intFutureMarketId = cd.intFutureMarketId
			left join tblRKFutSettlementPriceMarketMap fspm on fspm.intFutureSettlementPriceId = fsp.intFutureSettlementPriceId and cd.intFutureMonthId = fspm.intFutureMonthId
			outer apply (
				select top 1 1 ysnEnableBudgetForBasisPricing FROM tblCTCompanyPreference
			)pf
		) otherCosts
	where isnull(intBillDetailId,0) = 0
