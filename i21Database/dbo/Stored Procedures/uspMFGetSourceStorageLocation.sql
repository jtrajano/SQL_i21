CREATE PROCEDURE uspMFGetSourceStorageLocation (
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
		AND intAttributeId = 80

	IF @strStorageLocationId IS NULL
		OR @strStorageLocationId = ''
	BEGIN
		SELECT SL.intStorageLocationId
			,SL.strName
			,SL.intSubLocationId
		FROM dbo.tblICStorageLocation SL
		WHERE intLocationId = @intLocationId
			AND SL.ysnAllowConsume = 1
			AND SL.strName LIKE @strName + '%'
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
		FROM dbo.tblICStorageLocation SL
		WHERE intLocationId = @intLocationId
			AND SL.ysnAllowConsume = 1
			AND SL.strName LIKE @strName + '%'
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
