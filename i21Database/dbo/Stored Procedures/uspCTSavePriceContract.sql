CREATE PROCEDURE [dbo].[uspCTSavePriceContract]
	
	@intPriceContractId INT,
	@strXML				NVARCHAR(MAX),
	@ysnApprove			BIT = 0,
	@ysnProcessPricing	BIT = 1,
	@dtmLocalDate		DATETIME = NULL
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg						NVARCHAR(MAX),
			@idoc						INT,
			@intUniqueId				INT,
			@intPriceFixationId			INT,
			@intContractHeaderId		INT,
			@intContractDetailId		INT,
			@intUserId					INT,
			@strRowState				NVARCHAR(50),
			@Condition					NVARCHAR(MAX),
			@intPriceFixationDetailId	INT,
			@intFutOptTransactionId		INT,
			@intBrokerId				INT,
			@intBrokerageAccountId		INT,
			@intFutureMarketId			INT,
			@intCommodityId				INT,
			@intLocationId				INT,
			@intTraderId				INT,
			@intCurrencyId				INT,
			@strBuySell					NVARCHAR(50),
			@dblNoOfContract			NUMERIC(18,6),
			@dblHedgeNoOfLots			NUMERIC(18,6),
			@intHedgeFutureMonthId		INT,
			@dblHedgePrice				NUMERIC(18,6),
			@intBookId					INT,
			@intSubBookId				INT,
			@ysnHedge					BIT,
			@strAction					NVARCHAR(50) = '',
			@intOutputId				INT,
			@dtmFixationDate			DATETIME,
			@ysnFreezed					BIT,
			@ysnAA						BIT,
			@intFutOptTransactionHeaderId INT = NULL,
			@intScreenId				INT,
			@intTransactionId			INT,
			@ysnOnceApproved			INT = 0,
   			@ysnSplit 					BIT = CONVERT(BIT,0),
			@dblDerivativeNoOfContract	NUMERIC(18,6)

	SELECT @intUserId = ISNULL(intLastModifiedById,intCreatedById) FROM tblCTPriceContract WITH (UPDLOCK) WHERE intPriceContractId = @intPriceContractId

	DECLARE @PFTable TABLE(
		intPriceFixationId INT,
		intPriceContractId INT,
		intContractHeaderId int,
		intContractDetailId int
	)

	INSERT INTO @PFTable (intPriceFixationId, intPriceContractId,intContractHeaderId,intContractDetailId)
	SELECT intPriceFixationId, intPriceContractId, intContractHeaderId, intContractDetailId
	FROM tblCTPriceFixation 
	WHERE intPriceContractId = @intPriceContractId

	if exists (
		select
			top 1 1
		from
			tblCTContractDetail cd
			join @PFTable pf
				on pf.intContractHeaderId = cd.intContractHeaderId
				and pf.intContractDetailId = cd.intContractDetailId
		where
			cd.intContractStatusId = 3
	)
	begin
		RAISERROR ('Cancelled sequences cannot be priced.',18,1,'WITH NOWAIT');
	end

	SELECT @intPriceFixationId = MIN(intPriceFixationId) FROM @PFTable WHERE intPriceContractId = @intPriceContractId

	SELECT	@intScreenId	=	intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.PriceContracts'
	SELECT  @intTransactionId	=	intTransactionId,@ysnOnceApproved = ysnOnceApproved FROM tblSMTransaction WHERE intRecordId = @intPriceContractId AND intScreenId = @intScreenId

	IF EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurityRequireApprovalFor WHERE intEntityUserSecurityId = @intUserId AND intScreenId = @intScreenId) AND @ysnApprove = 0
	BEGIN
		RETURN
	END

	WHILE ISNULL(@intPriceFixationId,0) > 0
	BEGIN
		SELECT	@intPriceFixationDetailId = 0
		
		SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId)	FROM	tblCTPriceFixationDetail WITH (UPDLOCK) WHERE intPriceFixationId = @intPriceFixationId
		
		WHILE	ISNULL(@intPriceFixationDetailId,0) > 0
		BEGIN
		
			SELECT	@intFutOptTransactionId = 0,@ysnHedge = 0,@ysnFreezed = 0,@dblDerivativeNoOfContract = 0

			SELECT	@intFutOptTransactionId	=	FD.intFutOptTransactionId,	
					@intBrokerId			=	FD.intBrokerId,
					@intBrokerageAccountId	=	FD.intBrokerageAccountId,
					@intFutureMarketId		=	FD.intFutureMarketId,
					@dblNoOfContract		=	FD.dblNoOfLots,
					@intHedgeFutureMonthId	=	FD.intHedgeFutureMonthId,
					@dblHedgePrice			=	FD.dblHedgePrice,
					@ysnHedge				=	FD.ysnHedge,
					@dtmFixationDate		=	FD.dtmFixationDate,

					@intContractHeaderId	=	PF.intContractHeaderId,
					--@intContractDetailId	=	PF.intContractDetailId,
					@intContractDetailId = isnull(PF.intContractDetailId,TS1.intContractDetailId), 

					@intCommodityId			=	CH.intCommodityId,					
					@intTraderId			=	CH.intSalespersonId,
					@strBuySell				=	CASE WHEN CH.intContractTypeId = 1 THEN 'Sell' ELSE 'Buy' END,	

					-- @intCurrencyId			=	TS.intCurrencyId,
					-- @intBookId				=	TS.intBookId,
					-- @intSubBookId			=	TS.intSubBookId,
					-- @intLocationId			=	TS.intCompanyLocationId,
  
				     @intCurrencyId   = (case when PF.intContractDetailId is null then TS1.intCurrencyId else TS.intCurrencyId end),
				     @intBookId    = (case when PF.intContractDetailId is null then TS1.intBookId else TS.intBookId end),
				     @intSubBookId   = (case when PF.intContractDetailId is null then TS1.intSubBookId else TS.intSubBookId end),
				     @intLocationId   = (case when PF.intContractDetailId is null then TS1.intCompanyLocationId else TS.intCompanyLocationId end),

					@ysnAA					=	FD.ysnAA,
					@dblHedgeNoOfLots		= 	FD.dblHedgeNoOfLots
						
			FROM	tblCTPriceFixationDetail	FD WITH (UPDLOCK)
			JOIN	tblCTPriceFixation			PF	WITH (UPDLOCK) ON	PF.intPriceFixationId	=	FD.intPriceFixationId
			JOIN	tblCTContractHeader			CH	WITH (UPDLOCK) ON	CH.intContractHeaderId	=	PF.intContractHeaderId 
		    left join  tblCTContractDetail   TS  WITH (UPDLOCK) on  TS.intContractDetailId  =  PF.intContractDetailId  
		    CROSS APPLY fnCTGetTopOneSequence(PF.intContractHeaderId,isnull(PF.intContractDetailId,0)) TS1 
			WHERE	FD.intPriceFixationDetailId	=	@intPriceFixationDetailId

			SELECT @ysnFreezed = ysnFreezed FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = ISNULL(@intFutOptTransactionId,0)
			
			IF @ysnHedge = 1 
			BEGIN
				-- CHECK IF THERE IS NO CHANGES WITH dblHedgeNoOfLots
				SELECT @dblDerivativeNoOfContract = ISNULL(dblNoOfContract,0) FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = @intFutOptTransactionId
				IF @dblHedgeNoOfLots = @dblDerivativeNoOfContract
				BEGIN
					SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailId
					CONTINUE
				END

				IF ISNULL(@ysnFreezed,0) = 0
				BEGIN
					SET @strXML = '<root>'
					IF ISNULL(@intFutOptTransactionId,0) > 0
						SET @strXML = @strXML +  '<intFutOptTransactionId>' + LTRIM(@intFutOptTransactionId) + '</intFutOptTransactionId>'
					SET @strXML = @strXML +  '<intFutOptTransactionHeaderId>1</intFutOptTransactionHeaderId>'
					SET @strXML = @strXML +  '<intContractHeaderId>' + LTRIM(@intContractHeaderId) + '</intContractHeaderId>'
					IF ISNULL(@intContractDetailId,0) > 0
						SET @strXML = @strXML +  '<intContractDetailId>' + LTRIM(@intContractDetailId) + '</intContractDetailId>'
					SET @strXML = @strXML +  '<dtmTransactionDate>' + LTRIM(GETDATE()) + '</dtmTransactionDate>'
					SET @strXML = @strXML +  '<intEntityId>' + LTRIM(@intBrokerId) + '</intEntityId>'
					SET @strXML = @strXML +  '<intBrokerageAccountId>' + LTRIM(@intBrokerageAccountId) + '</intBrokerageAccountId>'
					SET @strXML = @strXML +  '<intFutureMarketId>' + LTRIM(@intFutureMarketId) + '</intFutureMarketId>'
					SET @strXML = @strXML +  '<intInstrumentTypeId>1</intInstrumentTypeId>'
					SET @strXML = @strXML +  '<intCommodityId>' + LTRIM(@intCommodityId) + '</intCommodityId>'
					SET @strXML = @strXML +  '<intLocationId>' + LTRIM(@intLocationId) + '</intLocationId>'
					SET @strXML = @strXML +  '<intTraderId>' + LTRIM(@intTraderId) + '</intTraderId>'
					SET @strXML = @strXML +  '<intCurrencyId>' + LTRIM(@intCurrencyId) + '</intCurrencyId>'
					SET @strXML = @strXML +  '<intSelectedInstrumentTypeId>1</intSelectedInstrumentTypeId>'
					SET @strXML = @strXML +  '<strBuySell>' + @strBuySell + '</strBuySell>'
					SET @strXML = @strXML +  '<dblNoOfContract>' + LTRIM(@dblHedgeNoOfLots) + '</dblNoOfContract>'
					SET @strXML = @strXML +  '<intFutureMonthId>' + LTRIM(@intHedgeFutureMonthId) + '</intFutureMonthId>'
					SET @strXML = @strXML +  '<dblPrice>' + LTRIM(@dblHedgePrice) + '</dblPrice>'
					SET @strXML = @strXML +  '<strStatus>' + 'Filled' + '</strStatus>'
					SET @strXML = @strXML +  '<dtmFilledDate>' + LTRIM(@dtmFixationDate) + '</dtmFilledDate>'
					SET @strXML = @strXML +  '<ysnAA>' + LTRIM(ISNULL(@ysnAA,0)) + '</ysnAA>'
					if ISNULL(@intBookId,0) > 0
						SET @strXML = @strXML +  '<intBookId>' + LTRIM(@intBookId) + '</intBookId>'
					if ISNULL(@intSubBookId,0) > 0
						SET @strXML = @strXML +  '<intSubBookId>' + LTRIM(@intSubBookId) + '</intSubBookId>'
					SET @strXML = @strXML +  '</root>'

					EXEC uspRKAutoHedge @strXML,@intUserId,@intOutputId OUTPUT

					IF ISNULL(@intFutOptTransactionId,0) = 0
					BEGIN
						UPDATE tblCTPriceFixationDetail SET intFutOptTransactionId = @intOutputId WHERE intPriceFixationDetailId = @intPriceFixationDetailId
						-- DERIVATIVE ENTRY HISTORY						
						SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = @intOutputId
						EXEC uspRKFutOptTransactionHistory @intOutputId, @intFutOptTransactionHeaderId, 'Price Contracts', @intUserId, 'ADD', 0
						-- DERIVATIVE ENTRY AUDIT LOG: EXEC uspSMAuditLog 'RiskManagement.view.DerivativeEntry', @intFutOptTransactionHeaderId, @intUserId, 'Created', 'small-new-plus'
					END
					ELSE IF dbo.fnCTCheckIfDuplicateFutOptTransactionHistory(@intOutputId) > 1
					BEGIN
						-- DERIVATIVE ENTRY HISTORY
						SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = @intOutputId
						EXEC uspRKFutOptTransactionHistory @intOutputId, @intFutOptTransactionHeaderId, 'Price Contracts', @intUserId, 'UPDATE', 0
					END
				END
			END
			ELSE
			BEGIN
				IF ISNULL(@intFutOptTransactionId,0) > 0
				BEGIN
					-- DERIVATIVE ENTRY HISTORY
					SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = @intOutputId
					EXEC uspRKFutOptTransactionHistory @intOutputId, @intFutOptTransactionHeaderId, 'Price Contracts', @intUserId, 'DELETE'
					UPDATE tblCTPriceFixationDetail SET intFutOptTransactionId = NULL WHERE intPriceFixationDetailId = @intPriceFixationDetailId
					EXEC uspRKDeleteAutoHedge @intFutOptTransactionId, @intUserId
				END
			END 
			SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId)	FROM	tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailId
		END

		set @ysnSplit = (select ysnSplit from tblCTPriceFixation WITH (UPDLOCK) where intPriceFixationId = @intPriceFixationId);
		
		EXEC uspCTPriceFixationSave @intPriceFixationId = @intPriceFixationId
								   ,@strAction			= @strRowState
								   ,@intUserId			= @intUserId
								   ,@dtmLocalDate		= @dtmLocalDate

		if (isnull(@ysnSplit,convert(bit,0)) = convert(bit,1))
		begin
			update
				a
			set
				intPricingTypeId = (case when DetailResult.dblContractDetailQuantity = DetailResult.dblPricedQuantity then 1 else DetailResult.intContractHeaderPricingTypeId end)
				,dblFutures = (case when DetailResult.dblContractDetailQuantity = DetailResult.dblPricedQuantity then DetailResult.dblContractDetailPrice else null end)
				,dblCashPrice = (case when DetailResult.dblContractDetailQuantity = DetailResult.dblPricedQuantity then DetailResult.dblContractDetailPrice else null end) + a.dblBasis
			from
				tblCTContractDetail a
				join
				(
				select
					cd.intContractHeaderId
					,cd.intContractDetailId
					,dblContractDetailQuantity = cd.dblQuantity
					,intContractDetailPricingTypeId = cd.intPricingTypeId
					,dblContractDetailFutures = cd.dblFutures
					,dblPricedQuantity = pfd.dblQuantity
					,dblPricedFutures = pfd.dblFutures
					,dblContractDetailPricedQuantity = sum(pfd.dblQuantity)
					,dblContractDetailPrice = avg(pfd.dblFutures)
					,intContractHeaderPricingTypeId = ch.intPricingTypeId
				from
					tblCTContractDetail cd WITH (UPDLOCK)
					join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
					left join tblCTPriceFixation pf on pf.intContractDetailId = cd.intContractDetailId
					left join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
				where
					cd.intContractHeaderId = @intContractHeaderId
				group by
					cd.intContractHeaderId
					,cd.intContractDetailId
					,cd.dblQuantity
					,cd.intPricingTypeId
					,cd.dblFutures
					,pfd.dblQuantity
					,pfd.dblFutures
					,ch.intPricingTypeId
				) as DetailResult on DetailResult.intContractDetailId = a.intContractDetailId
		end

		IF ISNULL(@intContractDetailId,0) > 0 
		BEGIN
			DECLARE @ticketId INT
			SELECT TOP 1 @ticketId = intTicketId FROM tblSCTicket with (nolock) WHERE intTicketType = 6 AND intContractId = @intContractDetailId
			IF @ticketId IS NOT NULL
			BEGIN
				DECLARE @newInvoiceId INT
				EXEC uspSCCreateInvoiceForPostedDestinationWeightsAndGrades @ticketId, @intUserId, @newInvoiceId OUTPUT
			END
			ELSE
			BEGIN
				if (@ysnProcessPricing = 1)
				begin
					EXEC uspCTCreateVoucherInvoiceForPartialPricing @intContractDetailId, @intUserId, 1
				end
			END			
		END

	/*(CT-4647) - this block will re-order the pricing number upon deleting pricing layer.*/
	Update
		fd
	set
		fd.intNumber = t.intOrder	 
	from
		(
			select
				intPriceFixationDetailId
				,intOrder = convert(int,ROW_NUMBER() over (order by intPriceFixationDetailId))
			from
				tblCTPriceFixationDetail
			where
				intPriceFixationId = @intPriceFixationId
		)t
		,tblCTPriceFixationDetail fd
	where
		fd.intPriceFixationDetailId = t.intPriceFixationDetailId

		SELECT @intPriceFixationId = MIN(intPriceFixationId) FROM @PFTable WHERE intPriceContractId = @intPriceContractId	AND intPriceFixationId > @intPriceFixationId
	END
	
	EXEC [uspCTInterCompanyPriceContract] @intPriceContractId,@ysnApprove,@strRowState

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH