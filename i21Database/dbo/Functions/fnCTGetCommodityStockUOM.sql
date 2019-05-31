﻿CREATE FUNCTION [dbo].[fnCT
GetCommodityStockUOM]
(
	@commodityId int
)
RETURNS INT
AS
BEGIN
	DECLARE @unitMeasureId INT
	
	SELECT @unitMeasureId = intUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE ysnStockUnit = 1
	AND intCommodityId = @commodityId 

	RETURN @unitMeasureId
END
