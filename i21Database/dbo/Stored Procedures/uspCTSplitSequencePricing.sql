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
				@strDate					NVARCHAR(100) = CONVERT(NVARCHAR(100),DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())),126),
				@ysnMultiSequencePricing	BIT
				

		SELECT	@dblNoOfLots		=	dblNoOfLots,
				@strContractSeq		=	STR(intContractSeq)
		FROM	tblCTContractDetail
		WHERE	intContractDetailId	=	@intContractDetailId

		SELECT	@intPriceFixationId =	intPriceFixationId 
		FROM	tblCTPriceFixation 
		WHERE	intContractDetailId =	@intContractDetailId

		IF	ISNULL(@intPriceFixationId,0) = 0
		BEGIN
			UPDATE tblCTContractDetail SET intSplitFromId = NULL WHERE intSplitFromId = @intContractDetailId
			RETURN
		END

		IF	NOT EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixationDetail WHERE intPriceFixationId = ISNULL(@intPriceFixationId,0))
		BEGIN
			UPDATE tblCTContractDetail SET intSplitFromId = NULL WHERE intSplitFromId = @intContractDetailId
			RETURN
		END

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblCTContractDetail WHERE intSplitFromId = @intContractDetailId)
			RETURN 

		IF	(SELECT COUNT(*) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId) > 1 AND 
			EXISTS	(SELECT TOP 1 1 FROM tblCTContractDetail WHERE intSplitFromId = @intContractDetailId)
		BEGIN
			SET @ysnMultiSequencePricing = 1
			--RAISERROR(110005,16,1,@strContractSeq,@strContractSeq)
		END

		IF	EXISTS	(SELECT TOP 1 1 FROM tblCTPriceFixation	WHERE intPriceFixationId = @intPriceFixationId AND dblTotalLots <> dblLotsFixed) AND 
			EXISTS	(SELECT TOP 1 1 FROM tblCTContractDetail WHERE intSplitFromId = @intContractDetailId)
		BEGIN
			SET @ysnMultiSequencePricing = 1
			--RAISERROR(110006,16,1,@strContractSeq,@strContractSeq)
		END

		IF(@ysnMultiSequencePricing = 1)
		BEGIN
			RETURN
		END

		IF EXISTS
		(
			SELECT TOP 1 1 FROM tblCTPriceFixation PF
			INNER JOIN tblCTContractDetail CD ON PF.intContractDetailId = CD.intContractDetailId
			WHERE CD.intSplitFromId = @intContractDetailId
		)
		BEGIN
			RETURN
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
		SET		FD.dblNoOfLots			=	CD.dblNoOfLots,
				FD.dblQuantity			=	CD.dblQuantity,
				FD.dblHedgeNoOfLots		=	CASE WHEN FD.ysnHedge = 1 THEN CD.dblNoOfLots ELSE NULL END
		FROM	tblCTPriceFixation			PF 
		JOIN	tblCTPriceFixationDetail	FD	ON	FD.intPriceFixationId	=	PF.intPriceFixationId
		JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId	=	PF.intContractDetailId
		WHERE	FD.intPriceFixationDetailId	=	@intPriceFixationDetailId

		UPDATE  tblRKAssignFuturesToContractSummary
		SET		dblHedgedLots			=	@dblNoOfLots
		WHERE	intContractDetailId		=	@intContractDetailId
		
		UPDATE	tblRKFutOptTransaction 
		SET		dblNoOfContract			=	@dblNoOfLots
		WHERE	intFutOptTransactionId	=	@intFutOptTransactionId

		if (@ysnHedge = 1)
		begin
			 --Insert into Summary Log
			EXEC uspRKSaveDerivativeEntry @intFutOptTransactionId, NULL, @intUserId, 'UPDATE';

			 --Insert into Derivative History
			EXEC uspRKFutOptTransactionHistory @intFutOptTransactionId, NULL, 'Contracts', @intUserId, 'UPDATE' , 0;
		end

		SELECT	@intChildContractDetailId = MIN(intContractDetailId) 
		FROM	tblCTContractDetail 
		WHERE	intSplitFromId			=	@intContractDetailId
		AND intPricingTypeId = 1

		WHILE	ISNULL(@intChildContractDetailId,0) > 0
		BEGIN
				SELECT	@dblChildSeqLots	=	dblNoOfLots,
						@dblChildSeqQty		=	dblQuantity
				FROM	tblCTContractDetail
				WHERE	intContractDetailId	=	@intChildContractDetailId

				select
					@intNewPriceFixationId = pf.intPriceFixationId
				from
					tblCTPriceFixation pf
				where
					pf.intContractDetailId = @intChildContractDetailId

				if (@intNewPriceFixationId is null)
				BEGIN

					SET @XML =	'<root><toUpdate><dblTotalLots>'+STR(@dblChildSeqLots,18,6)+'</dblTotalLots><dblLotsFixed>'+STR(@dblChildSeqLots,18,6)+'</dblLotsFixed>'+
								CASE WHEN @ysnHedge = 1 THEN '<intLotsHedged>'+STR(@dblChildSeqLots)+'</intLotsHedged>' ELSE '' END +
								'<intContractDetailId>'+STR(@intChildContractDetailId)+'</intContractDetailId></toUpdate></root>' 

					EXEC uspCTCreateADuplicateRecord 'tblCTPriceFixation',@intPriceFixationId, @intNewPriceFixationId OUTPUT,@XML
				
				end
				
				IF @ysnHedge = 1
				BEGIN
					SELECT	@intSummaryId = intAssignFuturesToContractSummaryId
					FROM	tblRKAssignFuturesToContractSummary
					WHERE	@intFutOptTransactionId = intFutOptTransactionId
					AND		intContractDetailId	= @intContractDetailId	
					
					EXEC	uspCTGetStartingNumber 'Derivative Entry', @strTradeNo OUTPUT
					SET		@strTradeNo	=	LTRIM(RTRIM(@strTradeNo)) + '-H'
					SET		@XML =	'<root><toUpdate><dblNoOfContract>'+STR(@dblChildSeqLots,18,6)+'</dblNoOfContract>'+
									'<dtmTransactionDate>'+@strDate+'</dtmTransactionDate>'+
									'<dtmFilledDate>'+@strDate+'</dtmFilledDate>'+
									'<strInternalTradeNo>'+@strTradeNo+'</strInternalTradeNo></toUpdate></root>' 

					EXEC uspCTCreateADuplicateRecord 'tblRKFutOptTransaction',@intFutOptTransactionId, @intNewFutOptTransactionId OUTPUT,@XML

					--Insert into Summary Log
					EXEC uspRKSaveDerivativeEntry @intNewFutOptTransactionId, NULL, @intUserId, 'ADD';

					 --Insert into Derivative History
					EXEC uspRKFutOptTransactionHistory @intNewFutOptTransactionId, NULL, 'Contracts', @intUserId, 'ADD' , 0;


					SET @XML =	'<root><toUpdate><dblHedgedLots>'+STR(@dblChildSeqLots,18,6)+'</dblHedgedLots>'+
								'<intFutOptTransactionId>'+STR(@intNewFutOptTransactionId)+'</intFutOptTransactionId>'+
								'<dtmMatchDate>'+@strDate+'</dtmMatchDate>'+
								'<intContractDetailId>'+STR(@intChildContractDetailId)+'</intContractDetailId></toUpdate></root>' 

					EXEC uspCTCreateADuplicateRecord 'tblRKAssignFuturesToContractSummary',@intSummaryId, @intNewSummaryId OUTPUT,@XML
				END

				EXEC	uspCTGetStartingNumber 'Price Fixation Trade No', @strTradeNo OUTPUT
				SET		@XML =	'<root><toUpdate><strTradeNo>'+LTRIM(RTRIM(@strTradeNo))+'</strTradeNo><dblNoOfLots>'+STR(@dblChildSeqLots,18,6)+'</dblNoOfLots>'+
								'<dblQuantity>'+STR(@dblChildSeqQty,18,6)+'</dblQuantity>'+
								--'<dtmFixationDate>'+@strDateWithTime+'</dtmFixationDate>'+
								CASE WHEN @ysnHedge = 1 THEN '<intFutOptTransactionId>'+STR(@intNewFutOptTransactionId)+'</intFutOptTransactionId>' ELSE '' END +
								CASE WHEN @ysnHedge = 1 THEN '<dblHedgeNoOfLots>'+STR(@dblChildSeqLots,18,6)+'</dblHedgeNoOfLots>' ELSE '' END +
								'<intPriceFixationId>'+STR(@intNewPriceFixationId)+'</intPriceFixationId></toUpdate></root>' 
				
				EXEC uspCTCreateADuplicateRecord 'tblCTPriceFixationDetail',@intPriceFixationDetailId, @intNewPFDetailId OUTPUT,@XML

				if exists (select top 1 1 from tblCTCompanyPreference where isnull(ysnEnableAdditionalFieldsOnSliceScreen,0) = 1)
				begin
					declare
						@intCDFutureMonthId int
						,@dblCDBasis numeric(18,6)
						,@dblCDFutures numeric(18,6)
						,@dblCDRatio numeric(18,6)
						,@dblCDCashPrice numeric(18,6)
						,@intCDPriceItemUOMId int
						,@dblCDQuantity numeric(18,6)
						,@intCDItemId int
						,@intCDBasisUOMId int
						,@intCDCurrencyId int

					select
						@intCDFutureMonthId=intFutureMonthId
						,@dblCDBasis=dblBasis
						,@dblCDRatio=dblRatio
						,@dblCDFutures=dblFutures
						,@dblCDCashPrice=dblCashPrice
						,@intCDPriceItemUOMId=intPriceItemUOMId
						,@dblCDQuantity=dblQuantity
						,@intCDItemId = intItemId
						,@intCDBasisUOMId = intBasisUOMId
						,@intCDCurrencyId = intCurrencyId
					from
						tblCTContractDetail
					where
						intContractDetailId = @intChildContractDetailId;

					update
						fd
					set
						fd.intFutureMonthId = @intCDFutureMonthId
						,fd.dblBasis = dbo.fnCTConvertQtyToTargetItemUOM(@intCDBasisUOMId,iuom.intItemUOMId,@dblCDBasis)
						,fd.dblQuantity = @dblCDQuantity
						,fd.dblFutures = dbo.fnCTConvertQtyToTargetItemUOM(@intCDPriceItemUOMId,iuom.intItemUOMId,@dblCDFutures) * (case when xrd.dblRate is not null then xrd.dblRate else 1 end)
						,fd.dblCashPrice = dbo.fnCTConvertQtyToTargetItemUOM(@intCDBasisUOMId,iuom.intItemUOMId,@dblCDBasis) + (dbo.fnCTConvertQtyToTargetItemUOM(@intCDPriceItemUOMId,iuom.intItemUOMId,@dblCDFutures) * (case when xrd.dblRate is not null then xrd.dblRate else 1 end))
					from tblCTPriceFixationDetail fd
					join tblCTPriceFixation pf on pf.intPriceFixationId = fd.intPriceFixationId
					join tblCTPriceContract pc on pc.intPriceContractId = pf.intPriceContractId
					left join tblSMCurrencyExchangeRate xr on xr.intFromCurrencyId = @intCDCurrencyId and xr.intToCurrencyId = pc.intFinalCurrencyId
					left join tblSMCurrencyExchangeRateDetail xrd on xrd.intCurrencyExchangeRateId = xr.intCurrencyExchangeRateId
					join tblICCommodityUnitMeasure cuom on cuom.intCommodityUnitMeasureId = fd.intPricingUOMId
					join tblICItemUOM iuom on iuom.intUnitMeasureId = cuom .intUnitMeasureId and iuom.intItemId = @intCDItemId
					where
						fd.intPriceFixationDetailId = @intNewPFDetailId;

				end

				UPDATE	tblCTContractDetail SET intSplitFromId = NULL WHERE intContractDetailId =@intChildContractDetailId

				SELECT	@intChildContractDetailId = MIN(intContractDetailId), @intNewPriceFixationId = null
				FROM	tblCTContractDetail 
				WHERE	intSplitFromId		=	@intContractDetailId
				AND intPricingTypeId = 1
		END				

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH