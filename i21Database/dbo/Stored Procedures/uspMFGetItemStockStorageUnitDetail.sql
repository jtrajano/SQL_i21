CREATE PROCEDURE uspMFGetItemStockStorageUnitDetail @intItemId INT
	,@intItemUOMId INT
	,@intLocationId INT
	,@strStorageLocationName NVARCHAR(50) = ''
	,@strSubLocationName NVARCHAR(50) = ''
AS
BEGIN
	SELECT SUOM.intItemStockUOMId
		,SUOM.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,SUOM.intSubLocationId
		,CSL.strSubLocationName
	FROM tblICItemStockUOM SUOM
	JOIN tblICItemLocation IL ON IL.intItemLocationId = SUOM.intItemLocationId
		AND SUOM.dblOnHand > 0
		AND SUOM.intItemId = @intItemId
		AND SUOM.intItemUOMId = @intItemUOMId
		AND IL.intLocationId = @intLocationId
	LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = SUOM.intStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SUOM.intSubLocationId
	WHERE ISNULL(SL.strName, '') = (
			CASE 
				WHEN @strStorageLocationName = ''
					THEN ISNULL(SL.strName, '')
				ELSE @strStorageLocationName
				END
			)
		AND ISNULL(CSL.strSubLocationName, '') = (
			CASE 
				WHEN @strSubLocationName = ''
					THEN ISNULL(CSL.strSubLocationName, '')
				ELSE @strSubLocationName
				END
			)
END
