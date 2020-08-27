CREATE PROCEDURE [dbo].[uspCTManageDerivatives]
	@id INT,
	@type NVARCHAR(10) = '',
	@remove BIT = 0
AS

BEGIN TRY
	
	DECLARE	@ErrMsg						NVARCHAR(MAX),
			@strXML						NVARCHAR(MAX),
			@intContractFuturesId		INT,
			@intUserId					INT,
			@strRowState				NVARCHAR(50),
			@Condition					NVARCHAR(MAX),
			@intContractHeaderId		INT,
			@intContractDetailId		INT,
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
			@ysnOnceApproved			INT = 0

	--IF EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurityRequireApprovalFor WHERE intEntityUserSecurityId = @intUserId AND intScreenId = @intScreenId) AND @ysnApprove = 0
	--BEGIN
	--	RETURN
	--END

	IF EXISTS(SELECT TOP 1 1 FROM tblCTContractDetail WHERE intPricingTypeId <> 1 AND intContractDetailId = @id AND @remove = 0)
	BEGIN
		RETURN
	END

	IF @remove = 0
	BEGIN
		SELECT @intContractFuturesId	= MIN(intContractFuturesId) FROM tblCTContractFutures WHERE intContractDetailId = @id
	
		WHILE ISNULL(@intContractFuturesId,0) > 0
		BEGIN
			SELECT	@intFutOptTransactionId = 0,@ysnHedge = 0,@ysnFreezed = 0

			SELECT	@intFutOptTransactionId	=	CF.intFutOptTransactionId,	
					@intBrokerId			=	CF.intBrokerId,
					@intBrokerageAccountId	=	CF.intBrokerageAccountId,
					@intFutureMarketId		=	CD.intFutureMarketId,
					@dblNoOfContract		=	CF.dblNoOfLots,
					@intHedgeFutureMonthId	=	CF.intHedgeFutureMonthId,
					@dblHedgePrice			=	CF.dblHedgePrice,
					@ysnHedge				=	1,
					@dtmFixationDate		=	GETDATE(),-- Transaction Date

					@intContractHeaderId	=	CD.intContractHeaderId,
					--@intContractDetailId	=	CD.intContractDetailId,

					@intCommodityId			=	CH.intCommodityId,					
					@intTraderId			=	CH.intSalespersonId,
					@strBuySell				=	CASE WHEN CH.intContractTypeId = 1 THEN 'Sell' ELSE 'Buy' END,	

					@intCurrencyId			=	TS.intCurrencyId,
					@intBookId				=	TS.intBookId,
					@intSubBookId			=	TS.intSubBookId,
					@intLocationId			=	TS.intCompanyLocationId,
					@ysnAA					=	CF.ysnAA,
					@dblHedgeNoOfLots		= 	CF.dblHedgeNoOfLots,
					@intUserId				=	CD.intCreatedById
						
			FROM	tblCTContractFutures		CF
			INNER 
			JOIN	tblCTContractDetail			CD		ON		CD.intContractDetailId = CF.intContractDetailId
			INNER 
			JOIN	tblCTContractHeader			CH		ON		CH.intContractHeaderId = CD.intContractHeaderId
			CROSS	
			APPLY	fnCTGetTopOneSequence(CD.intContractHeaderId,CD.intContractDetailId) TS
			WHERE	CF.intContractFuturesId	=	@intContractFuturesId

			SELECT @ysnFreezed = ysnFreezed FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = ISNULL(@intFutOptTransactionId,0)

			IF ISNULL(@ysnFreezed,0) = 0
			BEGIN
				SET @strXML = '<root>'
				IF ISNULL(@intFutOptTransactionId,0) > 0
					SET @strXML = @strXML +  '<intFutOptTransactionId>' + LTRIM(@intFutOptTransactionId) + '</intFutOptTransactionId>'
				SET @strXML = @strXML +  '<intFutOptTransactionHeaderId>1</intFutOptTransactionHeaderId>'
				SET @strXML = @strXML +  '<intContractHeaderId>' + LTRIM(@intContractHeaderId) + '</intContractHeaderId>'
				IF ISNULL(@id,0) > 0
					SET @strXML = @strXML +  '<intContractDetailId>' + LTRIM(@id) + '</intContractDetailId>'
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
					UPDATE tblCTContractFutures SET intFutOptTransactionId = @intOutputId WHERE intContractFuturesId = @intContractFuturesId
					-- DERIVATIVE ENTRY HISTORY						
					SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = @intOutputId
					EXEC uspRKFutOptTransactionHistory @intOutputId, @intFutOptTransactionHeaderId, 'Priced Contract', @intUserId, 'ADD', 0
					-- DERIVATIVE ENTRY AUDIT LOG: EXEC uspSMAuditLog 'RiskManagement.view.DerivativeEntry', @intFutOptTransactionHeaderId, @intUserId, 'Created', 'small-new-plus'
				END
				ELSE IF dbo.fnCTCheckIfDuplicateFutOptTransactionHistory(@intOutputId) > 1
				BEGIN
					-- DERIVATIVE ENTRY HISTORY
					SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = @intOutputId
					EXEC uspRKFutOptTransactionHistory @intOutputId, @intFutOptTransactionHeaderId, 'Priced Contract', @intUserId, 'UPDATE', 0
				END
			END

			SELECT @intContractFuturesId = MIN(intContractFuturesId) FROM tblCTContractFutures WHERE intContractDetailId = @id AND intContractFuturesId > @intContractFuturesId
		END
	END
	ELSE -- DELETE DERIVATIVE ENTRY AND HISTORY
	BEGIN
		IF @type = 'header'
		BEGIN
			SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @id
			WHILE ISNULL(@intContractDetailId,0) > 0
			BEGIN
				SELECT @intFutOptTransactionId = MIN(intFutOptTransactionId) FROM tblCTContractFutures WHERE intContractDetailId = @intContractDetailId
				WHILE ISNULL(@intFutOptTransactionId,0) > 0
				BEGIN
					SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = @intFutOptTransactionId
					EXEC uspRKFutOptTransactionHistory @intOutputId, @intFutOptTransactionHeaderId, 'Priced Contract', @intUserId, 'DELETE'
					EXEC uspRKDeleteAutoHedge @id, @intUserId
				
					SELECT @intFutOptTransactionId = MIN(intFutOptTransactionId) FROM tblCTContractFutures WHERE intContractDetailId = @intContractDetailId AND intFutOptTransactionId > @intFutOptTransactionId
				END
				SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @id AND intContractDetailId > @intContractDetailId
			END
		END
		ELSE IF @type = 'detail'
		BEGIN
			SELECT @intFutOptTransactionId = MIN(intFutOptTransactionId) FROM tblCTContractFutures WHERE intContractDetailId = @id
			WHILE ISNULL(@intFutOptTransactionId,0) > 0
			BEGIN
				SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = @intFutOptTransactionId
				EXEC uspRKFutOptTransactionHistory @intOutputId, @intFutOptTransactionHeaderId, 'Priced Contract', @intUserId, 'DELETE'
				EXEC uspRKDeleteAutoHedge @intFutOptTransactionId, @intUserId
				
				SELECT @intFutOptTransactionId = MIN(intFutOptTransactionId) FROM tblCTContractFutures WHERE intContractDetailId = @id AND intFutOptTransactionId > @intFutOptTransactionId
			END
		END
		ELSE IF @type = 'futures'
		BEGIN
			SELECT @intFutOptTransactionId = MIN(intFutOptTransactionId) FROM tblCTContractFutures WHERE intContractFuturesId = @id
			SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = @intFutOptTransactionId
			EXEC uspRKFutOptTransactionHistory @intOutputId, @intFutOptTransactionHeaderId, 'Priced Contract', @intUserId, 'DELETE'
			EXEC uspRKDeleteAutoHedge @intFutOptTransactionId, @intUserId
		END
	END
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO