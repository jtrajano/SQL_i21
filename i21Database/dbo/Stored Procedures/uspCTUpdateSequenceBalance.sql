﻿CREATE PROCEDURE [dbo].[uspCTUpdateSequenceBalance]
	@intContractDetailId			INT,
	@dblQuantityToUpdate			NUMERIC(12,4),
	@intUserId						INT,
	@intExternalId					INT,
	@strScreenName					NVARCHAR(50)
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@dblQuantity			NUMERIC(18,6),
			@dblOldBalance			NUMERIC(18,6),
			@dblNewBalance			NUMERIC(18,6),
			@strAdjustmentNo		NVARCHAR(50),
			@dblTransactionQuantity	NUMERIC(18,6),
			@dblQuantityToIncrease	NUMERIC(18,6),
			@ysnUnlimitedQuantity	BIT,
			@ysnCompleted			BIT	= 0,
			@intPricingTypeId		INT
	
	BEGINING:

	SELECT	@dblQuantity			=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN ISNULL(dblDetailQuantity,0) ELSE ISNULL(intNoOfLoad,0) END,
			@dblOldBalance			=	ISNULL(dblBalance,0),
			@ysnUnlimitedQuantity	=	ISNULL(ysnUnlimitedQuantity,0),
			@intPricingTypeId		=	intPricingTypeId
	FROM	vyuCTContractDetailView 
	WHERE	intContractDetailId		=	@intContractDetailId 
	
	SELECT	@dblTransactionQuantity	=	- @dblQuantityToUpdate
	SELECT	@dblNewBalance			=	@dblOldBalance - @dblQuantityToUpdate

	IF @dblNewBalance < 0
	BEGIN
		IF @ysnUnlimitedQuantity = 1
		BEGIN
			SET		@dblQuantityToIncrease	= @dblNewBalance * -1

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
			RAISERROR('Balance cannot be less than zero.',16,1)
		END
	END
	
	IF @dblNewBalance > @dblQuantity
	BEGIN
		RAISERROR('Balance cannot be more than quantity.',16,1)
	END
	
	IF	@ysnUnlimitedQuantity = 1 OR @intPricingTypeId IN (2,3,5)
	BEGIN
		SET @ysnCompleted = 0
	END
	ELSE IF @intPricingTypeId IN (1,6,7) AND @dblNewBalance = 0 
	BEGIN
		SET @ysnCompleted = 1
	END

	UPDATE	tblCTContractDetail
	SET		intConcurrencyId	=	intConcurrencyId + 1,
			dblBalance			=	@dblNewBalance,
			intContractStatusId	=	CASE	WHEN @ysnCompleted = 0  
											THEN	CASE	WHEN intContractStatusId = 5 
															THEN 1 
															ELSE intContractStatusId 
													END 
											ELSE 5 
									END
	WHERE	intContractDetailId =	@intContractDetailId

	EXEC	uspCTCreateSequenceUsageHistory 
			@intContractDetailId	=	@intContractDetailId,
			@strScreenName			=	@strScreenName,
			@intExternalId			=	@intExternalId,
			@strFieldName			=	'Balance',
			@dblOldValue			=	@dblOldBalance,
			@dblTransactionQuantity =	@dblTransactionQuantity,
			@dblNewValue			=	@dblNewBalance,	
			@intUserId				=	@intUserId
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH