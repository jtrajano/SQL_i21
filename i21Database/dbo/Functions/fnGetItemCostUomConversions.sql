CREATE FUNCTION [dbo].[fnGetItemCostUomConversions] (
	@strItemNo NVARCHAR(100),
	@strUnit NVARCHAR(100),
	@dblQty AS NUMERIC(38,20)
)
RETURNS TABLE 
AS

RETURN
SELECT u.intItemId, u.intItemUOMId, u.strUnitMeasure, 
	dbo.fnCalculateCostBetweenUOM(base.intItemUOMId, u.intItemUOMId, @dblQty) dblQty
	, u.ysnStockUnit
	, u.dblUnitQty
FROM tblICItem i
	LEFT OUTER JOIN vyuICItemUOM u ON u.intItemId = i.intItemId
	OUTER APPLY (
		SELECT TOP 1 intItemUOMId, dblUnitQty
		FROM vyuICItemUOM
		WHERE strUnitMeasure = @strUnit
	) base
WHERE i.strItemNo = @strItemNo