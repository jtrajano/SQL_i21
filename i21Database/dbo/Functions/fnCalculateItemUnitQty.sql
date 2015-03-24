
/*
	This function convert the qty to the stock unit qty. 
	Formula used is: Qty x Unit Qty
*/

CREATE FUNCTION [dbo].[fnCalculateItemUnitQty](
	@intItemUOMId INT
	,@dblQty NUMERIC(18,6)
)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	DECLARE	@Result AS NUMERIC(18,6)

	SELECT	TOP 1 
			@Result  = ISNULL(@dblQty, 0) * ISNULL(ItemUOM.dblUnitQty, 0)
	FROM	dbo.tblICItemUOM ItemUOM INNER JOIN dbo.tblICUnitMeasure UOM
				ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE	ItemUOM.intItemUOMId = @intItemUOMId

	RETURN @Result;	
END
GO