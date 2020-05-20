CREATE PROCEDURE [dbo].[uspCTUpdatePricingLayer]
	@intInvoiceId int = null, --> can be null - means detail delete only NOTE: If NULL, @intInvoiceDetailId parameter should have its value
	@intInvoiceDetailId int = null, --> can be null - means header delete NOTE: If NULL, @intInvoiceId parameter should have its value
	@strScreen nvarchar(50) = null --> possible values are 'Invoice', 'Voucher', etc...
AS
BEGIN

    declare @intPriceFixationId int;
    declare @intContractPriceId int;
    declare @intPriceFixationDetailId int;
	declare @dblPricedQuantity numeric(18,6);
	declare @dblInvoiceDetailQuantity numeric(18,6);
	declare @intContractDetailId int;

	declare @InvoiceDetails table (
		intInvoiceDetailId int
	)

	if (@intInvoiceDetailId is not null)
	begin
		insert into @InvoiceDetails select @intInvoiceDetailId;
	end
	else
	begin
		insert into @InvoiceDetails select intInvoiceDetailId from tblARInvoiceDetail where intInvoiceId = @intInvoiceId order by intInvoiceDetailId asc
	end

	set @intInvoiceDetailId = 0;

	set @intInvoiceDetailId = (select min(intInvoiceDetailId) from @InvoiceDetails where intInvoiceDetailId > @intInvoiceDetailId);

	while @intInvoiceDetailId is not null
	begin

		select
			@intInvoiceDetailId = intInvoiceDetailId
			,@intPriceFixationDetailId = intPriceFixationDetailId
		from
			tblCTPriceFixationDetailAPAR
		where intInvoiceDetailId = @intInvoiceDetailId;

		select
			@dblInvoiceDetailQuantity = dblQtyShipped
		from
			tblARInvoiceDetail
		where
			intInvoiceDetailId = @intInvoiceDetailId;

		select
			@dblPricedQuantity = dblQuantity
			,@intPriceFixationId = intPriceFixationId
		from
			tblCTPriceFixationDetail
		where
			intPriceFixationDetailId = @intPriceFixationDetailId

		select @intContractPriceId = intPriceContractId,@intContractDetailId = intContractDetailId from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;

		set @dblPricedQuantity = isnull(@dblPricedQuantity,0)
		set @dblInvoiceDetailQuantity = isnull(@dblInvoiceDetailQuantity,0)

		if (@dblPricedQuantity > @dblInvoiceDetailQuantity)
		begin
			update
				tblCTPriceFixationDetail
			set
				dblNoOfLots = dblNoOfLots - ((@dblPricedQuantity - @dblInvoiceDetailQuantity)/(dblQuantity / case when isnull(dblNoOfLots,0) = 0 then 1 else dblNoOfLots end))
				,dblQuantity = @dblPricedQuantity - @dblInvoiceDetailQuantity
			where
				intPriceFixationDetailId = @intPriceFixationDetailId;
		end
		else
		begin
			if ((select count(*) from tblCTPriceFixationDetail where intPriceFixationId = @intPriceFixationId) = 1)
			begin
				delete from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;
				if ((select count(*) from tblCTPriceFixation where intPriceContractId = @intContractPriceId) = 0)
				begin
					delete from tblCTPriceContract where intPriceContractId = @intContractPriceId;
				end
			end
			else
			begin
				delete from tblCTPriceFixationDetail where intPriceFixationDetailId = @intPriceFixationDetailId;
			end
		end

		set @intInvoiceDetailId = (select min(intInvoiceDetailId) from @InvoiceDetails where intInvoiceDetailId > @intInvoiceDetailId);
	end

	update tblCTContractDetail set intPricingTypeId = 2,dblFutures = null, dblCashPrice = null,intConcurrencyId = (intConcurrencyId + 1) where intContractDetailId = @intContractDetailId;
    

END