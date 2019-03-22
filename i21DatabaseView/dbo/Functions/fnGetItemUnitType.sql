
/*
	This function will the UOM's unit type. 

	Values are: 
	1. Area
	2. Length
	3. Quantity
	4. Time
	5. Volume
	6. Weight
	7. Packed
*/

CREATE FUNCTION [dbo].[fnGetItemUnitType](
	@intItemUOMId INT
)
RETURNS NVARCHAR(50)
AS 
BEGIN 
	DECLARE	@UnitType AS NVARCHAR(50)

	SELECT	@UnitType = UOM.strUnitType
	FROM	dbo.tblICItemUOM ItemUOM INNER JOIN dbo.tblICUnitMeasure UOM
				ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE	ItemUOM.intItemUOMId = @intItemUOMId

	RETURN @UnitType;	
END
GO