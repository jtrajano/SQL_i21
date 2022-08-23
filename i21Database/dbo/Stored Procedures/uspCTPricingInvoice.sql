CREATE PROCEDURE [dbo].[uspCTPricingInvoice]
	@intContractDetailId	INT
AS

BEGIN
	declare @tbl table (
		intPriceFixationDetailId INT
		,intInvoiceCnt	 int
	);

	declare @cnt int;

	INSERT INTO @tbl
		select fd.intPriceFixationDetailId, inv.intInvoiceCnt
		from tblCTPriceFixation pf
		join tblCTPriceFixationDetail fd on fd.intPriceFixationId = pf.intPriceFixationId
		cross apply (
			select intInvoiceCnt = count(*) from tblCTPriceFixationDetailAPAR aa where aa.intPriceFixationDetailId = fd.intPriceFixationDetailId and isnull(aa.intInvoiceDetailId,0) > 0
		) inv
		where pf.intContractDetailId = @intContractDetailId
	
	if not exists ( select top 1 1 from @tbl)
	begin
		select intResult = 1
	end
	else
	begin

		select @cnt = count(*) from @tbl;
		if (@cnt > 1)
		begin
			if exists (select top 1 1 from @tbl where isnull(intInvoiceCnt,0) = 0)
			begin
				select intResult = 1
			end
			else
			begin
				select intResult = 0
			end
		end
		else
		begin
			select intResult = 1
		end


	end

END
