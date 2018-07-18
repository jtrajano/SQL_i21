CREATE PROCEDURE uspMFGetStorageLocation (
	@intLocationId INT
	,@strName NVARCHAR(50) = '%'
	,@intStorageLocationId INT = 0
	,@intCategoryId INT = 0
	)
AS
BEGIN
	SELECT SL.intStorageLocationId
		,SL.strName
		,SL.intSubLocationId
		,CSL.strSubLocationName
		,SL.strDescription
	FROM dbo.tblICStorageLocation SL
	JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
	WHERE intLocationId = @intLocationId
		AND strName LIKE @strName + '%'
		AND SL.intStorageLocationId = (
			CASE 
				WHEN @intStorageLocationId > 0
					THEN @intStorageLocationId
				ELSE SL.intStorageLocationId
				END
			)
		AND NOT EXISTS (
			SELECT *
			FROM tblICStorageLocationCategory SLC
			WHERE SLC.intStorageLocationId = SL.intStorageLocationId
			)
	
	UNION
	
	SELECT SL.intStorageLocationId
		,SL.strName
		,SL.intSubLocationId
		,CSL.strSubLocationName
		,SL.strDescription
	FROM dbo.tblICStorageLocation SL
	JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
	JOIN tblICStorageLocationCategory SLC ON SLC.intStorageLocationId = SL.intStorageLocationId
		AND SLC.intCategoryId = CASE 
			WHEN @intCategoryId = 0
				THEN SLC.intCategoryId
			ELSE @intCategoryId
			END
	WHERE intLocationId = @intLocationId
		AND strName LIKE @strName + '%'
		AND SL.intStorageLocationId = (
			CASE 
				WHEN @intStorageLocationId > 0
					THEN @intStorageLocationId
				ELSE SL.intStorageLocationId
				END
			)
	ORDER BY SL.strName
END
