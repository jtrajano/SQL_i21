CREATE FUNCTION [dbo].[fnARIsStockTrackingItem]
(
	@strType			NVARCHAR(50),
	@intItemId			INT
)
RETURNS BIT
AS
BEGIN	
	DECLARE @isStockTracking BIT 


	IF ISNULL(@strType, '') <> ''
		SELECT	@isStockTracking = 
			CASE	WHEN @strType = 'Inventory' THEN 1
					WHEN @strType = 'Finished Good' THEN 1
					WHEN @strType = 'Raw Material' THEN 1
					ELSE 0 
			END 
	ELSE IF ISNULL(@intItemId, 0) > 0
	BEGIN
		SELECT @isStockTracking = dbo.fnIsStockTrackingItem(@intItemId)
	END


	RETURN ISNULL(@isStockTracking, 0)

END
