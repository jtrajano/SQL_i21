﻿CREATE PROCEDURE uspMFGetStorageLocation (
	@intLocationId INT
	,@strName NVARCHAR(50) = '%'
	,@intStorageLocationId INT = 0
	)
AS
BEGIN
	SELECT SL.intStorageLocationId
		,SL.strName
		,SL.intSubLocationId
		,CSL.strSubLocationName
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
	ORDER BY SL.strName
END
