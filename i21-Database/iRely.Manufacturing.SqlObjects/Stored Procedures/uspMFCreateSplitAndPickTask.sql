CREATE PROCEDURE [dbo].[uspMFCreateSplitAndPickTask]
					@intOrderHeaderId INT, 
					@intLotId INT, 
					@intEntityUserSecurityId INT, 
					@dblSplitAndPickWeight DECIMAL(24, 10), 
					@intTaskTypeId INT, 
					@intAssigneeId INT = 0,
				    @intItemId int=NULL
					,@intOrderDetailId int=NULL
							,@intFromStorageLocationId INT = NULL
	,@intItemUOMId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @intTaskId INT
	, @strTaskNo NVARCHAR(64)
	, @intToStorageLocationId INT
	, @dblLotQty AS NUMERIC(18, 6)
	, @dblLotWeight AS NUMERIC(18, 6)
	, @intWeightUOMId INT
	, @intDirectionId INT
	, @intStatusId INT
	, @dtmReleaseDate DATETIME
	, @dblSplitAndPickQty NUMERIC(18,6)
	, @dblWeightPerQty NUMERIC(18,6)
	, @strErrMsg NVARCHAR(MAX)
			,@intDefaultConsumptionLocationId int

	SELECT @strTaskNo = strOrderNo, 
	       @intToStorageLocationId = intStagingLocationId
	FROM tblMFOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT 
		  @intToStorageLocationId = IsNULL(intStagingLocationId,@intToStorageLocationId)
		  ,@intDefaultConsumptionLocationId=intStorageLocationId
	FROM tblMFOrderDetail
	WHERE intOrderHeaderId = @intOrderHeaderId
	and intItemId=@intItemId
	if @intLotId is not null
	Begin
	SELECT @dblSplitAndPickQty = @dblSplitAndPickWeight/(Case When dblWeightPerQty=0 Then 1 Else dblWeightPerQty End)
		  ,@intItemUOMId = intItemUOMId
		  ,@intWeightUOMId = intWeightUOMId
		  ,@dblWeightPerQty = dblWeightPerQty
		  ,@intFromStorageLocationId = intStorageLocationId
		  ,@dblLotQty = dblQty
		  ,@intItemId = intItemId
		  ,@dblLotWeight = dblWeight
	FROM tblICLot
	WHERE intLotId = @intLotId
	end

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
		,Case When @intDefaultConsumptionLocationId is null Then (CASE 
			WHEN @intAssigneeId > 0
				THEN 2
			ELSE 1
			END) Else 4 End
		,@intOrderHeaderId
		,@intOrderDetailId
		,NULL
		,NULL
		,@intAssigneeId
		,2
		,ISNULL(@dtmReleaseDate, GETDATE())
		,@intFromStorageLocationId
		,IsNULL(@intDefaultConsumptionLocationId,@intToStorageLocationId)
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
	if @intLotId is not null
	Begin
		UPDATE t 
				SET dblPickQty = 
				CASE WHEN strTaskType = 'Put Back'
				THEN l.dblQty - t.dblQty
				ELSE t.dblQty END
		FROM tblMFTask t
		JOIN tblICLot l ON l.intLotId = t.intLotId
		JOIN tblMFTaskType tt ON tt.intTaskTypeId = t.intTaskTypeId
		WHERE intTaskId = @intTaskId
	end
	else
	Begin
			UPDATE t 
				SET dblPickQty = 
				t.dblQty 
		FROM tblMFTask t
		WHERE intTaskId = @intTaskId
	End
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