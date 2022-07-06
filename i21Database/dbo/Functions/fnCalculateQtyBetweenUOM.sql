/*
	This function convert the qty to the stock unit qty. 
	Remember, the unit conversions are taken from the Item UOM table and NOT from the Unit of Measure table. 

	Parameters: 
		@intItemUOMIdFrom
			- The Item UOM id where to start the conversion. 

		@intItemUOMIdTo
			- The target Item UOM. 

		@dblQty
			- The quantity of the @intItemUOMIdFrom. 
	
	Sample:
		Let's say @intItemUOMIdFrom is 25 kg bags, @intItemUOMIdTo is Pound, and then @dblQty is 10. 
		Using this function will convert 10 bags, in 25 kg bag, to Pounds. 
*/

CREATE FUNCTION [dbo].[fnCalculateQtyBetweenUOM](
	@intItemUOMIdFrom INT
	,@intItemUOMIdTo INT 
	,@dblQty NUMERIC(38, 20)
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	
	--DEV NOTE
	--any modification here with regards to what are parameters
	--please update fnARCalculateQtyBetweenUOM as well
	DECLARE	@result AS NUMERIC(38,20)

	DECLARE @intUnitMeasureToId INT
	DECLARE @intUnitMeasureFromId INT
	DECLARE @intDecimalAdjustment INT
	DECLARE @intFinalNumberOfDecimal INT
	DECLARE @intInitialNumberOfDecimal INT
	DECLARE @intMinDecimal INT
	DECLARE @intItemId INT
	DECLARE @ysnScaleItem BIT
	DECLARE @ysnFixRounding BIT

	IF @dblQty = 0 
		RETURN @dblQty; 

	SELECT TOP 1 @intItemId = intItemId FROM tblICItemUOM WITH (NOLOCK) WHERE intItemUOMId = @intItemUOMIdFrom
	SELECT TOP 1 @ysnScaleItem = ysnUseWeighScales FROM tblICItem WITH (NOLOCK) WHERE intItemId = @intItemId

	IF (@ysnScaleItem = 1)
	BEGIN
		--Check rounding table if UOM conversion Exists
		SELECT TOP 1 
			@intUnitMeasureToId = intUnitMeasureId 
		FROM tblICItemUOM WHERE intItemUOMId = @intItemUOMIdTo

		SELECT TOP 1 
			@intUnitMeasureFromId = intUnitMeasureId 
		FROM tblICItemUOM WHERE intItemUOMId = @intItemUOMIdFrom

		IF(@intUnitMeasureToId IS NOT NULL AND @intUnitMeasureFromId IS NOT NULL)
		BEGIN
			SELECT TOP 1 
				@intDecimalAdjustment = intDecimalAdjustment
				,@ysnFixRounding = ysnFixRounding
			FROM tblGRUOMRounding
			WHERE intUnitOfMeasureFromId = @intUnitMeasureFromId
				AND intUnitOfMeasureToId = @intUnitMeasureToId
				AND intItemId = @intItemId
		END
	END

	

	SELECT	@result = 
			CASE	WHEN ISNULL(ItemUOMFrom.dblUnitQty, 0) = 0 OR ISNULL(ItemUOMTo.dblUnitQty, 0) = 0 THEN 
						NULL 			
					WHEN ItemUOMFrom.dblUnitQty = ItemUOMTo.dblUnitQty THEN 
						@dblQty 					
					ELSE 
						dbo.fnDivide(
							dbo.fnMultiply(@dblQty, ItemUOMFrom.dblUnitQty)
							,ItemUOMTo.dblUnitQty 
						)					
			END 
	FROM	
	--		(
	--			SELECT	ItemUOM.dblUnitQty 
	--			FROM	dbo.tblICItemUOM ItemUOM 
	--			WHERE	ItemUOM.intItemUOMId = @intItemUOMIdFrom
	--		) ItemUOMFrom
	--		, (
	--			SELECT	ItemUOM.dblUnitQty 
	--			FROM	dbo.tblICItemUOM ItemUOM 
	--			WHERE	ItemUOM.intItemUOMId = @intItemUOMIdTo
	--		) ItemUOMTo
			(
				SELECT	ItemUOM.dblUnitQty 
				FROM	dbo.tblICItemUOM ItemUOM 
				WHERE	ItemUOM.intItemUOMId = @intItemUOMIdFrom
			) ItemUOMFrom
			inner join (
				SELECT	ItemUOM.dblUnitQty 
				FROM	dbo.tblICItemUOM ItemUOM 
				WHERE	ItemUOM.intItemUOMId = @intItemUOMIdTo
			) ItemUOMTo
			on 1=1

	IF (@ysnScaleItem = 1 AND @intDecimalAdjustment IS NOT NULL)
	BEGIN
	
		IF @ysnFixRounding = 1
		BEGIN
			SET @intFinalNumberOfDecimal = ABS(@intDecimalAdjustment)
		END
		ELSE
		BEGIN
			SELECT @intInitialNumberOfDecimal = (LEN(REPLACE(REPLACE(RTRIM(LTRIM(REPLACE('@' + PARSENAME(@dblQty, 1), '0', ' '))), ' ', '0'), '@', '')))

			SET @intFinalNumberOfDecimal = @intInitialNumberOfDecimal + @intDecimalAdjustment
		END
		
		IF(@intFinalNumberOfDecimal < 0)
		BEGIN
			SET @intFinalNumberOfDecimal = 0
		END

		SET @result = ROUND(@result,@intFinalNumberOfDecimal)


	END

	RETURN @result;		
END