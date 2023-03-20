CREATE PROCEDURE [dbo].[uspCTUpdateSequencePrice]
	@intContractDetailId int			--> Contract Detail ID
	,@dblNewPrice numeric(38,20)		--> New Price
	,@intUserId int						--> User ID
	,@strScreen nvarchar(150)			--> Screen name / Remarks
	,@ysnLastRecord bit					--> If use in a loop, pass 1 for the last record in the loop.
	,@strTxnIdentifier nvarchar(36)		--> convert(nvarchar(36),NEWID()) - If use in loop, should pass the same identifier all over the loop
AS
BEGIN

	declare
		@ErrMsg nvarchar(max)
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
		,@dblOldTotalCost numeric(38,20)
		,@dblTotalCost numeric(38,20)
		,@dblTotalSequenceValue numeric(38,20)
		,@fromHeaderValue nvarchar(38)
		,@toHeaderValue nvarchar(38)
		,@intContractStatusId int
		,@intContractScreenId int
		,@ysnOnceApproved bit
		,@ysnFeedOnApproval bit
		,@intTransactionId int
		,@intApproverId int
		,@intContractSeq int
		,@intValueCurrencyId int
		,@intActiveContractHeaderId int
		,@ysnActiveValue bit
		,@intActiveValueCurrencyId int

		,@intActiveContractSeq int
		,@dblActiveCashPrice numeric(38,20)
		,@dblActiveNewPrice numeric(38,20)
		,@dblActiveOldTotalCost numeric(38,20)
		,@dblActiveTotalCost numeric(38,20)
		,@intActiveContractDetailId int
		;

	declare @UpdatedContract as table (intContractHeaderId int, ysnValue bit, intValueCurrencyId int null);
	DECLARE @auditLog AS BatchAuditLogParam;

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
			,@dblNetWeight = isnull(cd.dblNetWeight,cd.dblQuantity)
			,@intNetWeightUOMId = cd.intNetWeightUOMId
			,@intSequenceCurrencyId = cd.intCurrencyId
			,@intPriceItemUOMId = cd.intPriceItemUOMId
			,@dblCashPrice = cd.dblCashPrice
			,@dblFutures = cd.dblFutures
			,@dblOldTotalCost = cd.dblTotalCost
			,@intContractStatusId = cd.intContractStatusId
			,@intContractSeq = cd.intContractSeq
			,@intValueCurrencyId = ch.intValueCurrencyId
		from
			tblCTContractDetail cd
			join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
		where
			cd.intContractDetailId = @intContractDetailId
			and cd.intPricingTypeId in (6)
			and ch.intPricingTypeId = cd.intPricingTypeId;

		SELECT @ysnFeedOnApproval = ysnFeedOnApproval FROM tblCTCompanyPreference

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

		update tblCTContractDetail set dblCashPrice = @dblNewPrice, dblTotalCost = @dblTotalCost, ysnPriceChanged = 1 where intContractDetailId = @intContractDetailId;

		insert into tblCTUpdatedSequencePrice (
			strTxnIdentifier
			,intContractHeaderId
			,intContractDetailId
			,intContractSeq
			,dblOldCashPrice
			,dblNewCashPrice
			,dblOldTotalCost
			,dblNewTotalCost
			,intValueCurrencyId
			,ysnValue

		)
		select
			strTxnIdentifier = @strTxnIdentifier
			,intContractHeaderId = @intContractHeaderId
			,intContractDetailId = @intContractDetailId
			,intContractSeq = @intContractSeq
			,dblOldCashPrice = @dblCashPrice
			,dblNewCashPrice = @dblNewPrice
			,dblOldTotalCost = @dblOldTotalCost
			,dblNewTotalCost = @dblTotalCost
			,intValueCurrencyId = @intValueCurrencyId
			,ysnValue = case when @strContractBase = 'Value' then 1 else 0 end
		
		/*Begin of extracted code from uspCTSaveContract*/

		declare @ysnUpdateVesselInfo bit;
		SELECT @ysnUpdateVesselInfo = ysnUpdateVesselInfo FROM tblLGCompanyPreference
		IF @ysnUpdateVesselInfo = 1
		BEGIN
			UPDATE	LO
			SET		LO.strOriginPort		=	LC.strCity,
					LO.strDestinationPort	=	DC.strCity
			FROM	tblLGLoad			LO 
			JOIN	tblLGLoadDetail		LD	ON	LD.intLoadId	=	LO.intLoadId 
			JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	ISNULL(LD.intSContractDetailId,LD.intPContractDetailId)
			JOIN	tblSMCity			LC	ON	LC.intCityId	=	CD.intLoadingPortId
			JOIN	tblSMCity			DC	ON	DC.intCityId	=	CD.intDestinationPortId
			WHERE	(LD.intSContractDetailId = @intContractDetailId 
			OR		LD.intPContractDetailId = @intContractDetailId)
			AND		LC.strCity	IS NOT NULL 
			AND		DC.strCity	IS NOT NULL 

			UPDATE	LD
			SET		LD.intPSubLocationId = CD.intSubLocationId
			FROM	tblLGLoadDetail LD
			JOIN	tblCTContractDetail CD ON LD.intPContractDetailId = CD.intContractDetailId
			WHERE	(LD.intSContractDetailId = @intContractDetailId 
			OR		LD.intPContractDetailId = @intContractDetailId)
		END

		if (@ysnLastRecord = 1)
		begin

			insert into @UpdatedContract(intContractHeaderId, ysnValue, intValueCurrencyId) select distinct intContractHeaderId, ysnValue, intValueCurrencyId from tblCTUpdatedSequencePrice where strTxnIdentifier = @strTxnIdentifier;
			
			select @strScreen = 'Value from ' + @strScreen;

			while exists (select top 1 1 from @UpdatedContract)
			begin

				select top 1 @intActiveContractHeaderId = intContractHeaderId, @ysnActiveValue = ysnValue, @intActiveValueCurrencyId = intValueCurrencyId from @UpdatedContract;
				
				if (@ysnActiveValue = 1)
				begin
					select @dblTotalSequenceValue = sum(cd.dblTotalCost * isnull(x.dblRate,1))
					from
						tblCTContractDetail cd
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
						) x on x.intFromCurrencyId = cd.intCurrencyId and x.intToCurrencyId = @intActiveValueCurrencyId
					where
						cd.intContractHeaderId = @intActiveContractHeaderId

					if (@dblHeaderValue < @dblTotalSequenceValue)
					begin
						update tblCTContractHeader set dblValue = @dblTotalSequenceValue, intConcurrencyId = (intConcurrencyId + 1) where intContractHeaderId = @intContractHeaderId;

						INSERT INTO @auditLog (
							[Id]
							, [Namespace]
							, [Action]
							, [Description]
							, [From]
							, [To]
							, [EntityId]
						)
						SELECT
							[Id]				= L.intContractHeaderId
							, [Namespace]		= 'ContractManagement.view.Contract'
							, [Action]			= 'Updated'
							, [Change]		    = 'Value'
							, [From]			= @dblHeaderValue
							, [To]				= @dblTotalSequenceValue
							, [EntityId]		= @intUserId
						FROM tblCTUpdatedSequencePrice L

					end
				end

				delete @auditLog;

                INSERT INTO @auditLog (
                    [Id]
                    , [Namespace]
                    , [Action]
                    , [Description]
                    , [From]
                    , [To]
                    , [EntityId]
                )
                SELECT
                    [Id]				= L.intContractHeaderId
                    , [Namespace]		= 'ContractManagement.view.Contract'
                    , [Action]			= 'Updated'
                    , [Change]		    = 'Cash Price'
                    , [From]			= L.dblOldCashPrice
                    , [To]				= L.dblNewCashPrice
                    , [EntityId]		= @intUserId
                FROM tblCTUpdatedSequencePrice L
				union all
                SELECT
                    [Id]				= L.intContractHeaderId
                    , [Namespace]		= 'ContractManagement.view.Contract'
                    , [Action]			= 'Updated'
                    , [Change]		    = 'Total Cost'
                    , [From]			= L.dblOldTotalCost
                    , [To]				= L.dblNewTotalCost
                    , [EntityId]		= @intUserId
                FROM tblCTUpdatedSequencePrice L

                IF EXISTS (SELECT TOP 1 NULL FROM @auditLog)
                    EXEC dbo.uspSMBatchAuditLog
                        @AuditLogParam 	= @auditLog
                        ,@EntityId		= @intUserId

				select @ysnActiveValue = null, @intActiveValueCurrencyId = null;
				delete @UpdatedContract where intContractHeaderId = @intActiveContractHeaderId;
			end

			delete tblCTUpdatedSequencePrice where strTxnIdentifier = @strTxnIdentifier;

		end

		SELECT	@intContractScreenId=	intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract'

		SELECT  @ysnOnceApproved  =	ysnOnceApproved,
				@intTransactionId = intTransactionId 
		FROM	tblSMTransaction 
		WHERE	intRecordId = @intContractHeaderId 
		AND		intScreenId = @intContractScreenId

		SELECT	TOP 1
				@intApproverId	  =	intApproverId 
		FROM	tblSMApproval 
		WHERE	intTransactionId  =	@intTransactionId 
		AND		intScreenId = @intContractScreenId 
		AND		strStatus = 'Approved' 
		ORDER BY intApprovalId DESC

		IF	@intContractStatusId	=	1	AND
			@ysnOnceApproved		=	1	AND
			@ysnFeedOnApproval		=	1	AND
			NOT EXISTS (SELECT TOP 1 1 FROM tblCTApprovedContract WHERE intContractHeaderId = @intContractHeaderId)
		BEGIN
			EXEC uspCTContractApproved	@intContractHeaderId, @intApproverId, @intContractDetailId, 1, 1
		END

		/*End of extracted code from uspCTSaveContract*/

	goSkip:

	end try
	begin catch
		delete tblCTUpdatedSequencePrice where strTxnIdentifier = @strTxnIdentifier;
		SET @ErrMsg = ERROR_MESSAGE()  
		RAISERROR (@ErrMsg,18,1,'WITH NOWAIT') 
	end catch

END