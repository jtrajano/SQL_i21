CREATE FUNCTION [dbo].[fnARCalculateQtyBetweenUOM]
(
	@intItemUOMIdFrom 				INT
	,@intItemUOMIdTo				INT 
	,@dblQty 						NUMERIC(38, 20)
	,@intItemId 					INT
	,@strType	 					NVARCHAR(50)
)
RETURNS NUMERIC(38,20)
AS
BEGIN
	
	IF ISNULL(@dblQty, 0) = 0 
		RETURN 0;
	DECLARE @isStockTracking BIT 

	if isnull(@intItemId, 0) <> 0 or isnull(@strType, '') <> ''
	begin
		SELECT @isStockTracking = dbo.fnARIsStockTrackingItem(@strType, @intItemId)

		IF(@isStockTracking = 0)
		BEGIN
			RETURN 0;
		END
	end
	
	
	

	DECLARE @dblConvertedQty NUMERIC(38,20)

	SELECT @dblConvertedQty = [dbo].[fnCalculateQtyBetweenUOM](@intItemUOMIdFrom, ISNULL(@intItemUOMIdTo, @intItemUOMIdFrom), @dblQty)


	RETURN @dblConvertedQty;


END
