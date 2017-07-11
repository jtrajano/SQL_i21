CREATE PROCEDURE uspCTUpdateReservedQuantity

	@intContractDetailId	INT, 
	@dblQuantityToUpdate	NUMERIC(18,6),
	@intUserId				INT,
	@intExternalId			INT,
	@strScreenName			NVARCHAR(50)
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@dblQuantity			NUMERIC(18,6),
			@dblReservedQty			NUMERIC(18,6),
			@dblNewReservedQty		NUMERIC(18,6),
			@dblQuantityToIncrease	NUMERIC(18,6),
			@strQuantityToUpdate	NVARCHAR(100) = LTRIM(@dblQuantityToUpdate)

	IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
	BEGIN
		RAISERROR('Sequence is deleted by other user.',16,1)
	END 
	
	BEGINING:

	SELECT	@dblQuantity			=	ISNULL(dblQuantity,0),
			@dblReservedQty			=	ISNULL(dblReservedQty,0)
	FROM	tblCTContractDetail
	WHERE	intContractDetailId = @intContractDetailId
	
	IF	@dblReservedQty + @dblQuantityToUpdate > @dblQuantity 
	BEGIN
		RAISERROR('Reserved quantity cannot be more than contract sequence quantity.',16,1)
	END
	
	IF	@dblReservedQty + @dblQuantityToUpdate < 0 
	BEGIN
		RAISERROR('Reserved quantity cannot be less than zero.',16,1)
	END
	
	SELECT	@dblNewReservedQty =	@dblReservedQty + @dblQuantityToUpdate

	UPDATE 	tblCTContractDetail
	SET		dblReservedQty		=	@dblNewReservedQty,
			intConcurrencyId	=	intConcurrencyId + 1
	WHERE	intContractDetailId =	@intContractDetailId
	
	IF ISNULL(@intUserId,0) <> 0 AND ISNULL(@strScreenName,'') <> '' AND ISNULL(@intExternalId,0) <> 0 
	BEGIN
		EXEC	uspCTCreateSequenceUsageHistory 
				@intContractDetailId	=	@intContractDetailId,
				@strScreenName			=	@strScreenName,
				@intExternalId			=	@intExternalId,
				@strFieldName			=	'Reserved Quantity',
				@dblOldValue			=	@dblReservedQty,
				@dblTransactionQuantity =	@dblQuantityToUpdate,
				@dblNewValue			=	@dblNewReservedQty,	
				@intUserId				=	@intUserId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO