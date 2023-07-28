--liquibase formatted sql

-- changeset Von:fnCTConvertQtyToTargetItemUOM.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCTConvertQtyToTargetItemUOM]
(
	@IntFromItemUOMId	INT,
	@intToItemUOMId		INT,
	@dblQty				NUMERIC(26,12)
)
RETURNS NUMERIC(26,12)
AS 
BEGIN 
	DECLARE	@result					NUMERIC(26,12),
			@intItemId				INT,
			@IntFromUnitMeasureId	INT,
			@intToUnitMeasureId		INT,
			@dblUnitQtyTo			NUMERIC(26,12)

	SELECT	@intItemId = intItemId,@IntFromUnitMeasureId = intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = @IntFromItemUOMId
	SELECT	@intToUnitMeasureId = intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = @intToItemUOMId
	
	SELECT @result = dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@IntFromUnitMeasureId,ISNULL(@intToUnitMeasureId,@IntFromUnitMeasureId),@dblQty)
	
	RETURN @result;	
END



