CREATE VIEW [dbo].[vyuCTGetAvailablePriceForVoucher]
	AS
		select
		    intId = intId
			,intContractDetailId      
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
			,intPriceItemUOMId
			,intPricingTypeId
			,intFreightTermId 
			,intCompanyLocationId
		from      
			(      
				select
					intId = pfd.intPriceFixationDetailId  
					,pf.intContractDetailId      
					,pf.intPriceFixationId      
					,pfd.intPriceFixationDetailId     
					,pfd.dtmFixationDate     
					,pfd.dblQuantity  
					,pfd.dblLoadPriced   
					,dblFinalprice = dbo.fnCTConvertToSeqFXCurrency(cd.intContractDetailId,pc.intFinalCurrencyId,iu.intItemUOMId,pfd.dblFinalPrice)      
					,dblBilledQuantity = (case when isnull(cd.intNoOfLoad,0) = 0 then isnull(sum(dbo.fnCTConvertQtyToTargetItemUOM(bd.intUnitOfMeasureId,cd.intItemUOMId,bd.dblQtyReceived)),0) else pfd.dblQuantity end)
					,intBilledLoad = (case when isnull(cd.intNoOfLoad,0) = 0 then 0 else isnull(count(distinct bd.intBillId),0) end)
					,intPriceItemUOMId = pfd.intQtyItemUOMId
	 				,cd.intPricingTypeId
					,cd.intFreightTermId 
					,cd.intCompanyLocationId 
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
	 				,cd.intPricingTypeId
					,cd.intFreightTermId 
					,cd.intCompanyLocationId
					,pfd.intQtyItemUOMId 

                union all

                select
                	intId = cd.intContractDetailId        
                    ,cd.intContractDetailId        
                    ,intPriceFixationId = null
                    ,intPriceFixationDetailId = null
                    ,dtmFixationDate = null
                    ,cd.dblQuantity    
                    ,dblLoadPriced = (cd.dblQuantity / cd.dblQuantityPerLoad)
                    ,dblFinalprice = dbo.fnCTConvertToSeqFXCurrency(cd.intContractDetailId,cd.intCurrencyId,cd.intPriceItemUOMId,cd.dblCashPrice)        
                    ,dblBilledQuantity = (case when isnull(cd.intNoOfLoad,0) = 0 then isnull(sum(dbo.fnCTConvertQtyToTargetItemUOM(bd.intUnitOfMeasureId,cd.intItemUOMId,bd.dblQtyReceived)),0) else cd.dblQuantity end)  
                    ,intBilledLoad = (case when isnull(cd.intNoOfLoad,0) = 0 then 0 else isnull(count(distinct bd.intBillId),0) end)  
                    ,intPriceItemUOMId = cd.intPriceItemUOMId
	 				,cd.intPricingTypeId
					,cd.intFreightTermId 
					,cd.intCompanyLocationId 
                from        
				    tblCTContractDetail cd  
				    left join tblAPBillDetail bd1 on bd1.intContractDetailId = cd.intContractDetailId and isnull(bd1.intSettleStorageId,0) = 0      and bd1.intInventoryReceiptChargeId is null 
				    left join tblAPBill b on b.intBillId = bd1.intBillId and b.intTransactionType = 1  
				    left join tblAPBillDetail bd on bd.intContractDetailId = cd.intContractDetailId and isnull(bd.intSettleStorageId,0) = 0 and bd.intBillId = b.intBillId and bd.intInventoryReceiptChargeId is null
				    cross apply (
						select intPricingCount = count(*)
						from
							tblCTPriceFixation pf
						where
							pf.intContractDetailId = cd.intContractDetailId
				    ) pricing
                where
                	cd.dblCashPrice is not null
					and isnull(pricing.intPricingCount,0) = 0
                group by        
                    cd.intContractDetailId        
                    ,cd.dblQuantity        
                    ,cd.dblQuantityPerLoad         
                    ,cd.intCurrencyId       
                    ,cd.dblCashPrice        
                    ,cd.intNoOfLoad  
                    ,cd.intPriceItemUOMId
	 				,cd.intPricingTypeId
					,cd.intFreightTermId 
					,cd.intCompanyLocationId
			)tbl      
		where
			(tbl.dblQuantity - tbl.dblBilledQuantity) > 0
			or (tbl.dblLoadPriced - tbl.intBilledLoad) > 0
