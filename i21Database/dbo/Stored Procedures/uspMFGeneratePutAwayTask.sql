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
			,@strMask1 nvarchar(MAX)
			,@intStorageLocationId int

	SELECT @strTaskNo = strOrderNo, 
	    @intToStorageLocationId = intStagingLocationId
	FROM tblMFOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @dblSplitAndPickQty = dblQty
		  ,@intItemUOMId = intItemUOMId
		  ,@intWeightUOMId = IsNULL(intWeightUOMId,intItemUOMId)
		  ,@dblWeightPerQty = Case When intWeightUOMId is null Then 1 Else dblWeightPerQty End
		  ,@intFromStorageLocationId = intStorageLocationId
		  ,@dblLotQty = dblQty
		  ,@intItemId = intItemId
		  ,@dblLotWeight = Case When intWeightUOMId is null Then dblQty Else dblWeight End
		  ,@intItemUOMId = intItemUOMId
		  ,@intWeightUOMId = IsNULL(intWeightUOMId,intItemUOMId)
	FROM tblICLot
	WHERE intLotId = @intLotId

	Select @strMask1 =strMask1 
	from dbo.tblICItem
	Where intItemId=@intItemId

	Select @intStorageLocationId =intStorageLocationId 
	From tblICStorageLocation
	Where strName Like @strMask1

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
		,dblPickQty)
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
		,IsNUll(@intStorageLocationId,@intToStorageLocationId)
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
		,GETDATE()
		,@dblLotWeight)


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
