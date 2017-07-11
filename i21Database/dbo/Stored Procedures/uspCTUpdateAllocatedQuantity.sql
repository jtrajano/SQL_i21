CREATE PROCEDURE uspCTUpdateAllocatedQuantity

	@intContractDetailId	INT, 
	@dblQuantityToUpdate	NUMERIC(18,6),
	@intUserId				INT,
	@intExternalId			INT,
	@strScreenName			NVARCHAR(50)
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@dblQuantity			NUMERIC(18,6),
			@dblAllocatedQty		NUMERIC(18,6),
			@dblNewAllocatedQty		NUMERIC(18,6),
			@dblQuantityToIncrease	NUMERIC(18,6),
			@strQuantityToUpdate	NVARCHAR(100) = LTRIM(@dblQuantityToUpdate)

	IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
	BEGIN
		RAISERROR('Sequence is deleted by other user.',16,1)
	END 
	
	BEGINING:

	SELECT	@dblQuantity			=	ISNULL(dblQuantity,0),
			@dblAllocatedQty		=	ISNULL(dblAllocatedQty,0)
	FROM	tblCTContractDetail
	WHERE	intContractDetailId = @intContractDetailId
	
	IF	@dblAllocatedQty + @dblQuantityToUpdate > @dblQuantity 
	BEGIN
		RAISERROR('Allocated quantity cannot be more than contract sequence quantity.',16,1)
	END
	
	IF	@dblAllocatedQty + @dblQuantityToUpdate < 0 
	BEGIN
		RAISERROR('Allocated quantity cannot be less than zero.',16,1)
	END
	
	SELECT	@dblNewAllocatedQty =	@dblAllocatedQty + @dblQuantityToUpdate

	UPDATE 	tblCTContractDetail
	SET		dblAllocatedQty		=	@dblNewAllocatedQty,
			intConcurrencyId	=	intConcurrencyId + 1
	WHERE	intContractDetailId =	@intContractDetailId
	
	IF ISNULL(@intUserId,0) <> 0 AND ISNULL(@strScreenName,'') <> '' AND ISNULL(@intExternalId,0) <> 0 
	BEGIN
		EXEC	uspCTCreateSequenceUsageHistory 
				@intContractDetailId	=	@intContractDetailId,
				@strScreenName			=	@strScreenName,
				@intExternalId			=	@intExternalId,
				@strFieldName			=	'Allocated Quantity',
				@dblOldValue			=	@dblAllocatedQty,
				@dblTransactionQuantity =	@dblQuantityToUpdate,
				@dblNewValue			=	@dblNewAllocatedQty,	
				@intUserId				=	@intUserId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO