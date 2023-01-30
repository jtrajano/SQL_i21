CREATE TABLE [dbo].[tblCTPriceFixationDetailAPAR]
(
	intPriceFixationDetailAPARId	INT IDENTITY NOT NULL,
	intPriceFixationDetailId		INT	NOT NULL,
	intBillId						INT,
	intBillDetailId					INT,
	intInvoiceId					INT,
	intInvoiceDetailId				INT,
	intSourceId						INT,
	dblQuantity						numeric(18,6),
	dtmCreatedDate					datetime null default getdate(),
	ysnMarkDelete					BIT,
	ysnReturn						BIT null default 0,
	ysnPreDeploymentFix				BIT null default 0,
	strInvoiceDiscountsChargesIds	nvarchar(500) COLLATE Latin1_General_CI_AS,
	[intConcurrencyId]				INT NOT NULL,

	CONSTRAINT [PK_tblCTPriceFixationDetailAPAR_intPriceFixationDetailAPARId] PRIMARY KEY CLUSTERED (intPriceFixationDetailAPARId ASC),
	CONSTRAINT [FK_tblCTPriceFixationDetailAPAR_tblCTPriceFixationDetail_intPriceFixationDetailId] FOREIGN KEY (intPriceFixationDetailId) REFERENCES tblCTPriceFixationDetail(intPriceFixationDetailId) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTPriceFixationDetailAPAR_tblAPBill_intBillId] FOREIGN KEY (intBillId) REFERENCES tblAPBill(intBillId),
	CONSTRAINT [FK_tblCTPriceFixationDetailAPAR_tblAPBillDetail_intBillDetailId] FOREIGN KEY (intBillDetailId) REFERENCES tblAPBillDetail(intBillDetailId) ON DELETE CASCADE,
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
		declare @dblBalance numeric(18,6);

		begin try  
		
		select top 1
			@intActiveContractDetailId = pf.intContractDetailId
			,@dblBalance = (case when isnull(ch.ysnLoad,0) = 0 then cd.dblBalance else cd.dblBalanceLoad end)
		from
			inserted i
			inner join tblCTPriceFixationDetail pfd on pfd.intPriceFixationDetailId = i.intPriceFixationDetailId
			inner join tblCTPriceFixation pf on pf.intPriceFixationId = pfd.intPriceFixationId
			inner join tblCTContractDetail cd on cd.intContractDetailId = pf.intContractDetailId
			inner join tblCTContractHeader ch on ch.intContractHeaderId = pf.intContractHeaderId
		
		exec uspCTUpdateAppliedAndPrice
			@intContractDetailId = @intActiveContractDetailId
			,@dblBalance = @dblBalance

		end try  
		begin catch  

			SET @ErrMsg = ERROR_MESSAGE();  
			RAISERROR (@ErrMsg,18,1,'WITH NOWAIT');  

		end catch  


    END

GO
