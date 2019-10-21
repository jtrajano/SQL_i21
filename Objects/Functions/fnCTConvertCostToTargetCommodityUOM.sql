CREATE FUNCTION [dbo].[fnCTConvertCostToTargetCommodityUOM]  
(  
	@intCommodityId INT,  
	@intFromCommodityUOMId INT,  
	@intToCommodityUOMId INT,  
	@dblCost  NUMERIC(26,12)  
)  
RETURNS NUMERIC(26,12)  
AS  
BEGIN  
	DECLARE @dblUnitQtyFrom NUMERIC(26,12)=1  
	DECLARE @unitMeasureId INT

	SELECT @unitMeasureId = intUnitMeasureId from tblICItemUOM where intItemUOMId = @intFromCommodityUOMId
	SELECT @dblUnitQtyFrom=ISNULL(dblUnitQty,1) From tblICCommodityUnitMeasure Where intCommodityId = @intCommodityId and intUnitMeasureId =@unitMeasureId
  
	RETURN @dblCost / (NULLIF(@dblUnitQtyFrom,0)/1)
END


/*
CREATE FUNCTION [dbo].[fnCTConvertCostToTargetCommodityUOM]
(
	@intCommodityId	INT,
	@intFromCommodityUOMId	INT,
	@intToCommodityUOMId	INT,
	@dblCost		NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN
	Declare @dblUnitQtyFrom NUMERIC(38,20)=1
	Declare @dblUnitQtyTo NUMERIC(38,20)=1

	Select @dblUnitQtyFrom=ISNULL(dblUnitQty,1) From tblICCommodityUnitMeasure Where intCommodityId = @intCommodityId and intUnitMeasureId =@intFromCommodityUOMId
	Select @dblUnitQtyTo=ISNULL(dblUnitQty,1) From tblICCommodityUnitMeasure Where intCommodityId = @intCommodityId and intUnitMeasureId=@intToCommodityUOMId

	return @dblCost / (NULLIF(@dblUnitQtyFrom,0)/NULLIF(@dblUnitQtyTo,0))
END
*/