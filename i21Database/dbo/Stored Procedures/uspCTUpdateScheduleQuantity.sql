CREATE PROCEDURE uspCTUpdateScheduleQuantity

	@intContractDetailId	INT, 
	@dblQuantityToUpdate	NUMERIC(18,6),
	@intUserId				INT,
	@intExternalId			INT,
	@strScreenName			NVARCHAR(50)
	/*
	All the parameters are required. I am going to remove default value from the parameter in future.
	So provide all the parameter while calling the sp.
	*/
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@dblQuantity			NUMERIC(18,6),
			@dblScheduleQty			NUMERIC(18,6),
			@dblBalance				NUMERIC(18,6),
			@dblNewScheduleQty		NUMERIC(18,6),
			@dblQuantityToIncrease	NUMERIC(18,6),
			@ysnUnlimitedQuantity	BIT,
			@intPricingTypeId		INT,
			@strContractNumber		NVARCHAR(100),
			@strContractSeq			NVARCHAR(100),
			@strAvailableQty		NVARCHAR(100),
			@strQuantityToUpdate	NVARCHAR(100) = LTRIM(@dblQuantityToUpdate)

	IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
	BEGIN
		RAISERROR('Sequence is deleted by other user.',16,1)
	END 
	
	BEGINING:

	SELECT	@dblQuantity			=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN ISNULL(dblDetailQuantity,0) ELSE ISNULL(intNoOfLoad,0) END,
			@dblScheduleQty			=	ISNULL(dblScheduleQty,0),
			@dblBalance				=	ISNULL(dblBalance,0),
			@ysnUnlimitedQuantity	=	ISNULL(ysnUnlimitedQuantity,0),
			@intPricingTypeId		=	intPricingTypeId,
			@strContractNumber		=	strContractNumber,
			@strContractSeq			=	LTRIM(intContractSeq),
			@strAvailableQty		=	LTRIM(dblAvailableQty)
	FROM	vyuCTContractDetailView 
	WHERE	intContractDetailId = @intContractDetailId
	
	IF	@dblScheduleQty + @dblQuantityToUpdate > @dblBalance 
	BEGIN
		IF @ysnUnlimitedQuantity = 1 OR @intPricingTypeId = 5
		BEGIN
			SET		@dblQuantityToIncrease	= (@dblBalance - (@dblScheduleQty + @dblQuantityToUpdate)) * -1

			EXEC	uspCTUpdateSequenceQuantity
					@intContractDetailId	=	@intContractDetailId,
					@dblQuantityToUpdate	=	@dblQuantityToIncrease,
					@intUserId				=	@intUserId,
					@intExternalId			=	@intExternalId,
					@strScreenName			=	@strScreenName

			GOTO BEGINING
		END
		ELSE
		BEGIN
			RAISERROR('Available quantity for the contract %s and sequence %s is %s, which is insufficient to Save/Post a quantity of %s therefore could not Save/Post this transaction.',16,1,@strContractNumber,@strContractSeq,@strAvailableQty,@strQuantityToUpdate)
		END
	END
	
	IF	@dblScheduleQty + @dblQuantityToUpdate < 0 
	BEGIN
		RAISERROR('Total scheduled quantity cannot be less than zero.',16,1)
	END
	
	SELECT	@dblNewScheduleQty =	@dblScheduleQty + @dblQuantityToUpdate

	UPDATE 	tblCTContractDetail
	SET		dblScheduleQty		=	@dblNewScheduleQty,
			intConcurrencyId	=	intConcurrencyId + 1
	WHERE	intContractDetailId =	@intContractDetailId
	
	IF ISNULL(@intUserId,0) <> 0 AND ISNULL(@strScreenName,'') <> '' AND ISNULL(@intExternalId,0) <> 0 
	BEGIN
		EXEC	uspCTCreateSequenceUsageHistory 
				@intContractDetailId	=	@intContractDetailId,
				@strScreenName			=	@strScreenName,
				@intExternalId			=	@intExternalId,
				@strFieldName			=	'Scheduled Quantity',
				@dblOldValue			=	@dblScheduleQty,
				@dblTransactionQuantity =	@dblQuantityToUpdate,
				@dblNewValue			=	@dblNewScheduleQty,	
				@intUserId				=	@intUserId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO