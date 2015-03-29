
-- This function will retrieve what kind of lot items it is. It can be "Manual" or "Serialized"
-- Value of 0: No
-- Value of 1: Yes - Manual
-- Value of 2: Yes - Serial Number

CREATE FUNCTION [dbo].[fnGetItemLotType](
	@intItemId INT
)
RETURNS INT
AS 
BEGIN 
	DECLARE	@LotType AS INT 

	SELECT	@LotType =  
				CASE	WHEN Item.strLotTracking = 'Yes - Manual' THEN 1
						WHEN Item.strLotTracking = 'Yes - Serial Number' THEN 2
						ELSE 0 
				END 
	FROM	dbo.tblICItem Item
	WHERE	Item.intItemId = @intItemId

	RETURN @LotType;	
END
GO