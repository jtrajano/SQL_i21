CREATE TABLE [dbo].[tblCTPriceFixationDetailAPAR]
(
	intPriceFixationDetailAPARId	INT IDENTITY NOT NULL,
	intPriceFixationDetailId		INT	NOT NULL,
	intBillId						INT,
	intBillDetailId					INT,
	intInvoiceId					INT,
	intInvoiceDetailId				INT,
	ysnMarkDelete					BIT,
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

		declare @intActiveContractDetailId int = 0;
		declare @intPricingTypeId int = 0;
		declare @dblSequenceQuantity numeric(18,6) = 0.00;
		declare @intPricingStatus int = 0;
		declare @dblPricedQuantity numeric(18,6) = 0.00;
	
		declare @intActiveId int = 0;
		declare @dblCommulativeAppliedAndPrice numeric(18,6) = 0;
		declare @dblActivelAppliedQuantity numeric(18,6);
		declare @dblRemainingAppliedQuantity numeric(18,6) = 0;
		declare @ysnLoad bit;
		declare @ErrMsg nvarchar(max);

		declare @Pricing table (
			intId int
			,intContractHeaderId int
			,ysnLoad bit
			,intContractDetailId int
			,dblSequenceQuantity numeric(18,6)
			,dblBalance numeric(18,6)
			,dblAppliedQuantity numeric(18,6)
			,intNoOfLoad int null
			,dblBalanceLoad numeric(18,6)
			,dblAppliedLoad numeric(18,6)
			,intPriceFixationId int
			,intPriceFixationDetailId int
			,intPricingNumber int
			,intNumber int
			,dblPricedQuantity numeric(18,6)
			,dblQuantityAppliedAndPriced numeric(18,6)
			,dblLoadPriced numeric(18,6)
			,dblLoadAppliedAndPriced numeric(18,6)
			,dblCorrectAppliedAndPriced numeric(18,6) null
		)
		
		begin try

		select top 1 @intActiveContractDetailId = pf.intContractDetailId from inserted i, tblCTPriceFixationDetail pfd, tblCTPriceFixation pf where pfd.intPriceFixationDetailId = i.intPriceFixationDetailId and pf.intPriceFixationId = pfd.intPriceFixationId;

		insert into @Pricing
		select
			intId = convert(int,ROW_NUMBER() over (order by pfd.intPriceFixationDetailId))
			,ch.intContractHeaderId
			,ch.ysnLoad
			,cd.intContractDetailId
			,dblSequenceQuantity = cd.dblQuantity
			,cd.dblBalance
			,dblAppliedQuantity = cd.dblQuantity - cd.dblBalance
			,cd.intNoOfLoad
			,cd.dblBalanceLoad
			,dblAppliedLoad = cd.intNoOfLoad - cd.dblBalanceLoad
			,pf.intPriceFixationId
			,pfd.intPriceFixationDetailId
			,intPricingNumber = ROW_NUMBER() over (partition by pf.intPriceFixationId order by pfd.intPriceFixationDetailId)
			,pfd.intNumber
			,dblPricedQuantity = isnull(invoiced.dblQtyShipped, pfd.dblQuantity)
			,pfd.dblQuantityAppliedAndPriced
			,pfd.dblLoadPriced
			,pfd.dblLoadAppliedAndPriced
			,dblCorrectAppliedAndPriced = null
		from tblCTPriceFixation pf
		join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
		join tblCTContractDetail cd on cd.intContractDetailId = pf.intContractDetailId
		join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
		left join (
			select 
				ar.intPriceFixationDetailId, dblQtyShipped = sum(di.dblQtyShipped)
			from
				tblCTPriceFixationDetailAPAR ar
				join tblARInvoiceDetail di on di.intInvoiceDetailId = ar.intInvoiceDetailId
			group by
				ar.intPriceFixationDetailId
		) invoiced on invoiced.intPriceFixationDetailId = pfd.intPriceFixationDetailId
		where pf.intContractDetailId = @intActiveContractDetailId
		order by pfd.intPriceFixationDetailId

		select @intActiveId = min(intId) from @Pricing
		while (@intActiveId is not null)
		begin
			select
				@dblActivelAppliedQuantity = (case when ysnLoad = 1 then dblAppliedLoad else dblAppliedQuantity end)
				,@dblPricedQuantity = (case when ysnLoad = 1 then dblLoadPriced else dblPricedQuantity end)
				,@ysnLoad = isnull(ysnLoad,0)
			from
				@Pricing
			where
				intId = @intActiveId;

			set @dblCommulativeAppliedAndPrice += @dblPricedQuantity;
			if (@dblRemainingAppliedQuantity = 0)
			begin
				set @dblRemainingAppliedQuantity = @dblActivelAppliedQuantity;
			end

			if (@dblCommulativeAppliedAndPrice < @dblActivelAppliedQuantity)
			begin
				update @Pricing
				set dblCorrectAppliedAndPriced = @dblPricedQuantity
				where intId = @intActiveId

				set @dblRemainingAppliedQuantity -= @dblPricedQuantity;
			end
			else
			begin
				update @Pricing
				set dblCorrectAppliedAndPriced = @dblRemainingAppliedQuantity
				where intId = @intActiveId

				set @dblRemainingAppliedQuantity -= @dblRemainingAppliedQuantity;
			end



			select @intActiveId = min(intId) from @Pricing where intId > @intActiveId;
		end

		update
			b
		set
			b.intNumber = (case when b.intNumber <> a.intPricingNumber then a.intPricingNumber else b.intNumber end)
			,b.dblQuantityAppliedAndPriced = (case when b.dblQuantityAppliedAndPriced <> a.dblCorrectAppliedAndPriced then a.dblCorrectAppliedAndPriced else b.dblQuantityAppliedAndPriced end)
			,b.dblLoadAppliedAndPriced = (case when @ysnLoad = 1 then a.dblCorrectAppliedAndPriced else null end)
		from
			@Pricing a
			,tblCTPriceFixationDetail b
		where
			(
				a.intNumber <> a.intPricingNumber
				or a.dblCorrectAppliedAndPriced <> (
					case
					when a.ysnLoad = 1
					then a.dblLoadAppliedAndPriced
					else a.dblQuantityAppliedAndPriced
					end
				)
			 )
			and b.intPriceFixationDetailId = a.intPriceFixationDetailId
		end try
		begin catch
			SET @ErrMsg = ERROR_MESSAGE();
			RAISERROR (@ErrMsg,18,1,'WITH NOWAIT');
		end catch


    END