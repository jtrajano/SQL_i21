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
			@intSequenceUsageHistoryId	INT,
			@dblCurrentContracted		NUMERIC(18,6),
			@dblCurrentScheduled		NUMERIC(18,6),
			@dblCurrentAvailable		NUMERIC(18,6),
			@dblCurrentApplied			NUMERIC(18,6),
			@dblCurrentBalance			NUMERIC(18,6),
			@intContractStatusId		INT,
			@intLineNo					INT,
			@dtmOrigLastDeliveryDate	DATETIME,
			@strItemContractNumber		NVARCHAR(50),
			@intTransactionId			INT,
			@intTransactionDetailId		INT,
			@strTransactionId			NVARCHAR(50),
			@dtmTransactionDate			DATETIME

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblCTItemContractDetail WHERE intItemContractDetailId = @intItemContractDetailId)
	BEGIN
		RAISERROR('Sequence is deleted by other user.',16,1)
	END 
	
	SELECT	@dblQuantity				=		CD.dblContracted,
	
			--
			@dblScheduleQty				=		CD.dblScheduled,
			@dblBalance					=		CD.dblBalance,

			@dblAvailable				=		CD.dblAvailable,

			--
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
	SET		
			--dblContracted		=	@dblNewQuantity,
			dblScheduled		=	CASE WHEN @dblQuantityToUpdate < 0 THEN dblScheduled + @dblQuantityToUpdate ELSE dblScheduled END,
			dblApplied			=	CASE WHEN @dblQuantityToUpdate < 0 THEN dblApplied + @dblQuantityToUpdate *-1 ELSE dblApplied END,
			intConcurrencyId	=	intConcurrencyId + 1
	WHERE	intItemContractDetailId =	@intItemContractDetailId

	SET		@dblBalanceToUpdate		=	@dblQuantityToUpdate * -1

	--EXEC	uspCTUpdateItemContractSequenceBalance
	--		@intItemContractDetailId	=	@intItemContractDetailId,
	--		@dblQuantityToUpdate		=	@dblBalanceToUpdate,
	--		@intUserId					=	@intUserId,
	--		@intExternalId				=	@intExternalId,
	--		@strScreenName				=	@strScreenName

	SELECT	@dblCurrentContracted		=	ISNULL(D.dblContracted,0),
			@dblCurrentScheduled		=	ISNULL(D.dblScheduled,0),
			@dblCurrentAvailable		=	ISNULL(D.dblAvailable,0),
			@dblCurrentApplied			=	ISNULL(D.dblApplied,0),
			@dblCurrentBalance			=	ISNULL(D.dblBalance,0),
			@intContractStatusId		=	D.intContractStatusId,
			@intLineNo					=	D.intLineNo,
			@dtmOrigLastDeliveryDate	=	D.dtmLastDeliveryDate,
			@strItemContractNumber		=	H.strContractNumber
	FROM	tblCTItemContractDetail		D
	JOIN	tblCTItemContractHeader		H	ON	H.intItemContractHeaderId	=	D.intItemContractHeaderId 
	WHERE	intItemContractDetailId	=	@intItemContractDetailId

	SELECT 
	@intTransactionId = item.intInventoryShipmentId,
	@intTransactionDetailId = item.intInventoryShipmentItemId,
	@strTransactionId = shipment.strShipmentNumber
	FROM tblICInventoryShipmentItem item
	INNER JOIN tblICInventoryShipment shipment ON shipment.intInventoryShipmentId = item.intInventoryShipmentId
	WHERE item.intInventoryShipmentItemId = @intExternalId
	
	SET @dtmTransactionDate = GETDATE()

	-- Usage History
	EXEC uspCTItemContractCreateHistory
	@intItemContractDetailId	=	@intItemContractDetailId, 
	@intTransactionId			=	@intTransactionId,
	@intTransactionDetailId		=	@intTransactionDetailId,
	@strTransactionId			=	@strTransactionId,
	@intUserId					=	@intUserId,
	@strTransactionType			=	@strScreenName,
	@dblNewContracted			=	@dblCurrentContracted,
	@dblNewScheduled			=	@dblCurrentScheduled,
	@dblNewAvailable			=	@dblCurrentAvailable,
	@dblNewApplied				=	@dblCurrentApplied,
	@dblNewBalance				=	@dblCurrentBalance,
	@intNewContractStatusId		=	@intContractStatusId,
	@dtmNewLastDeliveryDate		=	@dtmOrigLastDeliveryDate,
	@dtmTransactionDate			=	@dtmTransactionDate

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO