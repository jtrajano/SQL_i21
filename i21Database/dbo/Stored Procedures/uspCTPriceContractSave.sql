CREATE PROCEDURE [dbo].[uspCTPriceContractSave]
	
	@intPriceContractId INT,
	@strXML				NVARCHAR(MAX)
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@idoc					INT,
			@intUniqueId			INT,
			@intPriceFixationId		INT,
			@intContractHeaderId	INT,
			@intContractDetailId	INT,
			@intUserId				INT,
			@strRowState			NVARCHAR(50),
			@Condition				NVARCHAR(MAX),
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
			@intOutputId				INT


	IF @strXML = 'Delete'
	BEGIN
		SET	@strAction = @strXML
		SET @Condition = 'intPriceContractId = ' + STR(@intPriceContractId)
		EXEC [dbo].[uspCTGetTableDataInXML] 'tblCTPriceFixation', @Condition, @strXML OUTPUT,null,'intPriceFixationId,intContractHeaderId,intContractDetailId,''Delete'' AS strRowState'
	END

	EXEC sp_xml_preparedocument @idoc OUTPUT, @strXML      

	IF OBJECT_ID('tempdb..#ProcessFixation') IS NOT NULL  	
		DROP TABLE #ProcessFixation	

	SELECT  ROW_NUMBER() OVER(ORDER BY strRowState) intUniqueId,
			* 
	INTO	#ProcessFixation
	FROM OPENXML(@idoc,'tblCTPriceFixations/tblCTPriceFixation',2)          
	WITH
	(
		intPriceFixationId	INT,
		strRowState			NVARCHAR(50)
	)      

	SELECT @intUserId = ISNULL(intLastModifiedById,intCreatedById) FROM tblCTPriceContract WHERE intPriceContractId = @intPriceContractId

	SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessFixation

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intPriceFixationId		=	NULL,
				@strRowState			=	NULL,
				@intPriceFixationDetailId = NULL

		SELECT	@intPriceFixationId		=	intPriceFixationId,
				@strRowState			=	strRowState
		FROM	#ProcessFixation 
		WHERE	intUniqueId				=	 @intUniqueId
		
		SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId)	FROM	tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId
		
		WHILE	ISNULL(@intPriceFixationDetailId,0) > 0 AND @strAction <> 'Delete'
		BEGIN
		
			SELECT	@intFutOptTransactionId	=	FD.intFutOptTransactionId,	
					@intBrokerId			=	FD.intBrokerId,
					@intBrokerageAccountId	=	FD.intBrokerageAccountId,
					@intFutureMarketId		=	FD.intFutureMarketId,
					@intNoOfContract		=	FD.dblNoOfLots,
					@intHedgeFutureMonthId	=	FD.intHedgeFutureMonthId,
					@dblHedgePrice			=	FD.dblHedgePrice,
					@ysnHedge				=	FD.ysnHedge,

					@intContractHeaderId	=	PF.intContractHeaderId,
					@intContractDetailId	=	PF.intContractDetailId,

					@intCommodityId			=	CH.intCommodityId,					
					@intTraderId			=	CH.intSalespersonId,
					@strBuySell				=	CASE WHEN CH.intContractTypeId = 1 THEN 'Sell' ELSE 'Buy' END,	

					@intCurrencyId			=	TS.intCurrencyId,
					@intBookId				=	TS.intBookId,
					@intSubBookId			=	TS.intSubBookId,
					@intLocationId			=	TS.intCompanyLocationId
						
			FROM	tblCTPriceFixationDetail	FD
			JOIN	tblCTPriceFixation			PF	ON	PF.intPriceFixationId	=	FD.intPriceFixationId
			JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId	=	PF.intContractHeaderId
			CROSS	
			APPLY	fnCTGetTopOneSequence(PF.intContractHeaderId,PF.intContractDetailId) TS
			WHERE	FD.intPriceFixationDetailId	=	@intPriceFixationDetailId

			IF @ysnHedge = 1 AND @strRowState <> 'Delete' AND @strXML <> 'Delete'
			BEGIN
				SET @strXML = '<root>'
				IF ISNULL(@intFutOptTransactionId,0) > 0
					SET @strXML = @strXML +  '<intFutOptTransactionId>' + STR(@intFutOptTransactionId) + '</intFutOptTransactionId>'
				SET @strXML = @strXML +  '<intFutOptTransactionHeaderId>1</intFutOptTransactionHeaderId>'
				SET @strXML = @strXML +  '<intContractHeaderId>' + STR(@intContractHeaderId) + '</intContractHeaderId>'
				IF ISNULL(@intContractDetailId,0) > 0
					SET @strXML = @strXML +  '<intContractDetailId>' + STR(@intContractDetailId) + '</intContractDetailId>'
				SET @strXML = @strXML +  '<dtmTransactionDate>' + LTRIM(GETDATE()) + '</dtmTransactionDate>'
				SET @strXML = @strXML +  '<intEntityId>' + STR(@intBrokerId) + '</intEntityId>'
				SET @strXML = @strXML +  '<intBrokerageAccountId>' + STR(@intBrokerageAccountId) + '</intBrokerageAccountId>'
				SET @strXML = @strXML +  '<intFutureMarketId>' + STR(@intFutureMarketId) + '</intFutureMarketId>'
				SET @strXML = @strXML +  '<intInstrumentTypeId>1</intInstrumentTypeId>'
				SET @strXML = @strXML +  '<intCommodityId>' + STR(@intCommodityId) + '</intCommodityId>'
				SET @strXML = @strXML +  '<intLocationId>' + STR(@intLocationId) + '</intLocationId>'
				SET @strXML = @strXML +  '<intTraderId>' + STR(@intTraderId) + '</intTraderId>'
				SET @strXML = @strXML +  '<intCurrencyId>' + STR(@intCurrencyId) + '</intCurrencyId>'
				SET @strXML = @strXML +  '<intSelectedInstrumentTypeId>1</intSelectedInstrumentTypeId>'
				SET @strXML = @strXML +  '<strBuySell>' + @strBuySell + '</strBuySell>'
				SET @strXML = @strXML +  '<intNoOfContract>' + STR(@intNoOfContract) + '</intNoOfContract>'
				SET @strXML = @strXML +  '<intFutureMonthId>' + STR(@intHedgeFutureMonthId) + '</intFutureMonthId>'
				SET @strXML = @strXML +  '<dblPrice>' + STR(@dblHedgePrice) + '</dblPrice>'
				SET @strXML = @strXML +  '<strStatus>' + 'Filled' + '</strStatus>'
				SET @strXML = @strXML +  '<dtmFilledDate>' + LTRIM(GETDATE()) + '</dtmFilledDate>'
				if ISNULL(@intBookId,0) > 0
					SET @strXML = @strXML +  '<intBookId>' + STR(@intBookId) + '</intBookId>'
				if ISNULL(@intSubBookId,0) > 0
					SET @strXML = @strXML +  '<intSubBookId>' + STR(@intSubBookId) + '</intSubBookId>'
				SET @strXML = @strXML +  '</root>'

				EXEC uspRKAutoHedge @strXML,@intOutputId OUTPUT

				IF ISNULL(@intFutOptTransactionId,0) = 0
					UPDATE tblCTPriceFixationDetail SET intFutOptTransactionId = @intOutputId WHERE intPriceFixationDetailId = @intPriceFixationDetailId
			END
			
			IF @strRowState = 'Delete' AND ISNULL(@intFutOptTransactionId,0) > 0
			BEGIN
				EXEC uspRKDeleteAutoHedge @intFutOptTransactionId
			END
			 
			SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId)	FROM	tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailId
		END
		
		EXEC uspCTPriceFixationSave @intPriceFixationId,@strRowState,@intUserId

		SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessFixation WHERE intUniqueId > @intUniqueId
	END
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH