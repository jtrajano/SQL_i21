CREATE FUNCTION [dbo].[fnIsStockTrackingItem]
(
	@intItemId INT
)
RETURNS BIT
AS 
BEGIN 
	--DEV NOTE
	--any modification here with regards to what are the stock tracking item
	--please update fnARIsStockTrackingItem as well	
	DECLARE @isStockTracking BIT 

	SELECT	@isStockTracking = 
				CASE	WHEN Item.strType = 'Inventory' THEN 1
						WHEN Item.strType = 'Finished Good' THEN 1
						WHEN Item.strType = 'Raw Material' THEN 1
						ELSE 0 
				END 
	FROM	dbo.tblICItem Item
	WHERE	Item.intItemId = @intItemId

	RETURN ISNULL(@isStockTracking, 0)
END
GO