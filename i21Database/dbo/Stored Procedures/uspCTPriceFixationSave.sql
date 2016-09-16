CREATE PROCEDURE [dbo].[uspCTPriceFixationSave]
	
	@intPriceFixationId INT,
	@strAction			NVARCHAR(50),
	@intUserId			INT
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg						NVARCHAR(MAX),
			@intContractDetailId		INT,
			@intContractHeaderId		INT,
			@intFinalPriceUOMId			INT,
			@intCommodityId				INT,
			@intPriceItemUOMId			INT,
			@intPriceCommodityUOMId		INT,
			@intUnitMeasureId			INT,
			@strUnitMeasure				NVARCHAR(50),	
			@strCommodityDescription	NVARCHAR(MAX),
			@dblCashPrice				NUMERIC(18,6),
			@intTypeRef					INT,
			@intNewFutureMonthId		INT,
			@intNewFutureMarketId		INT,
			@intLotsUnfixed				INT,
			@intPriceFixationDetailId	INT,
			@intFutOptTransactionId		INT,
			@ysnMultiplePriceFixation	BIT,
			@intPricingTypeId			INT,
			@ysnPartialPricing			BIT,
			@dblQuantity				NUMERIC(18,6),
			@dblPFDetailQuantity		NUMERIC(18,6),
			@intNextSequence			INT,
			@XML						NVARCHAR(MAX),
			@dblNewQuantity				NUMERIC(18,6),
			@intNewContractDetailId		INT,
			@intPFDetailNoOfLots		INT,
			@ysnSplit					BIT,
			@intNewPriceFixationId		INT,
			@ysnHedge					BIT,
			@dblFutures					NUMERIC(18,6),
			@intTotalLots				INT,
			@intTotalPFDetailNoOfLots	INT,
			@ysnUnlimitedQuantity		BIT,
			@intFirstPFDetailId			INT

	SET		@ysnMultiplePriceFixation = 0

	SELECT	@intLotsUnfixed			=	ISNULL(intTotalLots,0) - ISNULL(intLotsFixed,0),
			@intContractDetailId	=	intContractDetailId,
			@intContractHeaderId	=	intContractHeaderId,
			@intFinalPriceUOMId		=	intFinalPriceUOMId,
			@ysnSplit				=	ysnSplit,
			@intTotalLots			=	intTotalLots
	FROM	tblCTPriceFixation
	WHERE	intPriceFixationId		=	@intPriceFixationId

	SELECT	@intTotalPFDetailNoOfLots	=	SUM(intNoOfLots)
	FROM	tblCTPriceFixationDetail
	WHERE	intPriceFixationId		=	@intPriceFixationId

	SELECT	@ysnUnlimitedQuantity	=	ysnUnlimitedQuantity FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId

	SELECT	@ysnPartialPricing = ysnPartialPricing FROM tblCTCompanyPreference

	IF ISNULL(@intContractDetailId,0) > 0
	BEGIN
		ProcessContractDetail:

		SELECT	@intCommodityId				=	intCommodityId,
				@intPriceItemUOMId			=	intPriceItemUOMId,
				@strCommodityDescription	=	strCommodityDescription,
				@intPricingTypeId			=	intPricingTypeId,
				@dblQuantity				=	dblDetailQuantity
		FROM	vyuCTContractDetailView 
		WHERE	intContractDetailId =	@intContractDetailId
			
		SELECT	@intUnitMeasureId	=	UM.intUnitMeasureId,
				@strUnitMeasure		=	UM.strUnitMeasure
		FROM	tblICItemUOM		IM
		JOIN	tblICUnitMeasure	UM	ON IM.intUnitMeasureId = UM.intUnitMeasureId
		WHERE	IM.intItemUOMId		=	@intPriceItemUOMId

		IF NOT EXISTS(SELECT * FROM tblICCommodityUnitMeasure WHERE intCommodityId = @intCommodityId AND intUnitMeasureId = @intUnitMeasureId)
		BEGIN
			SET @ErrMsg = @strUnitMeasure + ' not configured for the commodity ' + @strCommodityDescription + '.'
			RAISERROR(@ErrMsg,16,1)
		END

		SELECT	@intPriceCommodityUOMId = intCommodityUnitMeasureId 
		FROM	tblICCommodityUnitMeasure 
		WHERE	intCommodityId		=	@intCommodityId 
		AND		intUnitMeasureId	=	@intUnitMeasureId

		IF @intPricingTypeId = 2
		BEGIN
			UPDATE tblCTContractDetail SET dblOriginalBasis = dblBasis WHERE intContractDetailId = @intContractDetailId
		END

		IF @strAction = 'Delete'
		BEGIN

			UPDATE	CD
			SET		CD.dblBasis				=	ISNULL(CD.dblOriginalBasis,0),
					CD.intFutureMarketId	=	PF.intOriginalFutureMarketId,
					CD.intFutureMonthId		=	PF.intOriginalFutureMonthId,
					CD.intPricingTypeId		=	2,
					CD.dblFutures			=	NULL,
					CD.dblCashPrice			=	NULL,
					CD.dblTotalCost			=	NULL,
					CD.intConcurrencyId		=	CD.intConcurrencyId + 1
			FROM	tblCTContractDetail	CD
			JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId
			WHERE	PF.intPriceFixationId	=	@intPriceFixationId

			SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId) 
			FROM	tblCTPriceFixationDetail 
			WHERE	intPriceFixationId = @intPriceFixationId
		

			WHILE	ISNULL(@intPriceFixationDetailId,0) > 0
			BEGIN
			
					SELECT @intFutOptTransactionId = NULL

					SELECT	@intFutOptTransactionId  = intFutOptTransactionId
					FROM	tblCTPriceFixationDetail 
					WHERE	intPriceFixationDetailId = @intPriceFixationDetailId 

					IF ISNULL(@intFutOptTransactionId,0) > 0
					BEGIN
						UPDATE	tblCTPriceFixationDetail
						SET		intFutOptTransactionId = NULL
						WHERE	intPriceFixationDetailId = @intPriceFixationDetailId

						EXEC	uspRKDeleteAutoHedge @intFutOptTransactionId
					END

					SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId) 
					FROM	tblCTPriceFixationDetail 
					WHERE	intPriceFixationId = @intPriceFixationId
					AND		intPriceFixationDetailId > @intPriceFixationDetailId
				
			END

			IF	@ysnMultiplePriceFixation = 1
			BEGIN
				SELECT	@intContractDetailId = MIN(intContractDetailId)
				FROM	tblCTContractDetail 
				WHERE	intContractHeaderId = @intContractHeaderId 
				AND		intContractDetailId > @intContractDetailId

				IF ISNULL(@intContractDetailId,0) = 0
					SET @intContractDetailId = -1

				GOTO NextDetail
			END
			ELSE
				RETURN
		END

		IF ISNULL(@ysnSplit,0) = 1
		BEGIN				
		
			SELECT	@intFirstPFDetailId = MIN(intPriceFixationDetailId) 
			FROM	tblCTPriceFixationDetail
			WHERE	intPriceFixationId = @intPriceFixationId

			UPDATE	PF
			SET		PF.intTotalLots			=	FD.intNoOfLots,
					PF.intLotsFixed			=	FD.intNoOfLots,
					PF.intLotsHedged		=	CASE WHEN @ysnHedge = 1 THEN FD.intNoOfLots ELSE NULL END,
					PF.dblPriceWORollArb	=	FD.dblFutures,
					PF.dblFinalPrice		=	PF.dblFinalPrice - PF.dblPriceWORollArb + FD.dblFutures
			FROM	tblCTPriceFixation			PF 
			JOIN	tblCTPriceFixationDetail	FD	ON	FD.intPriceFixationId	=	PF.intPriceFixationId
			WHERE	FD.intPriceFixationDetailId	=	@intFirstPFDetailId 

			UPDATE	tblCTContractDetail	
			SET		dblNoOfLots				=	 (SELECT SUM(intNoOfLots) FROM tblCTPriceFixationDetail WHERE intPriceFixationDetailId = @intFirstPFDetailId) 
			WHERE	intContractDetailId		=	 @intContractDetailId

			SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId) 
			FROM	tblCTPriceFixationDetail 
			WHERE	intPriceFixationId = @intPriceFixationId AND 
					intPriceFixationDetailId > @intFirstPFDetailId
		

			WHILE	ISNULL(@intPriceFixationDetailId,0) > 0
			BEGIN
					
					SELECT	@dblPFDetailQuantity	=	dblQuantity,
							@intPFDetailNoOfLots	=	intNoOfLots,
							@intFutOptTransactionId	=	intFutOptTransactionId,
							@ysnHedge				=	ysnHedge,
							@dblFutures				=	dblFutures
					FROM	tblCTPriceFixationDetail 
					WHERE	intPriceFixationDetailId = @intPriceFixationDetailId

					SELECT	@intNextSequence		=	MAX(intContractSeq) + 1 FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId

					SELECT @dblNewQuantity =  @dblPFDetailQuantity
					SELECT @dblQuantity = @dblQuantity - @dblPFDetailQuantity

					IF	@dblNewQuantity > 0
					BEGIN
						EXEC uspCTSplitSequence @intContractDetailId,@dblNewQuantity,@intUserId,@intPriceFixationId,'Price Contract', @intNewContractDetailId OUTPUT
						SET @XML = '<root><toUpdate><ysnSplit>0</ysnSplit><intContractDetailId>'+LTRIM(@intNewContractDetailId)+'</intContractDetailId></toUpdate><child><tblCTSpreadArbitrage></tblCTSpreadArbitrage></child></root>' 
						EXEC uspCTCreateADuplicateRecord 'tblCTPriceFixation',@intPriceFixationId, @intNewPriceFixationId OUTPUT,@XML
						
						UPDATE	tblCTPriceFixation 
						SET		intContractDetailId =	@intNewContractDetailId,
								intTotalLots		=	@intPFDetailNoOfLots,
								intLotsFixed		=	@intPFDetailNoOfLots,
								intLotsHedged		=	CASE WHEN @ysnHedge = 1 THEN @intPFDetailNoOfLots ELSE NULL END,
								dblPriceWORollArb	=	@dblFutures,
								dblFinalPrice		=	dblFinalPrice - dblPriceWORollArb + @dblFutures
						WHERE	intPriceFixationId	=	@intNewPriceFixationId

						UPDATE	tblCTPriceFixationDetail 
						SET		intPriceFixationId			=	@intNewPriceFixationId
						WHERE	intPriceFixationDetailId	=	@intPriceFixationDetailId

						UPDATE	tblRKAssignFuturesToContractSummary
						SET		intContractDetailId		=	@intNewContractDetailId
						WHERE	intContractDetailId		=	@intContractDetailId
						AND		intFutOptTransactionId	=	@intFutOptTransactionId

						UPDATE	tblCTContractDetail	
						SET		dblNoOfLots				=	 @intPFDetailNoOfLots 
						WHERE	intContractDetailId		=	 @intNewContractDetailId

						EXEC	uspCTPriceFixationSave @intNewPriceFixationId, 'Added', @intUserId

					END

					SELECT	@intPriceFixationDetailId	=	MIN(intPriceFixationDetailId) 
					FROM	tblCTPriceFixationDetail 
					WHERE	intPriceFixationId			=	@intPriceFixationId
					AND		intPriceFixationDetailId	>	@intPriceFixationDetailId
				
			END	

			IF	@intLotsUnfixed > 0
			BEGIN

				SELECT	@intPriceFixationDetailId	=	MIN(intPriceFixationDetailId) 
				FROM	tblCTPriceFixationDetail 
				WHERE	intPriceFixationId			=	@intPriceFixationId

				SELECT	@dblPFDetailQuantity		=	dblQuantity,
						@intPFDetailNoOfLots		=	intNoOfLots,
						@intFutOptTransactionId		=	intFutOptTransactionId,
						@ysnHedge					=	ysnHedge,
						@dblFutures					=	dblFutures
				FROM	tblCTPriceFixationDetail 
				WHERE	intPriceFixationDetailId	=	@intPriceFixationDetailId

				UPDATE tblCTPriceFixation	
				SET		intTotalLots		=	@intPFDetailNoOfLots,
						intLotsFixed		=	@intPFDetailNoOfLots,
						intLotsHedged		=	CASE WHEN @ysnHedge = 1 THEN @intPFDetailNoOfLots ELSE NULL END,
						dblPriceWORollArb	=	@dblFutures,
						dblFinalPrice		=	dblFinalPrice - dblPriceWORollArb + @dblFutures
				WHERE intPriceFixationId	=	@intPriceFixationId

				UPDATE tblCTContractDetail	SET dblNoOfLots = @intPFDetailNoOfLots WHERE intContractDetailId = @intContractDetailId

				SELECT	@dblPFDetailQuantity	=	dblQuantity
				FROM	tblCTPriceFixationDetail 
				WHERE	intPriceFixationId = @intPriceFixationId

				SELECT @dblNewQuantity = @dblQuantity - @dblPFDetailQuantity

				IF	@dblNewQuantity > 0
				BEGIN
					EXEC uspCTSplitSequence @intContractDetailId,@dblNewQuantity,@intUserId,@intPriceFixationId,'Price Contract', @intNewContractDetailId OUTPUT
					
					UPDATE	tblCTContractDetail	
					SET		dblNoOfLots = CASE WHEN @intTotalLots - @intTotalPFDetailNoOfLots <=0 THEN 1 ELSE  @intTotalLots - @intTotalPFDetailNoOfLots END,
							dblFutures = null,
							dblCashPrice = null,
							dblTotalCost = null
					WHERE	intContractDetailId = @intNewContractDetailId	
				END

				SET @intLotsUnfixed = 0
			END
			
		END

		IF EXISTS(SELECT TOP 1 1 FROM tblCTSpreadArbitrage WHERE intPriceFixationId = @intPriceFixationId)
		BEGIN
		
			SELECT	@intTypeRef				=	MAX(intTypeRef) 
			FROM	tblCTSpreadArbitrage 
			WHERE	intPriceFixationId		=	@intPriceFixationId

			SELECT  @intNewFutureMonthId	=	intNewFutureMonthId,
					@intNewFutureMarketId	=	intNewFutureMarketId
			FROM	tblCTSpreadArbitrage 
			WHERE	intPriceFixationId		=	@intPriceFixationId
			AND		intTypeRef				=	@intTypeRef

			UPDATE	CD
			SET		CD.dblBasis				=	ISNULL(CD.dblOriginalBasis,ISNULL(CD.dblBasis,0)) + dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,ISNULL(dblRollArb,0)),
					CD.intFutureMarketId	=	@intNewFutureMarketId,
					CD.intFutureMonthId		=	@intNewFutureMonthId,
					CD.intConcurrencyId		=	CD.intConcurrencyId + 1
			FROM	tblCTContractDetail	CD
			JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId
			WHERE	PF.intPriceFixationId	=	@intPriceFixationId
		END
		ELSE
		BEGIN
			UPDATE	CD
			SET		CD.dblBasis				=	ISNULL(CD.dblOriginalBasis,0) + ISNULL(dblRollArb,0),
					CD.intFutureMarketId	=	PF.intOriginalFutureMarketId,
					CD.intFutureMonthId		=	PF.intOriginalFutureMonthId,
					CD.intConcurrencyId		=	CD.intConcurrencyId + 1
			FROM	tblCTContractDetail	CD
			JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId
			WHERE	PF.intPriceFixationId	=	@intPriceFixationId
		END

		IF	@intLotsUnfixed = 0
		BEGIN
			UPDATE	CD
			SET		CD.intPricingTypeId		=	1,
					CD.dblFutures			=	dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,ISNULL(dblPriceWORollArb,0)),
					CD.dblCashPrice			=	CD.dblBasis + dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,ISNULL(dblPriceWORollArb,0)),	
					CD.dblTotalCost			=	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity) * 
												(CD.dblBasis + dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,ISNULL(dblPriceWORollArb,0)))/
												CASE WHEN ISNULL(CY.ysnSubCurrency,0) = 0 THEN 1 ELSE CY.intCent END,	
					CD.intConcurrencyId		=	CD.intConcurrencyId + 1,
					CD.intContractStatusId	=	CASE WHEN CD.dblBalance = 0 AND ISNULL(@ysnUnlimitedQuantity,0) = 0 THEN 5 ELSE CD.intContractStatusId END
			FROM	tblCTContractDetail	CD
			JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID = CD.intCurrencyId
			JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId
			WHERE	PF.intPriceFixationId	=	@intPriceFixationId
		END
		ELSE
		BEGIN
			UPDATE	CD
			SET		CD.intPricingTypeId		=	2,
					CD.dblFutures			=	NULL,
					CD.dblCashPrice			=	NULL,	
					CD.dblTotalCost			=	NULL,
					CD.intConcurrencyId		=	CD.intConcurrencyId + 1
			FROM	tblCTContractDetail	CD
			JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId
			WHERE	PF.intPriceFixationId	=	@intPriceFixationId
		END

		SELECT @intPricingTypeId = intPricingTypeId, @dblCashPrice = dblCashPrice FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
		
		EXEC	uspCTSequencePriceChanged @intContractDetailId

		IF	@ysnMultiplePriceFixation = 1
		BEGIN
			SELECT	@intContractDetailId = MIN(intContractDetailId)
			FROM	tblCTContractDetail 
			WHERE	intContractHeaderId = @intContractHeaderId 
			AND		intContractDetailId > @intContractDetailId

			IF ISNULL(@intContractDetailId,0) = 0
				SET @intContractDetailId = -1

			GOTO NextDetail
		END
	END
	ELSE
	BEGIN
		NextDetail:

		SET		@ysnMultiplePriceFixation = 1

		IF ISNULL(@intContractDetailId,0) = 0
		BEGIN
			SELECT	@intContractDetailId = MIN(intContractDetailId)
			FROM	tblCTContractDetail 
			WHERE	intContractHeaderId = @intContractHeaderId
		END

		IF ISNULL(@intContractDetailId,0) > 0
		BEGIN
			
			UPDATE	tblCTPriceFixation 
			SET		intContractDetailId = @intContractDetailId
			WHERE	intPriceFixationId	=	@intPriceFixationId

			GOTO ProcessContractDetail
		END
		ELSE
		BEGIN
			UPDATE	tblCTPriceFixation 
			SET		intContractDetailId = NULL
			WHERE	intPriceFixationId	=	@intPriceFixationId
		END
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO