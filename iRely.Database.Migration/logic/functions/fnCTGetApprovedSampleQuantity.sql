--liquibase formatted sql

-- changeset Von:fnCTGetApprovedSampleQuantity.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCTGetApprovedSampleQuantity]
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
	WHERE	intProductTypeId = 8  AND intSampleStatusId = 3 AND intProductValueId = @intContractDetailId AND intTypeId = 1

	RETURN @result;	
END



