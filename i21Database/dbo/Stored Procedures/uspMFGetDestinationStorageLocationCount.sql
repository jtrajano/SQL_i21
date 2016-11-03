CREATE PROCEDURE uspMFGetDestinationStorageLocationCount (
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
		SELECT Count(*) AS StorageLocationCount
		FROM dbo.tblICStorageLocation SL
		WHERE intLocationId = @intLocationId
			AND strName LIKE @strName + '%'
			AND SL.intStorageLocationId = (
				CASE 
					WHEN @intStorageLocationId > 0
						THEN @intStorageLocationId
					ELSE SL.intStorageLocationId
					END
				)
	END
	ELSE
	BEGIN
		SELECT Count(*) AS StorageLocationCount
		FROM dbo.tblICStorageLocation SL
		WHERE intLocationId = @intLocationId
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
	END
END
