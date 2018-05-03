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
			@dblTolerance				NUMERIC(18,6) = 0.0001

	IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
	BEGIN
		RAISERROR('Sequence is deleted by other user.',16,1)
	END 
	
	SELECT	@dblQuantity				=		CASE WHEN ISNULL(ysnLoad,0) = 0 THEN dblDetailQuantity ELSE ISNULL(intNoOfLoad,0) END,
			@dblScheduleQty				=		ISNULL(dblScheduleQty,0),
			@dblBalance					=		ISNULL(dblBalance,0),
			@dblAvailable				=		ISNULL(dblBalance,0) - ISNULL(dblScheduleQty,0),
			@intCommodityUnitMeasureId	=		intCommodityUnitMeasureId,
			@intItemUOMId				=		intItemUOMId,
			@intItemId					=		intItemId,
			@intContractHeaderId		=		intContractHeaderId,
			@ysnLoad					=		ysnLoad 
	FROM	vyuCTContractDetailView
	WHERE	intContractDetailId = @intContractDetailId
	
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
	SET		dblQuantity			=	CASE  WHEN ISNULL(@ysnLoad,0) = 0 THEN @dblNewQuantity ELSE dblQuantity END,
			intNoOfLoad			=	CASE  WHEN ISNULL(@ysnLoad,0) = 0 THEN intNoOfLoad ELSE @dblNewQuantity END,
			dblNetWeight		=	dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId,intNetWeightUOMId,@dblNewQuantity),
			intConcurrencyId	=	intConcurrencyId + 1
	WHERE	intContractDetailId =	@intContractDetailId
	

	EXEC	uspCTCreateSequenceUsageHistory 
			@intContractDetailId	=	@intContractDetailId,
			@strScreenName			=	@strScreenName,
			@intExternalId			=	@intExternalId,
			@strFieldName			=	'Quantity',
			@dblOldValue			=	@dblQuantity,
			@dblTransactionQuantity =	@dblQuantityToUpdate,
			@dblNewValue			=	@dblNewQuantity,	
			@intUserId				=	@intUserId

	SET		@dblBalanceToUpdate		=	@dblQuantityToUpdate * -1

	EXEC	uspCTUpdateSequenceBalance
			@intContractDetailId	=	@intContractDetailId,
			@dblQuantityToUpdate	=	@dblBalanceToUpdate,
			@intUserId				=	@intUserId,
			@intExternalId			=	@intExternalId,
			@strScreenName			=	@strScreenName

	SELECT	@IntFromUnitMeasureId = intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = @intItemUOMId
	SELECT	@intToUnitMeasureId = intUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityUnitMeasureId = @intCommodityUnitMeasureId

	SELECT	@dblQuantityToUpdate = dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@IntFromUnitMeasureId,@intToUnitMeasureId,@dblQuantityToUpdate)

	IF @dblQuantityToUpdate = NULL
	BEGIN
		RAISERROR('UOM configured in the header not available in the sequence.',16,1)
	END

	UPDATE	tblCTContractHeader
	SET		dblQuantity			=	dblQuantity + @dblQuantityToUpdate,
			intConcurrencyId	=	intConcurrencyId + 1
	WHERE	intContractHeaderId	=	@intContractHeaderId
	
	EXEC	uspCTCreateDetailHistory	NULL,@intContractDetailId
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO