CREATE FUNCTION [dbo].[fnRKConvertQuantityToTargetUOM] (
	 @intFutureMarketId INT
	,@intToUnitMeasureId INT
	,@dblQty NUMERIC(38, 20)
	)
RETURNS NUMERIC(38, 20)
AS
BEGIN

	DECLARE @result AS NUMERIC(38, 20)
	       ,@dblUnitQtyFrom AS NUMERIC(38, 20)	
	       ,@intFromUOM AS int
	       
		SELECT @dblUnitQtyFrom = mc.dblConversionToStock
		FROM tblRKFutureMarket fm 
		JOIN tblICUnitMeasureConversion mc on mc.intUnitMeasureId= fm.intUnitMeasureId AND intStockUnitMeasureId=@intToUnitMeasureId
	if isnull(@dblUnitQtyFrom,0)=0
	BEGIN
	SET @dblUnitQtyFrom = 1
	END
	
	SELECT @dblUnitQtyFrom = ISNULL(@dblUnitQtyFrom, 0)

	IF (@intFromUOM=@intToUnitMeasureId)
	BEGIN
		SET @result = @dblUnitQtyFrom  					
	END
	ELSE
	BEGIN
		SET @result = @dblQty * @dblUnitQtyFrom				
	END

	RETURN @result;
END

