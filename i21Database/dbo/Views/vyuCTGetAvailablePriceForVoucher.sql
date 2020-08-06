CREATE VIEW [dbo].[vyuCTGetAvailablePriceForVoucher]
	AS
		select      
			intContractDetailId      
			,intPriceFixationId      
			,intPriceFixationDetailId      
			,dtmFixationDate    
			,dblQuantity      
			,dblFinalprice      
			,dblBilledQuantity      
			,dblAvailableQuantity = tbl.dblQuantity - tbl.dblBilledQuantity   
			,tbl.dblLoadPriced
			,tbl.intBilledLoad  
			,intAvailableLoad = isnull(tbl.dblLoadPriced,0) - isnull(tbl.intBilledLoad,0)  
		from      
			(      
				select      
					pf.intContractDetailId      
					,pf.intPriceFixationId      
					,pfd.intPriceFixationDetailId     
					,pfd.dtmFixationDate     
					,pfd.dblQuantity  
					,pfd.dblLoadPriced   
					,dblFinalprice = dbo.fnCTConvertToSeqFXCurrency(cd.intContractDetailId,pc.intFinalCurrencyId,iu.intItemUOMId,pfd.dblFinalPrice)      
					,dblBilledQuantity = (case when isnull(cd.intNoOfLoad,0) = 0 then isnull(sum(dbo.fnCTConvertQtyToTargetItemUOM(bd.intUnitOfMeasureId,cd.intItemUOMId,bd.dblQtyReceived)),0) else pfd.dblQuantity end)
					,intBilledLoad = (case when isnull(cd.intNoOfLoad,0) = 0 then 0 else isnull(count(distinct bd.intBillId),0) end)
				from      
					tblCTPriceFixation pf      
					left join tblCTContractDetail cd on cd.intContractDetailId = pf.intContractDetailId      
					left join tblCTPriceContract pc on pc.intPriceContractId = pf.intPriceContractId      
					left join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId      
					left join tblCTPriceFixationDetailAPAR ap on ap.intPriceFixationDetailId = pfd.intPriceFixationDetailId      
					left join tblAPBillDetail bd on bd.intBillDetailId = ap.intBillDetailId and isnull(bd.intSettleStorageId,0) = 0      
					left join tblICCommodityUnitMeasure co on co.intCommodityUnitMeasureId = pfd.intPricingUOMId      
					left join tblICItemUOM iu on iu.intItemId = cd.intItemId and iu.intUnitMeasureId = co.intUnitMeasureId
				group by      
					pf.intContractDetailId      
					,pf.intPriceFixationId      
					,pfd.intPriceFixationDetailId      
					,pfd.dtmFixationDate    
					,pfd.dblQuantity      
					,pfd.dblLoadPriced  
					,cd.intContractDetailId      
					,pc.intFinalCurrencyId      
					,iu.intItemUOMId      
					,pfd.dblFinalPrice      
					,cd.intNoOfLoad
			)tbl      
		where
			(tbl.dblQuantity - tbl.dblBilledQuantity) > 0
			or (tbl.dblLoadPriced - tbl.intBilledLoad) > 0