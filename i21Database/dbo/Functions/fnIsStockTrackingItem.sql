CREATE FUNCTION [dbo].[fnIsStockTrackingItem]
(
	@intItemId INT
)
RETURNS BIT
AS 
BEGIN 
	DECLARE @isStockTracking BIT 

	SELECT	@isStockTracking = 
				CASE	WHEN Item.strType = 'Inventory' THEN 1
						WHEN Item.strType = 'Assembly/Blend' THEN 1
						WHEN Item.strType = 'Manufacturing' THEN 1
						WHEN Item.strType = 'Raw Material' THEN 1
						WHEN Item.strType = 'Commodity' THEN 1
						ELSE 0 
				END 
	FROM	dbo.tblICItem Item
	WHERE	Item.intItemId = @intItemId

	RETURN ISNULL(@isStockTracking, 0)
END
GO