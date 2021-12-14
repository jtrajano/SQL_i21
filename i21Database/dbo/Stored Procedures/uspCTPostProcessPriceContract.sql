CREATE PROCEDURE [dbo].[uspCTPostProcessPriceContract]
	
	@intPriceContractId INT
	,@intUserId INT
	,@dtmLocalDate		DATETIME = NULL

AS

BEGIN

	DECLARE @ErrMsg nvarchar(max);

	BEGIN TRY
		Declare
			@intScreenId int
			,@intTransactionId int
			,@ysnOnceApproved bit
			,@intPriceFixationId int
			,@intPriceFixationDetailId int
			,@intFutOptTransactionId	int
			,@intBrokerId int
			,@intBrokerageAccountId int
			,@intFutureMarketId int
			,@dblNoOfContract numeric(18,6)
			,@intHedgeFutureMonthId int
			,@dblHedgePrice numeric(18,6)
			,@ysnHedge bit
			,@dtmFixationDate datetime
			,@intContractHeaderId int
			,@intContractDetailId int
			,@intCommodityId int
			,@intTraderId int
			,@strBuySell nvarchar(50)
			,@intCurrencyId int
			,@intBookId int
			,@intSubBookId int
			,@intLocationId int
			,@ysnAA bit
			,@dblHedgeNoOfLots numeric(18,6)
			,@ysnFreezed bit
			,@dblDerivativeNoOfContract numeric(18,6)
			,@strXML nvarchar(max)
			,@intOutputId int
			,@intFutOptTransactionHeaderId int
			,@ysnSplit bit
			;

		DECLARE @PFTable TABLE(
			intPriceFixationId INT,
			intPriceContractId INT
		)

		SELECT
			@intScreenId = intScreenId
		FROM
			tblSMScreen
		WHERE
			strNamespace = 'ContractManagement.view.PriceContracts'

		SELECT
			@intTransactionId	=	intTransactionId
			,@ysnOnceApproved = ysnOnceApproved
		FROM
			tblSMTransaction
		WHERE
			intRecordId = @intPriceContractId
			AND intScreenId = @intScreenId

		IF EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurityRequireApprovalFor WHERE intEntityUserSecurityId = @intUserId AND intScreenId = @intScreenId)
		BEGIN
			RETURN
		END

		if exists (select top 1 1 from tblCTPriceFixation pf join tblCTContractHeader ch on ch.intContractHeaderId = pf.intContractHeaderId where pf.intPriceContractId = @intPriceContractId and isnull(ch.ysnMultiplePriceFixation,0) = 1)
		begin

			exec uspCTProcessPriceFixationMultiplePrice
				@intPriceContractId = @intPriceContractId
				,@intUserId = @intUserId
		end

		INSERT INTO @PFTable (
			intPriceFixationId
			,intPriceContractId
		)
		SELECT
			intPriceFixationId
			,intPriceContractId 
		FROM
			tblCTPriceFixation 
		WHERE
			intPriceContractId = @intPriceContractId
	
		 --> Start Price Fixation loop
		SELECT @intPriceFixationId = MIN(intPriceFixationId) FROM @PFTable WHERE intPriceContractId = @intPriceContractId

		WHILE ISNULL(@intPriceFixationId,0) > 0
		BEGIN


			 --> Start Price Fixation Detail loop
			SELECT	@intPriceFixationDetailId = 0		
			SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId)	FROM	tblCTPriceFixationDetail WITH (UPDLOCK) WHERE intPriceFixationId = @intPriceFixationId

			WHILE	ISNULL(@intPriceFixationDetailId,0) > 0
			BEGIN

				SELECT
					@intFutOptTransactionId = 0
					,@ysnHedge = 0
					,@ysnFreezed = 0
					,@dblDerivativeNoOfContract = 0;

				SELECT
					@intFutOptTransactionId	=	FD.intFutOptTransactionId,	
					@intBrokerId			=	FD.intBrokerId,
					@intBrokerageAccountId	=	FD.intBrokerageAccountId,
					@intFutureMarketId		=	FD.intFutureMarketId,
					@dblNoOfContract		=	FD.dblNoOfLots,
					@intHedgeFutureMonthId	=	FD.intHedgeFutureMonthId,
					@dblHedgePrice			=	FD.dblHedgePrice,
					@ysnHedge				=	FD.ysnHedge,
					@dtmFixationDate		=	FD.dtmFixationDate,
					@intContractHeaderId	=	PF.intContractHeaderId,
					@intContractDetailId	= isnull(PF.intContractDetailId,TS1.intContractDetailId), 
					@intCommodityId			=	CH.intCommodityId,					
					@intTraderId			=	CH.intSalespersonId,
					@strBuySell				=	CASE WHEN CH.intContractTypeId = 1 THEN 'Sell' ELSE 'Buy' END,
					@intCurrencyId			= (case when PF.intContractDetailId is null then TS1.intCurrencyId else TS.intCurrencyId end),
					@intBookId				= (case when PF.intContractDetailId is null then TS1.intBookId else TS.intBookId end),
					@intSubBookId			= (case when PF.intContractDetailId is null then TS1.intSubBookId else TS.intSubBookId end),
					@intLocationId			= (case when PF.intContractDetailId is null then TS1.intCompanyLocationId else TS.intCompanyLocationId end),
					@ysnAA					=	FD.ysnAA,
					@dblHedgeNoOfLots		= 	FD.dblHedgeNoOfLots
				FROM
					tblCTPriceFixationDetail FD WITH (UPDLOCK)
					JOIN tblCTPriceFixation PF WITH (UPDLOCK) ON PF.intPriceFixationId = FD.intPriceFixationId
					JOIN tblCTContractHeader CH WITH (UPDLOCK) ON CH.intContractHeaderId = PF.intContractHeaderId 
					left join tblCTContractDetail TS WITH (UPDLOCK) on TS.intContractDetailId = PF.intContractDetailId  
					CROSS APPLY fnCTGetTopOneSequence(PF.intContractHeaderId,isnull(PF.intContractDetailId,0)) TS1 
				WHERE
					FD.intPriceFixationDetailId = @intPriceFixationDetailId

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
						BEGIN
							SET @strXML = @strXML +  '<intFutOptTransactionId>' + LTRIM(@intFutOptTransactionId) + '</intFutOptTransactionId>'
						END

						SET @strXML = @strXML +  '<intFutOptTransactionHeaderId>1</intFutOptTransactionHeaderId>'
						SET @strXML = @strXML +  '<intContractHeaderId>' + LTRIM(@intContractHeaderId) + '</intContractHeaderId>'

						IF ISNULL(@intContractDetailId,0) > 0
						BEGIN
							SET @strXML = @strXML +  '<intContractDetailId>' + LTRIM(@intContractDetailId) + '</intContractDetailId>'
						END

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
						BEGIN
							SET @strXML = @strXML +  '<intBookId>' + LTRIM(@intBookId) + '</intBookId>'
						END

						if ISNULL(@intSubBookId,0) > 0
						BEGIN
							SET @strXML = @strXML +  '<intSubBookId>' + LTRIM(@intSubBookId) + '</intSubBookId>'
						END

						SET @strXML = @strXML +  '</root>'


						EXEC uspRKAutoHedge @strXML,@intUserId,@intOutputId OUTPUT

						IF ISNULL(@intFutOptTransactionId,0) = 0
						BEGIN
							UPDATE tblCTPriceFixationDetail SET intFutOptTransactionId = @intOutputId WHERE intPriceFixationDetailId = @intPriceFixationDetailId
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
			
				--LOOP - Fetch next Fixation Detail
				SELECT @intPriceFixationDetailId = MIN(intPriceFixationDetailId)
				FROM tblCTPriceFixationDetail
				WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailId

			END --> End Price Fixation Detail loop

			EXEC uspCTPriceFixationSave
				@intPriceFixationId = @intPriceFixationId
				,@strAction			= null
				,@intUserId			= @intUserId
				,@dtmLocalDate		= @dtmLocalDate

			set @ysnSplit = (select ysnSplit from tblCTPriceFixation WITH (UPDLOCK) where intPriceFixationId = @intPriceFixationId);

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
					EXEC uspCTCreateVoucherInvoiceForPartialPricing @intContractDetailId, @intUserId, 1
				END			
			END

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

			--LOOP - Fetch next Fixation
			SELECT @intPriceFixationId = MIN(intPriceFixationId) FROM @PFTable WHERE intPriceContractId = @intPriceContractId	AND intPriceFixationId > @intPriceFixationId

		END --> End Price Fixation loop

		EXEC [uspCTInterCompanyPriceContract]
			@intPriceContractId = @intPriceContractId
			,@ysnApprove = 0
			,@strRowState = null;

		--------------------------------------------
		-- Call all pre process after validations --
		--------------------------------------------

		-- uspCTSavePriceContract
			-- include the ones that were previously on pre process routines but should be on post process instead
				-- uspCTSequencePriceChanged
				-- split routines
				-- ammendment and approval routines
			-- evaluate uspCTPriceFixationSave contents. we may not need some of the contents in here for price fixation
			-- create modular scripts each for invoice pricing and another for voucher pricing.


		
		-------------------------
		-- End all pre process --
		-------------------------

		-- Insert code to reorder intNumber on pricing layer (in cases of deletion of layers)

		-- EXEC [uspCTInterCompanyPriceContract] @intPriceContractId, @ysnApprove,@strRowState
	END TRY
	BEGIN CATCH
		SET @ErrMsg = ERROR_MESSAGE()  
		RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
	END CATCH
	
END;