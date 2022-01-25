CREATE PROCEDURE [dbo].[uspCTGetContractPrice]
	@intContractHeaderId int
	,@intContractDetailId int
	,@dblQuantityToPrice numeric(18,6)
	,@strScreen nvarchar(100) /*screen that calls the procedure like "Ticket", "Inventory", etc..*/
	
AS

BEGIN TRY

declare @ErrMsg NVARCHAR(MAX);
declare @pricing cursor;
declare @intPriceContractId int;
declare @intPriceFixationId int;
declare @intPriceFixationDetailId int;
declare @dblPricedQuantity numeric(18,6);
declare @dblFinalPrice numeric(18,6);
declare @dblShippedForInvoice numeric(18,6);
declare @dblInvoicedPricedQuantity  numeric(18,6);
declare @intItemUOMId int;
declare @dblPricedQuantityForInvoice  numeric(18,6);
declare @dblQuantityForInvoice  numeric(18,6);
declare @ysnLoad bit = 0;

declare @ContractPrieList table (
	intIdentity int identity not null
	,intContractHeaderId int
	,intContractDetailId int
	,ysnLoad bit
	,intPriceContractId int
	,intPriceFixationId int
	,intPriceFixationDetailId int
	,dblQuantity numeric(18,6)
	,dblPrice numeric(18,6)
)

select @intContractHeaderId = isnull(@intContractHeaderId,intContractHeaderId), @intItemUOMId = intItemUOMId from tblCTContractDetail where intContractDetailId = @intContractDetailId;
select @ysnLoad = isnull(ysnLoad,0) from tblCTContractHeader where intContractHeaderId = @intContractHeaderId;
select @intPriceContractId = intPriceContractId from tblCTPriceFixation where intContractDetailId = @intContractDetailId;

set @dblShippedForInvoice = @dblQuantityToPrice;
				/*---Loop Pricing---*/
				SET @pricing = CURSOR FOR
					select
						intContractHeaderId = isnull(@intContractHeaderId,a.intContractHeaderId)
						,a.intPriceFixationId
						,b.intPriceFixationDetailId
						,dblQuantity = (case when @ysnLoad = 0 then b.dblQuantity else b.dblLoadPriced end)
						,dblFinalPrice = dbo.fnCTConvertToSeqFXCurrency(a.intContractDetailId,c.intFinalCurrencyId,f.intItemUOMId,b.dblFinalPrice)
					from
						tblCTPriceFixation a
						,tblCTPriceFixationDetail b
						,tblCTPriceContract c
						,tblCTContractDetail d
						,tblICCommodityUnitMeasure e
						,tblICItemUOM f
					where
						a.intPriceContractId = @intPriceContractId
						and b.intPriceFixationId = a.intPriceFixationId
						and c.intPriceContractId = a.intPriceContractId
						and d.intContractDetailId = a.intContractDetailId
						and e.intCommodityUnitMeasureId	=	b.intPricingUOMId
						and f.intItemId = d.intItemId
						and f.intUnitMeasureId = e.intUnitMeasureId
						and a.intContractDetailId = @intContractDetailId

				OPEN @pricing

				FETCH NEXT
				FROM
					@pricing
				INTO
					@intContractHeaderId
					,@intPriceFixationId
					,@intPriceFixationDetailId
					,@dblPricedQuantity
					,@dblFinalPrice

				WHILE @@FETCH_STATUS = 0
				BEGIN
					
					--Skip Pricing loop if Shipped Quantity For Invoice is 0
					if (@dblShippedForInvoice = 0)
					begin
						goto SkipPricingLoop;
					end

					if (@ysnLoad = 0)
					begin
						set @dblInvoicedPricedQuantity = 
							case
							when isnull(@intPriceFixationDetailId,0) = 0
							then
								(
									SELECT
										SUM(dbo.fnCTConvertQtyToTargetItemUOM(AD.intItemUOMId,@intItemUOMId,AD.dblQtyShipped))
									FROM
										tblARInvoiceDetail AD
									WHERE
										AD.intContractDetailId = @intContractDetailId
										and isnull(AD.intInventoryShipmentChargeId,0) = 0
										and isnull(AD.ysnReturned,0) = 0
								)
							else
								(
									SELECT
										SUM(dbo.fnCTConvertQtyToTargetItemUOM(AD.intItemUOMId,@intItemUOMId,AD.dblQtyShipped))
									FROM
										tblCTPriceFixationDetailAPAR AA
										JOIN tblARInvoiceDetail AD ON AD.intInvoiceDetailId	= AA.intInvoiceDetailId
									WHERE
										AA.intPriceFixationDetailId = @intPriceFixationDetailId
										and isnull(AD.ysnReturned,0) = 0
								)
							end
					end
					else
					begin
						set @dblInvoicedPricedQuantity =
							case
							when
								isnull(@intPriceFixationDetailId,0) = 0
							then
								(
									SELECT
										count(AD.intInvoiceDetailId)
									FROM
										tblARInvoiceDetail AD
									WHERE
										AD.intContractDetailId = @intContractDetailId
										and isnull(AD.intInventoryShipmentChargeId,0) = 0
										and isnull(AD.ysnReturned,0) = 0
								)
							else
								(
									select count(*) from
									(
										select distinct intInvoiceId from tblCTPriceFixationDetailAPAR where intPriceFixationDetailId = @intPriceFixationDetailId and isnull(ysnReturn,0) = 0
									) uniqueInvoice
								)
							end
					end

					
					set @dblPricedQuantityForInvoice = 0;
					set @dblInvoicedPricedQuantity = isnull(@dblInvoicedPricedQuantity,0.00);

					--Check if Priced Detail has remaining quantity. If no, skip Pricing Loop
					if (@dblPricedQuantity = @dblInvoicedPricedQuantity)
					begin
						goto SkipPricingLoop;
					end

					if (@dblPricedQuantity > @dblInvoicedPricedQuantity)
					begin
						set @dblPricedQuantityForInvoice = (@dblPricedQuantity - @dblInvoicedPricedQuantity);
					end

					set @dblQuantityForInvoice = @dblPricedQuantityForInvoice;
					if (@dblPricedQuantityForInvoice > @dblShippedForInvoice)
					begin
						set @dblQuantityForInvoice = @dblShippedForInvoice;	
					end

					set @dblPricedQuantityForInvoice = (@dblPricedQuantityForInvoice - @dblQuantityForInvoice);
					set @dblShippedForInvoice = (@dblShippedForInvoice - @dblQuantityForInvoice);

					--select @dblQuantityForInvoice,@dblPricedQuantityForInvoice,@dblShippedForInvoice,@dblFinalPrice;

					insert into @ContractPrieList
						select
						intContractHeaderId = @intContractHeaderId
						,intContractDetailId = @intContractDetailId
						,ysnLoad = @ysnLoad
						,intPriceContractId = @intPriceContractId
						,intPriceFixationId = @intPriceFixationId
						,intPriceFixationDetailId = @intPriceFixationDetailId
						,dblQuantity = @dblQuantityForInvoice
						,dblPrice = @dblFinalPrice

					SkipPricingLoop:
						
					FETCH NEXT
					FROM
						@pricing
					INTO
						@intContractHeaderId
						,@intPriceFixationId
						,@intPriceFixationDetailId
						,@dblPricedQuantity
						,@dblFinalPrice

				END

				CLOSE @pricing
				DEALLOCATE @pricing
				/*---End Loop Pricing---*/

				select * from @ContractPrieList

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH