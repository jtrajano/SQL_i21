CREATE PROCEDURE [dbo].[uspMFCreateSplitAndPickTask] @intOrderHeaderId INT
	,@intLotId INT
	,@intEntityUserSecurityId INT
	,@dblSplitAndPickWeight DECIMAL(24, 10)
	,@intTaskTypeId INT
	,@intAssigneeId INT = 0
	,@intItemId INT = NULL
	,@intOrderDetailId INT = NULL
	,@intFromStorageLocationId INT = NULL
	,@intItemUOMId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @intTaskId INT
		,@strTaskNo NVARCHAR(64)
		,@intToStorageLocationId INT
		,@dblLotQty AS NUMERIC(18, 6)
		,@dblLotWeight AS NUMERIC(18, 6)
		,@intWeightUOMId INT
		,@intDirectionId INT
		,@intStatusId INT
		,@dtmReleaseDate DATETIME
		,@dblSplitAndPickQty NUMERIC(18, 6)
		,@dblWeightPerQty NUMERIC(18, 6)
		,@strErrMsg NVARCHAR(MAX)
		,@intDefaultConsumptionLocationId INT

	SELECT @strTaskNo = strOrderNo
		,@intToStorageLocationId = intStagingLocationId
	FROM tblMFOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @intToStorageLocationId = IsNULL(intStagingLocationId, @intToStorageLocationId)
		,@intDefaultConsumptionLocationId = intStorageLocationId
	FROM tblMFOrderDetail
	WHERE intOrderHeaderId = @intOrderHeaderId
		AND intItemId = @intItemId

	IF @intLotId IS NOT NULL
	BEGIN
		SELECT @dblSplitAndPickQty = dbo.fnMFConvertQuantityToTargetItemUOM(IsNULL(intWeightUOMId,intItemUOMId), intItemUOMId, @dblSplitAndPickWeight)
		--@dblSplitAndPickWeight / (
		--		CASE 
		--			WHEN dblWeightPerQty = 0
		--				THEN 1a
		--			ELSE dblWeightPerQty
		--			END
		--		)
			,@intItemUOMId = intItemUOMId
			,@intWeightUOMId = intWeightUOMId
			,@dblWeightPerQty = dblWeightPerQty
			,@intFromStorageLocationId = intStorageLocationId
			,@dblLotQty = dblQty
			,@intItemId = intItemId
			,@dblLotWeight = dblWeight
		FROM tblICLot
		WHERE intLotId = @intLotId
	END
	Else
	Begin
		Select @dblSplitAndPickQty=@dblSplitAndPickWeight
		Select @intWeightUOMId=@intItemUOMId
	End

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
		)
	VALUES (
		1
		,@strTaskNo
		,@intTaskTypeId
		,CASE 
			WHEN @intDefaultConsumptionLocationId IS NULL
				THEN (
						CASE 
							WHEN @intAssigneeId > 0
								THEN 2
							ELSE 1
							END
						)
			ELSE 4
			END
		,@intOrderHeaderId
		,@intOrderDetailId
		,NULL
		,NULL
		,@intAssigneeId
		,2
		,ISNULL(@dtmReleaseDate, GETDATE())
		,@intFromStorageLocationId
		,IsNULL(@intDefaultConsumptionLocationId, @intToStorageLocationId)
		,@intItemId
		,@intLotId
		,@dblSplitAndPickQty
		,@intItemUOMId
		,CASE 
			WHEN @intWeightUOMId IS NULL
				THEN @dblSplitAndPickQty
			ELSE @dblSplitAndPickWeight
			END
		,CASE 
			WHEN @intWeightUOMId IS NULL
				THEN @intItemUOMId
			ELSE @intWeightUOMId
			END
		,CASE 
			WHEN @intWeightUOMId IS NULL
				THEN 1
			ELSE @dblWeightPerQty
			END
		,@intEntityUserSecurityId
		,GETDATE()
		,@intEntityUserSecurityId
		,GETDATE()
		)

	SET @intTaskId = SCOPE_IDENTITY()

	IF @intLotId IS NOT NULL
	BEGIN
		UPDATE t
		SET dblPickQty = CASE 
				WHEN strTaskType = 'Put Back'
					THEN l.dblQty - t.dblQty
				ELSE t.dblQty
				END
		FROM tblMFTask t
		JOIN tblICLot l ON l.intLotId = t.intLotId
		JOIN tblMFTaskType tt ON tt.intTaskTypeId = t.intTaskTypeId
		WHERE intTaskId = @intTaskId
	END
	ELSE
	BEGIN
		UPDATE t
		SET dblPickQty = t.dblQty
		FROM tblMFTask t
		WHERE intTaskId = @intTaskId
	END

	SELECT @intDirectionId = intOrderDirectionId
	FROM tblMFOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	IF @intDirectionId = 2
	BEGIN
		IF (
				SELECT COUNT(*)
				FROM tblMFTask
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intTaskTypeId IN (
						2
						,7
						,13
						)
				) = (
				SELECT COUNT(*)
				FROM tblMFTask
				WHERE intOrderHeaderId = @intOrderHeaderId
				)
		BEGIN
			SELECT @intStatusId = intOrderStatusId
			FROM tblMFOrderStatus
			WHERE strOrderStatus = 'RELEASED'

			UPDATE tblMFOrderHeader
			SET intOrderStatusId = @intStatusId
			WHERE intOrderHeaderId = @intOrderHeaderId
		END
		ELSE IF (
				SELECT COUNT(*)
				FROM tblMFTask
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intTaskTypeId = 3
				) = (
				SELECT COUNT(*)
				FROM tblMFTask
				WHERE intOrderHeaderId = @intOrderHeaderId
				)
		BEGIN
			SELECT @intStatusId = intOrderStatusId
			FROM tblMFOrderStatus
			WHERE strOrderStatus = 'STAGED'

			UPDATE tblMFOrderHeader
			SET intOrderStatusId = @intStatusId
			WHERE intOrderHeaderId = @intOrderHeaderId
		END
		ELSE IF EXISTS (
				SELECT *
				FROM tblMFTask
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intTaskTypeId IN (
						2
						,7
						,13
						)
				)
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

		RAISERROR (
				@strErrMsg
				,16
				,1
				,'WITH NOWAIT'
				)
	END
END CATCH
