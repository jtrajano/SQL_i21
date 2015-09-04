CREATE PROCEDURE [dbo].[uspCTPriceFixationSave]
	
	@intPriceFixationId INT,
	@strAction			NVARCHAR(50)
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@intContractDetailId	INT,
			@dblCashPrice			NUMERIC(6,4),
			@intTypeRef				INT,
			@intNewFutureMonthId	INT,
			@intNewFutureMarketId	INT,
			@intLotsUnfixed			INT

	SELECT	@intLotsUnfixed = ISNULL(intTotalLots,0) - ISNULL(intLotsFixed,0)
	FROM	tblCTPriceFixation
	WHERE	intPriceFixationId = @intPriceFixationId

	IF @strAction = 'Delete'
	BEGIN
		UPDATE	CD
		SET		CD.dblBasis				=	ISNULL(PF.dblOriginalBasis,0),
				CD.intFutureMarketId	=	PF.intOriginalFutureMarketId,
				CD.intFutureMonthId		=	PF.intOriginalFutureMonthId,
				CD.intConcurrencyId		=	CD.intConcurrencyId + 1
		FROM	tblCTContractDetail	CD
		JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId
		
		UPDATE	CD
		SET		CD.intPricingTypeId		=	2,
				CD.dblFutures			=	NULL,
				CD.dblCashPrice			=	NULL,	
				CD.intConcurrencyId		=	CD.intConcurrencyId + 1
		FROM	tblCTContractDetail	CD
		JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId

		RETURN
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
		SET		CD.dblBasis				=	ISNULL(PF.dblOriginalBasis,0) + ISNULL(dblRollArb,0),
				CD.intFutureMarketId	=	@intNewFutureMarketId,
				CD.intFutureMonthId		=	@intNewFutureMonthId,
				CD.intConcurrencyId		=	CD.intConcurrencyId + 1
		FROM	tblCTContractDetail	CD
		JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId
	END
	ELSE
	BEGIN
		UPDATE	CD
		SET		CD.dblBasis				=	ISNULL(PF.dblOriginalBasis,0) + ISNULL(dblRollArb,0),
				CD.intFutureMarketId	=	PF.intOriginalFutureMarketId,
				CD.intFutureMonthId		=	PF.intOriginalFutureMonthId,
				CD.intConcurrencyId		=	CD.intConcurrencyId + 1
		FROM	tblCTContractDetail	CD
		JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId
	END

	IF	@intLotsUnfixed = 0
	BEGIN
		UPDATE	CD
		SET		CD.intPricingTypeId		=	1,
				CD.dblFutures			=	ISNULL(dblPriceWORollArb,0),
				CD.dblCashPrice			=	CD.dblBasis + ISNULL(dblPriceWORollArb,0),	
				CD.intConcurrencyId		=	CD.intConcurrencyId + 1
		FROM	tblCTContractDetail	CD
		JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId
	END
	ELSE
	BEGIN
		UPDATE	CD
		SET		CD.intPricingTypeId		=	2,
				CD.dblFutures			=	NULL,
				CD.dblCashPrice			=	NULL,	
				CD.intConcurrencyId		=	CD.intConcurrencyId + 1
		FROM	tblCTContractDetail	CD
		JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO