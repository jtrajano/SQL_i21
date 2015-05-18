CREATE FUNCTION [dbo].[fnLGGetItemUnitConversion](
	@intItemId INT
	,@intItemUOMIdFrom INT
	,@intWeightUnitMeasureIdTo INT 
)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	DECLARE	@result AS NUMERIC(18,6)

	DECLARE @intItemUOMIdTo AS INT

	SELECT	@intItemUOMIdTo = ItemUOM.intItemUOMId
	FROM	dbo.tblICItemUOM ItemUOM 
	WHERE	ItemUOM.intItemId=@intItemId AND ItemUOM.intUnitMeasureId = @intWeightUnitMeasureIdTo

	IF @intItemUOMIdTo IS NULL 
	BEGIN 
		RETURN NULL; 
	END 

	-- Calculate the Unit Qty
	SET @result = [dbo].fnCalculateQtyBetweenUOM (@intItemUOMIdFrom, @intItemUOMIdTo, 1)

	RETURN @result;	
END
GO
