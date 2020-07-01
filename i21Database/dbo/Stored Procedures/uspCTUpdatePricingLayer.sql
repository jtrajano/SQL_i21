CREATE PROCEDURE [dbo].[uspCTUpdatePricingLayer]
	@intInvoiceId int = null, --> can be null - means detail delete only NOTE: If NULL, @intInvoiceDetailId parameter should have its value
	@intInvoiceDetailId int = null, --> can be null - means header delete NOTE: If NULL, @intInvoiceId parameter should have its value
	@strScreen nvarchar(50) = null, --> possible values are 'Invoice', 'Voucher', etc...
	@UserId int = null
AS
BEGIN

    declare @intPriceFixationId int;
    declare @intContractPriceId int;
    declare @intPriceFixationDetailId int;
	declare @dblPricedQuantity numeric(18,6);
	declare @dblInvoiceDetailQuantity numeric(18,6);
	declare @intContractDetailId int;
	declare @intContractHeaderId int;


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

		set @dblInvoiceDetailQuantity = isnull(@dblInvoiceDetailQuantity,0)

		update tblCTPriceFixationDetailAPAR set ysnMarkDelete = 1 where intInvoiceDetailId = @intInvoiceDetailId;
		exec uspCTProcessInvoiceDelete
			@dblInvoiceDetailQuantity = @dblInvoiceDetailQuantity
			,@intPriceFixationDetailId = @intPriceFixationDetailId
			,@UserId = null

		set @intInvoiceDetailId = (select min(intInvoiceDetailId) from @InvoiceDetails where intInvoiceDetailId > @intInvoiceDetailId);
	end


END