CREATE VIEW [dbo].[vyuCTGetAvailableInventoryItemForVoucher]
	AS
		select    
			tbl.intContractDetailId    
			,tbl.intInventoryReceiptId    
			,tbl.strReceiptNumber    
			,tbl.intInventoryReceiptItemId    
			,tbl.intTicketId   
			,strTicketNumber = (case when CHARINDEX('TKT-', tbl.strTicketNumber) = 0 then (SELECT ISNULL(strPrefix,'') FROM tblSMStartingNumber WHERE strTransactionType = 'Ticket Management' AND strModule = 'Ticket Management') + tbl.strTicketNumber else tbl.strTicketNumber  end)  
			,tbl.dblReceived    
			,tbl.dblBilledQuantity    
			,dblAvailableQuantity = tbl.dblReceived - tbl.dblBilledQuantity    
			,tbl.intBilledLoad  
			,intAvailableLoad = 1 - tbl.intBilledLoad  
		from    
			(    
				select    
					intContractDetailId = ri.intLineNo    
					,ri.intInventoryReceiptId    
					,ir.strReceiptNumber    
					,ri.intInventoryReceiptItemId    
					,ti.intTicketId    
					,ti.strTicketNumber  
					,dblReceived = dbo.fnCTConvertQtyToTargetItemUOM(ri.intUnitMeasureId,cd.intItemUOMId,ri.dblOpenReceive)    
					,dblBilledQuantity = isnull(sum(dbo.fnCTConvertQtyToTargetItemUOM(bd.intUnitOfMeasureId,cd.intItemUOMId,bd.dblQtyReceived)),0)
					,intBilledLoad = (case when isnull(cd.intNoOfLoad,0) = 0 then 1 else isnull(count(distinct bd.intBillId),0) end)
				from
					tblICInventoryReceiptItem ri    
					left join tblICInventoryReceipt ir on ir.intInventoryReceiptId = ri.intInventoryReceiptId and ir.strReceiptType = 'Purchase Contract'    
					left join tblCTContractDetail cd on cd.intContractDetailId = ri.intLineNo    
					left join tblAPBillDetail bd on bd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId and intInventoryReceiptChargeId is null    
					left join tblSCTicket ti on ti.intInventoryReceiptId = ir.intInventoryReceiptId    
				group by    
					ri.intLineNo    
					,ri.intInventoryReceiptId    
					,ir.strReceiptNumber    
					,ri.intInventoryReceiptItemId
					,ri.intUnitMeasureId    
					,cd.intItemUOMId    
					,ri.dblOpenReceive    
					,ti.intTicketId    
					,ti.strTicketNumber  
					,cd.intNoOfLoad
			)tbl    
		where
			(tbl.dblReceived - tbl.dblBilledQuantity) > 0  
			or tbl.intBilledLoad < 1
