﻿CREATE PROCEDURE [dbo].[uspCTPriceFixationSave]
	
	@intPriceFixationId INT,
	@strAction			NVARCHAR(50),
	@intUserId			INT,
	@ysnSaveContract	BIT = 0,
	@dtmLocalDate		DATETIME = NULL
	
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
			@ysnSeqSubCurrency			BIT,
			@contractDetails 			AS [dbo].[ContractDetailTable],
			@ysnPricingAsAmendment		BIT = 1,
			@strXML nvarchar(max),
			@ysnEnableDerivativeInArbitrage BIT = 0,
			@ysnPriceImpact bit = 0,
			@intContractTypeId int,
			@intSpreadArbitrageId int,
			@dblTotalSpread numeric(18,6),
			@intSpreadUOMId int,
			@ysnEnableFXFieldInContractPricing BIT = 0,
			@dblFixationFX numeric(18,6),
			@intMainCurrencyId int,
			@ysnApplyFuturesFromPricing bit = 0
			;

	SET		@ysnMultiplePriceFixation = 0

	SELECT	@dblLotsUnfixed			=	ISNULL([dblTotalLots],0) - ISNULL([dblLotsFixed],0),
			@intContractDetailId	=	intContractDetailId,
			@intContractHeaderId	=	intContractHeaderId,
			@intFinalPriceUOMId		=	PC.intFinalPriceUOMId,
			@ysnSplit				=	ysnSplit,
			@dblTotalLots			=	[dblTotalLots],
			@intFinalCurrencyId		=	PC.intFinalCurrencyId,
			@ysnFinalSubCurrency	=	CY.ysnSubCurrency,
			@intPriceContractId		=	PF.intPriceContractId,
			@dblFixationFX			=	PF.dblFX
	FROM	tblCTPriceFixation		PF  WITH (UPDLOCK)
	JOIN	tblCTPriceContract		PC	ON	PC.intPriceContractId	=	PF.intPriceContractId	LEFT 
	JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID		=	PC.intFinalCurrencyId
	WHERE	intPriceFixationId		=	@intPriceFixationId

	if exists (
		select
			top 1 1
		from
			tblCTContractDetail cd
		where
			cd.intContractStatusId = 3
			and cd.intContractDetailId = @intContractDetailId
	)
	begin
		RAISERROR ('Cancelled sequences cannot be priced.',18,1,'WITH NOWAIT');
	end

	SELECT	@dblTotalPFDetailNoOfLots	=	SUM([dblNoOfLots]),
			@dblTotalPFDetailQuantiy	=	SUM(dblQuantity)
	FROM	tblCTPriceFixationDetail
	WHERE	intPriceFixationId		=	@intPriceFixationId

	SELECT	@ysnPartialPricing = ysnPartialPricing, @strPricingQuantity = strPricingQuantity, @ysnPricingAsAmendment = ysnPricingAsAmendment,@ysnEnableDerivativeInArbitrage = ysnEnableDerivativeInArbitrage, @ysnEnableFXFieldInContractPricing = ysnEnableFXFieldInContractPricing  FROM tblCTCompanyPreference

	declare @intDWGIdId int
			,@ysnDestinationWeightsAndGrades bit;

	select @intDWGIdId = intWeightGradeId from tblCTWeightGrade where strWhereFinalized = 'Destination';
		
	select
		@ysnDestinationWeightsAndGrades = (case when ch.intContractTypeId = 2 and (ch.intWeightId = @intDWGIdId or ch.intGradeId = @intDWGIdId) then 1 else 0 end)
		,@intMainCurrencyId = cu.intMainCurrencyId
		,@ysnApplyFuturesFromPricing = case when @ysnEnableFXFieldInContractPricing = 1 and @intFinalCurrencyId <> cd.intCurrencyId and @intFinalCurrencyId <> isnull(cu.intMainCurrencyId,0) then 1 else 0 end
		,@ysnUnlimitedQuantity = ch.ysnUnlimitedQuantity
		,@intContractTypeId = ch.intContractTypeId
		,@strCommodityDescription = cy.strDescription
		,@intCommodityId = ch.intCommodityId
	from
		tblCTContractDetail cd
		inner join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
		inner join tblSMCurrency cu on cu.intCurrencyID = cd.intCurrencyId
		join tblICCommodity cy on cy.intCommodityId = ch.intCommodityId
	where
		cd.intContractDetailId = @intContractDetailId

	IF ISNULL(@intContractDetailId,0) > 0
	BEGIN
		ProcessContractDetail:

		SELECT	
				@intPriceItemUOMId			=	CD.intPriceItemUOMId,
				@intPricingTypeId			=	CD.intPricingTypeId,
				@dblQuantity				=	CD.dblQuantity,
				@intBasisUOMId				=	BM.intCommodityUnitMeasureId,
				@intCurrencyId				=	CD.intCurrencyId,
				@intBasisCurrencyId			=	CD.intBasisCurrencyId,
				@ysnBasisSubCurrency		=	AY.ysnSubCurrency,
				@ysnSeqSubCurrency			=	SY.ysnSubCurrency

		FROM	tblCTContractDetail			CD 
   LEFT JOIN	tblICItemUOM				BU	ON	BU.intItemUOMId			=	CD.intBasisUOMId
   LEFT JOIN	tblICCommodityUnitMeasure	BM	ON	BM.intCommodityId		=	@intCommodityId
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

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICCommodityUnitMeasure WHERE intCommodityId = @intCommodityId AND intUnitMeasureId = @intUnitMeasureId)
		BEGIN
			SET @ErrMsg = @strUnitMeasure + ' not configured for the commodity ' + @strCommodityDescription + '.'
			RAISERROR(@ErrMsg,16,1)
		END

		SELECT	@intPriceCommodityUOMId = intCommodityUnitMeasureId 
		FROM	tblICCommodityUnitMeasure 
		WHERE	intCommodityId		=	@intCommodityId 
		AND		intUnitMeasureId	=	@intUnitMeasureId

		IF @intPricingTypeId IN (2,8,3) AND isnull(@strAction,'') <> 'Delete'
		BEGIN
			UPDATE tblCTContractDetail SET dblOriginalBasis = dblBasis WHERE intContractDetailId = @intContractDetailId
		END

		IF @strAction = 'Delete'
		BEGIN

			UPDATE	CD
			SET		CD.dblBasis				=	CASE WHEN CH.intPricingTypeId = 3 THEN NULL ELSE ISNULL(CD.dblOriginalBasis,0) END,
					CD.dblFreightBasisBase	=	CASE WHEN CH.intPricingTypeId = 3 THEN NULL ELSE ISNULL(CD.dblFreightBasisBase,0) END,
					CD.intPricingTypeId		=	CASE WHEN CH.intPricingTypeId = 8 THEN 8 WHEN CH.intPricingTypeId = 3 THEN 3 ELSE 2 END,
					CD.dblFutures			=	CASE WHEN CH.intPricingTypeId = 3 THEN CD.dblFutures ELSE null END,
					CD.dblCashPrice			=	NULL,
					CD.dblTotalCost			=	NULL,
					CD.intConcurrencyId		=	CD.intConcurrencyId + 1,
					CD.intContractStatusId	=	case when CD.intContractStatusId = 5 and @ysnDestinationWeightsAndGrades = 0 then 1 else CD.intContractStatusId end
			FROM	tblCTContractDetail	CD
			JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
			JOIN	tblCTPriceFixation	PF	ON	PF.intContractDetailId IN (CD.intContractDetailId, CD.intSplitFromId)
			AND EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = CD.intContractDetailId)
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

			UPDATE tblCTPriceFixationDetail SET ysnToBeDeleted = 1
			WHERE  intPriceFixationId = @intPriceFixationId

			EXEC uspCTLogSummary @intContractHeaderId 	= 	@intContractHeaderId,
								@intContractDetailId 	= 	@intContractDetailId,
								@strSource			 	= 	'Pricing',
								@strProcess		 		= 	'Price Delete',
								@contractDetail 		= 	@contractDetails,
								@intUserId				= 	@intUserId

			EXEC	uspCTSequencePriceChanged @intContractDetailId, @intUserId, 'Price Contract', 1, @dtmLocalDate

			UPDATE tblCTContractDetail SET intSplitFromId = NULL WHERE intSplitFromId = @intContractDetailId

			EXEC	uspCTCreateDetailHistory	@intContractHeaderId	= @intContractHeaderId, 
												@intContractDetailId 	= @intContractDetailId, 
												@strSource 			 	= 'Pricing-Old',
												@strProcess 			= 'Price Delete',
												@intUserId				= @intUserId

			select @strXML = '<rows><row><intContractDetailId>' + convert(nvarchar(20),@intContractDetailId) + '</intContractDetailId></row></rows>';

			exec uspCTProcessTFLogs
				@strXML = @strXML,
				@intUserId = @intUserId

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

			DECLARE @_dblNoOfLots NUMERIC(18,6)
			SELECT _dblNoOfLotsv = SUM([dblNoOfLots]) FROM tblCTPriceFixationDetail WHERE intPriceFixationDetailId = @intFirstPFDetailId

			UPDATE	tblCTContractDetail	 
			SET		dblNoOfLots				=	 @_dblNoOfLots
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

		IF EXISTS(SELECT TOP 1 1 FROM tblCTSpreadArbitrage WITH (UPDLOCK) WHERE intPriceFixationId = @intPriceFixationId)
		BEGIN

			if (@ysnEnableDerivativeInArbitrage = 1)
			begin
				if exists (select top 1 1 from tblCTSpreadArbitrage where intPriceFixationId = @intPriceFixationId and strTradeType = 'Arbitrage' and ysnPriceImpact = 1)
				begin
					declare @dblArbitrageFX numeric(18,6)
						,@leg nvarchar(10) = 'Sell';
					if (@intContractTypeId = 2)
					begin
						select @leg = 'Buy';
					end
					
					select @ysnPriceImpact = 1;

					SELECT	@intSpreadArbitrageId = intSpreadArbitrageId, @dblTotalSpread = dblTotalSpread,@intSpreadUOMId = intSpreadUOMId,@intFinalCurrencyId = intCurrencyId,@dblArbitrageFX=dblFX,@intMarketCurrencyId = intCurrencyId
					FROM	tblCTSpreadArbitrage 
					WHERE	intPriceFixationId		=	@intPriceFixationId
					and strTradeType = 'Arbitrage'
					and strBuySell = @leg

					SELECT	@dblArbitrageFX=dblFX
					FROM	tblCTSpreadArbitrage 
					WHERE	intPriceFixationId		=	@intPriceFixationId
					and strTradeType = 'Arbitrage'
					and strBuySell = case when @leg = 'Buy' then 'Sell' else 'Buy' end;

					SELECT  @intNewFutureMonthId	=	intNewFutureMonthId,
							@intNewFutureMarketId	=	intNewFutureMarketId
					FROM	tblCTSpreadArbitrage 
					WHERE	intSpreadArbitrageId = @intSpreadArbitrageId

					SELECT	@intMarketUnitMeasureId = intUnitMeasureId
					FROM	tblRKFutureMarket 
					WHERE	intFutureMarketId = @intNewFutureMarketId

					SELECT	@intFinalPriceUOMId		=	intCommodityUnitMeasureId,
							@intPriceCommodityUOMId	=	intCommodityUnitMeasureId
					FROM	tblICCommodityUnitMeasure 
					WHERE	intCommodityId		=	@intCommodityId 
					AND		intUnitMeasureId	=	@intMarketUnitMeasureId

					declare @fromCurrencyId int, @toCurrencyId int, @toSubCurrency bit, @dblExRate numeric(18,6);
					select @fromCurrencyId = case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyID end from tblSMCurrency where intCurrencyID = @intCurrencyId
					select @toCurrencyId = case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyID end, @toSubCurrency = isnull(ysnSubCurrency,0) from tblSMCurrency where intCurrencyID = @intFinalCurrencyId

					UPDATE	FD
					SET		dblBasis		=	(dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,@intFinalPriceUOMId,FD.dblBasis) * @dblArbitrageFX) / 
														CASE
														WHEN @toSubCurrency = 1
														THEN 100 
														ELSE 1
														END,
							dblFutures		=	(dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,@intFinalPriceUOMId,FD.dblFixationPrice) * @dblArbitrageFX) / 
														CASE
														WHEN @toSubCurrency = 1
														THEN 100 
														ELSE 1 
														END,
							dblFixationPrice =	(dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,@intFinalPriceUOMId,FD.dblFixationPrice) * @dblArbitrageFX) / 
														CASE
														WHEN @toSubCurrency = 1
														THEN 100 
														ELSE 1 
														END,
							dblFinalPrice	=	((dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,@intFinalPriceUOMId,FD.dblFixationPrice) * @dblArbitrageFX) / 
														CASE
														WHEN @toSubCurrency = 1
														THEN 100 
														ELSE 1
														END) + 
															(dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,@intFinalPriceUOMId,FD.dblBasis) * @dblArbitrageFX) / 
																CASE
																WHEN @toSubCurrency = 1
																THEN 100 
																ELSE 1
																END	
														 + PF.dblRollArb,
							dblCashPrice	=	((dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,@intFinalPriceUOMId,FD.dblFixationPrice) * @dblArbitrageFX) / 
														CASE
														WHEN @toSubCurrency = 1
														THEN 100 
														ELSE 1
														END) + 
															(dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,@intFinalPriceUOMId,FD.dblBasis) * @dblArbitrageFX) / 
																CASE
																WHEN @toSubCurrency = 1
																THEN 100 
																ELSE 1
																END	
														 + PF.dblRollArb
					FROM	tblCTPriceFixation			PF 
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
			
					UPDATE	CD
					SET		CD.dblBasis				=	(
															dbo.fnCTConvertQuantityToTargetCommodityUOM(@intBasisUOMId,@intFinalPriceUOMId,(ISNULL(CD.dblOriginalBasis,ISNULL(CD.dblBasis,0)) + (dbo.fnCTConvertQuantityToTargetCommodityUOM(@intSpreadUOMId,@intBasisUOMId,ISNULL(@dblTotalSpread,0)) / @dblArbitrageFX))) / 
															CASE	WHEN	@intBasisCurrencyId = @intCurrencyId	THEN 1 
																	WHEN	@intBasisCurrencyId <> @intCurrencyId	
																	AND		@ysnBasisSubCurrency = 1				THEN 100 
																	ELSE	1
															END
														),
							CD.intFutureMarketId	=	@intNewFutureMarketId,
							CD.intFutureMonthId		=	@intNewFutureMonthId,
							CD.intConcurrencyId		=	CD.intConcurrencyId + 1,
							CD.intCurrencyId		=	@intMarketCurrencyId,
							CD.intPriceItemUOMId	=	(SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId = CD.intItemId AND intUnitMeasureId = @intMarketUnitMeasureId)
					FROM	tblCTContractDetail	CD
					JOIN	tblCTPriceFixation	PF	ON	PF.intContractDetailId IN (CD.intContractDetailId, CD.intSplitFromId)
					AND EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = ISNULL(CD.intContractDetailId,0))
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
				end
			end
			else
			begin
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
													),
						CD.intFutureMarketId	=	@intNewFutureMarketId,
						CD.intFutureMonthId		=	@intNewFutureMonthId,
						CD.intConcurrencyId		=	CD.intConcurrencyId + 1,
						CD.intCurrencyId		=	@intMarketCurrencyId,
						CD.intPriceItemUOMId	=	(SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId = CD.intItemId AND intUnitMeasureId = @intMarketUnitMeasureId)
				FROM	tblCTContractDetail	CD
				JOIN	tblCTPriceFixation	PF	ON	PF.intContractDetailId IN (CD.intContractDetailId, CD.intSplitFromId)
				AND EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = ISNULL(CD.intContractDetailId,0))
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
			end
		

		END
		ELSE
		BEGIN
			UPDATE	CD
			SET		CD.dblBasis				=	ISNULL(CD.dblOriginalBasis,0) + ISNULL(dblRollArb,0),
					CD.intFutureMarketId	=	CD.intFutureMarketId,
					CD.intFutureMonthId		=	CD.intFutureMonthId,
					CD.intConcurrencyId		=	CD.intConcurrencyId + 1
			FROM	tblCTContractDetail	CD WITH (ROWLOCK) 
			JOIN	tblCTPriceFixation	PF	ON	PF.intContractDetailId IN (CD.intSplitFromId, CD.intContractDetailId)
			AND EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = CD.intContractDetailId)
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

			if (@ysnEnableDerivativeInArbitrage = 1 and @ysnPriceImpact = 1)
			begin
			
				select @toCurrencyId = case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyID end, @toSubCurrency = isnull(ysnSubCurrency,0) from tblSMCurrency where intCurrencyID = @intFinalCurrencyId

				UPDATE	CD
				SET		CD.intPricingTypeId		=	1,
						CD.dblFutures			=	dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intSpreadUOMId,ISNULL(PF.dblPriceWORollArb,0)) / 
														CASE
														WHEN @toSubCurrency = 1
														THEN 100
														ELSE 1 
														END,
						CD.dblCashPrice			=	(
														(dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intBasisUOMId,ISNULL(CASE WHEN CD.intPricingTypeId = 3 THEN PF.dblOriginalBasis ELSE CD.dblBasis END,0)) * @dblArbitrageFX)/ 
															CASE
															WHEN @toSubCurrency = 1
															THEN 100
															ELSE 1 
															END
													) + 
													(
														CASE WHEN CH.intPricingTypeId = 8 THEN CD.dblRatio ELSE 1 END *
														(
															dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intSpreadUOMId,ISNULL(PF.dblPriceWORollArb,0)) / 
																CASE
																WHEN @toSubCurrency = 1
																THEN 100
																ELSE 1 
																END								
														) 
													),	
						CD.dblTotalCost			=	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity) * 
													(	
														(
															(dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intBasisUOMId,ISNULL(CASE WHEN CD.intPricingTypeId = 3 THEN PF.dblOriginalBasis ELSE CD.dblBasis END,0)) * @dblArbitrageFX)/ 
																CASE
																WHEN @toSubCurrency = 1
																THEN 100
																ELSE 1 
																END
														) + 
														(
															CASE WHEN CH.intPricingTypeId = 8 THEN CD.dblRatio ELSE 1 END *
															(
																dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,ISNULL(dblPriceWORollArb,0))  / 
																	CASE
																	WHEN @toSubCurrency = 1
																	THEN 100
																	ELSE 1 
																	END
															)
														)
													)/
													CASE WHEN ISNULL(CY.ysnSubCurrency,0) = 0 THEN 1 ELSE CY.intCent END,	
						CD.intConcurrencyId		=	CD.intConcurrencyId + 1,
						CD.intContractStatusId	=	CASE WHEN CD.dblBalance = 0 AND ISNULL(@ysnUnlimitedQuantity,0) = 0 and isnull(@ysnDestinationWeightsAndGrades,0) = 0 THEN 5 ELSE CD.intContractStatusId END,
						CD.dblBasis				=	CASE WHEN CD.intPricingTypeId = 3 THEN PF.dblOriginalBasis ELSE CD.dblBasis END,
						CD.dblFreightBasisBase	=	CASE WHEN CD.intPricingTypeId = 3 THEN PF.dblOriginalBasis ELSE CD.dblFreightBasisBase END,
						CD.dblRate	= case when @ysnEnableFXFieldInContractPricing = 1 then @dblFixationFX else CD.dblRate end,
						CD.ysnUseFXPrice	= case when @ysnEnableFXFieldInContractPricing = 1 and isnull(@dblFixationFX,0) <> 0 and isnull(@dblFixationFX,0) <> 1 then 1 else CD.ysnUseFXPrice end
						,CD.dblBudgetPrice = null
						,CD.dblTotalBudget = null
				FROM	tblCTContractDetail	CD WITH (ROWLOCK) 
				JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
				JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID = CD.intCurrencyId
				JOIN	tblCTPriceFixation	PF	ON	PF.intContractDetailId IN (CD.intSplitFromId, CD.intContractDetailId)
				AND EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = CD.intContractDetailId)
				WHERE	PF.intPriceFixationId	=	@intPriceFixationId


				UPDATE CD
				SET dblAmountMinValue = CD.dblTotalCost	- ((CD.dblAmountMinRate / 100.0) *  CD.dblTotalCost),
					dblAmountMaxValue = CD.dblTotalCost	+ ((CD.dblAmountMaxRate / 100.0) *  CD.dblTotalCost)
				FROM tblCTContractDetail	CD WITH (ROWLOCK) 
				JOIN tblCTPriceFixation		PF ON PF.intContractDetailId = CD.intContractDetailId
				where PF.intPriceFixationId = @intPriceFixationId


				exec uspCTUpdateSequenceCostRate
					@intContractDetailId = @intContractDetailId,
					@intUserId = @intUserId

				select @strXML = '<rows><row><intContractDetailId>' + convert(nvarchar(20),@intContractDetailId) + '</intContractDetailId><ysnStatusChange>0</ysnStatusChange></row></rows>';

				exec uspCTProcessTFLogs
					@strXML = @strXML,
					@intUserId = @intUserId

				IF	@ysnMultiplePriceFixation = 1
				BEGIN
					UPDATE	CH
					SET		CH.dblFutures			=	dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,ISNULL(dblPriceWORollArb,0)),
							CH.intConcurrencyId		=	CH.intConcurrencyId + 1
					FROM	tblCTContractHeader		CH
					JOIN	tblCTPriceFixation		PF	ON	CH.intContractHeaderId = PF.intContractHeaderId
					WHERE	PF.intPriceFixationId	=	@intPriceFixationId
				END
			end
			else
			begin

				
				UPDATE	CD
				SET		CD.intPricingTypeId		=	1,
						CD.dblFutures			=	dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,(case when @ysnApplyFuturesFromPricing = 1 then (ISNULL(PF.dblPriceWORollArb,0) / isnull(PF.dblFX,1)) else  ISNULL(dblPriceWORollArb,0) end))  / 
													CASE	WHEN	@intFinalCurrencyId = @intCurrencyId	THEN 1 
															WHEN	@intFinalCurrencyId <> @intCurrencyId	
															AND		@ysnFinalSubCurrency = 1				THEN 100 
															ELSE	1
													END,
						CD.dblCashPrice			=	(
														dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intBasisUOMId,ISNULL(CASE WHEN CD.intPricingTypeId = 3 THEN PF.dblOriginalBasis ELSE CD.dblBasis END,0)) / 
														CASE	WHEN	@intBasisCurrencyId = @intCurrencyId	THEN 1 
																WHEN	@intBasisCurrencyId <> @intCurrencyId	
																AND		@ysnBasisSubCurrency = 1				THEN 100 
																ELSE	1
														END
													) + 
													(
														CASE WHEN CH.intPricingTypeId = 8 THEN CD.dblRatio ELSE 1 END *
														(
															dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,(case when @ysnApplyFuturesFromPricing = 1 then (ISNULL(PF.dblPriceWORollArb,0) / isnull(PF.dblFX,1)) else  ISNULL(dblPriceWORollArb,0) end)) / 
															CASE	WHEN	@intFinalCurrencyId = @intCurrencyId	THEN 1 
																	WHEN	@intFinalCurrencyId <> @intCurrencyId	
																	AND		@ysnFinalSubCurrency = 1				THEN 100 
																	ELSE	1
															END									
														) 
													),	
						CD.dblTotalCost			=	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity) * 
													(	
														(
															dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intBasisUOMId,ISNULL(CASE WHEN CD.intPricingTypeId = 3 THEN PF.dblOriginalBasis ELSE CD.dblBasis END,0)) / 
															CASE	WHEN	@intBasisCurrencyId = @intCurrencyId	THEN 1 
																	WHEN	@intBasisCurrencyId <> @intCurrencyId	
																	AND		@ysnBasisSubCurrency = 1				THEN 100 
																	ELSE	1
															END
														) + 
														(
															CASE WHEN CH.intPricingTypeId = 8 THEN CD.dblRatio ELSE 1 END *
															(
																dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,(case when @ysnApplyFuturesFromPricing = 1 then (ISNULL(PF.dblPriceWORollArb,0) / isnull(PF.dblFX,1)) else  ISNULL(dblPriceWORollArb,0) end))  / 
																CASE	WHEN	@intFinalCurrencyId = @intCurrencyId	THEN 1 
																		WHEN	@intFinalCurrencyId <> @intCurrencyId	
																		AND		@ysnFinalSubCurrency = 1				THEN 100 
																		ELSE	1
																END
															)
														)
													)/
													CASE WHEN ISNULL(CY.ysnSubCurrency,0) = 0 THEN 1 ELSE CY.intCent END,	
						CD.intConcurrencyId		=	CD.intConcurrencyId + 1,
						CD.intContractStatusId	=	CASE WHEN CD.dblBalance = 0 AND ISNULL(@ysnUnlimitedQuantity,0) = 0 and isnull(@ysnDestinationWeightsAndGrades,0) = 0 THEN 5 ELSE CD.intContractStatusId END,
						CD.dblBasis				=	CASE WHEN CD.intPricingTypeId = 3 THEN PF.dblOriginalBasis ELSE CD.dblBasis END,
						CD.dblFreightBasisBase	=	CASE WHEN CD.intPricingTypeId = 3 THEN PF.dblOriginalBasis ELSE CD.dblFreightBasisBase END,
						CD.dblRate	= case when @ysnEnableFXFieldInContractPricing = 1 then @dblFixationFX else CD.dblRate end,
						CD.ysnUseFXPrice	= case when @ysnEnableFXFieldInContractPricing = 1 and isnull(@dblFixationFX,0) <> 0 and isnull(@dblFixationFX,0) <> 1 then 1 else CD.ysnUseFXPrice end
						,CD.dblBudgetPrice = null
						,CD.dblTotalBudget = null
				FROM	tblCTContractDetail	CD WITH (ROWLOCK) 
				JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
				JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID = CD.intCurrencyId
				JOIN	tblCTPriceFixation	PF	ON	PF.intContractDetailId IN ((case when @ysnMultiplePriceFixation = 1 then CD.intSplitFromId else CD.intContractDetailId end), CD.intContractDetailId)
				AND EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = CD.intContractDetailId)
				WHERE	PF.intPriceFixationId	=	@intPriceFixationId

				UPDATE CD
				SET dblAmountMinValue = CD.dblTotalCost	- ((CD.dblAmountMinRate / 100.0) *  CD.dblTotalCost),
					dblAmountMaxValue = CD.dblTotalCost	+ ((CD.dblAmountMaxRate / 100.0) *  CD.dblTotalCost),
					CD.dblFXPrice = (((CD.dblCashPrice * (sUOM.dblUnitQty / fUOM.dblUnitQty)) * tUOM.dblUnitQty)/case when isnull(ICY2.intMainCurrencyId,0) > 0 then 100 else 1 end) * 
					(
						case
						when CD.intCurrencyId = CD.intInvoiceCurrencyId or CD.intCurrencyId = isnull(ICY.intMainCurrencyId,0)
						then 1
						else CD.dblRate
						end
					) *
					(
						case
						when isnull(ICY.intMainCurrencyId,0) > 0
						then 100
						else 1
						end
					)
				FROM tblCTContractDetail	CD WITH (ROWLOCK)
				join tblICItemUOM fUOM on fUOM.intItemUOMId = CD.intPriceItemUOMId
				join tblICItemUOM tUOM on tUOM.intItemUOMId = CD.intFXPriceUOMId
				JOIN tblCTPriceFixation		PF ON PF.intContractDetailId = CD.intContractDetailId
				LEFT JOIN	tblSMCurrency		ICY	ON	ICY.intCurrencyID = CD.intInvoiceCurrencyId
				LEFT JOIN	tblSMCurrency		ICY2	ON	ICY2.intCurrencyID = CD.intCurrencyId
				cross apply (select top 1 *  from tblICItemUOM where ysnStockUnit = 1) sUOM
				where PF.intPriceFixationId = @intPriceFixationId

				exec uspCTUpdateSequenceCostRate
					@intContractDetailId = @intContractDetailId,
					@intUserId = @intUserId

				select @strXML = '<rows><row><intContractDetailId>' + convert(nvarchar(20),@intContractDetailId) + '</intContractDetailId><ysnStatusChange>0</ysnStatusChange></row></rows>';

				IF ISNULL(@strAction, '') = ''
				BEGIN
					exec uspCTProcessTFLogs
						@strXML = @strXML,
						@intUserId = @intUserId
				END

				IF	@ysnMultiplePriceFixation = 1
				BEGIN
					UPDATE	CH
					SET		CH.dblFutures			=	dbo.fnCTConvertQuantityToTargetCommodityUOM(@intPriceCommodityUOMId,@intFinalPriceUOMId,ISNULL(dblPriceWORollArb,0)),
							CH.intConcurrencyId		=	CH.intConcurrencyId + 1
					FROM	tblCTContractHeader		CH
					JOIN	tblCTPriceFixation		PF	ON	CH.intContractHeaderId = PF.intContractHeaderId
					WHERE	PF.intPriceFixationId	=	@intPriceFixationId
				END
				ELSE
				BEGIN
					UPDATE	CH
					SET		CH.intConcurrencyId		=	CH.intConcurrencyId + 1
					FROM	tblCTContractHeader		CH
					JOIN	tblCTPriceFixation		PF	ON	CH.intContractHeaderId = PF.intContractHeaderId
					WHERE	PF.intPriceFixationId	=	@intPriceFixationId
				END
			end
			
			
		END
		ELSE
		BEGIN
			UPDATE	CD
			SET		CD.intPricingTypeId		=	CASE WHEN CH.intPricingTypeId = 8 THEN 8 WHEN CH.intPricingTypeId = 3 THEN 3 ELSE 2 END,
					CD.dblFutures			=	CASE WHEN CH.intPricingTypeId = 3 THEN CD.dblFutures ELSE null END,
					CD.dblCashPrice			=	NULL,	
					CD.dblTotalCost			=	NULL,
					CD.intConcurrencyId		=	CD.intConcurrencyId + 1,
					CD.dblBasis 			=	CASE WHEN CH.intPricingTypeId = 3 THEN null ELSE CD.dblBasis END,
					CD.dblRate	= case when @ysnEnableFXFieldInContractPricing = 1 then @dblFixationFX else CD.dblRate end,
					CD.ysnUseFXPrice	= case when @ysnEnableFXFieldInContractPricing = 1 then 1 else CD.ysnUseFXPrice end,
					CD.dblFXPrice			=	null
			FROM	tblCTContractDetail	CD
			JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
			JOIN	tblCTPriceFixation	PF	ON	PF.intContractDetailId IN (CD.intContractDetailId, CD.intSplitFromId)
			AND EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = CD.intContractDetailId)
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
		
		DECLARE @process NVARCHAR(50)
			, @logProcess NVARCHAR(50)
		SELECT @process = CASE WHEN @ysnSaveContract = 0 THEN 'Price Fixation' ELSE 'Save Contract' END
		SELECT @logProcess = @process + CASE WHEN @strAction = 'Reassign' THEN ' - Reassign' ELSE '' END

		if exists (select top 1 1 from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId and isnull(intPreviousConcurrencyId,0) <> intConcurrencyId)
		begin
			EXEC uspCTLogSummary @intContractHeaderId 	= 	@intContractHeaderId,
								 @intContractDetailId 	= 	@intContractDetailId,
								 @strSource			 	= 	'Pricing',
								 @strProcess		 	= 	@logProcess,
								 @contractDetail 		= 	@contractDetails,
								 @intUserId				= 	@intUserId
		end

		EXEC	uspCTSequencePriceChanged @intContractDetailId, @intUserId, 'Price Contract', 0, @dtmLocalDate

		EXEC	uspCTCreateDetailHistory	@intContractHeaderId	= @intContractHeaderId, 
											@intContractDetailId 	= @intContractDetailId, 
											@strSource				= 'Pricing-Old',
											@strProcess 			= @process,
											@intUserId				= @intUserId
		
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


		if (@ysnPricingAsAmendment = 1)
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
			  ,dtmHistoryCreated	  = GETDATE()
			  ,intContractHeaderId	  = @intContractHeaderId
			  ,intContractDetailId	  = @intContractDetailId
			  ,intAmendmentApprovalId = 1
			  ,strItemChanged		  = CASE WHEN PFD.dblQuantity <> CD.dblQuantity THEN 'Partial Price Qty' ELSE 'Full Price Qty' END
			  --,strOldValue			  =  0
			  ,strOldValue			  =  (
											case
											when PFD.dblQuantity <> CD.dblQuantity then isnull(SALPart.strNewValue,'0')
											else isnull(SALFull.strNewValue,'0')
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
			  OUTER APPLY
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
			  ) SALPart
			  OUTER APPLY
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
			  ) SALFull
			  WHERE 
			  (
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
			 ,strItemChanged		  = 'Cash Price'
			 --,strOldValue			  =  0
			 ,strOldValue			  =  (
											case
											when PFD.dblFinalPrice <> CD.dblCashPrice then isnull(SALPart.strNewValue,'')
											else isnull(SALFull.strNewValue,'')
											end
										 )
			 ,strNewValue		      =  PFD.dblFinalPrice
			 ,intConcurrencyId		  =  1 
			 FROM 
			 tblCTPriceFixationDetail PFD
			 JOIN tblCTPriceFixation PF ON PF.intPriceFixationId = PFD.intPriceFixationId
			 JOIN tblCTContractDetail CD ON CD.intContractDetailId = PF.intContractDetailId
			 JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			 LEFT JOIN tblSMUserSecurityRequireApprovalFor RAF ON RAF.intEntityUserSecurityId = CH.intLastModifiedById
			 OUTER APPLY
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
		 	 ) SALPart
			OUTER APPLY
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
		 	 ) SALFull
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
											when PFD.dblQuantity <> CD.dblQuantity then isnull(SALPart.strNewValue,'0')
											else isnull(SALFull.strNewValue,'0')
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
			 OUTER APPLY
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
		 	 ) SALPart
			OUTER APPLY
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
		 	 ) SALFull
			 WHERE (
					ISNULL(CH.ysnPrinted, 0) = 1
					OR ISNULL(CH.ysnSigned, 0) = 1
					)
				AND CD.intContractDetailId = @intContractDetailId

		end

		
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
