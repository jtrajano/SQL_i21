CREATE PROCEDURE [dbo].[uspCTUpdateSequencePrice]
	@intContractDetailId int			--> Contract Detail ID
	,@dblNewPrice numeric(38,20)		--> New Price
	,@intUserId int						--> User ID
	,@strScreen nvarchar(150)			--> Screen name / Remarks
AS
BEGIN

	declare
		@ErrMsg nvarchar(max)
		,@strXML nvarchar(max) = ''
		,@logDetails nvarchar(max)
		,@intContractHeaderId int
		,@intPricingTypeId int
		,@strContractBase nvarchar(10)
		,@dblHeaderQuantity numeric(38,20)
		,@dblHeaderValue numeric(38,20)
		,@intCommodityUOMId int
		,@intHeaderValueCurrencyId int
		,@dblSequenceQuantity numeric(38,20)
		,@intItemUOMId int
		,@dblNetWeight numeric(38,20)
		,@intNetWeightUOMId int
		,@intSequenceCurrencyId int
		,@intPriceItemUOMId int
		,@dblCashPrice numeric(38,20)
		,@dblFutures numeric(38,20)

		,@dblSequenceConvertedQty numeric(38,20)
		,@dblTotalCost numeric(38,20)
		,@dblTotalSequenceValue numeric(38,20)
		,@ysnHedearValueChange bit = 0
		,@fromHeaderValue nvarchar(38)
		,@toHeaderValue nvarchar(38)
		;

	begin try

		select
			@intContractHeaderId = ch.intContractHeaderId
			,@intPricingTypeId = ch.intPricingTypeId
			,@strContractBase = isnull(ch.strContractBase,'Quantity')
			,@dblHeaderQuantity = ch.dblQuantity
			,@dblHeaderValue = ch.dblValue
			,@intCommodityUOMId = ch.intCommodityUOMId
			,@intHeaderValueCurrencyId = ch.intValueCurrencyId
			,@dblSequenceQuantity = cd.dblQuantity
			,@intItemUOMId = cd.intItemUOMId
			,@dblNetWeight = cd.dblNetWeight
			,@intNetWeightUOMId = cd.intNetWeightUOMId
			,@intSequenceCurrencyId = cd.intCurrencyId
			,@intPriceItemUOMId = cd.intPriceItemUOMId
			,@dblCashPrice = cd.dblCashPrice
			,@dblFutures = cd.dblFutures
		from
			tblCTContractDetail cd
			join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
		where
			cd.intContractDetailId = @intContractDetailId
			and cd.intPricingTypeId in (6)
			and ch.intPricingTypeId = cd.intPricingTypeId;

		if (isnull(@intContractHeaderId,0) = 0)
		begin
			SET @ErrMsg = 'The sequence number is not valid to change the price.';
			RAISERROR (@ErrMsg,18,1,'WITH NOWAIT') 
		end

		if exists (select top 1 1 from tblAPBillDetail where intContractDetailId = @intContractDetailId)
		begin
			SET @ErrMsg = 'Unable to change the price. Voucher is already created.';
			RAISERROR (@ErrMsg,18,1,'WITH NOWAIT') 
		end

		if exists (select top 1 1 from tblARInvoiceDetail where intContractDetailId = @intContractDetailId)
		begin
			SET @ErrMsg = 'Unable to change the price. Invoice is already created.';
			RAISERROR (@ErrMsg,18,1,'WITH NOWAIT') 
		end

		if (@intPricingTypeId = 6)
		begin
			if (@strContractBase = 'Value')
			begin
				select @dblSequenceConvertedQty = dbo.fnCTConvertQtyToTargetItemUOM(@intNetWeightUOMId,@intPriceItemUOMId,@dblNetWeight);
			end
			else
			begin
				select @dblSequenceConvertedQty = dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId,@intPriceItemUOMId,@dblSequenceQuantity);
			end
			
			select @dblTotalCost = @dblSequenceConvertedQty * @dblNewPrice;

		end
		else
		begin
			goto goSkip;
		end

		select @strXML = '
			<tblCTContractDetails>
				<tblCTContractDetail>
					<intContractDetailId>'+ convert(nvarchar(20),@intContractDetailId) +'</intContractDetailId>
					<intPricingTypeId>'+ convert(nvarchar(20),@intPricingTypeId) +'</intPricingTypeId>
					<strRowState>Modified</strRowState>
					<dblCashPrice>'+ convert(nvarchar(38),@dblNewPrice) +'</dblCashPrice>
					<tblCTContractCosts></tblCTContractCosts>
					<tblCTContractFutures></tblCTContractFutures>
				</tblCTContractDetail>
			</tblCTContractDetails>
		';

		EXEC uspCTBeforeSaveContract @intContractHeaderId = @intContractHeaderId, @intUserId=@intUserId, @strXML = @strXML;

		update tblCTContractDetail set dblCashPrice = @dblNewPrice, dblTotalCost = @dblTotalCost where intContractDetailId = @intContractDetailId;

		if (@strContractBase = 'Value')
		begin

			select @dblTotalSequenceValue = sum(cd.dblTotalCost * isnull(x.dblRate,1))
			from
				tblCTContractHeader ch
				join tblCTContractDetail cd on ch.intContractHeaderId = cd.intContractHeaderId
				left join (
					select
						dblRate
						,intFromCurrencyId
						,intToCurrencyId
					from 
					(
					select
						intRowId = ROW_NUMBER() OVER (PARTITION BY cerd.intCurrencyExchangeRateId ORDER BY cerd.dtmValidFromDate DESC)
						, cerd.dblRate
						, cer.intFromCurrencyId
						, cer.intToCurrencyId
						, cerd.dtmValidFromDate
						from
							tblSMCurrencyExchangeRate  cer
							join tblSMCurrencyExchangeRateDetail cerd on cerd.intCurrencyExchangeRateId = cer.intCurrencyExchangeRateId
						where
							cerd.dtmValidFromDate <= getdate()
					) exr
					where exr.intRowId = 1
				) x on x.intFromCurrencyId = cd.intCurrencyId and x.intToCurrencyId = ch.intValueCurrencyId
			where
				ch.intContractHeaderId = @intContractHeaderId

			if (@dblHeaderValue < @dblTotalSequenceValue)
			begin
				update tblCTContractHeader set dblValue = @dblTotalSequenceValue, intConcurrencyId = (intConcurrencyId + 1) where intContractHeaderId = @intContractHeaderId;
				select @ysnHedearValueChange = 1;
			end

		end

		select @strXML = '
			<rows>
				<row>
					<intContractDetailId>'+ convert(nvarchar(20),@intContractDetailId) +'</intContractDetailId>
					<ysnStatusChange>0</ysnStatusChange>
					<strRowState>Modified</strRowState>
				</row>
			</rows>
		';

		EXEC uspCTSaveContract @intContractHeaderId = @intContractHeaderId, @userId = @intUserId, @strXML = '', @strTFXML = @strXML;

		set @logDetails = '
		{
					"change": "tblCTContractHeader"
					,"iconCls":"small-tree-grid"
					,"changeDescription": "Pricing"
					,"children": [
						{
							"action": "Updated"
							,"change": "Updated - Record: Sequence 1"
							,"iconCls": "small-tree-modified"
							,"children": [
								{
									"change": "Cash Price"
									,"from": "' + convert(nvarchar(38),@dblCashPrice) + '"
									,"to": "' + convert(nvarchar(38),@dblNewPrice) + '"
									,"leaf": true
									,"iconCls": "small-gear"
								},
								{
									"change": "Total Cost"
									,"from": "15232.24"
									,"to": "163254.34"
									,"leaf": true
									,"iconCls": "small-gear"
								}
							]
						}
					]
		}
		';

		select @fromHeaderValue = '', @toHeaderValue = '';
		if (@ysnHedearValueChange = 1)
		begin
			select @fromHeaderValue = convert(nvarchar(38),@dblHeaderValue), @toHeaderValue = convert(nvarchar(38),@dblTotalSequenceValue);
		end

		EXEC uspSMAuditLog
			@screenName = 'ContractManagement.view.Contract',
			@entityId = @intUserId,
			@actionType = 'Updated',
			@actionIcon = 'small-tree-modified',
			@changeDescription =  @strScreen,
			@keyValue = @intContractHeaderId,
			@details = @logDetails,
			@fromValue = @fromHeaderValue,
			@toValue = @toHeaderValue

	goSkip:

	end try
	begin catch
		SET @ErrMsg = ERROR_MESSAGE()  
		RAISERROR (@ErrMsg,18,1,'WITH NOWAIT') 
	end catch

END