CREATE PROCEDURE [dbo].[uspMFCreatePickTask] @intOrderHeaderId INT
	,@intLotId INT
	,@intEntityUserSecurityId INT
	,@intAssigneeId INT = 0
	,@dtmReleaseDate NVARCHAR(32) = NULL
	,@intItemId INT = NULL
	,@intOrderDetailId INT = NULL
	,@intFromStorageLocationId INT = NULL
	,@dblLotQty NUMERIC(18, 6) = NULL
	,@intItemUOMId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @intTaskId INT
		,@intAddressId INT
		,@strTaskNo NVARCHAR(64)
		,@intToStorageLocationId INT
		,@dblQty NUMERIC(18, 6)
		,@strErrMsg NVARCHAR(MAX)
		,@intDirectionId INT
		,@intStatusId INT
		,@intCount INT
		,@dblLotWeight NUMERIC(18, 6)
		,@intWeightUOMId INT
		,@dblSplitAndPickQty NUMERIC(18, 6)
		,@dblSplitAndPickWeight NUMERIC(18, 6)
		,@dblWeightPerQty NUMERIC(18, 6)
		,@dtmDate datetime
		,@intDefaultConsumptionLocationId int

		Select @dtmDate=GETDATE()

	SET @strErrMsg = ''

	SELECT @strTaskNo = strOrderNo
		,@intToStorageLocationId = intStagingLocationId
	FROM tblMFOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @intToStorageLocationId = IsNULL(intStagingLocationId, @intToStorageLocationId)
		,@intDefaultConsumptionLocationId=intStorageLocationId
	FROM tblMFOrderDetail
	WHERE intOrderHeaderId = @intOrderHeaderId
		AND intItemId = @intItemId

	IF @intLotId IS NOT NULL
	BEGIN
		SELECT @intFromStorageLocationId = L.intStorageLocationId
			,@dblLotQty = L.dblQty- (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0)))
			,@intItemId = L.intItemId
			,@dblLotWeight = L.dblWeight -(SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intWeightUOMId, SR.dblQty), 0)))
			,@intItemUOMId = L.intItemUOMId
			,@intWeightUOMId = L.intWeightUOMId
			,@dblWeightPerQty = L.dblWeightPerQty
		FROM tblICLot L
		LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId and SR.ysnPosted =0
		WHERE  L.intLotId = @intLotId
		Group by L.intStorageLocationId,L.dblQty,L.intItemId,L.dblWeight,L.intItemUOMId, L.intWeightUOMId,L.dblWeightPerQty
	END

	INSERT INTO tblMFTask (
		intConcurrencyId
		,strTaskNo
		,intTaskTypeId
		,intTaskStateId
		,intAssigneeId
		,intOrderHeaderId
		,intOrderDetailId
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
		0
		,@strTaskNo
		,2
		,Case When @intDefaultConsumptionLocationId is null Then (CASE 
			WHEN @intAssigneeId > 0
				THEN 2
			ELSE 1
			END) Else 4 End
		,@intAssigneeId
		,@intOrderHeaderId
		,@intOrderDetailId
		,2
		,ISNULL(@dtmReleaseDate, @dtmDate)
		,@intFromStorageLocationId
		,IsNULL(@intDefaultConsumptionLocationId,@intToStorageLocationId)
		,@intItemId
		,@intLotId
		,@dblLotQty
		,@intItemUOMId
		,CASE 
			WHEN @intWeightUOMId IS NULL
				THEN @dblLotQty
			ELSE @dblLotWeight
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
		,@dtmDate
		,@intEntityUserSecurityId
		,@dtmDate
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
