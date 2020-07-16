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
			@dblLotsUnfixed				NUMERIC(18,6),
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
			@dblPFDetailNoOfLots		NUMERIC(18,6),
			@ysnSplit					BIT,
			@intNewPriceFixationId		INT,
			@ysnHedge					BIT,
			@dblFutures					NUMERIC(18,6),
			@dblTotalLots				NUMERIC(18,6),
			@dblTotalPFDetailNoOfLots	NUMERIC(18,6),
			@ysnUnlimitedQuantity		BIT,
			@intFirstPFDetailId			INT,
			@intBasisUOMId				INT,
			@intBasisCommodityUOMId		INT,
			@intCurrencyId				INT,
			@intBasisCurrencyId			INT,
			@ysnBasisSubCurrency		INT,
			@intFinalCurrencyId			INT,
			@ysnFinalSubCurrency		BIT,
			@dblTotalPFDetailQuantiy	NUMERIC(18,6),
			@ysnFullyPriced				BIT = 0,
			@strPricingQuantity			NVARCHAR(100),
			@intMarketUnitMeasureId		INT,
			@intMarketCurrencyId		INT,
			@intPriceContractId			INT,
			@ysnSeqSubCurrency			BIT

	SET		@ysnMultiplePriceFixation = 0

	SELECT	@dblLotsUnfixed			=	ISNULL([dblTotalLots],0) - ISNULL([dblLotsFixed],0),
			@intContractDetailId	=	intContractDetailId,
			@intContractHeaderId	=	intContractHeaderId,
			@intFinalPriceUOMId		=	PC.intFinalPriceUOMId,
			@ysnSplit				=	ysnSplit,
			@dblTotalLots			=	[dblTotalLots],
			@intFinalCurrencyId		=	intFinalCurrencyId,
			@ysnFinalSubCurrency	=	CY.ysnSubCurrency,
			@intPriceContractId		=	PF.intPriceContractId
	FROM	tblCTPriceFixation		PF
	JOIN	tblCTPriceContract		PC	ON	PC.intPriceContractId	=	PF.intPriceContractId	LEFT 
	JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID		=	PC.intFinalCurrencyId
	WHERE	intPriceFixationId		=	@intPriceFixationId

	SELECT	@dblTotalPFDetailNoOfLots	=	SUM([dblNoOfLots]),
			@dblTotalPFDetailQuantiy	=	SUM(dblQuantity)
	FROM	tblCTPriceFixationDetail
	WHERE	intPriceFixationId		=	@intPriceFixationId

	SELECT	@ysnUnlimitedQuantity	=	ysnUnlimitedQuantity FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId

	SELECT	@ysnPartialPricing = ysnPartialPricing, @strPricingQuantity = strPricingQuantity FROM tblCTCompanyPreference

	IF ISNULL(@intContractDetailId,0) > 0
	BEGIN
		ProcessContractDetail:

		SELECT	@intCommodityId				=	CH.intCommodityId,
				@intPriceItemUOMId			=	CD.intPriceItemUOMId,
				@strCommodityDescription	=	CH.strCommodityDescription,
				@intPricingTypeId			=	CD.intPricingTypeId,
				@dblQuantity				=	CD.dblQuantity,
				@intBasisUOMId				=	BM.intCommodityUnitMeasureId,
				@intCurrencyId				=	CD.intCurrencyId,
				@intBasisCurrencyId			=	CD.intBasisCurrencyId,
				@ysnBasisSubCurrency		=	AY.ysnSubCurrency,
				@ysnSeqSubCurrency		=	SY.ysnSubCurrency

		FROM	tblCTContractDetail			CD
		JOIN	vyuCTContractHeaderView		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId 
   LEFT JOIN	tblICItemUOM				BU	ON	BU.intItemUOMId			=	CD.intBasisUOMId
   LEFT JOIN	tblICCommodityUnitMeasure	BM	ON	BM.intCommodityId		=	CH.intCommodityId
												AND	BM.intUnitMeasureId		=	BU.intUnitMeasureId
   LEFT JOIN	tblSMCurrency				AY	ON	AY.intCurrencyID		=	CD.intBasisCurrencyId
   LEFT JOIN	tblSMCurrency				SY	ON	SY.intCurrencyID		=	CD.intCurrencyId
		WHERE	intContractDetailId			=	@intContractDetailId
		
		IF @strPricingQuantity = 'By Futures Contracts'
		BEGIN
			SELECT @ysnFullyPriced = CASE WHEN @dblLotsUnfixed = 0 THEN 1 ELSE 0 END
		END
		ELSE IF @ysnMultiplePriceFixation = 1
		BEGIN
			DECLARE @totalQuantity NUMERIC(18,6)
			SELECT @totalQuantity = SUM(dblQuantity)
			FROM tblCTContractDetail 
			WHERE intContractHeaderId = @intContractHeaderId

			SELECT @ysnFullyPriced = CASE WHEN @totalQuantity = @dblTotalPFDetailQuantiy THEN 1 ELSE 0 END
		END
		ELSE
		BEGIN
			SELECT @ysnFullyPriced = CASE WHEN @dblQuantity = @dblTotalPFDetailQuantiy THEN 1 ELSE 0 END
		END

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

		IF @intPricingTypeId IN (2,8) AND @strAction <> 'Delete'
		BEGIN
			UPDATE tblCTContractDetail SET dblOriginalBasis = dblBasis WHERE intContractDetailId = @intContractDetailId
		END

		IF @strAction = 'Delete'
		BEGIN

		declare @intDWGIdId int
				,@ysnDestinationWeightsAndGrades bit;

		select @intDWGIdId = intWeightGradeId from tblCTWeightGrade where strWhereFinalized = 'Destination';
			
		select
			@ysnDestinationWeightsAndGrades = (case when ch.intWeightId = @intDWGIdId or ch.intGradeId = @intDWGIdId then 1 else 0 end)
		from
			tblCTContractDetail cd
			,tblCTContractHeader ch
		where
			cd.intContractDetailId = @intContractDetailId
			and ch.intContractHeaderId = cd.intContractHeaderId

			UPDATE	CD
			SET		CD.dblBasis				=	ISNULL(CD.dblOriginalBasis,0),
					CD.intFutureMarketId	=	PF.intOriginalFutureMarketId,
					CD.intFutureMonthId		=	PF.intOriginalFutureMonthId,
					CD.intPricingTypeId		=	CASE WHEN CH.intPricingTypeId <> 8 THEN 2 ELSE 8 END,
					CD.dblFutures			=	NULL,
					CD.dblCashPrice			=	NULL,
					CD.dblTotalCost			=	NULL,
					CD.intConcurrencyId		=	CD.intConcurrencyId + 1,
					CD.intContractStatusId	=	case when CD.intContractStatusId = 5 and @ysnDestinationWeightsAndGrades = 0 then 1 else CD.intContractStatusId end
			FROM	tblCTContractDetail	CD
			JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
			JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId OR CD.intSplitFromId = PF.intContractDetailId
			AND EXISTS(SELECT * FROM tblCTPriceFixation WHERE intContractDetailId = ISNULL(CD.intContractDetailId,0))
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

						EXEC	uspRKDeleteAutoHedge @intFutOptTransactionId, @intUserId
					END

					SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId) 
					FROM	tblCTPriceFixationDetail 
					WHERE	intPriceFixationId = @intPriceFixationId
					AND		intPriceFixationDetailId > @intPriceFixationDetailId
				
			END

			EXEC	uspCTSequencePriceChanged @intContractDetailId, @intUserId, 'Price Contract', 1

			UPDATE tblCTContractDetail SET intSplitFromId = NULL WHERE intSplitFromId = @intContractDetailId

			EXEC	uspCTCreateDetailHistory	@intContractHeaderId,@intContractDetailId, 'Pricing Delete'

			IF	@ysnMultiplePriceFixation = 1
			BEGIN

				UPDATE	CH
				SET		CH.intFutureMarketId	=	PF.intOriginalFutureMarketId,
						CH.intFutureMonthId		=	PF.intOriginalFutureMonthId,
						CH.dblFutures			=	NULL,
						CH.intConcurrencyId		=	CH.intConcurrencyId + 1
				FROM	tblCTContractHeader		CH
				JOIN	tblCTPriceFixation		PF	ON	CH.intContractHeaderId = PF.intContractHeaderId
				WHERE	PF.intPriceFixationId	=	@intPriceFixationId

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
			SET		PF.[dblTotalLots]		=	FD.[dblNoOfLots],
					PF.[dblLotsFixed]		=	FD.[dblNoOfLots],
					PF.intLotsHedged		=	CASE WHEN @ysnHedge = 1 THEN FD.[dblNoOfLots] ELSE NULL END,
					PF.dblPriceWORollArb	=	FD.dblFutures,
					PF.dblFinalPrice		=	PF.dblFinalPrice - PF.dblPriceWORollArb + FD.dblFutures
			FROM	tblCTPriceFixation			PF 
			JOIN	tblCTPriceFixationDetail	FD	ON	FD.intPriceFixationId	=	PF.intPriceFixationId
			WHERE	FD.intPriceFixationDetailId	=	@intFirstPFDetailId 

			UPDATE	tblCTContractDetail	
			SET		dblNoOfLots				=	 (SELECT SUM([dblNoOfLots]) FROM tblCTPriceFixationDetail WHERE intPriceFixationDetailId = @intFirstPFDetailId) 
			WHERE	intContractDetailId		=	 @intContractDetailId

			SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId) 
			FROM	tblCTPriceFixationDetail 
			WHERE	intPriceFixationId = @intPriceFixationId AND 
					intPriceFixationDetailId > @intFirstPFDetailId
		

			WHILE	ISNULL(@intPriceFixationDetailId,0) > 0
			BEGIN
					
					SELECT	@dblPFDetailQuantity	=	dblQuantity,
							@dblPFDetailNoOfLots	=	[dblNoOfLots],
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
								[dblTotalLots]		=	@dblPFDetailNoOfLots,
								[dblLotsFixed]		=	@dblPFDetailNoOfLots,
								intLotsHedged		=	CASE WHEN @ysnHedge = 1 THEN @dblPFDetailNoOfLots ELSE NULL END,
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
						SET		dblNoOfLots				=	 @dblPFDetailNoOfLots 
						WHERE	intContractDetailId		=	 @intNewContractDetailId

						EXEC	uspCTPriceFixationSave @intNewPriceFixationId, 'Added', @intUserId

					END

					SELECT	@intPriceFixationDetailId	=	MIN(intPriceFixationDetailId) 
					FROM	tblCTPriceFixationDetail 
					WHERE	intPriceFixationId			=	@intPriceFixationId
					AND		intPriceFixationDetailId	>	@intPriceFixationDetailId
				
			END	

			IF	@dblLotsUnfixed > 0
			BEGIN

				SELECT	@intPriceFixationDetailId	=	MIN(intPriceFixationDetailId) 
				FROM	tblCTPriceFixationDetail 
				WHERE	intPriceFixationId			=	@intPriceFixationId

				SELECT	@dblPFDetailQuantity		=	dblQuantity,
						@dblPFDetailNoOfLots		=	[dblNoOfLots],
						@intFutOptTransactionId		=	intFutOptTransactionId,
						@ysnHedge					=	ysnHedge,
						@dblFutures					=	dblFutures
				FROM	tblCTPriceFixationDetail 
				WHERE	intPriceFixationDetailId	=	@intPriceFixationDetailId

				UPDATE tblCTPriceFixation	
				SET		[dblTotalLots]		=	@dblPFDetailNoOfLots,
						[dblLotsFixed]		=	@dblPFDetailNoOfLots,
						intLotsHedged		=	CASE WHEN @ysnHedge = 1 THEN @dblPFDetailNoOfLots ELSE NULL END,
						dblPriceWORollArb	=	@dblFutures,
						dblFinalPrice		=	dblFinalPrice - dblPriceWORollArb + @dblFutures
				WHERE intPriceFixationId	=	@intPriceFixationId

				UPDATE tblCTContractDetail	SET dblNoOfLots = @dblPFDetailNoOfLots WHERE intContractDetailId = @intContractDetailId

				SELECT	@dblPFDetailQuantity	=	dblQuantity
				FROM	tblCTPriceFixationDetail 
				WHERE	intPriceFixationId = @intPriceFixationId

				SELECT @dblNewQuantity = @dblQuantity - @dblPFDetailQuantity

				IF	@dblNewQuantity > 0
				BEGIN
					EXEC uspCTSplitSequence @intContractDetailId,@dblNewQuantity,@intUserId,@intPriceFixationId,'Price Contract', @intNewContractDetailId OUTPUT
					
					UPDATE	tblCTContractDetail	
					SET		dblNoOfLots = CASE WHEN @dblTotalLots - @dblTotalPFDetailNoOfLots <=0 THEN 1 ELSE  @dblTotalLots - @dblTotalPFDetailNoOfLots END,
							dblFutures = null,
							dblCashPrice = null,
							dblTotalCost = null
					WHERE	intContractDetailId = @intNewContractDetailId	
				END

				SET @dblLotsUnfixed = 0
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

			SELECT	@intMarketUnitMeasureId = intUnitMeasureId,
					@intMarketCurrencyId = intCurrencyId 
			FROM	tblRKFutureMarket 
			WHERE	intFutureMarketId = @intNewFutureMarketId

			SELECT	@intFinalPriceUOMId		=	intCommodityUnitMeasureId,
					@intFinalCurrencyId		=	@intMarketCurrencyId,
					@intPriceCommodityUOMId	=	intCommodityUnitMeasureId
			FROM	tblICCommodityUnitMeasure 
			WHERE	intCommodityId		=	@intCommodityId 
			AND		intUnitMeasureId	=	@intMarketUnitMeasureId

			UPDATE	FD
			SET		dblFutures		=	dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFinalPriceUOMId,PF.intFinalPriceUOMId,FD.dblFixationPrice) / 
												CASE	WHEN	@intFinalCurrencyId = @intCurrencyId	THEN 1 
														WHEN	@intFinalCurrencyId <> @intCurrencyId	
														AND		@ysnSeqSubCurrency = 1				THEN 100 
														ELSE	0.01 
												END,
					dblFinalPrice	=	(dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFinalPriceUOMId,PF.intFinalPriceUOMId,FD.dblFixationPrice) / 
												CASE	WHEN	@intFinalCurrencyId = @intCurrencyId	THEN 1 
														WHEN	@intFinalCurrencyId <> @intCurrencyId	
														AND		@ysnSeqSubCurrency = 1				THEN 100 
														ELSE	0.01 
												END) + PF.dblOriginalBasis + PF.dblRollArb,
					dblCashPrice	=	(dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFinalPriceUOMId,PF.intFinalPriceUOMId,FD.dblFixationPrice) / 
												CASE	WHEN	@intFinalCurrencyId = @intCurrencyId	THEN 1 
														WHEN	@intFinalCurrencyId <> @intCurrencyId	
														AND		@ysnSeqSubCurrency = 1				THEN 100 
														ELSE	0.01 
												END) + PF.dblOriginalBasis + PF.dblRollArb
			FROM	tblCTPriceFixation			PF 
			--JOIN	tblCTPriceContract			PC	ON	PC.intPriceContractId	=	PF.intPriceContractId
			JOIN	tblCTPriceFixationDetail	FD	ON	FD.intPriceFixationId	=	PF.intPriceFixationId
			WHERE	PF.intPriceFixationId	=	@intPriceFixationId

			UPDATE	PF
			SET		dblPriceWORollArb	=	dblFutXLots / @dblTotalPFDetailNoOfLots,
					dblFinalPrice		=	dblFutXLots / @dblTotalPFDetailNoOfLots + PF.dblOriginalBasis + PF.dblRollArb
			FROM	tblCTPriceFixation			PF 
			JOIN	(	SELECT	intPriceFixationId, SUM(FD.dblFutures * FD.dblNoOfLots) dblFutXLots 
						FROM	tblCTPriceFixationDetail FD
						WHERE	intPriceFixationId = @intPriceFixationId 
						GROUP	BY intPriceFixationId
					)	FD	ON	FD.intPriceFixationId	=	PF.intPriceFixationId
			WHERE	PF.intPriceFixationId	=	@intPriceFixationId

			UPDATE  tblCTPriceContract SET intFinalPriceUOMId = @intFinalPriceUOMId, intFinalCurrencyId = @intFinalCurrencyId WHERE intPriceContractId	=	@intPriceContractId
			
			UPDATE	tblCTSpreadArbitrage 
			SET		intSpreadUOMId			=	@intFinalPriceUOMId
			WHERE	intPriceFixationId		=	@intPriceFixationId
			AND		intTypeRef				=	@intTypeRef

			SELECT	@intCurrencyId	=	@intMarketCurrencyId

			UPDATE	CD
			SET		CD.dblBasis				=	(
													dbo.fnCTConvertQuantityToTargetCommodityUOM(@intBasisUOMId,@intFinalPriceUOMId,ISNULL(CD.dblOriginalBasis,ISNULL(CD.dblBasis,0))) / 
													CASE	WHEN	@intBasisCurrencyId = @intCurrencyId	THEN 1 
															WHEN	@intBasisCurrencyId <> @intCurrencyId	
															AND		@ysnBasisSubCurrency = 1				THEN 100 
															ELSE	0.01 
													END
												), -- + 
												--dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,ISNULL(dblRollArb,0)),
					CD.intFutureMarketId	=	@intNewFutureMarketId,
					CD.intFutureMonthId		=	@intNewFutureMonthId,
					CD.intConcurrencyId		=	CD.intConcurrencyId + 1,
					CD.intCurrencyId		=	@intMarketCurrencyId,
					CD.intPriceItemUOMId	=	(SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId = CD.intItemId AND intUnitMeasureId = @intMarketUnitMeasureId)
			FROM	tblCTContractDetail	CD
			JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId OR CD.intSplitFromId = PF.intContractDetailId
			AND EXISTS(SELECT * FROM tblCTPriceFixation WHERE intContractDetailId = ISNULL(CD.intContractDetailId,0))
			WHERE	PF.intPriceFixationId	=	@intPriceFixationId
			

			IF	@ysnMultiplePriceFixation = 1
			BEGIN
				UPDATE	CH
				SET		CH.intFutureMarketId	=	@intNewFutureMarketId,
						CH.intFutureMonthId		=	@intNewFutureMonthId,
						CH.intConcurrencyId		=	CH.intConcurrencyId + 1
				FROM	tblCTContractHeader		CH
				JOIN	tblCTPriceFixation		PF	ON	CH.intContractHeaderId = PF.intContractHeaderId
				WHERE	PF.intPriceFixationId	=	@intPriceFixationId
			END
		END
		ELSE
		BEGIN
			UPDATE	CD
			SET		CD.dblBasis				=	ISNULL(CD.dblOriginalBasis,0) + ISNULL(dblRollArb,0),
					CD.intFutureMarketId	=	PF.intOriginalFutureMarketId,
					CD.intFutureMonthId		=	PF.intOriginalFutureMonthId,
					CD.intConcurrencyId		=	CD.intConcurrencyId + 1
			FROM	tblCTContractDetail	CD
			JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId OR CD.intSplitFromId = PF.intContractDetailId
			AND EXISTS(SELECT * FROM tblCTPriceFixation WHERE intContractDetailId = ISNULL(CD.intContractDetailId,0))
			WHERE	PF.intPriceFixationId	=	@intPriceFixationId

			IF	@ysnMultiplePriceFixation = 1
			BEGIN
				UPDATE	CH
				SET		CH.intFutureMarketId	=	PF.intOriginalFutureMarketId,
						CH.intFutureMonthId		=	PF.intOriginalFutureMonthId,
						CH.intConcurrencyId		=	CH.intConcurrencyId + 1
				FROM	tblCTContractHeader		CH
				JOIN	tblCTPriceFixation		PF	ON	CH.intContractHeaderId = PF.intContractHeaderId
				WHERE	PF.intPriceFixationId	=	@intPriceFixationId
			END
		END

		IF	@ysnFullyPriced = 1
		BEGIN
			UPDATE	CD
			SET		CD.intPricingTypeId		=	1,
					CD.dblFutures			=	dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,ISNULL(dblPriceWORollArb,0))  / 
												CASE	WHEN	@intFinalCurrencyId = @intCurrencyId	THEN 1 
														WHEN	@intFinalCurrencyId <> @intCurrencyId	
														AND		@ysnFinalSubCurrency = 1				THEN 100 
														ELSE	0.01 
												END,
					CD.dblCashPrice			=	(
													dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intBasisUOMId,ISNULL(CD.dblBasis,0)) / 
													CASE	WHEN	@intBasisCurrencyId = @intCurrencyId	THEN 1 
															WHEN	@intBasisCurrencyId <> @intCurrencyId	
															AND		@ysnBasisSubCurrency = 1				THEN 100 
															ELSE	0.01 
													END
												) + 
												(
													CASE WHEN CH.intPricingTypeId = 8 THEN CD.dblRatio ELSE 1 END *
													(
														dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,ISNULL(dblPriceWORollArb,0)) / 
														CASE	WHEN	@intFinalCurrencyId = @intCurrencyId	THEN 1 
																WHEN	@intFinalCurrencyId <> @intCurrencyId	
																AND		@ysnFinalSubCurrency = 1				THEN 100 
																ELSE	0.01 
														END									
													) 
												),	
					CD.dblTotalCost			=	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity) * 
												(	
													(
														dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intBasisUOMId,ISNULL(CD.dblBasis,0)) / 
														CASE	WHEN	@intBasisCurrencyId = @intCurrencyId	THEN 1 
																WHEN	@intBasisCurrencyId <> @intCurrencyId	
																AND		@ysnBasisSubCurrency = 1				THEN 100 
																ELSE	0.01 
														END
													) + 
													(
														CASE WHEN CH.intPricingTypeId = 8 THEN CD.dblRatio ELSE 1 END *
														(
															dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,ISNULL(dblPriceWORollArb,0))  / 
															CASE	WHEN	@intFinalCurrencyId = @intCurrencyId	THEN 1 
																	WHEN	@intFinalCurrencyId <> @intCurrencyId	
																	AND		@ysnFinalSubCurrency = 1				THEN 100 
																	ELSE	0.01 
															END
														)
													)
												)/
												CASE WHEN ISNULL(CY.ysnSubCurrency,0) = 0 THEN 1 ELSE CY.intCent END,	
					CD.intConcurrencyId		=	CD.intConcurrencyId + 1,
					CD.intContractStatusId	=	CASE WHEN CD.dblBalance = 0 AND ISNULL(@ysnUnlimitedQuantity,0) = 0 THEN 5 ELSE CD.intContractStatusId END
			FROM	tblCTContractDetail	CD
			JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
			JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID = CD.intCurrencyId
			JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId OR CD.intSplitFromId = PF.intContractDetailId
			AND EXISTS(SELECT * FROM tblCTPriceFixation WHERE intContractDetailId = ISNULL(CD.intContractDetailId,0))
			WHERE	PF.intPriceFixationId	=	@intPriceFixationId

			IF	@ysnMultiplePriceFixation = 1
			BEGIN
				UPDATE	CH
				SET		CH.dblFutures			=	dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,ISNULL(dblPriceWORollArb,0)),
						CH.intConcurrencyId		=	CH.intConcurrencyId + 1
				FROM	tblCTContractHeader		CH
				JOIN	tblCTPriceFixation		PF	ON	CH.intContractHeaderId = PF.intContractHeaderId
				WHERE	PF.intPriceFixationId	=	@intPriceFixationId
			END
		END
		ELSE
		BEGIN
			UPDATE	CD
			SET		CD.intPricingTypeId		=	CASE WHEN CH.intPricingTypeId <> 8 THEN 2 ELSE 8 END,
					CD.dblFutures			=	NULL,
					CD.dblCashPrice			=	NULL,	
					CD.dblTotalCost			=	NULL,
					CD.intConcurrencyId		=	CD.intConcurrencyId + 1
			FROM	tblCTContractDetail	CD
			JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
			JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId OR CD.intSplitFromId = PF.intContractDetailId
			AND EXISTS(SELECT * FROM tblCTPriceFixation WHERE intContractDetailId = ISNULL(CD.intContractDetailId,0))
			WHERE	PF.intPriceFixationId	=	@intPriceFixationId

			IF	@ysnMultiplePriceFixation = 1
			BEGIN
				UPDATE	CH
				SET		CH.dblFutures			=	NULL,
						CH.intConcurrencyId		=	CH.intConcurrencyId + 1
				FROM	tblCTContractHeader		CH
				JOIN	tblCTPriceFixation		PF	ON	CH.intContractHeaderId = PF.intContractHeaderId
				WHERE	PF.intPriceFixationId	=	@intPriceFixationId
			END
		END

		SELECT @intPricingTypeId = intPricingTypeId, @dblCashPrice = dblCashPrice FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
		
		EXEC	uspCTSequencePriceChanged @intContractDetailId, @intUserId, 'Price Contract', 0

		EXEC	uspCTCreateDetailHistory	@intContractHeaderId,@intContractDetailId
		
		/*CT-3569 - this will create amendment for newly added sequence from partial pricing SPLIT function.*/
		  if (ISNULL(@ysnSplit,0) = 1 )
		  begin
				INSERT INTO tblCTSequenceAmendmentLog  
					(  
					  intSequenceHistoryId  
					 ,dtmHistoryCreated   
					 ,intContractHeaderId   
					 ,intContractDetailId  
					 ,intAmendmentApprovalId  
					 ,strItemChanged    
					 ,strOldValue       
					 ,strNewValue  
					 ,intConcurrencyId      
					)  
					  SELECT   
					  intSequenceHistoryId   = NULL  
					 ,dtmHistoryCreated   = GETDATE()  
					 ,intContractHeaderId   = CH.intContractHeaderId  
					 ,intContractDetailId   = CD.intContractDetailId  
					 ,intAmendmentApprovalId = 11
					 ,strItemChanged    = 'Quantity'  
					 ,strOldValue     =  0  
					 ,strNewValue        =  CD.dblQuantity  
					 ,intConcurrencyId    =  1   
					 FROM   
					 tblCTContractDetail CD
					 JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId  
					 LEFT JOIN tblSMUserSecurityRequireApprovalFor RAF ON RAF.intEntityUserSecurityId = CH.intLastModifiedById  
					 WHERE (  
					  ISNULL(CH.ysnPrinted, 0) = 1  
					  OR ISNULL(CH.ysnSigned, 0) = 1  
					  )  
					AND CD.intContractHeaderId = @intContractHeaderId
					AND CD.intContractDetailId not in (select distinct intContractDetailId from tblCTSequenceAmendmentLog where intContractHeaderId = CD.intContractHeaderId)
		  end
		/*End of CT-3569*/
		
				INSERT INTO tblCTSequenceAmendmentLog
				(
					 intSequenceHistoryId
					,dtmHistoryCreated	
					,intContractHeaderId	
					,intContractDetailId
					,intAmendmentApprovalId
					,strItemChanged		
					,strOldValue		  	
					,strNewValue
					,intConcurrencyId				
				)
			   SELECT 
			   intSequenceHistoryId   = NULL
			  ,dtmHistoryCreated	  = GETDATE()
			  ,intContractHeaderId	  = @intContractHeaderId
			  ,intContractDetailId	  = @intContractDetailId
			  ,intAmendmentApprovalId = 1
			  ,strItemChanged		  = CASE WHEN PFD.dblQuantity <> CD.dblQuantity THEN 'Partial Price Qty' ELSE 'Full Price Qty' END
			  --,strOldValue			  =  0
			  ,strOldValue			  =  (
											case
											when PFD.dblQuantity <> CD.dblQuantity
											then
												isnull(
													(
														select
															top 1 strNewValue
														from
															tblCTSequenceAmendmentLog
														where
															intContractHeaderId = @intContractHeaderId
															and intContractDetailId = @intContractDetailId
															and strItemChanged = 'Partial Price Qty'
														order by
															intSequenceAmendmentLogId desc
													),
												'0')
											else
												isnull(
													(
														select
															top 1 strNewValue
														from
															tblCTSequenceAmendmentLog
														where
															intContractHeaderId = @intContractHeaderId
															and intContractDetailId = @intContractDetailId
															and strItemChanged = 'Full Price Qty'
														order by
															intSequenceAmendmentLogId desc
													),
												'0')
											end
										 )
			  ,strNewValue		      =  PFD.dblQuantity
			  ,intConcurrencyId		  =  1 
			  FROM 
			  tblCTPriceFixationDetail PFD
			  JOIN tblCTPriceFixation PF ON PF.intPriceFixationId = PFD.intPriceFixationId
			  JOIN tblCTContractDetail CD ON CD.intContractDetailId = PF.intContractDetailId
			  JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			  LEFT JOIN tblSMUserSecurityRequireApprovalFor RAF ON RAF.intEntityUserSecurityId = CH.intLastModifiedById
			  WHERE (
						ISNULL(CH.ysnPrinted, 0) = 1
						OR ISNULL(CH.ysnSigned, 0) = 1
						)
					AND CD.intContractDetailId = @intContractDetailId
           UNION

			  SELECT 
			  intSequenceHistoryId   = NULL
			 ,dtmHistoryCreated	  = GETDATE()
			 ,intContractHeaderId	  = @intContractHeaderId
			 ,intContractDetailId	  = @intContractDetailId
			 ,intAmendmentApprovalId = 1
			 ,strItemChanged		  = CASE WHEN PFD.dblQuantity <> CD.dblQuantity THEN 'Partial Price Fixation' ELSE 'Full Price Fixation' END
			 --,strOldValue			  =  0
			 ,strOldValue			  =  (
											case
											when PFD.dblQuantity <> CD.dblQuantity
											then
												isnull(
													(
														select
															top 1 strNewValue
														from
															tblCTSequenceAmendmentLog
														where
															intContractHeaderId = @intContractHeaderId
															and intContractDetailId = @intContractDetailId
															and strItemChanged = 'Partial Price Fixation'
														order by
															intSequenceAmendmentLogId desc
													),
												'0')
											else
												isnull(
													(
														select
															top 1 strNewValue
														from
															tblCTSequenceAmendmentLog
														where
															intContractHeaderId = @intContractHeaderId
															and intContractDetailId = @intContractDetailId
															and strItemChanged = 'Full Price Fixation'
														order by
															intSequenceAmendmentLogId desc
													),
												'0')
											end
										 )
			 ,strNewValue		      =  PFD.dblFutures
			 ,intConcurrencyId		  =  1 
			 FROM 
			 tblCTPriceFixationDetail PFD
			 JOIN tblCTPriceFixation PF ON PF.intPriceFixationId = PFD.intPriceFixationId
			 JOIN tblCTContractDetail CD ON CD.intContractDetailId = PF.intContractDetailId
			 JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			 LEFT JOIN tblSMUserSecurityRequireApprovalFor RAF ON RAF.intEntityUserSecurityId = CH.intLastModifiedById
			 WHERE (
					ISNULL(CH.ysnPrinted, 0) = 1
					OR ISNULL(CH.ysnSigned, 0) = 1
					)
				AND CD.intContractDetailId = @intContractDetailId

		
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