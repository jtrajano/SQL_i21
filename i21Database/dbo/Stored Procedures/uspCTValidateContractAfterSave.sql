CREATE PROCEDURE [dbo].[uspCTValidateContractAfterSave]

	@intContractHeaderId INT
	
AS
BEGIN TRY
	
	DECLARE @ErrMsg						NVARCHAR(MAX),
			@intContractDetailId		INT,
			@dblAllocatedQty			NUMERIC(18,6),
			@dblQuantity				NUMERIC(18,6)
			

	SELECT @intContractDetailId		=	MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId
	
	WHILE ISNULL(@intContractDetailId,0) > 0
	BEGIN

		SELECT	@dblAllocatedQty	=	dblAllocatedQty,
				@dblQuantity		=	dblQuantity
		FROM	tblCTContractDetail 
		WHERE	intContractDetailId =	@intContractDetailId 
		
		IF @dblAllocatedQty > @dblQuantity
		BEGIN
			SET @ErrMsg = 'Cannot update sequence quantity below '+LTRIM(@dblAllocatedQty)+' as it is used in Allocation.'
			RAISERROR(@ErrMsg,16,1) 
		END

		SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO