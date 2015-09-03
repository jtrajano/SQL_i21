CREATE PROCEDURE [dbo].[uspCTPriceFixationSave]
	
	@intPriceFixationId INT
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@intContractDetailId	INT,
			@dblCashPrice			NUMERIC(6,4),
			@intPricingTypeId		INT
	
	UPDATE	CD
	SET		CD.dblBasis = ISNULL(PF.dblOriginalBasis,0) + ISNULL(dblRollArb,0),
			CD.intConcurrencyId = CD.intConcurrencyId + 1
	FROM	tblCTContractDetail	CD
	JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO