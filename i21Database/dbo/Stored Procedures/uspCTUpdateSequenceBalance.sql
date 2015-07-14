CREATE PROCEDURE [dbo].[uspCTUpdateSequenceBalance]
	@intContractDetailId INT,
	@dblAmountToUpdate DECIMAL(12,4)
AS

BEGIN TRY
	
	DECLARE @ErrMsg			NVARCHAR(MAX),
			@dblQuantity	DECIMAL(12,4),
			@dblBalance		DECIMAL(12,4)
	
	SELECT	@dblQuantity			=	dblQuantity,
			@dblBalance				=	dblBalance
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId		=	@intContractDetailId 
	
	IF @dblBalance - @dblAmountToUpdate < 0
	BEGIN
		RAISERROR('Balance cannot be less than zero.',16,1)
	END
	
	IF @dblBalance - @dblAmountToUpdate > @dblQuantity
	BEGIN
		RAISERROR('Balance cannot be more than quantity.',16,1)
	END
	
	UPDATE	tblCTContractDetail
	SET		intConcurrencyId = intConcurrencyId + 1,
			dblBalance = dblBalance - @dblAmountToUpdate	
	WHERE	intContractDetailId = @intContractDetailId
	
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTUpdateSequenceBalance - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH