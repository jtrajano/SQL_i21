CREATE FUNCTION [dbo].[fnCTConvertQuantityToTargetItemUOM2]
(
	 @intItemId INT,
	 @IntFromUnitMeasureId INT,
	 @intToUnitMeasureId INT,
	 @dblBalance NUMERIC(38,20),
	 @intNoOfLoad INT,
	 @dblQuantity NUMERIC(38,20),
	 @ysnLoad BIT
)
RETURNS @tblSpecialPriceTableReturn TABLE(
   dblBalance NUMERIC(38,20)
  ,dblAppliedQuantity NUMERIC(38,20)
)
AS 
BEGIN 
	DECLARE	@result AS NUMERIC(38,20),
			@intItemUOMIdFrom INT,
			@intItemUOMIdTo INT,
			@dblUnitQtyFrom AS NUMERIC(38,20),
			@dblUnitQtyTo AS NUMERIC(38,20),
			@dblAppliedQty AS NUMERIC(38,20),
			@dblReturnBalance AS NUMERIC(38,20),
			@dblReturnAppliedQty AS NUMERIC(38,20)

	SELECT @dblUnitQtyFrom = ItemUOM.dblUnitQty
	FROM dbo.tblICItemUOM ItemUOM 
	WHERE intUnitMeasureId =  @IntFromUnitMeasureId AND intItemId = @intItemId

	SELECT @dblUnitQtyTo = ItemUOM.dblUnitQty
	FROM dbo.tblICItemUOM ItemUOM 
	WHERE intUnitMeasureId =  @intToUnitMeasureId AND intItemId = @intItemId

	SET @dblUnitQtyFrom = ISNULL(@dblUnitQtyFrom, 0)
	SET @dblUnitQtyTo = ISNULL(@dblUnitQtyTo, 0)
	SET @dblBalance = ISNULL(@dblBalance, 0)
	SET @dblAppliedQty = CASE WHEN @ysnLoad = 1 THEN ISNULL(@intNoOfLoad,0) - ISNULL(@dblBalance,0) ELSE ISNULL(@dblQuantity,0) - ISNULL(@dblBalance,0) END

	IF @dblUnitQtyFrom = 0 OR @dblUnitQtyTo = 0 
	BEGIN 
		RETURN; 
	END 

	SET @dblReturnBalance =
	  CASE WHEN @dblUnitQtyFrom = @dblUnitQtyTo THEN 
		 @dblBalance
		ELSE 
		 CASE WHEN @dblUnitQtyTo <> 0 THEN CAST((@dblBalance * @dblUnitQtyFrom) AS  NUMERIC(18,6)) / CAST(@dblUnitQtyTo AS NUMERIC(18,6))       
		   ELSE NULL 
		 END
	  END 

	 SET @dblAppliedQty =
	  CASE WHEN @dblUnitQtyFrom = @dblUnitQtyTo THEN 
		 @dblAppliedQty
		ELSE 
		 CASE WHEN @dblUnitQtyTo <> 0 THEN CAST((@dblAppliedQty * @dblUnitQtyFrom) AS  NUMERIC(18,6)) / CAST(@dblUnitQtyTo AS NUMERIC(18,6))       
		   ELSE NULL 
		 END
	  END 
	 INSERT INTO @tblSpecialPriceTableReturn (dblBalance,dblAppliedQuantity) SELECT @dblReturnBalance,@dblAppliedQty

	 RETURN  	
END
GO