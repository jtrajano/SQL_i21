/*
	Validates the sub location. If it has stock, do not allow the system to change the sub location in the storage location setup. 
*/

CREATE PROCEDURE [dbo].[uspICValidateSubLocationChange]
	@intStorageLocationId INT 
	,@intNewSubLocationId INT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strItemNo AS NVARCHAR(50)
		,@strSubLocation AS NVARCHAR(50)
		,@strStorageLocation AS NVARCHAR(50) 
		,@intCount AS INT 
		,@intSubLocationId AS INT 

-- Get the current sub location. 
SELECT  @intSubLocationId = intSubLocationId 
FROM	tblICStorageLocation 
WHERE	intStorageLocationId = @intStorageLocationId

-- Do not validate if the new sub location is still the same sub location.
BEGIN 
	IF ISNULL(@intSubLocationId, 0) = ISNULL(@intNewSubLocationId, 0) RETURN; 
END 

SELECT	TOP 1 
		@strItemNo = i.strItemNo
		,@strSubLocation = subLoc.strSubLocationName
		,@strStorageLocation = storageLoc.strName 
FROM	tblICItemStockUOM su INNER JOIN tblICItem i
			ON su.intItemId = i.intItemId
		LEFT JOIN tblICStorageLocation storageLoc
			ON storageLoc.intStorageLocationId = su.intStorageLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation subLoc
			ON su.intSubLocationId = subLoc.intCompanyLocationSubLocationId			
WHERE	ISNULL(su.intSubLocationId, 0) = ISNULL(@intSubLocationId, ISNULL(su.intSubLocationId, 0))
		AND ISNULL(su.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, ISNULL(su.intStorageLocationId, 0)) 
		AND ISNULL(su.dblOnHand, 0) <> 0

SELECT @intCount = COUNT(1) 
FROM (
	SELECT	DISTINCT i.strItemNo
	FROM	tblICItemStockUOM su INNER JOIN tblICItem i
				ON su.intItemId = i.intItemId
			LEFT JOIN tblICStorageLocation storageLoc
				ON storageLoc.intStorageLocationId = su.intStorageLocationId
			LEFT JOIN tblSMCompanyLocationSubLocation subLoc
				ON su.intSubLocationId = subLoc.intCompanyLocationSubLocationId			
	WHERE	ISNULL(su.intSubLocationId, 0) = ISNULL(@intSubLocationId, ISNULL(su.intSubLocationId, 0))
			AND ISNULL(su.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, ISNULL(su.intStorageLocationId, 0)) 
			AND ISNULL(su.dblOnHand, 0) <> 0
	GROUP BY i.strItemNo
) findOtherItems 

IF @strItemNo IS NOT NULL 
BEGIN 
	DECLARE @location AS NVARCHAR(200)
			,@itemWithCount AS NVARCHAR(200)
	
	SET @location = 
		CASE 
			WHEN @strSubLocation IS NOT NULL AND @strStorageLocation IS NOT NULL THEN 
				 @strSubLocation + ' and ' + @strStorageLocation + ''
			WHEN @strSubLocation IS NOT NULL  THEN 
				@strSubLocation  + ' and (Blank Storage Location)' 
			ELSE
				'(Blank Sub Location) and ' + @strStorageLocation 
		END 

	IF @intCount > 1
	BEGIN 
		SET @intCount -= 1;
		EXEC uspICRaiseError 80188, @strItemNo, @intCount, @location;
	END 
	ELSE 
	BEGIN 
		EXEC uspICRaiseError 80187, @strItemNo, @location;
	END 
		
	RETURN -1; 
END 