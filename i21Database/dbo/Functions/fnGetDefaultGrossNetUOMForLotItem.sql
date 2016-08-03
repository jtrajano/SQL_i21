
-- Returns the default Gross Net UOM of an item. 
CREATE FUNCTION [dbo].[fnGetDefaultGrossNetUOMForLotItem] (
	@intItemId AS INT
)
RETURNS TABLE 
AS 

RETURN 
	SELECT	TOP 1 
			intGrossNetUOMId = tblICItemUOM.intItemUOMId 
	FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
				ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
	WHERE	tblICItemUOM.intItemId = @intItemId
			AND tblICItemUOM.ysnStockUnit = 1 
			AND tblICUnitMeasure.strUnitType IN ('Weight', 'Volume')
			AND dbo.fnGetItemLotType(@intItemId) IN (1, 2)