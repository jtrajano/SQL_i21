CREATE PROCEDURE [dbo].[uspCTCreateDerivative]

	@intContractHeaderId INT
	
AS

BEGIN TRY	
	BEGIN TRAN
	DECLARE	 @ErrMsg					NVARCHAR(MAX)
			,@strXML					NVARCHAR(MAX)
			,@intContractDetailId		INT
			,@intFutOptTransactionId	INT
			,@intBrokerId				INT
			,@intBrokerageAccountId		INT
			,@intFutureMarketId			INT
			,@intCommodityId			INT
			,@intLocationId				INT
			,@intTraderId				INT
			,@intCurrencyId				INT
			,@strBuySell				NVARCHAR(50)
			,@dblNoOfContract			NUMERIC(18,6)
			,@intHedgeFutureMonthId		INT
			,@dblHedgePrice				NUMERIC(18,6)
			,@intBookId					INT
			,@intSubBookId				INT
			,@ysnHedge					BIT
			,@strAction					NVARCHAR(50) = ''
			,@intOutputId				INT
			,@dtmFixationDate			DATETIME
			,@ysnFreezed				BIT
			,@ysnAA						BIT
			,@intUserId					INT
				

	SELECT	 @intBrokerId				=	CH.intBrokerId
			,@intBrokerageAccountId		=	CH.intBrokerageAccountId
			,@intFutureMarketId			=	CH.intFutureMarketId
			,@intCommodityId			=	CH.intCommodityId
			,@intLocationId				=	TS.intCompanyLocationId
			,@intTraderId				=	CH.intSalespersonId
			,@intCurrencyId				=	TS.intCurrencyId
			,@strBuySell				=	CASE WHEN CH.intContractTypeId = 1 THEN 'Sell' ELSE 'Buy' END
			,@dblNoOfContract			=	CH.dblNoOfLots
			,@intHedgeFutureMonthId		=	CH.intFutureMonthId
			,@dblHedgePrice				=	CH.dblFutures
			,@intBookId					=	CH.intBookId
			,@intSubBookId				=	CH.intSubBookId
			,@dtmFixationDate			=	GETDATE()
			,@ysnAA						=	0
			,@intUserId					=	CH.intCreatedById

	FROM	tblCTContractHeader	CH
	CROSS	APPLY	dbo.fnCTGetTopOneSequence(CH.intContractHeaderId,NULL) TS
	WHERE	intContractHeaderId			=	@intContractHeaderId

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
	SET @strXML = @strXML +  '<dblNoOfContract>' + LTRIM(@dblNoOfContract) + '</dblNoOfContract>'
	SET @strXML = @strXML +  '<intFutureMonthId>' + LTRIM(@intHedgeFutureMonthId) + '</intFutureMonthId>'
	SET @strXML = @strXML +  '<dblPrice>' + LTRIM(@dblHedgePrice) + '</dblPrice>'
	SET @strXML = @strXML +  '<strStatus>' + 'Filled' + '</strStatus>'
	SET @strXML = @strXML +  '<dtmFilledDate>' + LTRIM(@dtmFixationDate) + '</dtmFilledDate>'
	SET @strXML = @strXML +  '<ysnAA>' + LTRIM(ISNULL(@ysnAA,0)) + '</ysnAA>'
	IF ISNULL(@intBookId,0) > 0
		SET @strXML = @strXML +  '<intBookId>' + LTRIM(@intBookId) + '</intBookId>'
	IF ISNULL(@intSubBookId,0) > 0
		SET @strXML = @strXML +  '<intSubBookId>' + LTRIM(@intSubBookId) + '</intSubBookId>'
	SET @strXML = @strXML +  '</root>'

	EXEC uspRKAutoHedge @strXML,@intUserId,@intOutputId OUTPUT
	
	COMMIT TRAN
END TRY

BEGIN CATCH
	ROLLBACK TRAN
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
END CATCH
