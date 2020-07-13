CREATE PROCEDURE [dbo].[uspCTDeleteUnpostedInvoiceFromPricingUpdate]
	@InvoiceDetailIds nvarchar(100),
	@intUserId int
AS
begin try
	declare @strErrorMessage nvarchar(max);
	declare @intInvoiceDetailId int;
	declare @intInvoiceDetailParamId int;
	declare @intInvoiceId int;
	declare @Count int;

	SELECT  di.intInvoiceId, di.intInvoiceDetailId
	INTO	#ItemInvoice
	FROM	fnSplitString(@InvoiceDetailIds,',') ss
	join tblARInvoiceDetail di on di.intInvoiceDetailId = ss.Item
	order by ss.Item

	select @intInvoiceDetailId = MIN(intInvoiceDetailId) FROM #ItemInvoice
	while (@intInvoiceDetailId is not null)
	begin

		set @intInvoiceDetailParamId = @intInvoiceDetailId;
		select @intInvoiceId = intInvoiceId FROM #ItemInvoice where intInvoiceDetailId = @intInvoiceDetailParamId;
		select @Count = COUNT(*) FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId
		DELETE FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceDetailId = @intInvoiceDetailParamId
		
		if (@Count = 1)
		begin
			set @intInvoiceDetailParamId = null
		end

		EXEC uspARDeleteInvoice @intInvoiceId,@intUserId,@intInvoiceDetailParamId

		select @intInvoiceDetailId = MIN(intInvoiceDetailId) FROM #ItemInvoice where intInvoiceDetailId > @intInvoiceDetailId;
	end


end try
begin catch
		SET @strErrorMessage = ERROR_MESSAGE()  
		RAISERROR (@strErrorMessage,18,1,'WITH NOWAIT') 
end catch

