CREATE FUNCTION [dbo].[fnAGGetOrderedQuantityByUOMRate]
(
	@intWeightUOMId	INT
	,@intAreaUOMId	INT
	,@dblRate		NUMERIC(38,20)
	,@dblAcreArea	NUMERIC(38,20)
	,@intItemId INT
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 

	DECLARE	@IntFromUnitMeasureId INT
	DECLARE	@intToUnitMeasureId INT
	DECLARE @dblAreaUOMConversion NUMERIC(38,20) = 1
	DECLARE @dblWeightUOMConversion NUMERIC(38,20) = 1
	DECLARE @dblTotalArea NUMERIC(38,20) = 1
	DECLARE @dblQuantity NUMERIC(38,20)
	DECLARE @dblFinalQuantity NUMERIC(38,20)
	DECLARE @dblStockQuantity NUMERIC(38,20)
	DECLARE @intAcreId	INT
	DECLARE @intLbsId	INT
	DECLARE @intItemStockUOMId INT
	DECLARE @intItemUOMId INT
	DECLARE @intBaseUOMId INT


	/*
		-2 - Acre
		-1 - lbs
	*/
	SET @intAcreId = -2
	SET @intLbsId = -1


	--Get the Area UOM conversion (Acre Base)
	IF(@intAreaUOMId <> @intAcreId)
	BEGIN
		IF EXISTS (SELECT TOP 1 1 
					FROM [tblAGUnitMeasureConversion] 
					WHERE intAGUnitMeasureId =  @intAreaUOMId
					AND intStockUnitMeasureId = @intAcreId)
		BEGIN
			SELECT TOP 1
				@dblAreaUOMConversion = ISNULL(dblConversionToStock,0)
			FROM [tblAGUnitMeasureConversion] 
			WHERE intAGUnitMeasureId =  @intAreaUOMId
				AND intStockUnitMeasureId = @intAcreId
		END
	END


	
	--Get the Weight UOM conversion (lbs Base)
	IF(@intWeightUOMId <> @intLbsId)
	BEGIN
		IF EXISTS (SELECT TOP 1 1 
					FROM [tblAGUnitMeasureConversion] 
					WHERE intAGUnitMeasureId =  @intWeightUOMId
					AND intStockUnitMeasureId = @intLbsId)
		BEGIN
			SELECT TOP 1
				@dblWeightUOMConversion = ISNULL(dblConversionToStock,0)
			FROM [tblAGUnitMeasureConversion] 
			WHERE intAGUnitMeasureId =  @intWeightUOMId
				AND intStockUnitMeasureId = @intLbsId
		END
	END

	
	--totalQuantity in lbs
	SELECT @dblQuantity = dbo.fnMultiply(dbo.fnDivide(dbo.fnMultiply(@dblWeightUOMConversion, @dblRate),@dblAreaUOMConversion),@dblAcreArea)

	--convert lbs total quantity to item stock uom
	BEGIN
		--get the inventory UOM Id of the AG Base UOM
		SELECT TOP 1  
			@intBaseUOMId = intUnitMeasureId
		FROM tblICUnitMeasure
		WHERE strUnitMeasure = 'lb' --TODO change filter for searching base UOM from IC

		--get the ItemUOM ID
		SELECT TOP 1  
			@intItemUOMId = intItemUOMId
		FROM tblICItemUOM
		WHERE intUnitMeasureId = @intBaseUOMId 
			AND intItemId = @intItemId

		--get the stock ItemUOM ID
		SELECT TOP 1  
			@intItemStockUOMId = intItemUOMId
		FROM tblICItemUOM
		WHERE intUnitMeasureId = @intBaseUOMId 
			AND intItemId = @intItemId

		--convert to stock UOM
		SELECT @dblFinalQuantity = dbo.fnCalculateQtyBetweenUOM(@intItemUOMId,@intItemStockUOMId,@dblQuantity)

	END

	RETURN @dblFinalQuantity

	
END
GO