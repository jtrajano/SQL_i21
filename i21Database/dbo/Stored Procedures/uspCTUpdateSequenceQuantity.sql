CREATE PROCEDURE [dbo].[uspCTUpdateSequenceQuantity]
	@intContractDetailId	INT, 
	@dblQuantityToUpdate	NUMERIC(18,6),
	@intUserId				INT,
	@intExternalId			INT,
	@strScreenName			NVARCHAR(50)
AS

BEGIN TRY
	
	DECLARE @ErrMsg						NVARCHAR(MAX),
			@XML						NVARCHAR(MAX),
			@dblQuantity				NUMERIC(18,6),
			@dblScheduleQty				NUMERIC(18,6),
			@dblBalance					NUMERIC(18,6),
			@dblBalanceToUpdate			NUMERIC(18,6),
			@dblAvailable				NUMERIC(18,6),
			@dblNewQuantity				NUMERIC(18,6),
			@intCommodityUnitMeasureId	INT,
			@intItemUOMId				INT,
			@IntFromUnitMeasureId		INT,
			@intToUnitMeasureId			INT,
			@intItemId					INT,
			@intContractHeaderId		INT,
			@ysnLoad					BIT,
			@dblTolerance				NUMERIC(18,6) = 0.0001,
			@intSequenceUsageHistoryId	INT

	IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
	BEGIN
		RAISERROR('Sequence is deleted by other user.',16,1)
	END 
	
	SELECT	@dblQuantity				=		CASE WHEN ISNULL(ysnLoad,0) = 0 THEN CD.dblQuantity ELSE ISNULL(CD.intNoOfLoad,0) END,
			@dblScheduleQty				=		CASE WHEN ISNULL(ysnLoad,0) = 0 THEN ISNULL(dblScheduleQty,0) ELSE ISNULL(CD.dblScheduleLoad,0) END,
			@dblBalance					=		CASE WHEN ISNULL(ysnLoad,0) = 0 THEN ISNULL(dblBalance,0) ELSE ISNULL(CD.dblBalanceLoad,0) END,
			@dblAvailable				=		CASE WHEN ISNULL(ysnLoad,0) = 0 THEN ISNULL(dblBalance,0) - ISNULL(dblScheduleQty,0) ELSE ISNULL(dblBalanceLoad,0) - ISNULL(dblScheduleLoad,0) END,
			@intCommodityUnitMeasureId	=		CH.intCommodityUOMId,
			@intItemUOMId				=		intItemUOMId,
			@intItemId					=		intItemId,
			@intContractHeaderId		=		CH.intContractHeaderId,
			@ysnLoad					=		ysnLoad 
	FROM	tblCTContractDetail		CD
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId 
	WHERE	intContractDetailId		=	@intContractDetailId
	
	IF ABS(@dblQuantityToUpdate)- @dblAvailable < @dblTolerance AND ABS(@dblQuantityToUpdate)- @dblAvailable >0
	BEGIN
		 SET @dblQuantityToUpdate= - @dblAvailable
	END

	IF	@dblAvailable + @dblQuantityToUpdate < 0
	BEGIN
		SET @ErrMsg = 'Quantity cannot be reduced below '+LTRIM(@dblQuantity - @dblAvailable)+'.'
		RAISERROR(@ErrMsg,16,1)
	END
	
	SELECT	@dblNewQuantity		=	@dblQuantity + @dblQuantityToUpdate

	UPDATE 	tblCTContractDetail
	SET		dblQuantity			=	CASE  WHEN ISNULL(@ysnLoad,0) = 0 THEN @dblNewQuantity ELSE @dblNewQuantity * dblQuantityPerLoad END,
			intNoOfLoad			=	CASE  WHEN ISNULL(@ysnLoad,0) = 0 THEN NULL ELSE @dblNewQuantity END,
			dblNetWeight		=	dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId,intNetWeightUOMId,@dblNewQuantity),
			intConcurrencyId	=	intConcurrencyId + 1
	WHERE	intContractDetailId =	@intContractDetailId
	

	EXEC	uspCTCreateSequenceUsageHistory 
			@intContractDetailId		=	@intContractDetailId,
			@strScreenName				=	@strScreenName,
			@intExternalId				=	@intExternalId,
			@strFieldName				=	'Quantity',
			@dblOldValue				=	@dblQuantity,
			@dblTransactionQuantity		=	@dblQuantityToUpdate,
			@dblNewValue				=	@dblNewQuantity,	
			@intUserId					=	@intUserId,
			@dblBalance					=   @dblQuantityToUpdate,
			@intSequenceUsageHistoryId	=	@intSequenceUsageHistoryId	OUTPUT

	SET		@dblBalanceToUpdate		=	@dblQuantityToUpdate * -1

	EXEC	uspCTUpdateSequenceBalance
			@intContractDetailId	=	@intContractDetailId,
			@dblQuantityToUpdate	=	@dblBalanceToUpdate,
			@intUserId				=	@intUserId,
			@intExternalId			=	@intExternalId,
			@strScreenName			=	@strScreenName

	IF ISNULL(@ysnLoad,0) = 0 
	BEGIN
		SELECT	@IntFromUnitMeasureId = intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = @intItemUOMId
		SELECT	@intToUnitMeasureId = intUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityUnitMeasureId = @intCommodityUnitMeasureId

		SELECT	@dblQuantityToUpdate = dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@IntFromUnitMeasureId,@intToUnitMeasureId,@dblQuantityToUpdate)
	END

	IF @dblQuantityToUpdate = NULL
	BEGIN
		RAISERROR('UOM configured in the header not available in the sequence.',16,1)
	END

	UPDATE	tblCTContractHeader
	SET		dblQuantity			=	CASE  WHEN ISNULL(@ysnLoad,0) = 0 THEN dblQuantity + @dblQuantityToUpdate ELSE (dblQuantity + @dblQuantityToUpdate) * dblQuantityPerLoad END,
			intNoOfLoad			=	CASE  WHEN ISNULL(@ysnLoad,0) = 0 THEN NULL ELSE intNoOfLoad + @dblQuantityToUpdate END,
			intConcurrencyId	=	intConcurrencyId + 1
	WHERE	intContractHeaderId	=	@intContractHeaderId
	
	EXEC	uspCTCreateDetailHistory	
	@intContractHeaderId		=	NULL,
    @intContractDetailId		=	@intContractDetailId,
	@strComment				    =	NULL,
	@intSequenceUsageHistoryId  =	@intSequenceUsageHistoryId,
	@strSource	 				= 	'Inventory',
	@strProcess 				= 	'Update Sequence Quantity',
	@intUserId					= 	@intUserId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO