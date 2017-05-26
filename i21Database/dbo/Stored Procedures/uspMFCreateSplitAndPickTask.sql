CREATE PROCEDURE [dbo].[uspMFCreateSplitAndPickTask]
					@intOrderHeaderId INT, 
					@intLotId INT, 
					@intEntityUserSecurityId INT, 
					@dblSplitAndPickWeight DECIMAL(24, 10), 
					@intTaskTypeId INT, 
					@intAssigneeId INT = 0,
				    @intItemId int=NULL
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
	--DECLARE @intItemId INT
	DECLARE @intStatusId INT
	DECLARE @dtmReleaseDate DATETIME
	DECLARE @dblSplitAndPickQty NUMERIC(18,6)
	DECLARE @dblWeightPerQty NUMERIC(18,6)
	DECLARE @strErrMsg NVARCHAR(MAX)

	SELECT @strTaskNo = strOrderNo, 
	       @intToStorageLocationId = intStagingLocationId
	FROM tblMFOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT 
		  @intToStorageLocationId = IsNULL(intStagingLocationId,@intToStorageLocationId)
	FROM tblMFOrderDetail
	WHERE intOrderHeaderId = @intOrderHeaderId
	and intItemId=@intItemId

	SELECT @dblSplitAndPickQty = @dblSplitAndPickWeight/(Case When dblWeightPerQty=0 Then 1 Else dblWeightPerQty End)
		  ,@intItemUOMId = intItemUOMId
		  ,@intWeightUOMId = intWeightUOMId
		  ,@dblWeightPerQty = dblWeightPerQty
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @intFromStorageLocationId = intStorageLocationId
		  ,@dblLotQty = dblQty
		  ,@intItemId = intItemId
		  ,@dblLotWeight = dblWeight
		  ,@intItemUOMId = intItemUOMId
		  ,@intWeightUOMId = intWeightUOMId
	FROM tblICLot WHERE intLotId = @intLotId

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
		,@intTaskTypeId
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
		,Case When @intWeightUOMId is NULL Then @dblSplitAndPickQty Else @dblSplitAndPickQty End
		,Case When @intWeightUOMId is NULL Then @intItemUOMId Else @intItemUOMId End
		,Case When @intWeightUOMId is NULL Then @dblSplitAndPickQty Else @dblSplitAndPickWeight End
		,Case When @intWeightUOMId is NULL Then @intItemUOMId Else @intWeightUOMId End
		,Case When @intWeightUOMId is NULL Then 1 Else @dblWeightPerQty End
		,@intEntityUserSecurityId
		,GETDATE()
		,@intEntityUserSecurityId
		,GETDATE())
	
	SET @intTaskId = SCOPE_IDENTITY()

	UPDATE t 
			SET dblPickQty = 
			CASE WHEN strTaskType = 'Put Back'
			THEN l.dblQty - t.dblQty
			ELSE t.dblQty END
	FROM tblMFTask t
	JOIN tblICLot l ON l.intLotId = t.intLotId
	JOIN tblMFTaskType tt ON tt.intTaskTypeId = t.intTaskTypeId
	WHERE intTaskId = @intTaskId

	SELECT @intDirectionId = intOrderDirectionId
	FROM tblMFOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	IF @intDirectionId = 2
	BEGIN
		IF (SELECT COUNT(*) FROM tblMFTask WHERE intOrderHeaderId = @intOrderHeaderId AND intTaskTypeId IN (2,7,13)) = (SELECT COUNT(*) FROM tblMFTask WHERE intOrderHeaderId = @intOrderHeaderId)
		BEGIN
			SELECT @intStatusId = intOrderStatusId
			FROM tblMFOrderStatus
			WHERE strOrderStatus = 'RELEASED'

			UPDATE tblMFOrderHeader
			SET intOrderStatusId = @intStatusId
			WHERE intOrderHeaderId = @intOrderHeaderId
		END
		ELSE IF (SELECT COUNT(*) FROM tblMFTask WHERE intOrderHeaderId = @intOrderHeaderId AND intTaskTypeId = 3) = (SELECT COUNT(*) FROM tblMFTask WHERE intOrderHeaderId = @intOrderHeaderId)
		BEGIN
			SELECT @intStatusId = intOrderStatusId
			FROM tblMFOrderStatus
			WHERE strOrderStatus = 'STAGED'

			UPDATE tblMFOrderHeader
			SET intOrderStatusId = @intStatusId
			WHERE intOrderHeaderId = @intOrderHeaderId
		END
		ELSE IF EXISTS (SELECT * FROM tblMFTask WHERE intOrderHeaderId = @intOrderHeaderId AND intTaskTypeId IN (2,7,13))
		BEGIN
			SELECT @intStatusId = intOrderStatusId
			FROM tblMFOrderStatus
			WHERE strOrderStatus = 'PICKING'

			UPDATE tblMFOrderHeader
			SET intOrderStatusId = @intStatusId
			WHERE intOrderHeaderId = @intOrderHeaderId
		END
	END

	SELECT @intTaskId
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspMFCreatePickTask: ' + @strErrMsg
		RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH