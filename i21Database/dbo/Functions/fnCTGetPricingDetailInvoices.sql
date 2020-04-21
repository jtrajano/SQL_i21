CREATE FUNCTION [dbo].[fnCTGetPricingDetailInvoices]
(
	@intPriceFixationDetailId INT
)
RETURNS NVARCHAR(MAX)
AS 
begin
	declare @AffectedInvoices table (
		strMessage nvarchar(100)
	);
	declare @strFinalMessage nvarchar(max);

	insert into @AffectedInvoices
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

	select
		top 1 @strFinalMessage = 'Invoice/s' + stuff((SELECT ', ' + strMessage FROM @AffectedInvoices FOR XML PATH ('')), 1, 1, '') + ' is using the price. Please delete that first.'
	from
		@AffectedInvoices

	return @strFinalMessage;

end