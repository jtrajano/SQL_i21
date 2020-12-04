CREATE TABLE [dbo].[tblCTPriceFixationDetailAPAR]
(
	intPriceFixationDetailAPARId	INT IDENTITY NOT NULL,
	intPriceFixationDetailId		INT	NOT NULL,
	intBillId						INT,
	intBillDetailId					INT,
	intInvoiceId					INT,
	intInvoiceDetailId				INT,
	ysnMarkDelete					BIT,
	strBillDetailChargesId			NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]				INT NOT NULL,

	CONSTRAINT [PK_tblCTPriceFixationDetailAPAR_intPriceFixationDetailAPARId] PRIMARY KEY CLUSTERED (intPriceFixationDetailAPARId ASC),
	CONSTRAINT [FK_tblCTPriceFixationDetailAPAR_tblCTPriceFixationDetail_intPriceFixationDetailId] FOREIGN KEY (intPriceFixationDetailId) REFERENCES tblCTPriceFixationDetail(intPriceFixationDetailId) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTPriceFixationDetailAPAR_tblAPBill_intBillId] FOREIGN KEY (intBillId) REFERENCES tblAPBill(intBillId),
	CONSTRAINT [FK_tblCTPriceFixationDetailAPAR_tblAPBillDetail_intBillDetailId] FOREIGN KEY (intBillDetailId) REFERENCES tblAPBillDetail(intBillDetailId),
	CONSTRAINT [FK_tblCTPriceFixationDetailAPAR_tblARInvoice_intInvoiceId] FOREIGN KEY (intInvoiceId) REFERENCES tblARInvoice(intInvoiceId),
	CONSTRAINT [FK_tblCTPriceFixationDetailAPAR_tblARInvoiceDetail_intInvoiceDetailId] FOREIGN KEY (intInvoiceDetailId) REFERENCES tblARInvoiceDetail(intInvoiceDetailId) ON DELETE CASCADE
)

GO


CREATE TRIGGER [dbo].[trgCTPriceFixationDetailAPARDelete]
	ON [dbo].[tblCTPriceFixationDetailAPAR]  
	FOR INSERT  
	AS  
	BEGIN  
		SET NoCount ON  
		declare @ErrMsg nvarchar(max);  
		declare @intActiveContractDetailId int = 0; 

		begin try  
		
		select top 1
			@intActiveContractDetailId = pf.intContractDetailId
		from
			inserted i
			,tblCTPriceFixationDetail pfd
			,tblCTPriceFixation pf
		where
			pfd.intPriceFixationDetailId = i.intPriceFixationDetailId
			and pf.intPriceFixationId = pfd.intPriceFixationId;  

		update
			pfd
		set
			pfd.dblQuantityAppliedAndPriced = rd.dblInvoiceQuantityAppliedAndPriced
			,pfd.dblLoadAppliedAndPriced = rd.dblInvoiceLoadAppliedAndPriced
		from
			tblCTPriceFixationDetail pfd 
			join (
				select
					pfd.intPriceFixationDetailId
					,pfd.intNumber
					,pfd.dblQuantity
					,pfd.dblQuantityAppliedAndPriced
					,dblInvoiceQuantityAppliedAndPriced = (case when ch.intContractTypeId = 2 then sum(iq.dblQtyShipped) else sum(vq.dblQtyReceived) end)
					,pfd.dblLoadPriced
					,pfd.dblLoadAppliedAndPriced
					,dblInvoiceLoadAppliedAndPriced = (case when ch.intContractTypeId = 2 then convert(numeric(18,6),count(iq.intInvoiceDetailId)) else convert(numeric(18,6),count(vq.intBillDetailId)) end)
				from
					tblCTPriceFixation pf
					join tblCTContractHeader ch on ch.intContractHeaderId = pf.intContractHeaderId
					join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
					join tblCTPriceFixationDetailAPAR ar on ar.intPriceFixationDetailId = pfd.intPriceFixationDetailId
					left join (
						select di.intInvoiceDetailId, di.dblQtyShipped from tblARInvoiceDetail di where di.intInventoryShipmentChargeId is null and isnull(di.ysnReturned,0) = 0
					) iq on iq.intInvoiceDetailId = ar.intInvoiceDetailId
					left join (
						select bd.intBillDetailId, bd.dblQtyReceived from tblAPBillDetail bd where bd.intInventoryReceiptChargeId is null
					) vq on vq.intBillDetailId = ar.intBillDetailId
				where
					pf.intContractDetailId = @intActiveContractDetailId
				group by
					pfd.intPriceFixationDetailId
					,pfd.intNumber
					,pfd.dblQuantity
					,pfd.dblQuantityAppliedAndPriced
					,pfd.dblLoadPriced
					,pfd.dblLoadAppliedAndPriced
					,ch.intContractTypeId
			) rd  on rd.intPriceFixationDetailId = pfd.intPriceFixationDetailId
		where
			isnull(pfd.dblQuantityAppliedAndPriced,0) <> isnull(rd.dblInvoiceQuantityAppliedAndPriced,0)
			or isnull(pfd.dblLoadAppliedAndPriced,0) <> isnull(rd.dblInvoiceLoadAppliedAndPriced,0)

		end try  
		begin catch  

			SET @ErrMsg = ERROR_MESSAGE();  
			RAISERROR (@ErrMsg,18,1,'WITH NOWAIT');  

		end catch  
  
  
	END