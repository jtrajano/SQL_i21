CREATE PROCEDURE [dbo].[uspCTSavePriceContract]
	
	@intPriceContractId INT,
	@strXML				NVARCHAR(MAX)
	
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
			@intNoOfContract			INT,
			@intHedgeFutureMonthId		INT,
			@dblHedgePrice				NUMERIC(18,6),
			@intBookId					INT,
			@intSubBookId				INT,
			@ysnHedge					BIT,
			@strAction					NVARCHAR(50) = '',
			@intOutputId				INT,
			@dtmFixationDate			DATETIME,
			@ysnFreezed					BIT,
			@ysnAA						BIT

	SELECT @intUserId = ISNULL(intLastModifiedById,intCreatedById) FROM tblCTPriceContract WHERE intPriceContractId = @intPriceContractId

	SELECT @intPriceFixationId = MIN(intPriceFixationId) FROM tblCTPriceFixation WHERE intPriceContractId = @intPriceContractId	

	WHILE ISNULL(@intPriceFixationId,0) > 0
	BEGIN
		SELECT	@intPriceFixationDetailId = 0
		
		SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId)	FROM	tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId
		
		WHILE	ISNULL(@intPriceFixationDetailId,0) > 0
		BEGIN
		
			SELECT	@intFutOptTransactionId = 0,@ysnHedge = 0,@ysnFreezed = 0

			SELECT	@intFutOptTransactionId	=	FD.intFutOptTransactionId,	
					@intBrokerId			=	FD.intBrokerId,
					@intBrokerageAccountId	=	FD.intBrokerageAccountId,
					@intFutureMarketId		=	FD.intFutureMarketId,
					@intNoOfContract		=	FD.dblNoOfLots,
					@intHedgeFutureMonthId	=	FD.intHedgeFutureMonthId,
					@dblHedgePrice			=	FD.dblHedgePrice,
					@ysnHedge				=	FD.ysnHedge,
					@dtmFixationDate		=	FD.dtmFixationDate,

					@intContractHeaderId	=	PF.intContractHeaderId,
					@intContractDetailId	=	PF.intContractDetailId,

					@intCommodityId			=	CH.intCommodityId,					
					@intTraderId			=	CH.intSalespersonId,
					@strBuySell				=	CASE WHEN CH.intContractTypeId = 1 THEN 'Sell' ELSE 'Buy' END,	

					@intCurrencyId			=	TS.intCurrencyId,
					@intBookId				=	TS.intBookId,
					@intSubBookId			=	TS.intSubBookId,
					@intLocationId			=	TS.intCompanyLocationId,
					@ysnAA					=	FD.ysnAA
						
			FROM	tblCTPriceFixationDetail	FD
			JOIN	tblCTPriceFixation			PF	ON	PF.intPriceFixationId	=	FD.intPriceFixationId
			JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId	=	PF.intContractHeaderId
			CROSS	
			APPLY	fnCTGetTopOneSequence(PF.intContractHeaderId,PF.intContractDetailId) TS
			WHERE	FD.intPriceFixationDetailId	=	@intPriceFixationDetailId

			SELECT @ysnFreezed = ysnFreezed FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = ISNULL(@intFutOptTransactionId,0)
			
			IF @ysnHedge = 1 
			BEGIN
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
					SET @strXML = @strXML +  '<intNoOfContract>' + LTRIM(@intNoOfContract) + '</intNoOfContract>'
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

					EXEC uspRKAutoHedge @strXML,@intOutputId OUTPUT

					IF ISNULL(@intFutOptTransactionId,0) = 0
						UPDATE tblCTPriceFixationDetail SET intFutOptTransactionId = @intOutputId WHERE intPriceFixationDetailId = @intPriceFixationDetailId
				END
			END
			ELSE
			BEGIN
				IF ISNULL(@intFutOptTransactionId,0) > 0
				BEGIN
					UPDATE tblCTPriceFixationDetail SET intFutOptTransactionId = NULL WHERE intPriceFixationDetailId = @intPriceFixationDetailId
					EXEC uspRKDeleteAutoHedge @intFutOptTransactionId
				END
			END 
			SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId)	FROM	tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailId
		END
		
		EXEC uspCTPriceFixationSave @intPriceFixationId,@strRowState,@intUserId

		IF ISNULL(@intContractDetailId,0) > 0 
		BEGIN
			EXEC uspCTCreateVoucherInvoiceForPartialPricing @intContractDetailId, @intUserId
		END

		SELECT @intPriceFixationId = MIN(intPriceFixationId) FROM tblCTPriceFixation WHERE intPriceContractId = @intPriceContractId	AND intPriceFixationId > @intPriceFixationId
	END
	
	EXEC [uspCTInterCompanyPriceContract] @intPriceContractId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
