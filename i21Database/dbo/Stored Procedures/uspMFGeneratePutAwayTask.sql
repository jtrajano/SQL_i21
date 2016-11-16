CREATE PROCEDURE uspMFGeneratePutAwayTask
	@intOrderHeaderId INT, 
	@intLotId INT, 
	@intEntityUserSecurityId INT, 
	@intAssigneeId INT = 0
AS
BEGIN TRY
	SET NOCOUNT ON
	DECLARE @intTaskId INT
	DECLARE @strTaskNo NVARCHAR(64)
	DECLARE @intToStorageLocationId INT
	DECLARE @intFromStorageLocationId INT
	DECLARE @dblLotQty AS NUMERIC(18, 6)
	DECLARE @intItemUOMId INT
	DECLARE @dblLotWeight AS NUMERIC(18, 6)
	DECLARE @intWeightUOMId INT
	DECLARE @intDirectionId INT
	DECLARE @intItemId INT
	DECLARE @intStatusId INT
	DECLARE @dtmReleaseDate DATETIME
	DECLARE @dblSplitAndPickQty NUMERIC(18,6)
	DECLARE @dblWeightPerQty NUMERIC(18,6)
	DECLARE @strErrMsg NVARCHAR(MAX)

	SELECT @strTaskNo = strOrderNo, 
	    @intToStorageLocationId = intStagingLocationId
	FROM tblMFOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @dblSplitAndPickQty = dblQty
		  ,@intItemUOMId = intItemUOMId
		  ,@intWeightUOMId = intWeightUOMId
		  ,@dblWeightPerQty = dblWeightPerQty
		  ,@intFromStorageLocationId = intStorageLocationId
		  ,@dblLotQty = dblQty
		  ,@intItemId = intItemId
		  ,@dblLotWeight = dblWeight
		  ,@intItemUOMId = intItemUOMId
		  ,@intWeightUOMId = intWeightUOMId
	FROM tblICLot
	WHERE intLotId = @intLotId

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
		,dtmLastModified)
	VALUES 
		(0
		,@strTaskNo
		,5
		,CASE WHEN @intAssigneeId > 0 
			THEN 2
		 ELSE 1 END
		,@intOrderHeaderId
		,NULL
		,NULL
		,NULL
		,@intAssigneeId
		,2
		,ISNULL(@dtmReleaseDate, GETDATE())
		,@intFromStorageLocationId
		,@intToStorageLocationId
		,@intItemId
		,@intLotId
		,@dblSplitAndPickQty
		,@intItemUOMId
		,@dblLotQty
		,@intWeightUOMId
		,@dblWeightPerQty
		,@intEntityUserSecurityId
		,GETDATE()
		,@intEntityUserSecurityId
		,GETDATE())


END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspMFGeneratePutAwayTask' + @strErrMsg
		RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
	END
END CATCH
