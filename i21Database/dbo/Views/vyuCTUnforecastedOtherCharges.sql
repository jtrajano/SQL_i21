CREATE VIEW [dbo].[vyuCTUnforecastedOtherCharges]
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
			,dblFX  = ISNULL(cc.dblFX, 1)
			,ch.intContractHeaderId
			,cd.intContractDetailId
			,en.intEntityId
			,cu.intCurrencyID
			,cc.intItemUOMId
			,cc.intItemId
			,bd.intBillDetailId
			,vtg.intTaxGroupId
			,vtg.strTaxGroup
			,strItemDescription = it.strDescription
			,intAccountId = isnull(lga.intAccountId,lgac.intAccountId)
			,strAccountId = isnull(lga.strAccountId,lgac.strAccountId)
			,strAccountDescription = isnull(lga.strDescription,lgac.strDescription)
			,strAccountCategory = isnull(lga.strAccountCategory,lgac.strAccountCategory)
			,ld.intCount
			,ir.intIRCount
			,crt.intCurrencyExchangeRateTypeId
			,crt.strCurrencyExchangeRateType
		from
			tblCTContractCost cc
			join tblICItem it on it.intItemId = cc.intItemId
			join tblCTContractDetail cd on cd.intContractDetailId = cc.intContractDetailId
			join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
			join tblEMEntity en on en.intEntityId = cc.intVendorId
			--left join tblAPBillDetail bd on bd.intContractHeaderId = ch.intContractHeaderId and bd.intContractDetailId = cd.intContractDetailId and bd.intItemId = cc.intItemId
			left join (
				select
					b.intEntityVendorId
					,bd.intContractHeaderId
					,bd.intContractDetailId
					,bd.intBillDetailId
					,bd.intItemId
				from
					tblAPBill b
					join tblAPBillDetail bd on bd.intBillId = b.intBillId
			) bd on bd.intContractHeaderId = ch.intContractHeaderId and bd.intContractDetailId = cd.intContractDetailId and bd.intItemId = cc.intItemId and bd.intEntityVendorId = cc.intVendorId
			left join tblSMCurrency cu on cu.intCurrencyID = cc.intCurrencyId
			left join tblICItemUOM uom on uom.intItemUOMId = cc.intItemUOMId
			left join tblICItemUOM qu on qu.intItemUOMId = cd.intItemUOMId
			left join tblICUnitMeasure um on um.intUnitMeasureId = uom.intUnitMeasureId
			left join tblICItemUOM cm on cm.intUnitMeasureId = uom.intUnitMeasureId and cm.intItemId = cd.intItemId
			left join tblSMCurrency cy2 on cy2.intCurrencyID = cd.intCurrencyId
			left join tblICItemUOM pu on pu.intItemUOMId = cd.intPriceItemUOMId
			left join tblSMCurrencyExchangeRateType crt on crt.intCurrencyExchangeRateTypeId = cc.intRateTypeId
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
			left join (
				select
					v.intEntityId
					,el.intTaxGroupId
					,tg.strTaxGroup
				from
					tblAPVendor v
					join tblEMEntityLocation el on el.intEntityId = v.intEntityId
					join tblSMTaxGroup tg on tg.intTaxGroupId = el.intTaxGroupId
				where
					el.ysnDefaultLocation = 1
			)vtg on vtg.intEntityId = cc.intVendorId
			left join (
				select
					ia.intItemId
					,ga.intAccountId
					,ga.strAccountId
					,ga.strDescription
					,ac.strAccountCategory
				from
					tblICItemAccount ia
					join tblGLAccountCategory ac on ac.intAccountCategoryId =ia.intAccountCategoryId
					join tblGLAccount ga on ga.intAccountId = ia.intAccountId
				where
					ac.strAccountCategory = 'Other Charge Expense'
			) lga on lga.intItemId = cc.intItemId
			left join (
				select 
					ic.intCategoryId
					,ga.intAccountId
					,ga.strAccountId
					,ga.strDescription
					,ac.strAccountCategory
				from
					tblICCategory ic
					join tblICCategoryAccount ca on ca.intCategoryId = ic.intCategoryId
					join tblGLAccount ga on ga.intAccountId = ca.intAccountId
					join tblGLAccountCategory ac on ac.intAccountCategoryId = ca.intAccountCategoryId
				where
					ac.strAccountCategory = 'Other Charge Expense'
			) lgac on lgac.intCategoryId = it.intCategoryId
			left join (
				select
					ld.intPContractDetailId
					,ldc.intItemId
					,ldc.intVendorId
					,intCount = count(ldc.intLoadCostId)
				from tblLGLoadDetail ld
				join tblLGLoadCost ldc on ldc.intLoadId = ld.intLoadId
				group by
					ld.intPContractDetailId
					,ldc.intItemId
					,ldc.intVendorId
			) ld on ld.intPContractDetailId = cc.intContractDetailId and ld.intItemId = cc.intItemId and ld.intVendorId = cc.intVendorId
			left join (
				select
					irc.intContractDetailId
					,irc.intChargeId
					,irc.intEntityVendorId
					,intIRCount = count(irc.intInventoryReceiptChargeId)
				from
					tblICInventoryReceiptCharge irc
				group by irc.intContractDetailId, irc.intChargeId, irc.intEntityVendorId
			)ir on ir.intContractDetailId = cc.intContractDetailId and ir.intChargeId = cc.intItemId and ir.intEntityVendorId = cc.intVendorId
		where
			cc.ysnUnforcasted = 1
			and ch.intContractTypeId = 1
		) otherCosts
	where isnull(intBillDetailId,0) = 0 and isnull(intCount,0) = 0 and isnull(intIRCount,0) = 0