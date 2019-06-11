CREATE FUNCTION [dbo].[fnCTConvertQtyToTargetCommodityUOM]
(
	@intCommodityId INT,
	@IntFromUnitMeasureId INT,
	@intToUnitMeasureId INT,
	@dblQty NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 

declare @dblUnitQuantityFrom numeric(38,20) = 0.00;
declare @dblUnitQuantityTo numeric(38,20) = 0.00;

set @dblUnitQuantityFrom = (select (@dblQty * dblUnitQty) from tblICCommodityUnitMeasure where intCommodityId = @intCommodityId and intUnitMeasureId = @IntFromUnitMeasureId);
set @dblUnitQuantityTo = (select case when isnull(dblUnitQty,0) = 0 then 0 else (@dblUnitQuantityFrom / dblUnitQty) end from tblICCommodityUnitMeasure where intCommodityId = @intCommodityId and intUnitMeasureId = @intToUnitMeasureId);

if (@dblUnitQuantityTo = 0)
begin
	set @dblUnitQuantityTo = null;
end

return @dblUnitQuantityTo;

END

/*
CREATE FUNCTION [dbo].[fnCTConvertQtyToTargetCommodityUOM]
(
	@intCommodityId INT,
	@IntFromUnitMeasureId INT,
	@intToUnitMeasureId INT,
	@dblQty NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE	@result AS NUMERIC(38,20),
			@intItemUOMIdFrom INT,
			@intItemUOMIdTo INT,
			@dblUnitQtyFrom AS NUMERIC(38,20),
			@dblUnitQtyTo AS NUMERIC(38,20)

	SELECT @dblUnitQtyFrom = ItemUOM.dblUnitQty
	FROM dbo.tblICCommodityUnitMeasure ItemUOM 
	WHERE intUnitMeasureId =  @IntFromUnitMeasureId AND intCommodityId = @intCommodityId

	SELECT @dblUnitQtyTo = ItemUOM.dblUnitQty
	FROM dbo.tblICCommodityUnitMeasure ItemUOM 
	WHERE intUnitMeasureId =  @intToUnitMeasureId AND intCommodityId = @intCommodityId

	SELECT	@dblUnitQtyFrom = ISNULL(@dblUnitQtyFrom, 0)
	SELECT	@dblUnitQtyTo = ISNULL(@dblUnitQtyTo, 0)
	SELECT	@dblQty = ISNULL(@dblQty, 0)

	IF @dblUnitQtyFrom = 0 OR @dblUnitQtyTo = 0 
	BEGIN 
		RETURN NULL; 
	END 

	SET @result = 
		CASE	WHEN @dblUnitQtyFrom = @dblUnitQtyTo THEN 
					@dblQty
				ELSE 
					CASE	WHEN @dblUnitQtyTo <> 0 THEN CAST((@dblQty * @dblUnitQtyFrom) AS  NUMERIC(18,6)) / CAST(@dblUnitQtyTo AS NUMERIC(18,6))							
							ELSE NULL 
					END
		END 

	RETURN @result;	
END
*/