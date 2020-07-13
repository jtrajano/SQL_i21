CREATE FUNCTION [dbo].[fnCTGetPricingDetailVoucherInvoice]
(
	@intPriceFixationDetailId INT
)
RETURNS NVARCHAR(MAX)
AS 
begin
	declare @AffectedVoucherInvoice table (
		strMessage nvarchar(100)
	);
	declare @strFinalMessage nvarchar(max);
	declare @strContractType nvarchar(15);

	select top 1 @strContractType = case when ch.intContractTypeId = 1 then 'Purchase' else 'Sale' end
	from tblCTContractHeader ch
	inner join tblCTPriceFixation pf on ch.intContractHeaderId = pf.intContractHeaderId
	inner join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
	where pfd.intPriceFixationDetailId = @intPriceFixationDetailId

	if @strContractType = 'Purchase'
	begin
		insert into @AffectedVoucherInvoice
		select
			strMessage = d.strBillId + ' line item ' + convert(nvarchar(20),t.intVoucherLineItemId) 
		from
			tblCTPriceFixationDetailAPAR c
			left join 
			(
				select
					intVoucherLineItemId = ROW_NUMBER() over (partition by b.intBillId order by b.intBillDetailId)
					,a.intPriceFixationDetailId
					,b.intBillId
					,b.intBillDetailId
				from
					tblCTPriceFixationDetailAPAR a
					,tblAPBillDetail b
				where
					a.intPriceFixationDetailId = @intPriceFixationDetailId
					and b.intBillId = a.intBillId
			)t on t.intBillId = c.intBillId and t.intBillDetailId = c.intBillDetailId
			left join tblAPBill d on d.intBillId = c.intBillId
		where
			c.intPriceFixationDetailId = @intPriceFixationDetailId
	end
	else
	begin
		insert into @AffectedVoucherInvoice
		select
			strMessage = d.strInvoiceNumber + ' line item ' + convert(nvarchar(20),t.intInvoiceLineItemId) 
		from
			tblCTPriceFixationDetailAPAR c
			left join 
			(
				select
					intInvoiceLineItemId = ROW_NUMBER() over (partition by b.intInvoiceId order by b.intInvoiceDetailId)
					,a.intPriceFixationDetailId
					,b.intInvoiceId
					,b.intInvoiceDetailId
				from
					tblCTPriceFixationDetailAPAR a
					,tblARInvoiceDetail b
				where
					a.intPriceFixationDetailId = @intPriceFixationDetailId
					and b.intInvoiceId = a.intInvoiceId
			)t on t.intInvoiceId = c.intInvoiceId and t.intInvoiceDetailId = c.intInvoiceDetailId
			left join tblARInvoice d on d.intInvoiceId = c.intInvoiceId
		where
			c.intPriceFixationDetailId = @intPriceFixationDetailId
	end

	select top 1 @strFinalMessage = case when @strContractType = 'Purchase' 
										then 'Voucher/s' 
										else 'Invoice/s' 
								    end + stuff((SELECT ', ' + strMessage FROM @AffectedVoucherInvoice FOR XML PATH ('')), 1, 1, '') + ' is using the price. '
									+ case when @strContractType = 'Purchase' 
										then 'Price cannot be edited.' 
										else 'Please delete this price then price it again with the correct details.'
								    end
	from
		@AffectedVoucherInvoice

	return @strFinalMessage;

end