CREATE FUNCTION [dbo].[fnCalculateQtyBetweenUoms](
	  @strItemNo NVARCHAR(100)
	, @strFromUnitMeasure NVARCHAR(100)
	, @strToUnitMeasure NVARCHAR(100)
	, @dblQty NUMERIC(38, 20)
)
/*
 Summary:
    Gets the conversion of qty from one unit to another.
 
 Params:
    @strItemNo          : The item number of the item.
    @strFromUnitMeasure : The unit from which the qty is to be converted from.
    @strToUnitMeasure   : The unit to which the qty is to be converted to.
    @dblQty             : The quantity to convert from one unit to another.

  Usage:
     - Convert the qty of Corn from LB to KG.
     
	 SELECT dbo.fnCalculateQtyBetweenUoms ('Corn', 'LB', 'KG')
*/

RETURNS NUMERIC(38,20)
AS 
BEGIN 

DECLARE @result AS NUMERIC(38, 20)
DECLARE @intItemId INT
DECLARE @intFromItemUOMId INT
DECLARE @intToItemUOMId INT

SELECT @intItemId = intItemId
FROM tblICItem
WHERE strItemNo = @strItemNo

SELECT @intFromItemUOMId = intItemUOMId
FROM tblICItemUOM i
INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = i.intUnitMeasureId
WHERE intItemId = @intItemId
	AND strUnitMeasure = @strFromUnitMeasure

SELECT @intToItemUOMId = intItemUOMId
FROM tblICItemUOM i
INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = i.intUnitMeasureId
WHERE intItemId = @intItemId
	AND strUnitMeasure = @strToUnitMeasure

SELECT @result = dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId, @intToItemUOMId, @dblQty)

RETURN @result;

END