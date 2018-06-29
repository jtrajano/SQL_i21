CREATE PROCEDURE uspMFGeneratePutAwayTask @intOrderHeaderId INT
	,@intLotId INT
	,@intEntityUserSecurityId INT
	,@intAssigneeId INT = 0
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @intTaskId INT
		,@strTaskNo NVARCHAR(64)
		,@intToStorageLocationId INT
		,@intFromStorageLocationId INT
		,@dblLotQty AS NUMERIC(18, 6)
		,@intItemUOMId INT
		,@dblLotWeight AS NUMERIC(18, 6)
		,@intWeightUOMId INT
		,@intItemId INT
		,@intStatusId INT
		,@dtmReleaseDate DATETIME
		,@dblWeightPerQty NUMERIC(18, 6)
		,@strErrMsg NVARCHAR(MAX)
		,@strMask1 NVARCHAR(MAX)
		,@intStorageLocationId INT

	SELECT @strTaskNo = strOrderNo
		,@intToStorageLocationId = intStagingLocationId
	FROM tblMFOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @intItemId = intItemId
		,@intFromStorageLocationId = intStorageLocationId
		,@dblLotQty = dblQty
		,@intItemUOMId = intItemUOMId
		,@dblLotWeight = CASE 
			WHEN intWeightUOMId IS NULL
				THEN dblQty
			ELSE dblWeight
			END
		,@intWeightUOMId = IsNULL(intWeightUOMId, intItemUOMId)
		,@dblWeightPerQty = CASE 
			WHEN intWeightUOMId IS NULL
				THEN 1
			ELSE dblWeightPerQty
			END
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @strMask1 = strMask1
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	SELECT @intStorageLocationId = intStorageLocationId
	FROM tblICStorageLocation
	WHERE strName LIKE @strMask1

	INSERT INTO tblMFTask (
		intConcurrencyId
		,strTaskNo
		,intTaskTypeId
		,intTaskStateId
		,intOrderHeaderId
		,intOrderDetailId
		,intLoadId
		,intLoadDetailId
		,intAssigneeId
		,intTaskPriorityId
		,dtmReleaseDate
		,intFromStorageLocationId
		,intToStorageLocationId
		,intItemId
		,intLotId
		,dblQty
		,intItemUOMId
		,dblWeight
		,intWeightUOMId
		,dblWeightPerQty
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,dblPickQty
		)
	VALUES (
		0
		,@strTaskNo
		,5
		,CASE 
			WHEN @intAssigneeId > 0
				THEN 2
			ELSE 1
			END
		,@intOrderHeaderId
		,NULL
		,NULL
		,NULL
		,@intAssigneeId
		,2
		,ISNULL(@dtmReleaseDate, GETDATE())
		,@intFromStorageLocationId
		,IsNUll(@intStorageLocationId, @intToStorageLocationId)
		,@intItemId
		,@intLotId
		,@dblLotQty
		,@intItemUOMId
		,@dblLotWeight
		,@intWeightUOMId
		,@dblWeightPerQty
		,@intEntityUserSecurityId
		,GETDATE()
		,@intEntityUserSecurityId
		,GETDATE()
		,@dblLotQty
		)
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspMFGeneratePutAwayTask' + @strErrMsg

		RAISERROR (
				@strErrMsg
				,16
				,1
				,'WITH NOWAIT'
				)
	END
END CATCH
