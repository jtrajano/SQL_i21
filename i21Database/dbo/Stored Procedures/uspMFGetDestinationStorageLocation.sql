CREATE PROCEDURE uspMFGetDestinationStorageLocation (
	@intProcessId INT
	,@intLocationId INT
	,@strName NVARCHAR(50) = '%'
	,@intStorageLocationId INT = 0
	)
AS
BEGIN
	DECLARE @strStorageLocationId NVARCHAR(MAX)

	SELECT @strStorageLocationId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 81

	IF @strStorageLocationId IS NULL
		OR @strStorageLocationId = ''
	BEGIN
		SELECT SL.intStorageLocationId
			,SL.strName
			,SL.intSubLocationId
			,CSL.strSubLocationName
		FROM dbo.tblICStorageLocation SL
		JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
		WHERE intLocationId = @intLocationId
			AND NOT EXISTS (
				SELECT *
				FROM tblICStorageLocation SL1
				WHERE SL1.intParentStorageLocationId = SL.intStorageLocationId
				)
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
	ELSE
	BEGIN
		SELECT SL.intStorageLocationId
			,SL.strName
			,SL.intSubLocationId
			,CSL.strSubLocationName
		FROM dbo.tblICStorageLocation SL
		JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
		WHERE intLocationId = @intLocationId
			AND NOT EXISTS (
				SELECT *
				FROM tblICStorageLocation SL1
				WHERE SL1.intParentStorageLocationId = SL.intStorageLocationId
				)
			AND strName LIKE @strName + '%'
			AND SL.intStorageLocationId = (
				CASE 
					WHEN @intStorageLocationId > 0
						THEN @intStorageLocationId
					ELSE SL.intStorageLocationId
					END
				)
			AND SL.intStorageLocationId IN (
				SELECT Item Collate Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](@strStorageLocationId, ',')
				)
		ORDER BY SL.strName
	END
END
