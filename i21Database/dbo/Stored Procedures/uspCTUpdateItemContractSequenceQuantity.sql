CREATE PROCEDURE [dbo].[uspCTUpdateItemContractSequenceQuantity]
	@intItemContractDetailId	INT, 
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
			@intItemUOMId				INT,
			@IntFromUnitMeasureId		INT,
			@intToUnitMeasureId			INT,
			@intItemId					INT,
			@intContractHeaderId		INT,
			@dblTolerance				NUMERIC(18,6) = 0.0001,
			@intSequenceUsageHistoryId	INT

	IF NOT EXISTS(SELECT * FROM tblCTItemContractDetail WHERE intItemContractDetailId = @intItemContractDetailId)
	BEGIN
		RAISERROR('Sequence is deleted by other user.',16,1)
	END 
	
	SELECT	@dblQuantity				=		CD.dblContracted,
			@dblScheduleQty				=		CD.dblScheduled,
			@dblBalance					=		CD.dblBalance,
			@dblAvailable				=		CD.dblAvailable,
			@intItemUOMId				=		intItemUOMId,
			@intItemId					=		intItemId,
			@intContractHeaderId		=		CH.intItemContractHeaderId
	FROM	tblCTItemContractDetail		CD
	JOIN	tblCTItemContractHeader		CH	ON	CH.intItemContractHeaderId	=	CD.intItemContractHeaderId 
	WHERE	intItemContractDetailId		=	@intItemContractDetailId
	
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

	UPDATE 	tblCTItemContractDetail
	SET		dblContracted		=	@dblNewQuantity,
			intConcurrencyId	=	intConcurrencyId + 1
	WHERE	intItemContractDetailId =	@intItemContractDetailId

	SET		@dblBalanceToUpdate		=	@dblQuantityToUpdate * -1

	EXEC	uspCTUpdateItemContractSequenceBalance
		@intContractDetailId	=	@intItemContractDetailId,
		@dblQuantityToUpdate	=	@dblBalanceToUpdate,
		@intUserId				=	@intUserId,
		@intExternalId			=	@intExternalId,
		@strScreenName			=	@strScreenName
	
	/*Code here for History*/
	/*
	EXEC	uspCTCreateSequenceUsageHistory 
			@intContractDetailId		=	@intItemContractDetailId,
			@strScreenName				=	@strScreenName,
			@intExternalId				=	@intExternalId,
			@strFieldName				=	'Quantity',
			@dblOldValue				=	@dblQuantity,
			@dblTransactionQuantity		=	@dblQuantityToUpdate,
			@dblNewValue				=	@dblNewQuantity,	
			@intUserId					=	@intUserId,
			@dblBalance					=   @dblQuantityToUpdate,
			@intSequenceUsageHistoryId	=	@intSequenceUsageHistoryId	OUTPUT


	EXEC	uspCTUpdateSequenceBalance
			@intContractDetailId	=	@intItemContractDetailId,
			@dblQuantityToUpdate	=	@dblBalanceToUpdate,
			@intUserId				=	@intUserId,
			@intExternalId			=	@intExternalId,
			@strScreenName			=	@strScreenName
		
	EXEC	uspCTCreateDetailHistory	
	@intContractHeaderId		=	NULL,
    @intContractDetailId		=	@intItemContractDetailId,
	@strComment				    =	NULL,
	@intSequenceUsageHistoryId  =	@intSequenceUsageHistoryId,
	@strSource	 				= 	'Inventory',
	@strProcess 				= 	'Sequence Quantity'

	*/

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO