CREATE PROCEDURE [dbo].[uspICGetItemInTransitLocation]
	@intItemId INT 
	,@strItemNo NVARCHAR(50) = NULL
	,@intItemLocationId INT = NULL OUTPUT 
AS

DECLARE @validItemLocationId AS INT 

-- Counter check the item id from the item table. 
SELECT	@intItemId = i.intItemId	 
FROM	tblICItem i
WHERE	1 = CASE	WHEN i.intItemId = @intItemId THEN 1 
					WHEN @intItemId IS NULL AND i.strItemNo = @strItemNo THEN 1 
					ELSE 0 
		END 

-- Validate the item id. 
IF @intItemId IS NULL 
BEGIN
	SET @intItemLocationId = NULL 
	RETURN -1;
END 

-- Insert or get the item location id 
MERGE 
INTO	dbo.tblICItemLocation
WITH	(HOLDLOCK) 
AS		ItemLocation
USING	(
	SELECT	name = 'In-Transit'
			,intItemId = @intItemId
) InTransit
	ON ItemLocation.intItemId = InTransit.intItemId
	AND ItemLocation.strDescription = InTransit.name
	
WHEN MATCHED THEN 
	UPDATE	
	SET		@validItemLocationId = ItemLocation.intItemLocationId 

WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,strDescription
	)
	VALUES (
		InTransit.intItemId
		,InTransit.name 
	)
;

SET @intItemLocationId = ISNULL(@validItemLocationId, SCOPE_IDENTITY())

RETURN 0