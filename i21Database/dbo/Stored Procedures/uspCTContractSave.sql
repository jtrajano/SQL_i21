CREATE PROCEDURE [dbo].[uspCTContractSave]
	
	@intContractHeaderId int
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@intContractDetailId	INT,
			@dblCashPrice			NUMERIC(9,4),
			@intPricingTypeId		INT
	
	SELECT @intContractDetailId		=	MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId
	
	WHILE ISNULL(@intContractDetailId,0) > 0
	BEGIN
		SELECT	@intPricingTypeId	=	NULL,
				@dblCashPrice		=	NULL
				
		SELECT	@intPricingTypeId	=	intPricingTypeId,
				@dblCashPrice		=	dblCashPrice 
		FROM	tblCTContractDetail 
		WHERE	intContractDetailId =	@intContractDetailId 
		
		IF 		@intPricingTypeId	IN	(1,6)
		BEGIN	
			EXEC uspICUpdateInventoryReceiptUnitCost @intContractDetailId,@dblCashPrice
		END
		
		SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
	END

	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO