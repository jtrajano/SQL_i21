CREATE FUNCTION [dbo].[fnCTGetCommodityUnitMeasure]
(
	@commodityUnitMeasureId INT
)
RETURNS INT
AS
BEGIN
	DECLARE @unitMeasureId INT

	SELECT @unitMeasureId = intUnitMeasureId
	FROM tblICCommodityUnitMeasure 
	WHERE intCommodityUnitMeasureId = @commodityUnitMeasureId

	RETURN @unitMeasureId
END
