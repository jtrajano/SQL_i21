CREATE FUNCTION [dbo].[fnCTGetApprovedSampleQuantity]
(
	@intContractDetailId INT
)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	DECLARE	@result				NUMERIC(18,6),
			@intItemId			INT,
			@intUnitMeasureId	INT

	SELECT	@intItemId			=	intItemId, 
			@intUnitMeasureId	=	intUnitMeasureId
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId = @intContractDetailId

	SELECT	@result = SUM(dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, intRepresentingUOMId, @intUnitMeasureId, dblRepresentingQty))
	FROM	tblQMSample 
	WHERE	intProductTypeId = 8  AND intSampleStatusId = 3 AND intProductValueId = @intContractDetailId

	RETURN @result;	
END
GO