CREATE PROCEDURE [dbo].[uspCTValidatePricingUpdateDelete]
	@intPriceFixationDetailId	int					--= 1858
	,@dblPricedQuantity 		numeric(18,6) 		--= 350
	,@strTransaction 			nvarchar(10) 		--= 'delete'

AS

begin try

	declare @strErrorMessage nvarchar(1000) = 'Unable to update the price layer.  The quantity that you are reducing needs to equal to the last invoice quantity or the sum of the last X0 invoices.';
	declare @strErrorMessageForFirstLoop nvarchar(1000) = 'Unable to update the price layer.  The quantity that you are reducing needs to equal to the last invoice quantity or the sum of the last invoice quantity and excess quantity.';
	declare @strErrorMessageForLowerQuantity nvarchar(1000) = 'Unable to update the price layer.  The quantity that you are about to price should not less than the total quantity of posted invoices created from the price layer.';
	declare @dblTotalPostedInvoiceQuantity numeric(18,6) = 0;
	declare @ysnDeleteAllUnpostedDetail bit = 0;
	declare @intActiveId int = 0;
	declare @dblTotalInvoiceQuantity numeric(18,6) = 0;
	declare @dblForReduceQuantityFromUnpostedInvoices numeric(18,6);

	declare @intActiveInvoiceId int;
	declare @intActiveInvoiceDetailId int;
	declare @dblActiveQtyShipped numeric(18,6);
	declare @dblCommulativeQtyShipped numeric(18,6);

	declare @strPostedInvoices nvarchar(max) = '';
	declare @strErrorMessageForDeletingWithPostedInvoice nvarchar(1000) = 'X0';

	declare @ysnLoad bit = 0;

	declare @ReturnTable table (
		intInvoiceId int
		,intInvoiceDetailId int
		,strMessage nvarchar(1000)
	)

	declare @UnpostedInvoiceDetail table (
		intId int
		,intInvoiceId int
		,intInvoiceDetailId int
		,dblQtyShipped numeric(18,6)
	)

	select
		@ysnLoad = isnull(ch.ysnLoad,0)
	from
		tblCTPriceFixationDetail pfd
		,tblCTPriceFixation pf
		,tblCTContractHeader ch
	where
		pfd.intPriceFixationDetailId = @intPriceFixationDetailId
		and pf.intPriceFixationId = pfd.intPriceFixationId
		and ch.intContractHeaderId = pf.intContractHeaderId


	if (@strTransaction = 'update')
	begin

		/*Check if there's an invoice created from pricing layer.*/
		if exists (
			select
				top 1 1
			from
				tblCTPriceFixationDetailAPAR ar
				join tblARInvoiceDetail di on di.intInvoiceId = ar.intInvoiceId
			where ar.intPriceFixationDetailId = @intPriceFixationDetailId
		)
		begin
			/*Get the total quantity of posted invoice/s created from this pricing layer.*/
			if (@ysnLoad = 0)
			begin
				select
					@dblTotalPostedInvoiceQuantity = isnull(sum(di.dblQtyShipped),0)
				from
					tblCTPriceFixationDetailAPAR ar
					join tblARInvoiceDetail di on di.intInvoiceDetailId = ar.intInvoiceDetailId
					join tblARInvoice i on i.intInvoiceId = di.intInvoiceId
				where
					isnull(i.ysnPosted,0) = 1
					and ar.intPriceFixationDetailId = @intPriceFixationDetailId
				end
			else
			begin
				select
					@dblTotalPostedInvoiceQuantity = count(distinct ar.intInvoiceId)
				from
					tblCTPriceFixationDetailAPAR ar
					join tblARInvoice i on i.intInvoiceId = ar.intInvoiceId
				where
					isnull(i.ysnPosted,0) = 1
					and ar.intPriceFixationDetailId = @intPriceFixationDetailId
			end

			/*Compare the total quantity of posted invoice/s created from this pricing layer to the new priced quantity.*/
			/*If the price quantity is less than the total quantity of posted invoice/s created from this pricing layer, throw an error. This hould not happen.*/
			if (@dblPricedQuantity < @dblTotalPostedInvoiceQuantity)
			begin
				insert into @ReturnTable
				select
					intInvoiceId = 0
					,intInvoiceDetailId = 0
					,strMessage = @strErrorMessageForLowerQuantity

				goto exitupdatevalidation;
			end

			/*If the quantities are the same, set the flag to true.*/
			if (@dblPricedQuantity = @dblTotalPostedInvoiceQuantity)
			begin
				set @ysnDeleteAllUnpostedDetail = 1;
			end
			else
			begin
				/*Get the total quantity of invoice details created from this pricing layer.*/
				if (@ysnLoad = 0)
				begin
					select
						@dblTotalInvoiceQuantity = isnull(sum(di.dblQtyShipped),0)
					from
						tblCTPriceFixationDetailAPAR ar
						join tblARInvoiceDetail di on di.intInvoiceDetailId = ar.intInvoiceDetailId
					where
						ar.intPriceFixationDetailId = @intPriceFixationDetailId
				end
				else
				begin
					select
						@dblTotalInvoiceQuantity = count(distinct ar.intInvoiceId)
					from
						tblCTPriceFixationDetailAPAR ar
					where
						ar.intPriceFixationDetailId = @intPriceFixationDetailId
				end
				
				/*Get the difference between total invoice quantity and priced quantity*/
				set @dblForReduceQuantityFromUnpostedInvoices = @dblTotalInvoiceQuantity - @dblPricedQuantity;

				/*If the difference between total invoice quantity and priced quantity is less than 1, meaning there's no change in the quantity or the user increase the price quantity. So process the increase.*/
				if (@dblForReduceQuantityFromUnpostedInvoices < 1)
				begin
					insert into @ReturnTable
					select
						intInvoiceId = 0
						,intInvoiceDetailId = 0
						,strMessage = 'success'

					goto exitupdatevalidation;
				end
			end

			/*Get all unposted invoice details created from this pricing layer*/
			insert into @UnpostedInvoiceDetail
			select distinct
				intId = convert(int,ROW_NUMBER() over (order by di.intInvoiceDetailId desc))
				,i.intInvoiceId
				,di.intInvoiceDetailId
				,dblQtyShipped = (case when @ysnLoad = 1 then 1 else di.dblQtyShipped end)
			from
				tblCTPriceFixationDetail pfd
				join tblCTPriceFixationDetailAPAR ar on ar.intPriceFixationDetailId = pfd.intPriceFixationDetailId
				join tblARInvoiceDetail di on di.intInvoiceDetailId = ar.intInvoiceDetailId
				join tblARInvoice i on i.intInvoiceId = di.intInvoiceId
			where
				pfd.intPriceFixationDetailId = @intPriceFixationDetailId
				and isnull(i.ysnPosted,0) <> 1
			order by
				di.intInvoiceDetailId desc

			/*Check if there's an unposted invoice details created from this pricing layer.*/
			if exists(select top 1 1 from @UnpostedInvoiceDetail)
			begin
				select @intActiveId = min(intId) from @UnpostedInvoiceDetail;
				/*Loop through unposted invoice details created from this pricing layer.*/
				while (@intActiveId is not null)
				begin
					/*if the new price quantity is equal to the total posted quantity, get all unposted invoice details for delete.*/
					if (@ysnDeleteAllUnpostedDetail = 1)
					begin
						insert into @ReturnTable
						select
							intInvoiceId = intInvoiceId
							,intInvoiceDetailId = intInvoiceDetailId
							,strMessage = 'success'
						from @UnpostedInvoiceDetail
						where
							intId = @intActiveId
					end
					else
					begin
						--select * from @UnpostedInvoiceDetail
						print 'some code here'
						/*if the new price quantity is greater than the total posted quantity, validate if the reduce quantity is equal to the last invoice detail quantity or to the sum of X number of invoice details quantity..*/
						select
							@intActiveInvoiceId = intInvoiceId
							,@intActiveInvoiceDetailId = intInvoiceDetailId
							,@dblActiveQtyShipped = dblQtyShipped
						from @UnpostedInvoiceDetail
						where
							intId = @intActiveId

						/*On the 1st loop, if the quantity to be reduce from unposted invoice detail quantity is less than from the first unposted invoice detail quantity (latest), throw an error*/
						if (@intActiveId = 1 and @dblForReduceQuantityFromUnpostedInvoices = @dblActiveQtyShipped)
						begin
							insert into @ReturnTable
							select
								intInvoiceId = @intActiveInvoiceId
								,intInvoiceDetailId = @intActiveInvoiceDetailId
								,strMessage = 'success'

							goto exitupdatevalidation;
						end

						/*On the 1st loop, if the quantity to be reduce from unposted invoice detail quantity is less than from the first unposted invoice detail quantity (latest), throw an error*/
						if (@intActiveId = 1 and @dblForReduceQuantityFromUnpostedInvoices < @dblActiveQtyShipped)
						begin
							insert into @ReturnTable
							select
								intInvoiceId = 0
								,intInvoiceDetailId = 0
								,strMessage = @strErrorMessageForFirstLoop

							goto exitupdatevalidation;
						end

						set @dblCommulativeQtyShipped = isnull(@dblCommulativeQtyShipped,0) + @dblActiveQtyShipped;

						if (@dblForReduceQuantityFromUnpostedInvoices > @dblCommulativeQtyShipped)
						begin
							insert into @ReturnTable
							select
								intInvoiceId = @intActiveInvoiceId
								,intInvoiceDetailId = @intActiveInvoiceDetailId
								,strMessage = 'success'
						end

						if (@dblForReduceQuantityFromUnpostedInvoices = @dblCommulativeQtyShipped)
						begin
							insert into @ReturnTable
							select
								intInvoiceId = @intActiveInvoiceId
								,intInvoiceDetailId = @intActiveInvoiceDetailId
								,strMessage = 'success'

							goto exitupdatevalidation;
						end

						if (@dblForReduceQuantityFromUnpostedInvoices < @dblCommulativeQtyShipped)
						begin
							insert into @ReturnTable
							select
								intInvoiceId = @intActiveInvoiceId
								,intInvoiceDetailId = @intActiveInvoiceDetailId
								,strMessage = replace(@strErrorMessage,'X0',convert(nvarchar(20),@intActiveId))

							goto exitupdatevalidation;
						end
					end
					select @intActiveId = min(intId) from @UnpostedInvoiceDetail where intId > @intActiveId;
				end
			end
			else
			begin
				insert into @ReturnTable
				select
					intInvoiceId = 0
					,intInvoiceDetailId = 0
					,strMessage = 'success'
			end

		end
		else
		begin
			/*This means there's no invoice created from pricing layer. So, process the reduce quantity*/
			insert into @ReturnTable
			select
				intInvoiceId = 0
				,intInvoiceDetailId = 0
				,strMessage = 'success'
		end

		exitupdatevalidation:

	end

	if (@strTransaction = 'delete')
	begin
		/*Get all posted invoices exists in the price*/
		select @strPostedInvoices = STUFF(
				(
					select
						', ' + i.strInvoiceNumber
					from
						tblCTPriceFixationDetailAPAR ar
						join tblARInvoiceDetail di on di.intInvoiceDetailId = ar.intInvoiceDetailId
						join tblARInvoice i on i.intInvoiceId = di.intInvoiceId
					where
						isnull(i.ysnPosted,0) = 1
						and ar.intPriceFixationDetailId = @intPriceFixationDetailId
					FOR xml path('')
				)
			, 1
			, 1
			, ''
		)

		/*Throw an error if not null*/
		if (isnull(@strPostedInvoices,'') <> '')
		begin
			insert into @ReturnTable
			select
				intInvoiceId = 0
				,intInvoiceDetailId = 0
				,strMessage = replace(@strErrorMessageForDeletingWithPostedInvoice,'X0',@strPostedInvoices)
		end
		else
		begin
			insert into @ReturnTable
			select
				intInvoiceId = 0
				,intInvoiceDetailId = 0
				,strMessage = 'success'
		end

	end

	select * from @ReturnTable;

end try
begin catch
		SET @strErrorMessage = ERROR_MESSAGE()  
		RAISERROR (@strErrorMessage,18,1,'WITH NOWAIT') 
end catch