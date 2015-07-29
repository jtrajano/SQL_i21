CREATE PROCEDURE uspCTUpdateScheduleQuantity

	@intContractDetailId	INT, 
	@dblQuantityToUpdate	NUMERIC(12,4)/*,
	@intUserId				INT,
	@intExternalId			INT,
	@strScreenName			NVARCHAR(50)*/
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg			NVARCHAR(MAX),
			@dblQuantity	NUMERIC(12,4),
			@dblScheduleQty NUMERIC(12,4),
			@dblBalance		NUMERIC(12,4)
			
	IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
	BEGIN
		RAISERROR('Sequence is deleted by other user.',16,1)
	END 
	
	SELECT	@dblQuantity	=	dblQuantity,
			@dblScheduleQty	=	ISNULL(dblScheduleQty,0),
			@dblBalance		=	ISNULL(dblBalance,0)
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId = @intContractDetailId
	
	IF	@dblScheduleQty + @dblQuantityToUpdate > @dblBalance
	BEGIN
		RAISERROR('Total scheduled quantity should not be more than balance quantity.',16,1)
	END
	
	IF	@dblScheduleQty + @dblQuantityToUpdate < 0
	BEGIN
		RAISERROR('Total scheduled quantity cannot be less than zero.',16,1)
	END
	
	UPDATE 	tblCTContractDetail
	SET		dblScheduleQty		=	@dblScheduleQty + @dblQuantityToUpdate,
			intConcurrencyId	=	intConcurrencyId + 1
	WHERE	intContractDetailId = @intContractDetailId
	
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTUpdateScheduleQuantity - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO