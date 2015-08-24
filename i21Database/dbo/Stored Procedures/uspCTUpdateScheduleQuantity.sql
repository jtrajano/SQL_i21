CREATE PROCEDURE uspCTUpdateScheduleQuantity

	@intContractDetailId	INT, 
	@dblQuantityToUpdate	NUMERIC(12,4),
	@intUserId				INT = NULL,
	@intExternalId			INT = NULL,
	@strScreenName			NVARCHAR(50) = NULL
	/*
	All the parameters are required. I am going to remove default value from the parameter in future.
	So provide all the parameter while calling the sp.
	*/
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@dblQuantity			NUMERIC(12,4),
			@dblScheduleQty			NUMERIC(12,4),
			@dblBalance				NUMERIC(12,4),
			@dblNewScheduleQty		NUMERIC(12,4),
			@dblQuantityToIncrease	NUMERIC(12,4),
			@ysnUnlimitedQuantity	BIT

	IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
	BEGIN
		RAISERROR('Sequence is deleted by other user.',16,1)
	END 
	
	BEGINING:

	SELECT	@dblQuantity			=	ISNULL(dblDetailQuantity,0),
			@dblScheduleQty			=	ISNULL(dblScheduleQty,0),
			@dblBalance				=	ISNULL(dblBalance,0),
			@ysnUnlimitedQuantity	=	ISNULL(ysnUnlimitedQuantity,0)
	FROM	vyuCTContractDetailView 
	WHERE	intContractDetailId = @intContractDetailId
	
	IF	@dblScheduleQty + @dblQuantityToUpdate > @dblBalance 
	BEGIN
		IF @ysnUnlimitedQuantity = 1
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
			RAISERROR('Total scheduled quantity should not be more than balance quantity.',16,1)
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
				@strFieldName			=	'Scheduled Quantiy',
				@dblOldValue			=	@dblScheduleQty,
				@dblTransactionQuantity =	@dblQuantityToUpdate,
				@dblNewValue			=	@dblNewScheduleQty,	
				@intUserId				=	@intUserId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTUpdateScheduleQuantity - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO