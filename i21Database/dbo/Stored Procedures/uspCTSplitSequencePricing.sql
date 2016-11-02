CREATE PROCEDURE [dbo].[uspCTSplitSequencePricing]
	
	@intContractDetailId	INT,
	@intUserId				INT

AS

BEGIN TRY			
		DECLARE @intPriceFixationId			INT,
				@intPriceFixationDetailId	INT,
				@intChildContractDetailId	INT,
				@intNewPriceFixationId		INT,
				@intNewPFDetailId			INT,
				@intFutOptTransactionId		INT,
				@intNewFutOptTransactionId	INT,
				@intSummaryId				INT,
				@intNewSummaryId			INT,
				@ysnHedge					BIT,
				@dblNoOfLots				NUMERIC(18,6),
				@dblChildSeqLots			NUMERIC(18,6),
				@dblChildSeqQty				NUMERIC(18,6),
				@XML						NVARCHAR(MAX),
				@ErrMsg						NVARCHAR(MAX),
				@strTradeNo					NVARCHAR(100),
				@strContractSeq				NVARCHAR(100),
				@strDateWithTime			NVARCHAR(100) = CONVERT(NVARCHAR(100),GETDATE(),126),
				@strDate					NVARCHAR(100) = CONVERT(NVARCHAR(100),DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())),126)
				

		SELECT	@dblNoOfLots		=	dblNoOfLots,
				@strContractSeq		=	STR(intContractSeq)
		FROM	tblCTContractDetail
		WHERE	intContractDetailId	=	@intContractDetailId

		SELECT	@intPriceFixationId =	intPriceFixationId 
		FROM	tblCTPriceFixation 
		WHERE	intContractDetailId =	@intContractDetailId

		IF	ISNULL(@intPriceFixationId,0) = 0
			RETURN

		IF (SELECT COUNT(*) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId) > 1
		BEGIN
			RAISERROR(110005,16,1,@strContractSeq,@strContractSeq)
		END

		IF EXISTS(SELECT * FROM tblCTPriceFixation WHERE intPriceFixationId = @intPriceFixationId AND dblTotalLots <> dblLotsFixed)
		BEGIN
			RAISERROR(110006,16,1,@strContractSeq,@strContractSeq)
		END

		SELECT	@intPriceFixationDetailId	=	intPriceFixationDetailId,
				@ysnHedge					=	ysnHedge,
				@intFutOptTransactionId		=	intFutOptTransactionId
		FROM	tblCTPriceFixationDetail
		WHERE	intPriceFixationId = @intPriceFixationId

		UPDATE	PF
		SET		PF.dblTotalLots			=	CD.dblNoOfLots,
				PF.dblLotsFixed			=	CD.dblNoOfLots,
				PF.intLotsHedged		=	CASE WHEN FD.ysnHedge = 1 THEN CD.dblNoOfLots ELSE NULL END
		FROM	tblCTPriceFixation			PF 
		JOIN	tblCTPriceFixationDetail	FD	ON	FD.intPriceFixationId	=	PF.intPriceFixationId
		JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId	=	PF.intContractDetailId
		WHERE	PF.intPriceFixationId	=	@intPriceFixationId

		UPDATE	FD
		SET		FD.dblNoOfLots			=	CD.dblNoOfLots
		FROM	tblCTPriceFixation			PF 
		JOIN	tblCTPriceFixationDetail	FD	ON	FD.intPriceFixationId	=	PF.intPriceFixationId
		JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId	=	PF.intContractDetailId
		WHERE	FD.intPriceFixationDetailId	=	@intPriceFixationDetailId

		UPDATE  tblRKAssignFuturesToContractSummary
		SET		intHedgedLots			=	@dblNoOfLots
		WHERE	intContractDetailId		=	@intContractDetailId
		
		UPDATE	tblRKFutOptTransaction 
		SET		intNoOfContract			=	@dblNoOfLots
		WHERE	intFutOptTransactionId	=	@intFutOptTransactionId

		SELECT	@intChildContractDetailId = MIN(intContractDetailId) 
		FROM	tblCTContractDetail 
		WHERE	intSplitFromId			=	@intContractDetailId
		AND		intContractDetailId	 NOT IN (SELECT ISNULL(intContractDetailId,0) FROM tblCTPriceFixation)
		
		WHILE	ISNULL(@intChildContractDetailId,0) > 0
		BEGIN
				SELECT	@dblChildSeqLots	=	dblNoOfLots,
						@dblChildSeqQty		=	dblQuantity
				FROM	tblCTContractDetail
				WHERE	intContractDetailId	=	@intChildContractDetailId

				SET @XML =	'<root><toUpdate><dblTotalLots>'+STR(@dblChildSeqLots)+'</dblTotalLots><dblLotsFixed>'+STR(@dblChildSeqLots)+'</dblLotsFixed>'+
							CASE WHEN @ysnHedge = 1 THEN '<intLotsHedged>'+STR(@dblChildSeqLots)+'</intLotsHedged>' ELSE '' END +
							'<intContractDetailId>'+STR(@intChildContractDetailId)+'</intContractDetailId></toUpdate></root>' 

				EXEC uspCTCreateADuplicateRecord 'tblCTPriceFixation',@intPriceFixationId, @intNewPriceFixationId OUTPUT,@XML
				
				IF @ysnHedge = 1
				BEGIN
					SELECT	@intSummaryId = intAssignFuturesToContractSummaryId
					FROM	tblRKAssignFuturesToContractSummary
					WHERE	@intFutOptTransactionId = intFutOptTransactionId
					AND		intContractDetailId	= @intContractDetailId	
					
					EXEC	@strTradeNo	=	uspCTGetStartingNumber 'FutOpt Transaction'
					SET		@strTradeNo	=	LTRIM(RTRIM(@strTradeNo)) + '-H'
					SET		@XML =	'<root><toUpdate><intNoOfContract>'+STR(@dblChildSeqLots)+'</intNoOfContract>'+
									'<dtmTransactionDate>'+@strDate+'</dtmTransactionDate>'+
									'<dtmFilledDate>'+@strDate+'</dtmFilledDate>'+
									'<strInternalTradeNo>'+@strTradeNo+'</strInternalTradeNo></toUpdate></root>' 

					EXEC uspCTCreateADuplicateRecord 'tblRKFutOptTransaction',@intFutOptTransactionId, @intNewFutOptTransactionId OUTPUT,@XML

					SET @XML =	'<root><toUpdate><intHedgedLots>'+STR(@dblChildSeqLots)+'</intHedgedLots>'+
								'<intFutOptTransactionId>'+STR(@intNewFutOptTransactionId)+'</intFutOptTransactionId>'+
								'<dtmMatchDate>'+@strDate+'</dtmMatchDate>'+
								'<intContractDetailId>'+STR(@intChildContractDetailId)+'</intContractDetailId></toUpdate></root>' 

					EXEC uspCTCreateADuplicateRecord 'tblRKAssignFuturesToContractSummary',@intSummaryId, @intNewSummaryId OUTPUT,@XML
				END

				EXEC	@strTradeNo = uspCTGetStartingNumber 'Price Fixation Trade No'
				SET		@XML =	'<root><toUpdate><strTradeNo>'+LTRIM(RTRIM(@strTradeNo))+'</strTradeNo><dblNoOfLots>'+STR(@dblChildSeqLots)+'</dblNoOfLots>'+
								'<dblQuantity>'+STR(@dblChildSeqQty)+'</dblQuantity>'+
								'<dtmFixationDate>'+@strDateWithTime+'</dtmFixationDate>'+
								CASE WHEN @ysnHedge = 1 THEN '<intFutOptTransactionId>'+STR(@intNewFutOptTransactionId)+'</intFutOptTransactionId>' ELSE '' END +
								'<intPriceFixationId>'+STR(@intNewPriceFixationId)+'</intPriceFixationId></toUpdate></root>' 

				EXEC uspCTCreateADuplicateRecord 'tblCTPriceFixationDetail',@intPriceFixationDetailId, @intNewPFDetailId OUTPUT,@XML

				SELECT	@intChildContractDetailId = MIN(intContractDetailId) 
				FROM	tblCTContractDetail 
				WHERE	intSplitFromId		=	@intContractDetailId
				AND		intContractDetailId	>	@intChildContractDetailId
				AND		intContractDetailId NOT IN (SELECT ISNULL(intContractDetailId,0) FROM tblCTPriceFixation)
		END					
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH