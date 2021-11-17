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
			@dblOrgScheduleQty		NUMERIC(18,6),
			@dblBalance				NUMERIC(18,6),
			@dblNewScheduleQty		NUMERIC(18,6),
			@dblQuantityToIncrease	NUMERIC(18,6),
			@ysnUnlimitedQuantity	BIT,
			@intPricingTypeId		INT,
			@strContractNumber		NVARCHAR(100),
			@strContractSeq			NVARCHAR(100),
			@strAvailableQty		NVARCHAR(100),
			@strBalanceQty			NVARCHAR(100),
			@strQuantityToUpdate	NVARCHAR(100) = LTRIM(@dblQuantityToUpdate),
			@dblTolerance			NUMERIC(18,6) = 0.0001,
			@ysnAllowOverSchedule	BIT,
			@strReason				NVARCHAR(MAX),
			@ysnLoad				BIT,
			@intSequenceUsageHistoryId	INT,
			@intContractStatusId	INT

	IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
	BEGIN
		RAISERROR('Sequence is deleted by other user.',16,1)
	END 
	
	SELECT @ysnAllowOverSchedule = ysnAllowOverSchedule FROM tblCTCompanyPreference

	BEGINING:

	SELECT	@dblQuantityToUpdate	=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN @dblQuantityToUpdate ELSE @dblQuantityToUpdate / ABS(@dblQuantityToUpdate) END,
			@intContractStatusId	=	CD.intContractStatusId
	FROM	tblCTContractDetail		CD
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId 
	WHERE	intContractDetailId		=	@intContractDetailId

	SELECT	@strQuantityToUpdate	=	LTRIM(@dblQuantityToUpdate)

	SELECT	@dblQuantity			=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN ISNULL(CD.dblQuantity,0) ELSE ISNULL(CD.intNoOfLoad,0) END,
			@dblScheduleQty			=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN ISNULL(CD.dblScheduleQty,0) ELSE ISNULL(CD.dblScheduleLoad,0) END,
			@dblOrgScheduleQty		=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN ISNULL(CD.dblScheduleQty,0) ELSE ISNULL(CD.dblScheduleLoad,0) END,
			@dblBalance				=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN ISNULL(CD.dblBalance,0) ELSE ISNULL(CD.dblBalanceLoad,0) END,
			@ysnUnlimitedQuantity	=	ISNULL(CH.ysnUnlimitedQuantity,0),
			@intPricingTypeId		=	CD.intPricingTypeId,
			@strContractNumber		=	CH.strContractNumber,
			@strContractSeq			=	LTRIM(CD.intContractSeq),
			@strAvailableQty		=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN LTRIM(ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0)) ELSE LTRIM(ISNULL(CD.dblBalanceLoad,0) - ISNULL(CD.dblScheduleLoad,0)) END,
			@strBalanceQty			=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN LTRIM(ISNULL(CD.dblBalance,0)) ELSE LTRIM(ISNULL(CD.intNoOfLoad,0)) END,
			@ysnLoad				=	CH.ysnLoad
	FROM	tblCTContractDetail	CD
	JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId 
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
		ELSE IF @ysnAllowOverSchedule = 1
		BEGIN
			IF @dblQuantityToUpdate <= @dblBalance
			BEGIN
				SELECT @dblScheduleQty = (@dblQuantity + @dblQuantityToUpdate - @dblScheduleQty) - (@dblQuantity - @dblScheduleQty)
				SELECT @strReason = 'Over Schedule'
			END
			ELSE
			BEGIN
				RAISERROR('Balance quantity for the contract %s and sequence %s is %s, which is insufficient to Save/Post a quantity of %s therefore could not Save/Post this transaction.',16,1,@strContractNumber,@strContractSeq,@strBalanceQty,@strQuantityToUpdate)
			END
		END
		ELSE
		BEGIN
			IF ((@dblScheduleQty + @dblQuantityToUpdate) - @dblBalance) > @dblTolerance
			BEGIN
				RAISERROR('Available quantity for the contract %s and sequence %s is %s, which is insufficient to Save/Post a quantity of %s therefore could not Save/Post this transaction.',16,1,@strContractNumber,@strContractSeq,@strAvailableQty,@strQuantityToUpdate)
			END
			ELSE
			BEGIN
				SET @dblQuantityToUpdate = @dblQuantityToUpdate - ((@dblScheduleQty + @dblQuantityToUpdate) - @dblBalance)
			END
		END
	END
	
	IF	@dblScheduleQty + @dblQuantityToUpdate < 0 
	BEGIN
		IF @ysnAllowOverSchedule = 1
		BEGIN
			SET @dblScheduleQty = ABS(@dblQuantityToUpdate) + @dblScheduleQty
			SELECT @strReason = 'Over Schedule'
		END
		ELSE
		BEGIN
			IF ABS(@dblScheduleQty + @dblQuantityToUpdate) > @dblTolerance
			BEGIN
				IF @intContractStatusId IN (5,6) AND @strScreenName = 'Load Schedule'
				BEGIN
					SET @dblQuantityToUpdate = @dblQuantityToUpdate - (@dblScheduleQty + @dblQuantityToUpdate)
				END
				ELSE
				BEGIN
					SET @ErrMsg = 'Total scheduled quantity cannot be less than zero for contract '+@strContractNumber + ' and sequence ' +	@strContractSeq	+'.'
					RAISERROR(@ErrMsg,16,1)
				END
			END
			ELSE
			BEGIN
				SET @dblQuantityToUpdate = @dblQuantityToUpdate - (@dblScheduleQty + @dblQuantityToUpdate)
			END 
		END
	END
	
	SELECT	@dblNewScheduleQty =	@dblScheduleQty + @dblQuantityToUpdate

	UPDATE 	tblCTContractDetail
	SET		dblScheduleQty		=	CASE WHEN ISNULL(@ysnLoad,0) = 0 THEN ISNULL(@dblNewScheduleQty,0) ELSE ISNULL(@dblNewScheduleQty,0) * ISNULL(dblQuantityPerLoad,0) END, 
			dblScheduleLoad		=	CASE WHEN ISNULL(@ysnLoad,0) = 0 THEN NULL ELSE ISNULL(@dblNewScheduleQty,0) END, 
			intConcurrencyId	=	intConcurrencyId + 1
	WHERE	intContractDetailId =	@intContractDetailId
	
	IF ISNULL(@intUserId,0) <> 0 AND ISNULL(@strScreenName,'') <> '' AND ISNULL(@intExternalId,0) <> 0 
	BEGIN
		EXEC	uspCTCreateSequenceUsageHistory 
				@intContractDetailId	=	@intContractDetailId,
				@strScreenName			=	@strScreenName,
				@intExternalId			=	@intExternalId,
				@strFieldName			=	'Scheduled Quantity',
				@dblOldValue			=	@dblOrgScheduleQty,
				@dblTransactionQuantity =	@dblQuantityToUpdate,
				@dblNewValue			=	@dblNewScheduleQty,	
				@intUserId				=	@intUserId,
				@strReason				=	@strReason,
				@dblBalance				=   @dblBalance,
				@intSequenceUsageHistoryId	=	@intSequenceUsageHistoryId	OUTPUT
	END

	EXEC	uspCTCreateDetailHistory	
			@intContractHeaderId		=	NULL,
			@intContractDetailId		=	@intContractDetailId,
			@strComment				    =	NULL,
			@intSequenceUsageHistoryId  =	@intSequenceUsageHistoryId,
			@strSource	 				= 	'Inventory',
			@strProcess 				= 	'Update Scheduled Quantity',
			@intUserId					= 	@intUserId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO