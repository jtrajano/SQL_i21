CREATE PROCEDURE uspMFLotSplitOnHandHeld @intOrderHeaderId INT
	,@intUserId INT
	,@intTaskId INT = NULL
	,@strNewLotNumber NVARCHAR(50) = ''
AS
BEGIN TRY

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intLotId INT
		,@dblSplitQty DECIMAL(24, 10)
		,@intSplitItemUOMId INT
		,@intSplitSubLocationId INT
		,@intSplitStorageLocationId INT
		,@strTaskNo NVARCHAR(50)
		,@strSplitLotNumber NVARCHAR(50)
		,@intInventoryAdjustmentId INT
		,@intSplitLotId INT
		,@intCustomerLabelTypeId int
		,@strReferenceNo nvarchar(50)
		,@intEntityCustomerId int
		,@dblQty DECIMAL(24, 10)

	SELECT @intLotId = intLotId
		,@dblSplitQty = dblPickQty
		,@intSplitItemUOMId = intItemUOMId
		,@strTaskNo = strTaskNo
	FROM tblMFTask
	WHERE intTaskId = @intTaskId

	Select @dblQty=dblQty from tblICLot Where intLotId=@intLotId

	If @dblQty=@dblSplitQty OR @strNewLotNumber=''
	Begin
		Return
	End

	SELECT @intSplitSubLocationId = intSubLocationId
		,@intSplitStorageLocationId = intStorageLocationId
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @strReferenceNo = strReferenceNo
	FROM tblMFOrderHeader OH
	JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @intEntityCustomerId = intEntityCustomerId
	FROM tblICInventoryShipment
	WHERE strShipmentNumber = @strReferenceNo

	SELECT @intCustomerLabelTypeId = intCustomerLabelTypeId
	FROM tblMFItemOwner
	WHERE intOwnerId = @intEntityCustomerId
		AND intCustomerLabelTypeId IS NOT NULL

	IF @intCustomerLabelTypeId IS NULL
	BEGIN
		SELECT @intCustomerLabelTypeId = 0
	END

	EXEC [uspMFLotSplit] @intLotId = @intLotId
		,@intSplitSubLocationId = @intSplitSubLocationId
		,@intSplitStorageLocationId = @intSplitStorageLocationId
		,@dblSplitQty = @dblSplitQty
		,@intSplitItemUOMId = @intSplitItemUOMId
		,@intUserId = @intUserId
		,@strSplitLotNumber = @strSplitLotNumber OUTPUT
		,@strNewLotNumber = @strNewLotNumber
		,@strNote = @strTaskNo
		,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

	SELECT @intSplitLotId = intLotId
	FROM tblICLot
	WHERE strLotNumber = @strSplitLotNumber
		AND intStorageLocationId = @intSplitStorageLocationId

	UPDATE tblMFTask
	SET intLotId = @intSplitLotId
	WHERE intLotId = @intLotId
		AND intTaskId = @intTaskId

	IF @intCustomerLabelTypeId = 2
	BEGIN
		UPDATE tblMFOrderManifest
		SET intLotId = @intSplitLotId
		WHERE intOrderHeaderId = @intOrderHeaderId
			AND intLotId = @intLotId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
